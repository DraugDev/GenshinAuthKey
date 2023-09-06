Simple PowerShell script to get the AUTHKEY needed to fetch data from HoYoverse API for counting Wishes.

**How to use: 
```
 iex "&{$((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DraugDev/GenshinAuthKey/main/auth_key.ps1'))} global"
```
*Or
If you need an oldschool URL
```
 iex "&{$((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DraugDev/GenshinAuthKey/main/WishUrl.ps1'))} global"
```
