@echo off
title Setup-PC
chcp 65001
mode 112,27

setlocal
call :setESC

:continue
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
echo Permission check result: %errorlevel%
REM
if '%errorlevel%' NEQ '0' (
echo Requesting administrative privileges...
goto UACPrompt
) else ( goto main )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
timeout /T 0
"%temp%\getadmin.vbs"
exit /B

:startProg
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0" 

goto NoUAC

:NoUAC
echo ====== No UAC found, please run this application as administrator ======
echo.
pause
exit

:main
cls
echo.
for /f "tokens=2 delims==" %%E in ('wmic path Win32_Battery get EstimatedChargeRemaining /value') do (set "Ba=%%E")
echo            ╔═════════════════════════════════════════════════════════════════════════════════════╗
echo                      %Ba%%%                     %ESC%[1mMain Menu%ESC%[0m                   Welcome %username%
echo            ╚═════════════════════════════════════════════════════════════════════════════════════╝
                                                      echo.                                                                          
echo                                           %ESC%[91m[%ESC%[0m this will install: %ESC%[91m]%ESC%[0m
echo      chocolatey, steam, chrome, epic games, vcredist-all, directx, 7z, paint.net, sharex, rainmeter, htop,
echo      visual studio code, powershell tweaks, windows terminal, ohmyposh, fonts, curl and a couple pc tweaks
echo.                                                                                   
echo                                 make sure to run this file as administrator   
echo                                         press any key to continue
pause>nul
cls
echo - looking for c:
if exist "C:" (
echo - C drive found, installing programs to C:
goto choco
) else (
echo - C: not found, exiting
exit
)

:choco
echo - installing chocolatey for installations
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
goto steam

:steam
echo - steam
echo Searching for steam files
if exist "C:\Program Files (x86)\Steam" (
    echo - steam found, skipping
    goto chrome
) else (
    echo - steam not found, installing
    choco install steam-client -y
    goto chrome
)

:chrome
echo - chrome
echo Searching for chrome files
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
    echo - chrome found, skipping
    goto epic
) else (
    echo - chrome not found, installing
    choco install googlechrome -y
    goto epic
)

:epic
echo - epic games
echo Searching for epic games files
if exist "C:\Program Files (x86)\Epic Games" (
    echo - epic games found, skipping
    goto vcredist
) else (
    echo - epic games not found, installing
    choco install epicgameslauncher -y
    goto vcredist
)


:vcredist
echo - vcredist all
echo Skipping vcredist search, installing automatically.
choco install vcredist-all
goto directx

:directx
echo - directx
echo Skipping directx search, installing automatically.
choco install directx
goto 7z


:7z
echo - 7z
echo Searching for 7z files
if exist "C:\Program Files\7-Zip\7z.exe" (
    echo - 7z found, skipping
    goto paint
) else (
    echo - 7z not found, installing
    choco install 7zip.install -y
    goto paint
)

:paint
echo - paint.net
echo Searching for paint.net files
if exist "C:\Program Files\Paint.NET\PaintDotNet.exe" (
    echo - paint.net found, skipping
    goto sharex
) else (
    echo - paint.net not found, installing
    choco install paint.net -y
    goto sharex
)

:sharex
echo - sharex
echo Searching for sharex files
if exist "C:\Program Files\ShareX\ShareX.exe" (
    echo - sharex found, skipping
    goto rainmeter
) else (
    echo - sharex not found, installing
    choco install sharex -y
    goto rainmeter
)

:rainmeter
echo - rainmeter
echo Searching for rainmeter files
if exist "C:\Program Files\Rainmeter\Rainmeter.exe" (
    echo - rainmeter found, skipping
    goto vscode
) else (
    echo - rainmeter not found, installing
    choco install rainmeter -y
    goto vscode
)

:vscode
echo - visual studio code
echo Searching for visual studio code files
if exist "C:\Users\" + %username% + "\AppData\Local\Programs\Microsoft VS Code\Code.exe" (
    echo - visual studio code found, skipping
    goto htop
) else (
    echo - visual studio code not found, installing
    choco install vscode -y
    goto htop
)

:htop
echo - htop
echo Searching for htop.exe in System32
if exist "C:\Windows\System32\htop.exe" (
    echo - htop found, skipping
    goto powershell
) else (
    echo - htop not found, installing
    powershell -Command "Invoke-WebRequest https://github.com/gsass1/NTop/releases/download/v0.3.4/ntop.exe -OutFile htop.exe"
    echo moving htop to system32
    move "htop.exe" "C:\Windows\System32"
    goto powershell
)

:powershell
echo - powershell tweaks
echo Skipping searching, tweaking immediatly.
@powershell Set-ExecutionPolicy RemoteSigned
@powershell Set-ExecutionPolicy Unrestricted -Scope CurrentUser
@powershell Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
@powershell Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
@powershell Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force
powershell -Command "Invoke-WebRequest https://github.com/microsoft/terminal/releases/download/v1.14.2281.0/Microsoft.WindowsTerminal_Win10_1.14.2281.0_8wekyb3d8bbwe.msixbundle -OutFile Microsoft.WindowsTerminal_Win10_1.14.2281.0_8wekyb3d8bbwe.msixbundle"
@powershell add-appxpackage -Path "./Microsoft.WindowsTerminal_Win10_1.14.2281.0_8wekyb3d8bbwe.msixbundle"

:ohmyposh
echo - ohmyposh
@powershell Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
@powershell (Get-Command oh-my-posh).Source
echo cls > C:\Users\%username%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
echo winfetch >> C:\Users\%username%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
echo oh-my-posh init pwsh ^| Invoke-Expression >> C:\Users\%username%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
echo oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/1_shell.omp.json" ^| Invoke-Expression >> C:\Users\%username%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
oh-my-posh font install meslo

:fonts
echo - fonts
echo Searching for fonts files
if exist "C:\Windows\Fonts\consola.ttf" (
    echo - fonts found, skipping
    goto curl
) else (
    echo - fonts not found, installing
    start /wait cmd /c "consola.ttf" /install
)

:curl
echo - curl
echo Searching for curl files
if exist "C:\Program Files (x86)\curl\curl.exe" (
    echo - curl found, skipping
    goto tweaks
) else (
    echo - curl not found, installing
    choco install curl -y
    goto tweaks
)

:tweaks
echo - installing tweaks

echo ^> Changing registry and services
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\DPS" /v "Start" /t REG_DWORD /d 4 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WdiServiceHost" /v "Start" /t REG_DWORD /d 4 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WdiSystemHost" /v "Start" /t REG_DWORD /d 4 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\Spooler" /v "Start" /t REG_DWORD /d 4 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\PrintNotify" /v "Start" /t REG_DWORD /d 4 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\Themes" /v "Start" /t REG_DWORD /d 4 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\TabletInputService" /v "Start" /t REG_DWORD /d 4 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\stisvc" /v "Start" /t REG_DWORD /d 4 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WSearch" /v "Start" /t REG_DWORD /d 4 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\WpnService" /v "Start" /t REG_DWORD /d 4 /f
REG ADD "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" /v "Start" /t REG_DWORD /d 4 /f

echo ^> Removing some apps
powershell -command "Get-AppxPackage -AllUsers *sticky* | Remove-AppxPackage"
powershell -command "Get-AppxPackage -AllUsers *maps* | Remove-AppxPackage"
schtasks /Change /TN "\Microsoft\Windows\Maps\MapsUpdateTask" /disable
schtasks /Change /TN "\Microsoft\Windows\Maps\MapsToastTask" /disable
PowerShell -Command "Get-AppxPackage *Microsoft.MixedReality.Portal* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *Microsoft.MicrosoftOfficeHub* | Remove-AppxPackage"

echo ^> Turning TESTSIGNING off
bcdedit -set TESTSIGNING OFF

echo ^> Disabling Timeline
reg ADD HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System /v EnableActivityFeed /t REG_DWORD /d 0 /f
reg ADD HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System /v PublishUserActivities /t REG_DWORD /d 0 /f
reg ADD HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System /v UploadUserActivities  /t REG_DWORD /d 0 /f

echo ^> Fixing start menu
reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3 /f
sc config lfsvc start= auto

echo ^> Changing visual effects
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects /v VisualFXSetting /t REG_DWORD /d 2 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\AnimateMinMax /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ComboBoxAnimation /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ControlAnimations /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\CursorShadow /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DragFullWindows /v DefaultApplied /t REG_DWORD /d 1 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMAeroPeekEnabled /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMEnabled /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMSaveThumbnailEnabled /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing /v DefaultApplied /t REG_DWORD /d 1 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListBoxSmoothScrolling /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TaskbarAnimations /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\Themes /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ThumbnailsOrIcon /v DefaultApplied /t REG_DWORD /d 1 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation /v DefaultApplied /t REG_DWORD /d 0 /f
reg ADD HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TransparentGlass /v DefaultApplied /t REG_DWORD /d 0 /f

echo ^> Adding tweaks for gaming
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f
reg ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl /v Win32PrioritySeparation /t REG_DWORD /d 38 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /t REG_SZ /d "0" /f

echo ^> Adding tweaks for cpu
bcdedit /set hypervisorlaunchtype off
reg ADD HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\DeviceGuard /v EnableVirtualizationBasedSecurity  /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f

echo ^> Adding explorer tweaks
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t  REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCloudSearch" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWebOverMeteredConnections" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortanaAboveLock" /t REG_DWORD /d "0" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\TermServicentVersion\Search" /v "AllowCortana" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f

echo ^> Adding mouse tweaks
reg add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f
reg add "HKU\.DEFAULT\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseXCurve" /t REG_BINARY /d "000000000000000000a0000000000000004001000000000000800200000000000000050000000000" /f
reg add "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" /t REG_BINARY /d "000000000000000066a6020000000000cd4c050000000000a0990a00000000003833150000000000" /f

echo ^> Disabling smartscreen (Windows antivirus wont be disabled)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f 
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f 
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d "0" /f

echo.
echo.
echo.
echo.

echo ^>^> PC is fully tweaked.
echo ^> You might need to change font in windows terminal, copy the code from https://ohmyposh.dev/docs/installation/fonts and add it there
echo -^> Reboot your pc to see changes.
goto loop
:loop
pause>nul
goto loop

:setESC
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set ESC=%%b
  exit /B 0
)
exit /B 0
