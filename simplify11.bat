:: Future Plans:
: Add the comments to every section
: Release Perfomance Tweaks with sources and comments why is it worth it

@echo off
setlocal EnableDelayedExpansion
net session >nul 2>&1 || (powershell start -verb runas '%~0' & exit)
title Simplify11
@REM mode con: cols=75 lines=25

:: Define colors
set "cRosewater=[38;5;224m"
set "cFlamingo=[38;5;210m"
set "cPink=[38;5;212m"
set "cMauve=[38;5;141m"
set "cRed=[38;5;203m"
set "cMaroon=[38;5;167m"
set "cGreen=[38;5;120m"
set "cTeal=[38;5;116m"
set "cSky=[38;5;111m"
set "cSapphire=[38;5;69m"
set "cBlue=[38;5;75m"
set "cGrey=[38;5;250m"
set "cReset=[0m"

cls
echo.
echo.
echo %cRosewater%   "Before using any of the options, please make a system restore point,%cReset%
echo %cRosewater%   I do not take any responsibility if you break your system, lose data,%cReset%
echo %cRosewater%   or have a performance decrease, thank you for understanding"%cReset%
echo.
echo %cFlamingo%   I tried as hard as possible to make the script universal for everyone!%cReset%
echo.
echo.
set /p=%cGrey%Press any key to continue...%cReset%

:restoreSuggestion
echo %cGrey%Checking for existing 'Pre-Script Restore Point'...%cReset%
for /f "usebackq delims=" %%i in (`powershell -Command "Get-ComputerRestorePoint | Where-Object { $_.Description -eq 'Pre-Script Restore Point' } | Measure-Object -Property Description | Select-Object -ExpandProperty Count"`) do (
    if %%i gtr 0 (
        echo %cGrey%Pre-Script Restore Point already exists. Skipping restore point creation.%cReset%
        goto main
    )
)

echo %cGrey%Would you like to create a system restore point before proceeding?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==2 goto main

echo %cGrey%Creating system restore point...%cReset%
reg.exe add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t %dw% /d "0" /f
powershell -Command "Checkpoint-Computer -Description 'Pre-Script Restore Point' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel%==0 (
    echo %cGrey%Restore point created successfully.%cReset%
) else (
    echo %cRed%Failed to create restore point. Please check your system settings and try again.%cReset%
)

:main
cls
echo.
echo %cMauve% +--------------------------------------------------------+%cReset%
echo %cMauve% '%cMauve% Simplify your setup with Essential Tweaks and Scripts  %cMauve%'%cReset%
echo %cMauve% +--------------------------------------------------------+%cReset%
echo %cMauve% '%cGrey% [1] Apply Performance Tweaks                           %cMauve%'%cReset%
echo %cMauve% '%cGrey% [2] Free Up Space                                      %cMauve%'%cReset%
echo %cMauve% '%cGrey% [3] WinUtil - Install Programs, Tweaks and Fixes       %cMauve%'%cReset%
echo %cMauve% '%cGrey% [4] Privacy.Sexy - Tool to enforce privacy in clicks   %cMauve%'%cReset%
echo %cMauve% '%cGrey% [5] Winget - Install programs without browser          %cMauve%'%cReset%
echo %cMauve% '%cGrey% [6] Check other cool stuff                             %cMauve%'%cReset%
echo %cMauve% '%cGrey% [7] Exit                                               %cMauve%'%cReset%
echo %cMauve% +--------------------------------------------------------+%cReset%
choice /C 1234567 /N /M "Select and press Enter: "
goto option%errorlevel%

:option1
call :applyTweaks
goto main

:option2
call :freeUpSpace
goto main

:option3
call :launchWinUtil
goto main

:option4
call :launchPrivacySexy
goto main

:option5
call :wingetInstall
goto main

:option6
call :coolStuff
goto main

:option7
exit

:applyTweaks
echo Coming soon!
pause
goto main

:freeUpSpace

:: Disable Reserved Storage
echo.
echo %cGrey%Would you like to disable Reserved Storage?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==1 (
    echo %cGrey%Disabling Reserved Storage...%cReset%
    dism /Online /Set-ReservedStorageState /State:Disabled
)

:: Cleanup WinSxS
echo.
echo %cGrey%Would you like to clean up WinSxS?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==1 (
    echo %cGrey%Cleaning up WinSxS...%cReset%
    dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase /RestoreHealth
)

:: Remove Virtual Memory
echo.
echo %cGrey%Would you like to remove Virtual Memory (pagefile.sys)?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==1 (
    echo %cGrey%Removing Virtual Memory...%cReset%
    powershell -Command "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -Value ''"
)

:: Clear Windows Update Folder
echo.
echo %cGrey%Would you like to clear the Windows Update Folder?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==1 (
    echo %cGrey%Clearing Windows Update Folder...%cReset%
    net stop wuauserv
    rd /s /q %systemdrive%\Windows\SoftwareDistribution
    md %systemdrive%\Windows\SoftwareDistribution
)

:: Advanced disk cleaner
echo.
echo %cGrey%Would you like to run the advanced disk cleaner?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==1 (
    echo %cGrey%Running advanced disk cleaner...%cReset%
    cleanmgr /sageset:65535 /sagerun:65535
)

goto main

:launchWinUtil
cls
start cmd /c powershell -Command "irm 'https://christitus.com/win' | iex"
goto main

:launchPrivacySexy
cls
start "" "https://privacy.sexy/"
echo %cGrey%Recommended to set a Standard option if you are not sure what to do%cReset%
echo %cGrey%and also dont forget to download revert version for your selected tweaks if anything can go wrong%cReset%
pause
goto main

:wingetInstall
cls
echo %cMauve% --------------------------------------------------------%cReset%
echo %cMauve% '%cGreen% Search and Install:                                   %cMauve%'%cReset%
echo %cMauve% '%cGrey% [1] Search and Install a Package                      %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Browsers:                                             %cMauve%'%cReset%
echo %cMauve% '%cGrey% [2] Arc                  [3] Zen                      %cMauve%'%cReset%
echo %cMauve% '%cGrey% [4] Thorium              [5] Yandex                   %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Social Media:                                         %cMauve%'%cReset%
echo %cMauve% '%cGrey% [6] AyuGram              [7] Vesktop                  %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Utilities:                                            %cMauve%'%cReset%
echo %cMauve% '%cGrey% [8] UniGetUI             [9] NanaZip                  %cMauve%'%cReset%
echo %cMauve% '%cGrey% [10] Motrix              [11] NVIDIA Broadcast        %cMauve%'%cReset%
echo %cMauve% '%cGrey% [12] NVCleanstall        [13] Microsoft PC Manager    %cMauve%'%cReset%
echo %cMauve% '%cGrey% [14] PowerToys                                        %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Productivity:                                         %cMauve%'%cReset%
echo %cMauve% '%cGrey% [15] ChatGPT             [16] Todoist                 %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Games:                                                %cMauve%'%cReset%
echo %cMauve% '%cGrey% [17] Steam               [18] Epic Games Store        %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Coding:                                               %cMauve%'%cReset%
echo %cMauve% '%cGrey% [19] Python              [20] Cursor                  %cMauve%'%cReset%
echo %cMauve% '%cGrey% [21] Node.js             [22] Visual Studio Code      %cMauve%'%cReset%
echo.
echo %cMauve% '%cGrey% [23] Exit                                             %cMauve%'%cReset%
echo %cMauve% --------------------------------------------------------%cReset%
set /p choice="%cSapphire%Select and press Enter: %cReset%"

set /a isValid=0
for /l %%i in (1,1,23) do (
    if "%choice%"=="%%i" set /a isValid=1
)
if %isValid%==0 (
    goto wingetInstall
)

if "!choice!"=="1" (
    cls
    echo Name of the program? or type exit
    set /p name=""
    if /i "%name%"=="exit" goto wingetInstall
    winget search "%name%"
    echo.
    echo Enter the exact ID of the package to install:
    set /p packageId=""
    if not "%packageId%"=="" (
        winget install "%packageId%"
    )
    goto wingetInstall
)
if "!choice!"=="2"  (winget install TheBrowserCompany.Arc)
if "!choice!"=="3"  (winget install Zen-Team.Zen-Browser)
if "!choice!"=="4"  (winget install Alex313031.Thorium)
if "!choice!"=="5"  (winget install Yandex.Browser)
if "!choice!"=="6"  (winget install RadolynLabs.AyuGramDesktop)
if "!choice!"=="7"  (winget install Vencord.Vesktop)
if "!choice!"=="8"  (winget install MartiCliment.UniGetUI)
if "!choice!"=="9"  (winget install M2Team.NanaZip)
if "!choice!"=="10" (winget install agalwood.motrix)
if "!choice!"=="11" (winget install NVIDIA.Broadcast)
if "!choice!"=="12" (winget install TechPowerUp.NVCleanstall)
if "!choice!"=="13" (winget install Microsoft.PCManager)
if "!choice!"=="14" (winget install Microsoft.PowerToys)
if "!choice!"=="15" (winget install lencx.ChatGPT)
if "!choice!"=="16" (winget install Doist.Todoist)
if "!choice!"=="17" (winget install Valve.Steam)
if "!choice!"=="18" (winget install EpicGames.EpicGamesLauncher)
if "!choice!"=="19" (winget install Python)
if "!choice!"=="20" (winget install Anysphere.Cursor)
if "!choice!"=="21" (winget install OpenJS.NodeJS)
if "!choice!"=="22" (winget install Microsoft.VisualStudioCode)
if "!choice!"=="23" (goto main)

goto wingetInstall

:coolStuff
cls
start "" "https://github.com/emylfy/simplify11?tab=readme-ov-file#simplify11"
pause
goto main

:reg
set "key=%~1"
set "valueName=%~2"
set "type=%~3"
set "value=%~4"

if "%type%"=="" set "type=REG_SZ"

reg.exe add "%key%" /v "%valueName%" /t "%type%" /d "%value%" /f
if errorlevel 1 (
    echo Error: Failed to add registry key "%key%" with value "%valueName%".
) else (
    echo Successfully added registry key "%key%" with value "%valueName%".
)

goto :eof