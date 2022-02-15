# xcpnc

A small command-line tool for get files not contained in an xcode project.

Support `.swift`, `.h`, `.m` and `.c` source files.

## Instalation

Requires Xcode 11.4+

```shell
curl -Ls https://raw.githubusercontent.com/MihailPreis/xcpnc/main/Scripts/install | bash
```

## Example

```shell
find Sources \
    \( -name "*.swift" -o -name "*.h" -o -name "*.m" -o -name "*.c" \) \
    -a ! -path "*/Dependencies/*" \
    -a ! -path "*/Resources/*" \
    -print0 | \
    xcpnc -0 "Some.xcodeproj" | \
    xargs -I {} rm -f {}
```
