@echo off
setlocal EnableDelayedExpansion
net session >nul 2>&1 || (powershell start -verb runas '%~0' & exit)
cls
title Simplify11

:: Catppuccin colors
set "colorRosewater=[38;5;224m"
set "colorFlamingo=[38;5;210m"
set "colorPink=[38;5;212m"
set "colorMauve=[38;5;141m"
set "colorRed=[38;5;203m"
set "colorMaroon=[38;5;167m"
set "colorPeach=[38;5;209m"
set "colorYellow=[38;5;229m"
set "colorGreen=[38;5;120m"
set "colorTeal=[38;5;116m"
set "colorSky=[38;5;111m"
set "colorSapphire=[38;5;69m"
set "colorBlue=[38;5;75m"
set "colorLavender=[38;5;183m"
set "colorText=[38;5;250m"
set "colorReset=[0m"

echo.
echo.
echo %colorRosewater%   "Before using any of the options, please make a system restore point,%colorReset%
echo %colorRosewater%   I do not take any responsibility if you break your system, lose data,%colorReset%
echo %colorRosewater%   or have a performance decrease, thank you for understanding"%colorReset%
echo.
echo %colorFlamingo%   I tried as hard as possible to make the script universal for everyone!%colorReset%
echo.
echo.
pause

:backup

echo %colorText%Checking for existing 'Pre-Script Restore Point'...%colorReset%
for /f "usebackq delims=" %%i in (`powershell -Command "Get-ComputerRestorePoint | Where-Object { $_.Description -eq 'Pre-Script Restore Point' } | Measure-Object -Property Description | Select-Object -ExpandProperty Count"`) do (
    if %%i gtr 0 (
        echo %colorYellow%A 'Pre-Script Restore Point' already exists. Skipping restore point creation.%colorReset%
        goto main
    )
)

echo %colorText%Would you like to create a system restore point before proceeding?%colorReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if errorlevel 2 (
    echo %colorYellow%Skipping restore point creation.%colorReset%
    goto main
)

echo %colorGreen%Creating system restore point...%colorReset%
reg.exe add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d "0" /f
powershell -Command "Checkpoint-Computer -Description 'Pre-Script Restore Point' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel%==0 (
    echo %colorGreen%Restore point created successfully.%colorReset%
) else (
    echo %colorRed%Failed to create restore point. Please check your system settings and try again.%colorReset%
)

:main
cls
echo.
echo %colorMauve% ──────────────────────────────────────────────────────────────────────%colorReset%
echo %colorMauve% │%colorMauve% Inspired by every "Win Tweaker", this script reveals a simpler way %colorMauve%│%colorReset%
echo %colorMauve% ──────────────────────────────────────────────────────────────────────%colorReset%
echo %colorMauve% │%colorText% [1] Apply Performance Tweaks                                       %colorMauve%│%colorReset%
echo %colorMauve% │%colorText% [2] Custom GPU and RAM Tweaks                                      %colorMauve%│%colorReset%
echo %colorMauve% │%colorText% [3] Free Up Space                                                  %colorMauve%│%colorReset%
echo %colorMauve% │%colorText% [4] Launch WinUtil - Install Programs and Tweaks                   %colorMauve%│%colorReset%
echo %colorMauve% │%colorText% [5] Privacy.Sexy - Create a personal batch in clicks               %colorMauve%│%colorReset%
echo %colorMauve% │%colorText% [6] Exit                                                           %colorMauve%│%colorReset%
echo %colorMauve% ──────────────────────────────────────────────────────────────────────%colorReset%
choice /C 123456 /N /M "%colorSapphire%>%colorReset%"
goto %errorlevel%

:1
cls
call :applyPerformanceTweaks
goto main

:2
cls
call :customGPUTweaks
goto main

:3
cls
call :freeUpSpace
goto main

:4
cls
call :launchWinUtil
goto main

:5
cls
call :launchPrivacySexy

:6
cls
exit

:applyPerformanceTweaks
:: Mouse & Keyboard Tweaks

:: These settings disable Enhance Pointer Precision, which increases pointer speed with mouse speed
:: This can be useful generally, but it causes cursor issues in games
:: It's recommended to disable this for gaming
call :setReg "HKCU\Control Panel\Mouse" "MouseSpeed" "0"
call :setReg "HKCU\Control Panel\Mouse" "MouseThreshold1" "0"
call :setReg "HKCU\Control Panel\Mouse" "MouseThreshold2" "0"

:: The MouseDataQueueSize and KeyboardDataQueueSize parameters set the number of events stored in the mouse and keyboard driver buffers
:: A smaller value means faster processing of new information
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataQueueSize" "20" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "KeyboardDataQueueSize" "20" REG_DWORD

:: Disable StickyKeys
:: These settings disable the annoying Sticky Keys feature when Shift is pressed repeatedly, and the delay in character input.
call :setReg "HKCU\Control Panel\Accessibility" "StickyKeys" "506"
call :setReg "HKCU\Control Panel\Accessibility\ToggleKeys" "Flags" "58"
call :setReg "HKCU\Control Panel\Accessibility\Keyboard Response" "DelayBeforeAcceptance" "0"
call :setReg "HKCU\Control Panel\Accessibility\Keyboard Response" "AutoRepeatRate" "0"
call :setReg "HKCU\Control Panel\Accessibility\Keyboard Response" "AutoRepeatDelay" "0"
call :setReg "HKCU\Control Panel\Accessibility\Keyboard Response" "Flags" "122"

:: GPU Tweaks
:: The HwSchMode parameter optimizes hardware-level computation scheduling (Hardware Accelerated GPU Scheduling), reducing latency on lower-end GPUs.
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" "2" REG_DWORD
call :setReg "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "EnablePreemption" "0" REG_DWORD

:: Network Tweaks

:: By default, Windows uses network throttling to limit non-multimedia traffic to 10 packets per millisecond (about 100 Mb/s).
:: This is to prioritize CPU access for multimedia applications, as processing network packets can be resource-intensive.
:: However, it's recommended to disable this setting, especially with gigabit networks, to avoid unnecessary interference.
call :setReg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" "ffffffff" REG_DWORD
call :setReg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" "10" REG_DWORD
call :setReg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NoLazyMode" "1" REG_DWORD

:: CPU Tweaks

:: LazyMode is a software flag that allows the system to skip some hardware events when CPU load is low.
:: Disabling it can use more resources for event processing, so we set the timer to a minimum of 1ms (10000ms).
call :setReg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "LazyModeTimeout" "10000" REG_DWORD

:: Power Tweaks

:: Power Throttling is a service that slows down background apps to save energy on laptops.
:: In this case, it's unnecessary, so it's recommended to disable it.
call :setReg "HKLM\SYSTEM\ControlSet001\Control\Power\PowerThrottling" "PowerThrottlingOff" "1" REG_DWORD
call :setReg "HKLM\System\CurrentControlSet\Control\Power" "EnergyEstimationEnabled" "0" REG_DWORD
call :setReg "HKLM\System\CurrentControlSet\Control\Power" "EventProcessorEnabled" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Power" "PlatformAoAcOverride" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Power" "CsEnabled" "0" REG_DWORD

:: Activate Hidden Ultimate Performance Power Plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee
powercfg -setactive eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee

:: Other Tweaks

:: Specify priority for services (drivers) to handle interrupts first.
:: Windows uses IRQL to determine interrupt priority. If an interrupt can be serviced, it starts execution.
:: Lower priority tasks are queued. This ensures critical services are prioritized for interrupts.
call :setReg "HKLM\SYSTEM\CurrentControlSet\services\DXGKrnl\Parameters" "ThreadPriority" "15" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\services\USBHUB3\Parameters" "ThreadPriority" "15" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\services\USBXHCI\Parameters" "ThreadPriority" "15" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "ThreadPriority" "31" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "ThreadPriority" "31" REG_DWORD

:: Set Priority For Programs Instead Of Background Services
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" "00000026" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" "IRQ8Priority" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" "IRQ16Priority" "2" REG_DWORD

:: Boot System & Software without limits
call :setReg "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" "Startupdelayinmsec" "0" REG_DWORD

:: Disable DistributeTimers
reg.exe delete "HKLM\SYSTEM\ControlSet001\Control\Session Manager\kernel" /v "DistributeTimers" /f

:: Boot Optimization
bcdedit /timeout 0
bcdedit /set quietboot yes
bcdedit /set {globalsettings} custom:16000067 true

:: Disable Kernel Mitigations
call :setReg "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" "MitigationOptions" "222222222222222222222222222222222222222222222222" REG_BINARY

:: Disable Automatic maintenance
call :setReg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" "MaintenanceDisabled" "1" REG_DWORD

:: Speed up start time
call :setReg "HKCU\AppEvents\Schemes" "" "" /f
call :setReg "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DelayedDesktopSwitchTimeout" "0" REG_DWORD

:: Disable ApplicationPreLaunch & Prefetch

:: The outdated Prefetcher and Superfetch services run in the background, analyzing loaded apps/libraries/services.
:: They cache repeated data to disk and then to RAM, speeding up app launches.
:: However, with an SSD, apps load quickly without this, so constant disk caching is unnecessary.
powershell Disable-MMAgent -ApplicationPreLaunch
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnablePrefetcher" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "SfTracingState" "0" REG_DWORD

:: Reducing time of disabling processes and menu
call :setReg "HKCU\Control Panel\Desktop" "AutoEndTasks" "1"
call :setReg "HKCU\Control Panel\Desktop" "HungAppTimeout" "1000"
call :setReg "HKCU\Control Panel\Desktop" "WaitToKillAppTimeout" "2000"
call :setReg "HKCU\Control Panel\Desktop" "LowLevelHooksTimeout" "1000"
call :setReg "HKCU\Control Panel\Desktop" "MenuShowDelay" "0"
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control" "WaitToKillServiceTimeout" "2000"

:: Memory Tweaks
:: Enabling Large System Cache makes the OS use all RAM for caching system files,
:: except 4MB reserved for disk cache, improving Windows responsiveness.
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "LargeSystemCache" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingCombining" "1" REG_DWORD

:: Enabling this parameter keeps the system kernel and drivers in RAM instead of the page file, improving responsiveness.
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingExecutive" "1" REG_DWORD

goto :eof

:customGPUTweaks
cls
echo What size of RAM do you have?
echo.
echo [1] 4GB
echo [2] 6GB
echo [3] 8GB
echo [4] 16GB
echo [5] 32GB
echo [6] 64GB
echo [7] Skip if Unsure
choice /C 1234567 /N /M "> "
if errorlevel 7 goto main
call :setRAMSize %errorlevel%

:setRAMSize
set "ramSize=%1"
set "svcHostThreshold="
if !ramSize! == 1 set "svcHostThreshold=68764420"
if !ramSize! == 2 set "svcHostThreshold=103355478"
if !ramSize! == 3 set "svcHostThreshold=137922056"
if !ramSize! == 4 set "svcHostThreshold=376926742"
if !ramSize! == 5 set "svcHostThreshold=861226034"
if !ramSize! == 6 set "svcHostThreshold=1729136740"

if defined svcHostThreshold (
    call :setReg "HKLM\SYSTEM\ControlSet001\Control" "SvcHostSplitThresholdInKB" "!svcHostThreshold!" REG_DWORD
    echo Successfully applied tweak for !ramSize!GB RAM.
) else (
    echo Invalid selection.
)
pause
goto next

:next
cls
echo What kind of video card do you have?
echo.
echo [1] NVIDIA
echo [2] AMD
echo.
echo [3] Skip if Unsure
echo.
choice /C 123 /N /M "> "
if errorlevel 3 goto main
if errorlevel 2 goto amd
if errorlevel 1 goto nvidia

:nvidia
:: NVIDIA GPU Tweaks
call :setReg "HKCU\SOFTWARE\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" "NvCplUseColorCorrection" "0" REG_DWORD
call :setReg "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" "EnableRID44231" "0" REG_DWORD
call :setReg "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" "EnableRID64640" "0" REG_DWORD
call :setReg "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" "EnableRID66610" "0" REG_DWORD
call :setReg "HKLM\SOFTWARE\NVIDIA Corporation\Global\Startup\SendTelemetryData" "0" REG_DWORD
call :setReg "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" "OptInOrOutPreference" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "PlatformSupportMiracast" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "RmGpsPsEnablePerCpuCoreDpc" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Power" "RmGpsPsEnablePerCpuCoreDpc" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" "ComputePreemption" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" "DisableCudaContextPreemption" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" "DisablePreemption" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" "DisablePreemptionOnS3S4" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" "EnableCEPreemption" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" "EnableTiledDisplay" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" "RmGpsPsEnablePerCpuCoreDpc" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" "EnableRID61684" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" "EnableRID73779" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" "EnableRID73780" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" "EnableRID74361" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" "RmGpsPsEnablePerCpuCoreDpc" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\Startup" "SendTelemetryData" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\NVAPI" "RmGpsPsEnablePerCpuCoreDpc" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" "ThreadPriority" "31" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\services\NvTelemetryContainer" "Start" "4" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "D3PCLatency" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "F1TransitionLatency" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "LOWLATENCY" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "Node3DLowLatency" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PciLatencyTimerControl" "20" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "RMDeepL1EntryLatencyUsec" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "RMLpwrEiIdleThresholdUs" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "RMLpwrGrIdleThresholdUs" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "RMLpwrGrRgIdleThresholdUs" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "RMLpwrMsIdleThresholdUs" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "RmGspcMaxFtuS" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "RmGspcMinFtuS" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "RmGspcPerioduS" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "TCCSupported" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "VRDirectFlipDPCDelayUs" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "VRDirectFlipTimingMarginUs" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "VRDirectJITFlipMsHybridFlipDelayUs" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "vrrCursorMarginUs" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "vrrDeflickerMarginUs" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "vrrDeflickerMaxUs" "1" REG_DWORD
goto main

:amd
:: AMD GPU Tweaks
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DalAllowDPrefSwitchingForGLSync" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DalAllowDirectMemoryAccessTrig" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableBlockWrite" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableDMACopy" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableDrmdmaPowerGating" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableEarlySamuInit" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableFBCForFullScreenApp" "0" REG_SZ
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableFBCSupport" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisablePowerGating" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableSAMUPowerGating" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableUVDPowerGatingDynamic" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "DisableVCEPowerGating" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "EnableUlps" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "EnableUvdClockGating" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "EnableVceSwClockGating" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "GCOOPTION_DisableGPIOPowerSaveMode" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "KMD_DeLagEnabled" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "KMD_EnableComputePreemption" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "KMD_FRTEnabled" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "KMD_MaxUVDSessions" "32" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PP_ActivityTarget" "30" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PP_AllGraphicLevel_DownHyst" "20" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PP_AllGraphicLevel_UpHyst" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PP_GPUPowerDownEnabled" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PP_MCLKStutterModeThreshold" "4096" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PP_ODNFeatureEnable" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PP_SclkDeepSleepDisable" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "PP_ThermalAutoThrottlingEnable" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "StutterMode" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "TVEnableOverscan" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" "WmAgpMaxIdleClk" "32" REG_DWORD
goto main

:freeUpSpace
:: Disable Reserved Storage
dism /Online /Set-ReservedStorageState /State:Disabled

:: Cleanup WinSxS
dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase /RestoreHealth

:: Remove Virtual Memory
wmic pagefileset delete

:: Clear Windows Update Folder
net stop wuauserv
rd /s /q %systemdrive%\SoftwareDistribution
md %systemdrive%\SoftwareDistribution
net start wuauserv

goto main

:launchWinUtil
cls
start cmd /c powershell -Command "irm 'https://christitus.com/win' | iex"
goto main

:launchPrivacySexy
cls
start "" "https://privacy.sexy/"
echo Recommended to set a Standard option if you are not sure what to do
pause
goto main

:setReg
set "key=%~1"
set "valueName=%~2"
set "value=%~3"
set "type=%~4"
if "%type%"=="" set "type=REG_SZ"
reg.exe add "%key%" /v "%valueName%" /t "%type%" /d "%value%" /f
exit /b