$logLocation = "%userprofile%\AppData\LocalLow\miHoYo\Genshin Impact\output_log.txt"
$path = [System.Environment]::ExpandEnvironmentVariables($logLocation)

$authKeys = @()

$baseUrl = "https://public-operation-hk4e-sg.hoyoverse.com/gacha_info/api/getGachaLog"

if (-Not [System.IO.File]::Exists($path)) {
    Write-Host "Cannot find the log file! Make sure to open the wish history first! Or try to restart your PowerShell as administrator" -ForegroundColor Red
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

$webCachesDir = "$gamedir/webCaches"
$versionPattern = '^\d+\.\d+\.\d+\.\d+$'
$latestPatchDir = Get-ChildItem -Path $webCachesDir -Directory | Where-Object { $_.Name -match $versionPattern } | Sort-Object { $_.Name } -Descending | Select-Object -First 1

$cachefile = "$($latestPatchDir.FullName)\Cache\Cache_Data\data_2"
$tmpfile = "$env:TEMP/ch_data_2"
Write-Output $cachefile
Copy-Item $cachefile -Destination $tmpfile

$content = Get-Content -Encoding UTF8 -Raw $tmpfile

$pattern = 'authkey=(.*?)&game_biz'

foreach ($inputString in $content) {
    $matchedData = $inputString | Select-String -Pattern $pattern -AllMatches
    
    if ($matchedData.Matches.Count -gt 0) {
        foreach ($match in $matchedData.Matches) {
            $authKey = $match.Groups[1].Value
            $authKeys += "$authKey"
        }
    }
}
Write-Host $authKeys.Length "Keys found"

foreach ($authKey in $authKeys) {
    $url = $baseUrl + "?authkey=$authKey&win_mode=fullscreen&authkey_ver=1&sign_type=2&auth_appid=webview_gacha&init_type=301&gacha_type=301&page=1&size=20&end_id=0&lang=en"
    $response = Invoke-RestMethod -Uri $url -Method Get -ContentType 'application/json'

    if ($response.message -eq "OK") {
        Set-Clipboard -Value $authkey
        Write-Host "authkey value:`n`n$authkey"
        break
    }
    else {
        $count++
        Write-Host -NoNewline ("Searching: $count`r")
    }
}
