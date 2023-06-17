param (
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType 'Leaf'})]
    [string]$inputFile,

    [Parameter(Mandatory=$true)]
    [string]$outputFile
)

function RemoveBlockComments($line) {
    while ($line -match "(.*)--\[\[(.*)\]\](.*)") {
        $line = $Matches[1] + $Matches[3]
    }
    return $line
}

function ProcessFile($filePath) {
    $fileContent = Get-Content -Path $filePath
    $newContent = @()

    foreach ($line in $fileContent) {
        $cleanedLine = $line
        # $cleanedLine = $line -replace "--.*", ""   # Remove -- comments
        # $cleanedLine = RemoveBlockComments $cleanedLine

        if ($cleanedLine -match "require\s*\(?\'(.+?)\'\)?") {
            $requiredFile = $Matches[1] + ".lua"

            if (-not [System.IO.Path]::IsPathRooted($requiredFile)) {
                $requiredFile = Join-Path -Path (Split-Path -Parent $filePath) -ChildPath $requiredFile
            }

            if (Test-Path -Path $requiredFile -PathType 'Leaf') {
                $newContent += ProcessFile $requiredFile
                continue
            }
            else {
                Write-Host "Warning: Required file '$requiredFile' not found."
            }
        }

        if (![string]::IsNullOrWhiteSpace($cleanedLine)) {
            $newContent += $cleanedLine
        }
    }

    return $newContent
}

$processedContent = ProcessFile $inputFile
[IO.File]::WriteAllLines($outputFile, $processedContent -join "`n")
#$processedContent -join "`n" | Out-File -FilePath $outputFile -Encoding utf8

Write-Host "Concatenation complete. Output file: $outputFile"