$logLocation = "%userprofile%\AppData\LocalLow\miHoYo\Genshin Impact\output_log.txt"
$path = [System.Environment]::ExpandEnvironmentVariables($logLocation)

$param = $args[0];

$authKeys = @()
Write-Host "Using global location"
$baseUrl = "https://hk4e-api-os.hoyoverse.com/event/gacha_info/api/getGachaLog"
if ($param -eq "china") {
    Write-Host "Using china location"
    $baseUrl = "https://hk4e-api.mihoyo.com/event/gacha_info/api/getGachaLog"
}


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
$cachefile = "$gamedir/webCaches/2.16.0.0/Cache/Cache_Data/data_2"
$tmpfile = "$env:TEMP/ch_data_2"
Write-Output $cachefile
Copy-Item $cachefile -Destination $tmpfile

$content = Get-Content -Encoding UTF8 -Raw $tmpfile

$pattern = 'authkey=(.*?)&game_biz'


foreach ($inputString in $content) {
    $matches = $inputString | Select-String -Pattern $pattern -AllMatches
    
    if ($matches.Matches.Count -gt 0) {
        foreach ($match in $matches.Matches) {
            $authKey = $match.Groups[1].Value
            $authKeys += "$authKey"
        }
    }
}
Write-Host $authKeys.Length "Keys found"

[array]::Reverse($authKeys)

foreach ($authKey in $authKeys) {
    $url = $baseUrl + "?authkey=$authKey&win_mode=fullscreen&authkey_ver=1&sign_type=2&auth_appid=webview_gacha&init_type=301&gacha_id=58776b704143c91eafe5f8f732a84821bd4be7e3&gacha_type=301&page=1&size=1&end_id=0"
    $response = Invoke-RestMethod -Uri $url -Method Get -ContentType 'application/json'

    if($response.message -eq "OK") {
        Set-Clipboard -Value $authkey
        Write-Host "authkey value:`n`n$authkey`n`n"
        Write-Host "URL: "$url
        break
    } else {
        $count++
        Write-Host -NoNewline ("Searching: $count`r")
    }
}