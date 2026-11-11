# ppy Dark, adapted for Kakoune from peppy/ppy-jetbrains-theme.
# Upstream 0fd810e515ea810654573e78900727864aa4eec1, MIT, Dean Herbert.
# Exact source colours and licence: ../../vendor/ppy-jetbrains-theme/.

# Syntax: DEFAULT_* attributes from ppy Dark.xml.
face global value rgb:ce95b8
face global type rgb:61afef
face global variable rgb:dcdcdc
face global module rgb:61afef
face global function rgb:98c379
face global string rgb:e5bc66
face global keyword rgb:fb7385
face global operator rgb:abb2bf
face global attribute rgb:76a1ce
face global comment rgb:5c6370+i
face global documentation comment
face global meta rgb:d080fb
face global builtin rgb:61afef

# Markup: ppy's Markdown headings and default syntax palette.
face global title rgb:4c9eca+b
face global header rgb:4c9eca+b
face global mono rgb:e5bc66
face global block rgb:e5bc66
face global link rgb:7094ff+u
face global bullet rgb:ce95b8
face global list rgb:fb7385

# Editor: TEXT, SELECTION_BACKGROUND, CARET_COLOR, GUTTER_BACKGROUND.
face global Default rgb:abb2bf,rgb:20202a
face global PrimarySelection default,rgb:40375e
face global SecondarySelection default,rgb:3d3952
face global PrimaryCursor rgb:20202a,rgb:dedede
face global SecondaryCursor rgb:20202a,rgb:8994a7
face global PrimaryCursorEol rgb:20202a,rgb:dedede
face global SecondaryCursorEol rgb:20202a,rgb:8994a7
face global LineNumbers rgb:495162,rgb:22222e
face global LineNumberCursor rgb:abb2bf,rgb:2f2f3f+b
face global LineNumbersWrapped rgb:495162,rgb:22222e
face global MatchingChar default,rgb:564a56+b
face global Whitespace rgb:333344
face global BufferPadding rgb:495162,rgb:20202a

# Menus/status/info: ppy Dark.theme.json's purple UI surfaces.
face global MenuForeground rgb:d0d0d9,rgb:623380
face global MenuBackground rgb:d0d0d9,rgb:2c2c3b
face global MenuInfo rgb:ed94ff,rgb:2c2c3b
face global Information rgb:d0d0d9,rgb:463f57
face global Error rgb:d0d0d9,rgb:802d43
face global DiagnosticError rgb:ff4e4e+u
face global DiagnosticWarning rgb:eda726+u
face global DiagnosticInfo rgb:61afef
face global DiagnosticHint rgb:8994a7
face global StatusLine rgb:d0d0d9,rgb:2c2c3b
face global StatusLineMode rgb:ed94ff,rgb:2c2c3b
face global StatusLineInfo rgb:8994a7,rgb:2c2c3b
face global StatusLineValue rgb:98c379,rgb:2c2c3b
face global StatusCursor rgb:20202a,rgb:8e70be
face global Prompt rgb:ed94ff,rgb:2c2c3b

# LSP faces are declared by the bridge before this scheme loads.
face global LineFlagError rgb:ff4e4e
face global LineFlagWarning rgb:eda726
face global LineFlagInfo rgb:61afef
face global LineFlagHint rgb:8994a7
face global InlayHint rgb:8994a7
face global InlayCodeLens rgb:8994a7
face global SnippetsNextPlaceholders rgb:20202a,rgb:98c379
face global SnippetsOtherPlaceholders rgb:20202a,rgb:e5bc66
