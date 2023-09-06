$logLocation = "%userprofile%\AppData\LocalLow\miHoYo\Genshin Impact\output_log.txt"
$path = [System.Environment]::ExpandEnvironmentVariables($logLocation)

if (-Not [System.IO.File]::Exists($path)) {
    Write-Host "Cannot find the log file! Make sure to open the wish history first!" -ForegroundColor Red
    return
}

$logs = Get-Content -Path $path
$m = $logs -match "(?m).:/.+(GenshinImpact_Data)"
$m[0] -match "(.:/.+(GenshinImpact_Data))" >$null

if ($matches.Length -eq 0) {
    Write-Host "Cannot find the wish history url! Make sure to open the wish history first!" -ForegroundColor Red
    return
}

$gamedir = $matches[1]
$cachefile = "$gamedir/webCaches/2.15.0.0/Cache/Cache_Data/data_2"
$tmpfile = "$env:TEMP/ch_data_2"
Write-Output $cachefile
Copy-Item $cachefile -Destination $tmpfile

$content = Get-Content -Encoding UTF8 -Raw $tmpfile

# Define a regular expression pattern to extract the authkey parameter
$pattern = "&authkey=([^&]+)"

# Use the Select-String cmdlet to find the authkey parameter
$match = $content | Select-String -Pattern $pattern

# Extract the authkey value from the match
if ($match) {
    $authkey = $match.Matches[0].Groups[1].Value
    Set-Clipboard -Value $authkey
    Write-Host "authkey value:`n`n$authkey`n`n"
} else {
    Write-Host "authkey parameter not found."
}