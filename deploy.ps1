# DrSpeedy#1852
# https://github.com/DrSpeedy

$TARGET_DIR="C:\Users\bwils\AppData\Roaming\Stand\Lua Scripts"
$SOURCE_DIR=""

Get-ChildItem -Path $SOURCE_DIR -Recurse |
ForEach-Object {
    if ($_.BaseName -ne '.vscode' -And $_.BaseName -ne 'deploy' -And $_.BaseName -ne 'Speedy') {
        echo $_.FullName
        Copy-Item $_.FullName -Destination $TARGET_DIR -Recurse -Force
    }
}