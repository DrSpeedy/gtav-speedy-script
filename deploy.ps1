# DrSpeedy#1852
# https://github.com/DrSpeedy

$TARGET_DIR="$env:APPDATA\Stand\Lua Scripts"
$SOURCE_DIR=".\*"
$EXCLUDE_FILES=@('.vscode', 'deploy.ps1', '.git', 'build.ps1')

Copy-Item -Path $SOURCE_DIR -Destination $TARGET_DIR -Exclude $EXCLUDE_FILES -Recurse -Force