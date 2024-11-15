@echo off
setlocal EnableDelayedExpansion
net session >nul 2>&1 || (powershell start -verb runas '%~0' & exit)
set "dw=REG_DWORD"
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

cls
echo.
echo.
echo %colorRosewater%   "Before using any of the options, please make a system restore point,%colorReset%
echo %colorRosewater%   I do not take any responsibility if you break your system, lose data,%colorReset%
echo %colorRosewater%   or have a performance decrease, thank you for understanding"%colorReset%
echo.
echo %colorFlamingo%   I tried as hard as possible to make the script universal for everyone!%colorReset%
echo.
echo.
set /p=%colorText%Press any key to continue...%colorReset%

:main
cls
echo.
echo %colorMauve% ──────────────────────────────────────────────────────────────────────%colorReset%
echo %colorMauve% │%colorMauve% Inspired by every "Win Tweaker", this script reveals a simpler way %colorMauve%│%colorReset%
echo %colorMauve% ──────────────────────────────────────────────────────────────────────%colorReset%
echo %colorMauve% │%colorText% [1] Apply Performance Tweaks                                       %colorMauve%│%colorReset%
echo %colorMauve% │%colorText% [2] Free Up Space                                                  %colorMauve%│%colorReset%
echo %colorMauve% │%colorText% [3] Launch WinUtil - Install Programs and Tweaks                   %colorMauve%│%colorReset%
echo %colorMauve% │%colorText% [4] Privacy.Sexy - Create a personal batch in clicks               %colorMauve%│%colorReset%
echo %colorMauve% │%colorText% [5] Exit                                                           %colorMauve%│%colorReset%
echo %colorMauve% ──────────────────────────────────────────────────────────────────────%colorReset%
choice /C 123456 /N /M "%colorSapphire%>%colorReset%"
goto %errorlevel%

:1
cls
call :restoreSuggestion

:2
cls
call :freeUpSpace

:3
cls
call :launchWinUtil

:4
cls
call :launchPrivacySexy

:5
cls
exit

:restoreSuggestion
echo %colorText%Checking for existing 'Pre-Script Restore Point'...%colorReset%
for /f "usebackq delims=" %%i in (`powershell -Command "Get-ComputerRestorePoint | Where-Object { $_.Description -eq 'Pre-Script Restore Point' } | Measure-Object -Property Description | Select-Object -ExpandProperty Count"`) do (
    if %%i gtr 0 (
        echo %colorYellow%A 'Pre-Script Restore Point' already exists. Skipping restore point creation.%colorReset%
        goto applyTweaks
    )
)

echo %colorText%Would you like to create a system restore point before proceeding?%colorReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==2 goto applyTweaks

echo %colorText%Creating system restore point...%colorReset%
reg.exe add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t %dw% /d "0" /f
powershell -Command "Checkpoint-Computer -Description 'Pre-Script Restore Point' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel%==0 (
    echo %colorText%Restore point created successfully.%colorReset%
) else (
    echo %colorRed%Failed to create restore point. Please check your system settings and try again.%colorReset%
)

:applyTweaks

set "pMouse=HKCU\Control Panel\Mouse"
set "pMouclass=HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters"
set "pKbdclass=HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters"
set "pAccessibility=HKCU\Control Panel\Accessibility"
set "pGraphicsDrivers=HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
set "pMultimedia=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
set "pPower=HKLM\SYSTEM\CurrentControlSet\Control\Power"
set "pMemoryManagement=HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
set "pDesktop=HKCU\Control Panel\Desktop"
set "pDXGKrnl=HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl"
set "pPriorityControl=HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl"
set "pNvlddmkm=HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm"
set "pFTS=HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS"
set "pClass=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000"

cls

:: Mouse & Keyboard Tweaks
call :reg "%pMouse%" "MouseSpeed" "0"
call :reg "%pMouse%" "MouseThreshold1" "0"
call :reg "%pMouse%" "MouseThreshold2" "0"
call :reg "%pMouclass%" "MouseDataQueueSize" "20" %dw%
call :reg "%pKbdclass%" "KeyboardDataQueueSize" "20" %dw%

:: Disable StickyKeys
call :reg "%pAccessibility%" "StickyKeys" "506"
call :reg "%pAccessibility%\ToggleKeys" "Flags" "58"
call :reg "%pAccessibility%\Keyboard Response" "DelayBeforeAcceptance" "0"
call :reg "%pAccessibility%\Keyboard Response" "AutoRepeatRate" "0"
call :reg "%pAccessibility%\Keyboard Response" "AutoRepeatDelay" "0"
call :reg "%pAccessibility%\Keyboard Response" "Flags" "122"

:: GPU Tweaks
call :reg "%pGraphicsDrivers%" "HwSchMode" "2" %dw%
call :reg "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "EnablePreemption" "0" %dw%

:: Network Tweaks
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f
call :reg "%pMultimedia%" "SystemResponsiveness" "10" %dw%
call :reg "%pMultimedia%" "NoLazyMode" "1" %dw%

:: CPU Tweaks
call :reg "%pMultimedia%" "LazyModeTimeout" "10000" %dw%

:: Power Tweaks
call :reg "%pPower%" "PowerThrottlingOff" "1" %dw%
call :reg "%pPower%" "EnergyEstimationEnabled" "0" %dw%
call :reg "%pPower%" "EventProcessorEnabled" "0" %dw%
call :reg "%pPower%" "PlatformAoAcOverride" "0" %dw%
call :reg "%pPower%" "CsEnabled" "0" %dw%

:: Activate Hidden Ultimate Performance Power Plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee
powercfg -setactive eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee

:: Other Tweaks
call :reg "%pDXGKrnl%\Parameters" "ThreadPriority" "15" %dw%
call :reg "HKLM\SYSTEM\CurrentControlSet\services\USBHUB3\Parameters" "ThreadPriority" "15" %dw%
call :reg "HKLM\SYSTEM\CurrentControlSet\services\USBXHCI\Parameters" "ThreadPriority" "15" %dw%
call :reg "%pMouclass%" "ThreadPriority" "31" %dw%
call :reg "%pKbdclass%" "ThreadPriority" "31" %dw%

reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 0x00000024 /f
call :reg "%pPriorityControl%" "IRQ8Priority" "1" %dw%
call :reg "%pPriorityControl%" "IRQ16Priority" "2" %dw%

call :reg "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" "Startupdelayinmsec" "0" %dw%

:: Boot Optimization
bcdedit /timeout 0
bcdedit /set quietboot yes
bcdedit /set {globalsettings} custom:16000067 true

:: Disable Kernel Mitigations
call :reg "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" "MitigationOptions" "222222222222222222222222222222222222222222222222" REG_BINARY

:: Disable Automatic maintenance
call :reg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" "MaintenanceDisabled" "1" %dw%

:: Speed up start time
call :reg "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DelayedDesktopSwitchTimeout" "0" %dw%

:: Disable ApplicationPreLaunch & Prefetch
powershell Disable-MMAgent -ApplicationPreLaunch
call :reg "%pMemoryManagement%\PrefetchParameters" "EnablePrefetcher" "0" %dw%
call :reg "%pMemoryManagement%\PrefetchParameters" "SfTracingState" "0" %dw%

:: Reducing time of disabling processes and menu
call :reg %pDesktop% "AutoEndTasks" "1"
call :reg %pDesktop% "HungAppTimeout" "1000"
call :reg %pDesktop% "WaitToKillAppTimeout" "2000"
call :reg %pDesktop% "LowLevelHooksTimeout" "1000"
call :reg %pDesktop% "MenuShowDelay" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control" "WaitToKillServiceTimeout" "2000"

:: Memory Tweaks
call :reg "%pMemoryManagement%" "LargeSystemCache" "1" %dw%
call :reg "%pMemoryManagement%" "DisablePagingCombining" "1" %dw%
call :reg "%pMemoryManagement%" "DisablePagingExecutive" "1" %dw%

:: DirectX Tweaks
call :reg "%pDXGKrnl%" "CreateGdiPrimaryOnSlaveGPU" "1" %dw%
call :reg "%pDXGKrnl%" "DriverSupportsCddDwmInterop" "1" %dw%
call :reg "%pDXGKrnl%" "DxgkCddSyncDxAccess" "1" %dw%
call :reg "%pDXGKrnl%" "DxgkCddSyncGPUAccess" "1" %dw%
call :reg "%pDXGKrnl%" "DxgkCddWaitForVerticalBlankEvent" "1" %dw%
call :reg "%pDXGKrnl%" "DxgkCreateSwapChain" "1" %dw%
call :reg "%pDXGKrnl%" "DxgkFreeGpuVirtualAddress" "1" %dw%
call :reg "%pDXGKrnl%" "DxgkOpenSwapChain" "1" %dw%
call :reg "%pDXGKrnl%" "DxgkShareSwapChainObject" "1" %dw%
call :reg "%pDXGKrnl%" "DxgkWaitForVerticalBlankEvent" "1" %dw%
call :reg "%pDXGKrnl%" "DxgkWaitForVerticalBlankEvent2" "1" %dw%
call :reg "%pDXGKrnl%" "SwapChainBackBuffer" "1" %dw%
call :reg "%pDXGKrnl%" "TdrResetFromTimeoutAsync" "1" %dw%

call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "SerializeTimerExpiration" "1" %dw%
pause
cls
:: Detect RAM size using PowerShell and handle arithmetic in PowerShell
for /f "usebackq" %%i in (`powershell -Command "(Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1MB"`) do set ramSizeMB=%%i

set "svcHostThreshold="
set "ramSizeText="

if !ramSizeMB! lss 6144 (
    set "svcHostThreshold=68764420"
    set "ramSizeText=4GB"
) else if !ramSizeMB! lss 8192 (
    set "svcHostThreshold=103355478"
    set "ramSizeText=6GB"
) else if !ramSizeMB! lss 16384 (
    set "svcHostThreshold=137922056"
    set "ramSizeText=8GB"
) else if !ramSizeMB! lss 32768 (
    set "svcHostThreshold=376926742"
    set "ramSizeText=16GB"
) else if !ramSizeMB! lss 65536 (
    set "svcHostThreshold=861226034"
    set "ramSizeText=32GB"
) else (
    set "svcHostThreshold=1729136740"
    set "ramSizeText=64GB"
)

if defined svcHostThreshold (
    call :reg "HKLM\SYSTEM\ControlSet001\Control" "SvcHostSplitThresholdInKB" "!svcHostThreshold!" %dw%
    echo Successfully applied tweak for !ramSizeText! RAM.
) else (
    echo Could not determine RAM size.
)
pause
cls
:: Detect GPU type using PowerShell
set "gpuType="
for /f "usebackq" %%i in (`powershell -Command "Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name"`) do (
    echo %%i | findstr /i "NVIDIA" >nul && set "gpuType=NVIDIA"
    echo %%i | findstr /i "AMD" >nul && set "gpuType=AMD"
)

if "!gpuType!"=="NVIDIA" (
    goto nvidia
) else if "!gpuType!"=="AMD" (
    goto amd
) else (
    echo Could not determine GPU type. Skipping GPU tweaks.
    goto main
)

:nvidia
call :reg "HKCU\SOFTWARE\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" "NvCplUseColorCorrection" "0" %dw%
call :reg "%pFTS%" "EnableRID44231" "0" %dw%
call :reg "%pFTS%" "EnableRID64640" "0" %dw%
call :reg "%pFTS%" "EnableRID66610" "0" %dw%
call :reg "HKLM\SOFTWARE\NVIDIA Corporation\Global\Startup\SendTelemetryData" "0" %dw%
call :reg "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" "OptInOrOutPreference" "0" %dw%
call :reg "%pGraphicsDrivers%" "PlatformSupportMiracast" "0" %dw%
call :reg "%pGraphicsDrivers%" "RmGpsPsEnablePerCpuCoreDpc" "1" %dw%
call :reg "%pGraphicsDrivers%\Power" "RmGpsPsEnablePerCpuCoreDpc" "1" %dw%
call :reg "%pNvlddmkm%" "ComputePreemption" "0" %dw%
call :reg "%pNvlddmkm%" "DisableCudaContextPreemption" "1" %dw%
call :reg "%pNvlddmkm%" "DisablePreemption" "1" %dw%
call :reg "%pNvlddmkm%" "DisablePreemptionOnS3S4" "1" %dw%
call :reg "%pNvlddmkm%" "EnableCEPreemption" "0" %dw%
call :reg "%pNvlddmkm%" "EnableTiledDisplay" "0" %dw%
call :reg "%pNvlddmkm%" "RmGpsPsEnablePerCpuCoreDpc" "1" %dw%
call :reg "%pNvlddmkm%\FTS" "EnableRID61684" "1" %dw%
call :reg "%pNvlddmkm%\FTS" "EnableRID73779" "1" %dw%
call :reg "%pNvlddmkm%\FTS" "EnableRID73780" "1" %dw%
call :reg "%pNvlddmkm%\FTS" "EnableRID74361" "1" %dw%
call :reg "%pNvlddmkm%\Global\NVTweak" "RmGpsPsEnablePerCpuCoreDpc" "1" %dw%
call :reg "%pNvlddmkm%\Global\Startup" "SendTelemetryData" "0" %dw%
call :reg "%pNvlddmkm%\NVAPI" "RmGpsPsEnablePerCpuCoreDpc" "1" %dw%
call :reg "%pNvlddmkm%\Parameters" "ThreadPriority" "31" %dw%
call :reg "HKLM\SYSTEM\CurrentControlSet\services\NvTelemetryContainer" "Start" "4" %dw%
call :reg "%pClass%" "D3PCLatency" "1" %dw%
call :reg "%pClass%" "F1TransitionLatency" "1" %dw%
call :reg "%pClass%" "LOWLATENCY" "1" %dw%
call :reg "%pClass%" "Node3DLowLatency" "1" %dw%
call :reg "%pClass%" "PciLatencyTimerControl" "20" %dw%
call :reg "%pClass%" "RMDeepL1EntryLatencyUsec" "1" %dw%
call :reg "%pClass%" "RMLpwrEiIdleThresholdUs" "1" %dw%
call :reg "%pClass%" "RMLpwrGrIdleThresholdUs" "1" %dw%
call :reg "%pClass%" "RMLpwrGrRgIdleThresholdUs" "1" %dw%
call :reg "%pClass%" "RMLpwrMsIdleThresholdUs" "1" %dw%
call :reg "%pClass%" "RmGspcMaxFtuS" "1" %dw%
call :reg "%pClass%" "RmGspcMinFtuS" "1" %dw%
call :reg "%pClass%" "RmGspcPerioduS" "1" %dw%
call :reg "%pClass%" "TCCSupported" "0" %dw%
call :reg "%pClass%" "VRDirectFlipDPCDelayUs" "1" %dw%
call :reg "%pClass%" "VRDirectFlipTimingMarginUs" "1" %dw%
call :reg "%pClass%" "VRDirectJITFlipMsHybridFlipDelayUs" "1" %dw%
call :reg "%pClass%" "vrrCursorMarginUs" "1" %dw%
call :reg "%pClass%" "vrrDeflickerMarginUs" "1" %dw%
call :reg "%pClass%" "vrrDeflickerMaxUs" "1" %dw%
cls
echo Successfully applied NVIDIA tweaks
pause
goto main

:amd
:: source - https://www.youtube.com/watch?v=nuUV2RoPOWc&t=160s
call :reg "%pClass%" "AllowRSOverlay" "false" REG_SZ
call :reg "%pClass%" "AllowSkins" "false" REG_SZ
call :reg "%pClass%" "AllowSnapshot" "0" %dw%
call :reg "%pClass%" "AllowSubscription" "0" %dw%
call :reg "%pClass%" "AutoColorDepthReduction_NA" "0" %dw%
call :reg "%pClass%" "BGM_LTRMaxNoSnoopLatencyValue" "1" %dw%
call :reg "%pClass%" "BGM_LTRMaxSnoopLatencyValue" "1" %dw%
call :reg "%pClass%" "BGM_LTRNoSnoopL0Latency" "1" %dw%
call :reg "%pClass%" "BGM_LTRNoSnoopL1Latency" "1" %dw%
call :reg "%pClass%" "BGM_LTRSnoopL0Latency" "1" %dw%
call :reg "%pClass%" "BGM_LTRSnoopL1Latency" "1" %dw%
call :reg "%pClass%" "DalAllowDPrefSwitchingForGLSync" "0" %dw%
call :reg "%pClass%" "DalAllowDirectMemoryAccessTrig" "1" %dw%
call :reg "%pClass%" "DalNBLatencyForUnderFlow" "1" %dw%
call :reg "%pClass%" "DalUrgentLatencyNs" "1" %dw%
call :reg "%pClass%" "DisableBlockWrite" "0" %dw%
call :reg "%pClass%" "DisableDMACopy" "1" %dw%
call :reg "%pClass%" "DisableDrmdmaPowerGating" "1" %dw%
call :reg "%pClass%" "DisableEarlySamuInit" "1" %dw%
call :reg "%pClass%" "DisableFBCForFullScreenApp" "0" REG_SZ
call :reg "%pClass%" "DisableFBCSupport" "0" %dw%
call :reg "%pClass%" "DisablePowerGating" "1" %dw%
call :reg "%pClass%" "DisableSAMUPowerGating" "1" %dw%
call :reg "%pClass%" "DisableUVDPowerGatingDynamic" "1" %dw%
call :reg "%pClass%" "DisableVCEPowerGating" "1" %dw%
call :reg "%pClass%" "EnableUlps" "0" %dw%
call :reg "%pClass%" "EnableUvdClockGating" "1" %dw%
call :reg "%pClass%" "EnableVceSwClockGating" "1" %dw%
call :reg "%pClass%" "GCOOPTION_DisableGPIOPowerSaveMode" "1" %dw%
call :reg "%pClass%" "KMD_DeLagEnabled" "0" %dw%
call :reg "%pClass%" "KMD_EnableComputePreemption" "0" %dw%
call :reg "%pClass%" "KMD_FRTEnabled" "0" %dw%
call :reg "%pClass%" "KMD_MaxUVDSessions" "32" %dw%
call :reg "%pClass%" "KMD_RpmComputeLatency" "1" %dw%
call :reg "%pClass%" "LTRMaxNoSnoopLatency" "1" %dw%
call :reg "%pClass%" "LTRNoSnoopL1Latency" "1" %dw%
call :reg "%pClass%" "LTRSnoopL0Latency" "1" %dw%
call :reg "%pClass%" "LTRSnoopL1Latency" "1" %dw%
call :reg "%pClass%" "PP_ActivityTarget" "30" %dw%
call :reg "%pClass%" "PP_AllGraphicLevel_DownHyst" "20" %dw%
call :reg "%pClass%" "PP_AllGraphicLevel_UpHyst" "0" %dw%
call :reg "%pClass%" "PP_DGBMMMaxTransitionLatencyUvd" "1" %dw%
call :reg "%pClass%" "PP_DGBPMMaxTransitionLatencyGfx" "1" %dw%
call :reg "%pClass%" "PP_GPUPowerDownEnabled" "0" %dw%
call :reg "%pClass%" "PP_MCLKStutterModeThreshold" "4096" %dw%
call :reg "%pClass%" "PP_ODNFeatureEnable" "1" %dw%
call :reg "%pClass%" "PP_RTPMComputeF1Latency" "1" %dw%
call :reg "%pClass%" "PP_SclkDeepSleepDisable" "1" %dw%
call :reg "%pClass%" "PP_ThermalAutoThrottlingEnable" "0" %dw%
call :reg "%pClass%" "StutterMode" "0" %dw%
call :reg "%pClass%" "TVEnableOverscan" "0" %dw%
call :reg "%pClass%" "WmAgpMaxIdleClk" "32" %dw%
cls
echo Successfully applied AMD tweaks
pause
goto main

:freeUpSpace

:: Disable Reserved Storage
echo %colorText%Disabling Reserved Storage...%colorReset%
dism /Online /Set-ReservedStorageState /State:Disabled

:: Cleanup WinSxS
echo %colorText%Cleaning up WinSxS...%colorReset%
dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase /RestoreHealth

:: Remove Virtual Memory
echo.
echo %colorText%Would you like to remove Virtual Memory (pagefile.sys)?%colorReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if not errorlevel 1 (
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -Value ''
)

:: Clear Windows Update Folder
echo %colorText%Clearing Windows Update Folder...%colorReset%
net stop wuauserv
rd /s /q %systemdrive%\Windows\SoftwareDistribution
md %systemdrive%\Windows\SoftwareDistribution

:: Advanced disk cleaner
echo.
echo %colorText%Would you like to run the advanced disk cleaner?%colorReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if not errorlevel 1 (
    echo %colorText%Running advanced disk cleaner...%colorReset%
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
echo %colorText%Recommended to set a Standard option if you are not sure what to do%colorReset%
echo %colorText%and also dont forget to download revert version for your selected tweaks if anything can go wrong%colorReset%
goto main

:reg
set "key=%~1"
set "valueName=%~2"
set "value=%~3"
set "type=%~4"
if "%type%"=="" set "type=REG_SZ"
reg.exe add "%key%" /v "%valueName%" /t "%type%" /d "%value%" /f
if errorlevel 1 (
    echo Error: Failed to add registry key "%key%" with value "%valueName%".
    goto :eof
)