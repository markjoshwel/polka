#!/usr/bin/env python3
"""Exercise the built distribution, including real Python/Nix diagnostics."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import uuid


def quote(value):
    return "'" + str(value).replace("'", "''") + "'"


polka = str(Path(sys.argv[1] if len(sys.argv) > 1 else "result/bin/polka").resolve())
with tempfile.TemporaryDirectory(prefix="polka-check-") as directory:
    root = Path(directory).resolve()
    python_file = root / "example.py"
    nix_file = root / "example.nix"
    python_file.write_text('def greet(name: str) -> str:\n    return name\ncount: int = "wrong"\ngreet("world")\n')
    nix_file.write_text("{ value = missingName; }\n")
    config = root / "config" / "polka"
    config.mkdir(parents=True)
    (config / "extra.kak").write_text("set-option global tabstop 7\n")
    env = dict(os.environ, HOME=str(root), XDG_CONFIG_HOME=str(root / "config"),
               POLKA_USER_CONFIG=str(config / "extra.kak"),
               POLKA_CHECK_SNAPSHOT=str(root / "snapshot"))
    session = "polka-check-" + uuid.uuid4().hex[:12]
    process = subprocess.Popen([polka, "-ui", "dummy", "-s", session, str(python_file)],
                               cwd=root, env=env, stdin=subprocess.DEVNULL,
                               stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

    def send(commands):
        subprocess.run([polka, "-p", session], input=(commands + "\n").encode(),
                       cwd=root, env=env, check=True, capture_output=True, timeout=5)

    def wait_for(predicate, label):
        deadline = time.monotonic() + 25
        while time.monotonic() < deadline:
            if process.poll() is not None:
                raise RuntimeError(process.stderr.read().decode())
            snapshot = root / "snapshot"
            snapshot.unlink(missing_ok=True)
            send('evaluate-commands -client client0 %{ nop %sh{ printf "%s\\n" '
                 '"$kak_opt_lsp_diagnostic_error_count" "$kak_buffile" '
                 '"$kak_cursor_line" "$kak_opt_tabstop" > "$POLKA_CHECK_SNAPSHOT" } }')
            time.sleep(0.15)
            if snapshot.exists():
                values = snapshot.read_text().splitlines()
                if predicate(values):
                    print("PASS:", label)
                    return values
        send("evaluate-commands -client client0 %{ buffer *debug*; "
             f"write! {quote(root / 'failure-debug')} }}")
        time.sleep(0.2)
        if (root / "failure-debug").exists():
            print((root / "failure-debug").read_text(), flush=True)
        raise AssertionError(f"{label}: timed out; last snapshot={values if snapshot.exists() else 'missing'}")

    try:
        # The server needs a moment to create its socket before accepting -p.
        deadline = time.monotonic() + 5
        while True:
            try:
                send("nop")
                break
            except subprocess.CalledProcessError:
                if time.monotonic() >= deadline:
                    raise
                time.sleep(0.1)
        wait_for(lambda v: len(v) == 4 and int(v[0]) >= 1 and v[3] == "7",
                 "Python diagnostics and personal override")
        send(f"evaluate-commands -client client0 %{{ edit {quote(python_file)} 4 1; lsp-definition }}")
        wait_for(lambda v: v[1] == str(python_file) and v[2] == "1", "Python go-to-definition")
        send("evaluate-commands -client client0 %{ polka-wrap; polka-wrap; "
             f"edit {quote(nix_file)} }}")
        wait_for(lambda v: v[1] == str(nix_file) and int(v[0]) >= 1, "Nix diagnostics")
        # Validate the picker in the live client, and then inspect the selected file.
        send("evaluate-commands -client client0 %{ evaluate-commands -draft %{ "
             "polka-files; execute-keys example.py<ret>; "
             'nop %sh{ printf "%s" "$kak_buffile" > "$HOME/picked" } } }')
        deadline = time.monotonic() + 5
        while not (root / "picked").exists() and time.monotonic() < deadline:
            time.sleep(0.1)
        assert (root / "picked").read_text() == str(python_file)
        print("PASS: file picker and wrap toggle")
        send("evaluate-commands -client client0 %{ buffer *debug*; "
             f"write! {quote(root / 'debug')} }}")
        deadline = time.monotonic() + 5
        while not (root / "debug").exists() and time.monotonic() < deadline:
            time.sleep(0.1)
        debug = (root / "debug").read_text()
        assert "Error while sourcing" not in debug and "could not load" not in debug, debug
        print("PASS: clean configuration startup")
    finally:
        try:
            send("kill!")
            process.wait(timeout=5)
        except (subprocess.SubprocessError, OSError):
            process.kill()
            process.wait()
