$logLocation = "%userprofile%\AppData\LocalLow\miHoYo\Genshin Impact\output_log.txt"
$path = [System.Environment]::ExpandEnvironmentVariables($logLocation)

if (-Not [System.IO.File]::Exists($path)) {
    Write-Host "Cannot find the log file! Make sure to open the wish history first!" -ForegroundColor Red
    return
}

$logs = Get-Content -Path $path
$m = $logs -match "(?m).:/.+(GenshinImpact_Data|YuanShen_Data)"
$m[0] -match "(.:/.+(GenshinImpact_Data|YuanShen_Data))" >$null

if ($matches.Length -eq 0) {
    Write-Host "Can't fine the url! Make sure to open the wish history first!" -ForegroundColor Red
    return
}

$gamedir = $matches[1]
$cachefile = "$gamedir/webCaches/Cache/Cache_Data/data_2"
$tmpfile = "$env:TEMP/ch_data_2"
Write-Output $tmpfile
Copy-Item $cachefile -Destination $tmpfile

function testUrl($url) {
  try {
    Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing | Out-Null
    return $true
  } catch {
    return $false
  }
}
$content = Get-Content -Encoding UTF8 -Raw $tmpfile
$splitted = $content -split "1/0/"
$found = $splitted -match "e20190909gacha-v2"
$link = $false
$linkFound = $false
for ($i = $found.Length - 1; $i -ge 0; $i -= 1) {
  $t = $found[$i] -match "(https.+?game_biz=)"
  $link = $matches[0]
  Write-Host "`rChecking Link $i" -NoNewline
  $testResult = testUrl $link
  if ($testResult -eq $true) {
    $linkFound = $true
    break
  }
  Sleep 1
}


if (-Not $linkFound) {
  Write-Host "Cannot find the wish history url! Make sure to open the wish history first!" -ForegroundColor Red
  return
}

Write-Host $ $link
