@echo off
setlocal EnableDelayedExpansion
net session >nul 2>&1 || (powershell start -verb runas '%~0' & exit)
title Simplify11

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

:restoreSuggestion
echo %cGrey%Checking for existing 'Pre-Script Restore Point'...%cReset%
for /f "usebackq delims=" %%i in (`powershell -Command "Get-ComputerRestorePoint | Where-Object { $_.Description -eq 'Pre-Script Restore Point' } | Measure-Object -Property Description | Select-Object -ExpandProperty Count"`) do (
    if %%i gtr 0 (
        set "hasRestorePoint=1"
        echo %cGrey%Pre-Script Restore Point already exists. You can apply it from the main menu.%cReset%
        pause
        goto main
    )
)

echo %cGrey%Would you like to create a system restore point before proceeding?%cReset%
echo %cGrey%This is recommended to safely revert changes if needed%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==2 goto main

echo %cGrey%Configuring system restore settings...%cReset%
reg.exe add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d "0" /f >nul 2>&1
if errorlevel 1 (
    echo %cRed%Failed to configure system restore settings. Continuing anyway...%cReset%
    timeout /t 2 >nul
)

echo %cGrey%Creating system restore point (this may take a moment)...%cReset%
powershell -Command "Checkpoint-Computer -Description 'Pre-Script Restore Point' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop" >nul 2>&1
if errorlevel 1 (
    echo %cRed%Failed to create restore point. Please ensure System Protection is enabled.%cReset%
    echo %cRed%You can enable it in System Properties ^> System Protection.%cReset%
    pause
) else (
    echo %cGreen%Restore point created successfully.%cReset%
    timeout /t 2 >nul
)

:main
title Simplify11
cls
echo.
echo %cMauve% +--------------------------------------------------------+%cReset%
echo %cMauve% '%cMauve% Simplify your setup with Essential Tweaks ^& Scripts  %cMauve%'%cReset%
echo %cMauve% +--------------------------------------------------------+%cReset%
if "%hasRestorePoint%"=="1" (
    echo %cMauve% '%cGrey% [0] Use Existing Restore Point                     %cMauve%'%cReset%
)
echo %cMauve% '%cGrey% [1] Apply Performance Tweaks                           %cMauve%'%cReset%
echo %cMauve% '%cGrey% [2] Free Up Space                                      %cMauve%'%cReset%
echo %cMauve% '%cGrey% [3] WinUtil - Install Programs, Tweaks ^& Fixes        %cMauve%'%cReset%
echo %cMauve% '%cGrey% [4] Privacy.Sexy - Tool to enforce privacy in clicks   %cMauve%'%cReset%
echo %cMauve% '%cGrey% [5] Winget - Install programs without browser          %cMauve%'%cReset%
echo %cMauve% '%cGrey% [6] Check other cool stuff                             %cMauve%'%cReset%
echo %cMauve% '%cGrey% [7] Exit                                               %cMauve%'%cReset%
echo %cMauve% +--------------------------------------------------------+%cReset%
if "%hasRestorePoint%"=="1" (
    choice /C 01234567 /N /M "Select and press Enter: "
) else (
    choice /C 1234567 /N /M "Select and press Enter: "
)
if "%hasRestorePoint%"=="1" (
    if %errorlevel%==1 goto applyRestorePoint
    set /a "menuChoice=!errorlevel!-1"
) else (
    set "menuChoice=%errorlevel%"
)
goto option!menuChoice!

:applyRestorePoint
cls
echo %cGrey%Applying the Pre-Script Restore Point...%cReset%
powershell -Command "Get-ComputerRestorePoint | Where-Object { $_.Description -eq 'Pre-Script Restore Point' } | ForEach-Object { Restore-Computer -RestorePoint $_.SequenceNumber -Confirm:$false }"
if errorlevel 1 (
    echo %cRed%Failed to apply restore point. Please try applying it manually through System Restore.%cReset%
) else (
    echo %cGreen%Restore point applied successfully.%cReset%
    echo %cGrey%It is recommended to restart your computer to ensure all changes take effect.%cReset%
    echo %cGrey%Would you like to restart now?%cReset%
    choice /C YN /N /M "[Y] Yes [N] No: "
    if !errorlevel!==1 (
        shutdown /r /t 0
    ) else (
        echo %cGrey%Restart your PC to take full effect.%cReset%
        pause
    )
)
pause

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

:: Storage Type Selection
cls
echo %cGrey%What type of storage device do you have?%cReset%
echo.
echo %cGrey%[1] SSD/NVMe%cReset%
echo %cGrey%[2] HDD%cReset%
echo.
choice /C 12 /N /M "%cGrey%Select your storage type: %cReset%"

if errorlevel 2 (
    echo %cGrey%HDD selected - Applying HDD optimizations...%cReset%
    :: Enable Superfetch/Prefetch for HDDs as they benefit from it
    reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d "1" /f
    reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "3" /f
) else (
    echo %cGreen%SSD/NVMe selected - Applying SSD optimizations...%cReset%
    :: Enable and optimize TRIM for SSD
    fsutil behavior set DisableDeleteNotify 0
    :: Disable defragmentation for SSDs
    schtasks /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Disable
    :: Disable NTFS last access time updates
    fsutil behavior set disablelastaccess 1
)

:: Mouse & Keyboard Tweaks


:: These settings disable Enhance Pointer Precision, which increases pointer speed with mouse speed
:: This can be useful generally, but it causes cursor issues in games
:: It's recommended to disable this for gaming
reg.exe add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f
reg.exe add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f
reg.exe add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f

:: The MouseDataQueueSize and KeyboardDataQueueSize parameters set the number of events stored in the mouse and keyboard driver buffers
:: A smaller value means faster processing of new information
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "20" /f
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d "20" /f

:: Disable StickyKeys
:: These settings disable the annoying Sticky Keys feature when Shift is pressed repeatedly, and the delay in character input.

reg.exe add "HKCU\Control Panel\Accessibility" /v "StickyKeys" /t REG_SZ /d "506" /f
reg.exe add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f
reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "DelayBeforeAcceptance" /t REG_SZ /d "0" /f
reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatRate" /t REG_SZ /d "0" /f
reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatDelay" /t REG_SZ /d "0" /f
reg.exe add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f

:: GPU Tweaks
:: The HwSchMode parameter optimizes hardware-level computation scheduling (Hardware Accelerated GPU Scheduling), reducing latency on lower-end GPUs.
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f
reg.exe add "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d "0" /f

:: Network Tweaks

:: By default, Windows uses network throttling to limit non-multimedia traffic to 10 packets per millisecond (about 100 Mb/s).
:: This is to prioritize CPU access for multimedia applications, as processing network packets can be resource-intensive.
:: However, it's recommended to disable this setting, especially with gigabit networks, to avoid unnecessary interference.
: source - https://www.youtube.com/watch?v=EmdosMT5TtA
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "4294967295" /f
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d "1" /f

:: CPU Tweaks

:: LazyMode is a software flag that allows the system to skip some hardware events when CPU load is low.
:: Disabling it can use more resources for event processing, so we set the timer to a minimum of 1ms (10000ms).
: source - https://www.youtube.com/watch?v=FxpRL7wheGc
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "LazyModeTimeout" /t REG_DWORD /d "25000" /f
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\MMCSS" /v "Start" /t REG_DWORD /d "2" /f

:: Power Tweaks

:: Power Throttling is a service that slows down background apps to save energy on laptops.
:: In this case, it's unnecessary, so it's recommended to disable it.
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f

: source - https://github.com/ancel1x/Ancels-Performance-Batch
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "PlatformAoAcOverride" /t REG_DWORD /d "0" /f
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EnergyEstimationEnabled" /t REG_DWORD /d "0" /f
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "EventProcessorEnabled" /t REG_DWORD /d "0" /f
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /t REG_DWORD /d "0" /f

:: Activate Hidden Ultimate Performance Power Plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee
powercfg -setactive eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee

:: Other Tweaks

:: Specify priority for services (drivers) to handle interrupts first.
:: Windows uses IRQL to determine interrupt priority. If an interrupt can be serviced, it starts execution.
:: Lower priority tasks are queued. This ensures critical services are prioritized for interrupts.
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\services\DXGKrnl\Parameters" /v "ThreadPriority" /t REG_DWORD /d "15" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\services\USBHUB3\Parameters" /v "ThreadPriority" /t REG_DWORD /d "15" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\services\USBXHCI\Parameters" /v "ThreadPriority" /t REG_DWORD /d "15" /f 
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "ThreadPriority" /t REG_DWORD /d "31" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "ThreadPriority" /t REG_DWORD /d "31" /f

:: Set Priority For Programs Instead Of Background Services
: source - https://www.youtube.com/watch?v=bqDMG1ZS-Yw
reg.exe add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 0x00000024 /f
: source -
reg.exe add "HKLM\SYSTEM\ControlSet001\Control\PriorityControl" /v IRQ8Priority /t REG_DWORD /d 1 /f
reg.exe add "HKLM\SYSTEM\ControlSet001\Control\PriorityControl" /v IRQ16Priority /t REG_DWORD /d 2 /f

:: Boot System & Software without limits
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "Startupdelayinmsec" /t REG_DWORD /d "0" /f

:: Disable DistributeTimers
@REM reg.exe delete "HKLM\SYSTEM\ControlSet001\Control\Session Manager\kernel" /v "DistributeTimers" /f

:: Disable Kernel Mitigations
@REM call :setReg "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" "MitigationOptions" "222222222222222222222222222222222222222222222222" REG_BINARY

:: Disable Automatic maintenance
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d "1" /f


:: Speed up start time
reg.exe add "HKCU\AppEvents\Schemes" /f
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DelayedDesktopSwitchTimeout" /t REG_DWORD /d "0" /f

:: Disable ApplicationPreLaunch & Prefetch
:: The outdated Prefetcher and Superfetch services run in the background, analyzing loaded apps/libraries/services.
:: They cache repeated data to disk and then to RAM, speeding up app launches.
:: However, with an SSD, apps load quickly without this, so constant disk caching is unnecessary.
powershell Disable-MMAgent -ApplicationPreLaunch
reg.exe add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "0" /f
reg.exe add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "SfTracingState" /t REG_DWORD /d "0" /f

:: Reducing time of disabling processes and menu
reg.exe add "HKCU\Control Panel\Desktop" /v  "AutoEndTasks" /t REG_SZ /d "1" /f
reg.exe add "HKCU\Control Panel\Desktop" /v  "HungAppTimeout" /t REG_SZ /d "1000" /f
reg.exe add "HKCU\Control Panel\Desktop" /v  "WaitToKillAppTimeout" /t REG_SZ /d "2000" /f
reg.exe add "HKCU\Control Panel\Desktop" /v  "LowLevelHooksTimeout" /t REG_SZ /d "1000" /f
reg.exe add "HKCU\Control Panel\Desktop" /v  "MenuShowDelay" /t REG_SZ /d "0" /f
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control" "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f

:: Memory Tweaks
: source - https://github.com/SanGraphic/QuickBoost/blob/main/v2/MemoryTweaks.bat

:: Enabling Large System Cache makes the OS use all RAM for caching system files,
:: except 4MB reserved for disk cache, improving Windows responsiveness.
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "1" /f

:: Disabling Windows attempt to save as much RAM as possible, such as sharing pages for images, copy-on-write for data pages, and compression
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingCombining" /t REG_DWORD /d "1" /f

:: Enabling this parameter keeps the system kernel and drivers in RAM instead of the page file, improving responsiveness.
reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f

:: DirectX Tweaks
:: source - https://www.youtube.com/watch?v=itTcqcJxtbo
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D12_ENABLE_UNSAFE_COMMAND_BUFFER_REUSE" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D12_ENABLE_RUNTIME_DRIVER_OPTIMIZATIONS" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D12_RESOURCE_ALIGNMENT" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D11_MULTITHREADED" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D12_MULTITHREADED" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D11_DEFERRED_CONTEXTS" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D12_DEFERRED_CONTEXTS" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D11_ALLOW_TILING" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D11_ENABLE_DYNAMIC_CODEGEN" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D12_ALLOW_TILING" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D12_CPU_PAGE_TABLE_ENABLED" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D12_HEAP_SERIALIZATION_ENABLED" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D12_MAP_HEAP_ALLOCATIONS" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX" /v "D3D12_RESIDENCY_MANAGEMENT_ENABLED" /t REG_DWORD /d "1" /f

:: Serialize Timer Expiration mechanism, officially documented in Windows Internals 7th Edition Part 2
:: source - https://www.youtube.com/watch?v=wil-09_5H0M
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "SerializeTimerExpiration" "1" "REG_DWORD"

goto customGPUTweaks

:customGPUTweaks
cls
echo %colorText%What size of RAM do you have?%colorReset%
echo.
echo %colorText%[1] 4GB%colorReset%
echo %colorText%[2] 6GB%colorReset%
echo %colorText%[3] 8GB%colorReset%
echo %colorText%[4] 16GB%colorReset%
echo %colorText%[5] 32GB%colorReset%
echo %colorText%[6] 64GB%colorReset%
echo %colorText%[7] Skip if Unsure%colorReset%
choice /C 1234567 /N /M "%colorSapphire%>%colorReset%"
if errorlevel 7 goto main
call :setRAMSize %errorlevel%

:setRAMSize
set "ramSize=%1"
set "svcHostThreshold="
set "ramSizeText="

if !ramSize! == 1 (
    set "svcHostThreshold=68764420"
    set "ramSizeText=4GB"
)
if !ramSize! == 2 (
    set "svcHostThreshold=103355478"
    set "ramSizeText=6GB"
)
if !ramSize! == 3 (
    set "svcHostThreshold=137922056"
    set "ramSizeText=8GB"
)
if !ramSize! == 4 (
    set "svcHostThreshold=376926742"
    set "ramSizeText=16GB"
)
if !ramSize! == 5 (
    set "svcHostThreshold=861226034"
    set "ramSizeText=32GB"
)
if !ramSize! == 6 (
    set "svcHostThreshold=1729136740"
    set "ramSizeText=64GB"
)

if defined svcHostThreshold (
    call :setReg "HKLM\SYSTEM\ControlSet001\Control" "SvcHostSplitThresholdInKB" "!svcHostThreshold!" REG_DWORD
    echo %colorGreen%Successfully applied tweak for !ramSizeText! RAM.%colorReset%
) else (
    echo %colorRed%Invalid selection.%colorReset%
)
pause
goto next

:next
cls
echo %colorText%What kind of video card do you have?%colorReset%
echo.
echo %colorText%[1] NVIDIA%colorReset%
echo %colorText%[2] AMD%colorReset%
echo.
echo %colorText%[3] Skip if Unsure%colorReset%
echo.
choice /C 123 /N /M "%colorSapphire%>%colorReset%"
if errorlevel 3 goto main
if errorlevel 2 goto amd
if errorlevel 1 goto nvidia

:nvidia
: source - https://github.com/AlchemyTweaks/Verified-Tweaks/blob/main/Nvidia/RmGpsPsEnablePerCpuCoreDpc
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "RmGpsPsEnablePerCpuCoreDpc" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" /v "RmGpsPsEnablePerCpuCoreDpc" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "RmGpsPsEnablePerCpuCoreDpc" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\NVAPI" /v "RmGpsPsEnablePerCpuCoreDpc" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "RmGpsPsEnablePerCpuCoreDpc" /t REG_DWORD /d "1" /f

goto main

:amd
: source - https://www.youtube.com/watch?v=nuUV2RoPOWc
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AllowSnapshot" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AllowSubscription" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AllowRSOverlay" /t REG_SZ /d "false" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AllowSkins" /t REG_SZ /d "false" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "AutoColorDepthReduction_NA" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableUVDPowerGatingDynamic" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableVCEPowerGating" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisablePowerGating" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDrmdmaPowerGating" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableDMACopy" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableBlockWrite" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "StutterMode" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_GPUPowerDownEnabled" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "LTRSnoopL1Latency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "LTRSnoopL0Latency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "LTRNoSnoopL1Latency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "LTRMaxNoSnoopLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_RpmComputeLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DalUrgentLatencyNs" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "memClockSwitchLatency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_RTPMComputeF1Latency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_DGBMMMaxTransitionLatencyUvd" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_DGBPMMaxTransitionLatencyGfx" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DalNBLatencyForUnderFlow" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "BGM_LTRSnoopL1Latency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "BGM_LTRSnoopL0Latency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "BGM_LTRNoSnoopL1Latency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "BGM_LTRNoSnoopL0Latency" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "BGM_LTRMaxSnoopLatencyValue" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "BGM_LTRMaxNoSnoopLatencyValue" /t REG_DWORD /d "1" /f

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
    rd /s /q %systemdrive%\Windows\SoftwareDistribution
    md %systemdrive%\Windows\SoftwareDistribution
)

:: Advanced disk cleaner
echo.
echo %cGrey%Would you like to run the advanced disk cleaner?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==1 (
    echo %cGrey%Running advanced disk cleaner...%cReset%
    cleanmgr /sagerun:65535
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
title Simplyfy11: Install apps
cls
:: Define packages for winget installation
set "packages[1]=Microsoft.VisualStudioCode"
set "packages[2]=Python"
set "packages[3]=OpenJS.NodeJS"
set "packages[4]=Anysphere.Cursor"
set "packages[5]=Git.Git"
set "packages[6]=GitHub.GitHubDesktop"
set "packages[7]=TheBrowserCompany.Arc"
set "packages[8]=Alex313031.Thorium"
set "packages[9]=Zen-Team.Zen-Browser"
set "packages[10]=Yandex.Browser"
set "packages[11]=Microsoft.PowerToys"
set "packages[12]=M2Team.NanaZip"
set "packages[13]=agalwood.motrix"
set "packages[14]=MartiCliment.UniGetUI"
set "packages[15]=TechPowerUp.NVCleanstall"
set "packages[16]=NVIDIA.Broadcast"
set "packages[17]=Microsoft.PCManager"
set "packages[18]=RadolynLabs.AyuGramDesktop"
set "packages[19]=Vencord.Vesktop"
set "packages[20]=lencx.ChatGPT"
set "packages[21]=Doist.Todoist"
set "packages[22]=Valve.Steam"
set "packages[23]=EpicGames.EpicGamesLauncher"

echo %cMauve% +--------------------------------------------------------+%cReset%
echo %cMauve% '%cGreen% [0] Search for any program                             %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Development Tools:                                      %cMauve%'%cReset%
echo %cMauve% '%cGrey% [1] Visual Studio Code   [2] Python                   %cMauve%'%cReset%
echo %cMauve% '%cGrey% [3] Node.js             [4] Cursor                    %cMauve%'%cReset%
echo %cMauve% '%cGrey% [5] Git                 [6] GitHub Desktop            %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Browsers:                                              %cMauve%'%cReset%
echo %cMauve% '%cGrey% [7] Arc                 [8] Thorium                   %cMauve%'%cReset%
echo %cMauve% '%cGrey% [9] Zen                 [10] Yandex                   %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Utilities:                                             %cMauve%'%cReset%
echo %cMauve% '%cGrey% [11] PowerToys          [12] NanaZip                  %cMauve%'%cReset%
echo %cMauve% '%cGrey% [13] Motrix             [14] UniGetUI                 %cMauve%'%cReset%
echo %cMauve% '%cGrey% [15] NVCleanstall       [16] NVIDIA Broadcast        %cMauve%'%cReset%
echo %cMauve% '%cGrey% [17] PC Manager                                       %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Social ^& Productivity:                                 %cMauve%'%cReset%
echo %cMauve% '%cGrey% [18] AyuGram            [19] Vesktop                  %cMauve%'%cReset%
echo %cMauve% '%cGrey% [20] ChatGPT            [21] Todoist                  %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Gaming:                                                %cMauve%'%cReset%
echo %cMauve% '%cGrey% [22] Steam              [23] Epic Games Store         %cMauve%'%cReset%
echo.
echo %cMauve% '%cGrey% [24] Back to Main Menu                                %cMauve%'%cReset%
echo %cMauve% +--------------------------------------------------------+%cReset%

set /p choice="%cSapphire%Enter your choices (space-separated numbers, e.g., '1 2'): %cReset%"

:: Process each number in the input
for %%a in (%choice%) do (
    if "%%a"=="0" (
        goto searchProgram
    ) else if "%%a"=="24" (
        goto main
    ) else (
        :: Check if it's a valid number between 1 and 23
        set /a "num=%%a" 2>nul
        if !num! geq 1 if !num! leq 23 (
            if defined packages[%%a] (
                call :installPackage "!packages[%%a]!"
            ) else (
                echo %cRed%No package defined for choice %%a%cReset%
                timeout /t 2 >nul
            )
        ) else (
            echo %cRed%Invalid choice: %%a%cReset%
            timeout /t 2 >nul
        )
    )
)

:: After all installations are complete
echo.
echo %cGreen%All selected programs have been processed.%cReset%
timeout /t 2 >nul
goto wingetInstall

:searchProgram
cls
echo %cGrey%Enter Program name to search (or 'back' to return):%cReset%
set /p "searchTerm="
if /i "%searchTerm%"=="back" goto wingetInstall
if /i "%searchTerm%"=="" goto searchProgram

echo %cGrey%Searching for "%searchTerm%"...%cReset%
winget search "%searchTerm%"
echo.
echo %cGrey%Enter the exact package ID to install (or 'back' to return):%cReset%
set /p "packageId="
if /i "%packageId%"=="back" goto wingetInstall
if /i "%packageId%"=="" goto searchProgram

call :installPackage "%packageId%"
goto wingetInstall

:installPackage
set "packageId=%~1"
echo.
echo %cGrey%Installing %packageId%...%cReset%
winget install --id %packageId% --accept-package-agreements --accept-source-agreements
if !errorlevel! equ 0 (
    echo %cGreen%Successfully installed %packageId%%cReset%
) else (
    echo %cRed%Failed to install %packageId%. Error code: !errorlevel!%cReset%
    pause
    goto wingetInstall
)

:coolStuff
cls
start "" "https://github.com/emylfy/simplify11?tab=readme-ov-file#simplify11"
pause
goto main
