@echo off
setlocal EnableDelayedExpansion
net session >nul 2>&1 || (powershell start -verb runas '%~0' & exit)
set "dw=REG_DWORD"
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
echo %cMauve% '%cGrey% [6] Exit                                               %cMauve%'%cReset%
echo %cMauve% +--------------------------------------------------------+%cReset%
choice /C 123456 /N /M "%cSapphire%>%cReset%"
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
echo Please wait before winget will get updated..
winget install winget
call :wingetInstall

:6
cls
exit

:restoreSuggestion
echo %cGrey%Checking for existing 'Pre-Script Restore Point'...%cReset%
for /f "usebackq delims=" %%i in (`powershell -Command "Get-ComputerRestorePoint | Where-Object { $_.Description -eq 'Pre-Script Restore Point' } | Measure-Object -Property Description | Select-Object -ExpandProperty Count"`) do (
    if %%i gtr 0 (
        echo %cGrey%A 'Pre-Script Restore Point' already exists. Skipping restore point creation.%cReset%
        goto applyTweaks
    )
)

echo %cGrey%Would you like to create a system restore point before proceeding?%cReset%
choice /C 12 /N /M "[1] Yes or [2] No : "
if %errorlevel%==2 goto applyTweaks

echo %cGrey%Creating system restore point...%cReset%
reg.exe add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t %dw% /d "0" /f
powershell -Command "Checkpoint-Computer -Description 'Pre-Script Restore Point' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel%==0 (
    echo %cGrey%Restore point created successfully.%cReset%
) else (
    echo %cRed%Failed to create restore point. Please check your system settings and try again.%cReset%
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

:: Set ANSI, OEM and MAC Code Page to UTF-8
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Nls\CodePage" /v ACP /t REG_SZ /d 65001 /f

:: Mouse & Keyboard Tweaks
call :reg "%pMouse%" "MouseSpeed" "0"
call :reg "%pMouse%" "MouseThreshold1" "0"
call :reg "%pMouse%" "MouseThreshold2" "0"
call :reg "%pMouclass%" "MouseDataQueueSize" %dw% "20"
call :reg "%pKbdclass%" "KeyboardDataQueueSize" %dw% "20"

:: Disable StickyKeys
call :reg "%pAccessibility%" "StickyKeys" "506"
call :reg "%pAccessibility%\ToggleKeys" "Flags" "58"
call :reg "%pAccessibility%\Keyboard Response" "DelayBeforeAcceptance" "0"
call :reg "%pAccessibility%\Keyboard Response" "AutoRepeatRate" "0"
call :reg "%pAccessibility%\Keyboard Response" "AutoRepeatDelay" "0"
call :reg "%pAccessibility%\Keyboard Response" "Flags" "122"

:: GPU Tweaks
call :reg "%pGraphicsDrivers%" "HwSchMode" %dw% "2"
call :reg "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "EnablePreemption" %dw% "0"

:: Network Tweaks
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f
call :reg "%pMultimedia%" "SystemResponsiveness" %dw% "10"
call :reg "%pMultimedia%" "NoLazyMode" %dw% "1"

:: CPU Tweaks
call :reg "%pMultimedia%" "LazyModeTimeout" %dw% "10000"

:: Power Tweaks
call :reg "%pPower%" "PowerThrottlingOff" %dw% "1"
call :reg "%pPower%" "EnergyEstimationEnabled" %dw% "0"
call :reg "%pPower%" "EventProcessorEnabled" %dw% "0"
call :reg "%pPower%" "PlatformAoAcOverride" %dw% "0"
call :reg "%pPower%" "CsEnabled" %dw% "0"

:: Activate Hidden Ultimate Performance Power Plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee
powercfg -setactive eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee

:: Other Tweaks
call :reg "%pDXGKrnl%\Parameters" "ThreadPriority" %dw% "15"
call :reg "HKLM\SYSTEM\CurrentControlSet\services\USBHUB3\Parameters" "ThreadPriority" %dw% "15"
call :reg "HKLM\SYSTEM\CurrentControlSet\services\USBXHCI\Parameters" "ThreadPriority" %dw% "15"
call :reg "%pMouclass%" "ThreadPriority" %dw% "31"
call :reg "%pKbdclass%" "ThreadPriority" %dw% "31"

reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 0x00000024 /f
call :reg "%pPriorityControl%" "IRQ8Priority" %dw% "1"
call :reg "%pPriorityControl%" "IRQ16Priority" %dw% "2"

call :reg "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" "Startupdelayinmsec" %dw% "0"

:: Boot Optimization
bcdedit /timeout 0
bcdedit /set quietboot yes
bcdedit /set {globalsettings} custom:16000067 true

:: Disable Kernel Mitigations
call :reg "HKLM\System\CurrentControlSet\Control\Session Manager\kernel" "MitigationOptions" REG_BINARY "222222222222222222222222222222222222222222222222"

:: Disable Automatic maintenance
call :reg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" "MaintenanceDisabled" %dw% "1"

:: Speed up start time
call :reg "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DelayedDesktopSwitchTimeout" %dw% "0"

:: Disable ApplicationPreLaunch & Prefetch
powershell Disable-MMAgent -ApplicationPreLaunch
call :reg "%pMemoryManagement%\PrefetchParameters" "EnablePrefetcher" %dw% "0"
call :reg "%pMemoryManagement%\PrefetchParameters" "SfTracingState" %dw% "0"

:: Reducing time of disabling processes and menu
call :reg "%pDesktop%" "AutoEndTasks" "1"
call :reg "%pDesktop%" "HungAppTimeout" "1000"
call :reg "%pDesktop%" "WaitToKillAppTimeout" "2000"
call :reg "%pDesktop%" "LowLevelHooksTimeout" "1000"
call :reg "%pDesktop%" "MenuShowDelay" "0"
call :reg "HKLM\SYSTEM\CurrentControlSet\Control" "WaitToKillServiceTimeout" "2000"

:: Memory Tweaks
call :reg "%pMemoryManagement%" "LargeSystemCache" %dw% "1"
call :reg "%pMemoryManagement%" "DisablePagingCombining" %dw% "1"
call :reg "%pMemoryManagement%" "DisablePagingExecutive" %dw% "1"

:: DirectX Tweaks
call :reg "%pDXGKrnl%" "CreateGdiPrimaryOnSlaveGPU" %dw% "1"
call :reg "%pDXGKrnl%" "DriverSupportsCddDwmInterop" %dw% "1"
call :reg "%pDXGKrnl%" "DxgkCddSyncDxAccess" %dw% "1"
call :reg "%pDXGKrnl%" "DxgkCddSyncGPUAccess" %dw% "1"
call :reg "%pDXGKrnl%" "DxgkCddWaitForVerticalBlankEvent" %dw% "1"
call :reg "%pDXGKrnl%" "DxgkCreateSwapChain" %dw% "1"
call :reg "%pDXGKrnl%" "DxgkFreeGpuVirtualAddress" %dw% "1"
call :reg "%pDXGKrnl%" "DxgkOpenSwapChain" %dw% "1"
call :reg "%pDXGKrnl%" "DxgkShareSwapChainObject" %dw% "1"
call :reg "%pDXGKrnl%" "DxgkWaitForVerticalBlankEvent" %dw% "1"
call :reg "%pDXGKrnl%" "DxgkWaitForVerticalBlankEvent2" %dw% "1"
call :reg "%pDXGKrnl%" "SwapChainBackBuffer" %dw% "1"
call :reg "%pDXGKrnl%" "TdrResetFromTimeoutAsync" %dw% "1"

call :reg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" "SerializeTimerExpiration" %dw% "1"
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
    call :reg "HKLM\SYSTEM\ControlSet001\Control" "SvcHostSplitThresholdInKB" %dw% "!svcHostThreshold!"
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
call :reg "HKCU\SOFTWARE\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\c" "NvCplUsecCorrection" %dw% "0"
call :reg "%pFTS%" "EnableRID44231" %dw% "0"
call :reg "%pFTS%" "EnableRID64640" %dw% "0"
call :reg "%pFTS%" "EnableRID66610" %dw% "0"
call :reg "HKLM\SOFTWARE\NVIDIA Corporation\Global\Startup\SendTelemetryData" %dw% "0"
call :reg "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" "OptInOrOutPreference" %dw% "0"
call :reg "%pGraphicsDrivers%" "PlatformSupportMiracast" %dw% "0"
call :reg "%pGraphicsDrivers%" "RmGpsPsEnablePerCpuCoreDpc" %dw% "1"
call :reg "%pGraphicsDrivers%\Power" "RmGpsPsEnablePerCpuCoreDpc" %dw% "1"
call :reg "%pNvlddmkm%" "ComputePreemption" %dw% "0"
call :reg "%pNvlddmkm%" "DisableCudaContextPreemption" %dw% "1"
call :reg "%pNvlddmkm%" "DisablePreemption" %dw% "1"
call :reg "%pNvlddmkm%" "DisablePreemptionOnS3S4" %dw% "1"
call :reg "%pNvlddmkm%" "EnableCEPreemption" %dw% "0"
call :reg "%pNvlddmkm%" "EnableTiledDisplay" %dw% "0"
call :reg "%pNvlddmkm%" "RmGpsPsEnablePerCpuCoreDpc" %dw% "1"
call :reg "%pNvlddmkm%\FTS" "EnableRID61684" %dw% "1"
call :reg "%pNvlddmkm%\FTS" "EnableRID73779" %dw% "1"
call :reg "%pNvlddmkm%\FTS" "EnableRID73780" %dw% "1"
call :reg "%pNvlddmkm%\FTS" "EnableRID74361" %dw% "1"
call :reg "%pNvlddmkm%\Global\NVTweak" "RmGpsPsEnablePerCpuCoreDpc" %dw% "1"
call :reg "%pNvlddmkm%\Global\Startup" "SendTelemetryData" %dw% "0"
call :reg "%pNvlddmkm%\NVAPI" "RmGpsPsEnablePerCpuCoreDpc" %dw% "1"
call :reg "%pNvlddmkm%\Parameters" "ThreadPriority" %dw% "31"
call :reg "%pClass%" "D3PCLatency" %dw% "1"
call :reg "%pClass%" "F1TransitionLatency" %dw% "1"
call :reg "%pClass%" "LOWLATENCY" %dw% "1"
call :reg "%pClass%" "Node3DLowLatency" %dw% "1"
call :reg "%pClass%" "PciLatencyTimerControl" %dw% "20"
call :reg "%pClass%" "RMDeepL1EntryLatencyUsec" %dw% "1"
call :reg "%pClass%" "RMLpwrEiIdleThresholdUs" %dw% "1"
call :reg "%pClass%" "RMLpwrGrIdleThresholdUs" %dw% "1"
call :reg "%pClass%" "RMLpwrGrRgIdleThresholdUs" %dw% "1"
call :reg "%pClass%" "RMLpwrMsIdleThresholdUs" %dw% "1"
call :reg "%pClass%" "RmGspcMaxFtuS" %dw% "1"
call :reg "%pClass%" "RmGspcMinFtuS" %dw% "1"
call :reg "%pClass%" "RmGspcPerioduS" %dw% "1"
call :reg "%pClass%" "TCCSupported" %dw% "0"
call :reg "%pClass%" "VRDirectFlipDPCDelayUs" %dw% "1"
call :reg "%pClass%" "VRDirectFlipTimingMarginUs" %dw% "1"
call :reg "%pClass%" "VRDirectJITFlipMsHybridFlipDelayUs" %dw% "1"
call :reg "%pClass%" "vrrCursorMarginUs" %dw% "1"
call :reg "%pClass%" "vrrDeflickerMarginUs" %dw% "1"
call :reg "%pClass%" "vrrDeflickerMaxUs" %dw% "1"
cls
echo Successfully applied NVIDIA tweaks
pause
goto main

:amd
call :reg "%pClass%" "AllowRSOverlay" "false" REG_SZ
call :reg "%pClass%" "AllowSkins" "false" REG_SZ
call :reg "%pClass%" "AllowSnapshot" %dw% "0"
call :reg "%pClass%" "AllowSubscription" %dw% "0"
call :reg "%pClass%" "AutocDepthReduction_NA" %dw% "0"
call :reg "%pClass%" "BGM_LTRMaxNoSnoopLatencyValue" %dw% "1"
call :reg "%pClass%" "BGM_LTRMaxSnoopLatencyValue" %dw% "1"
call :reg "%pClass%" "BGM_LTRNoSnoopL0Latency" %dw% "1"
call :reg "%pClass%" "BGM_LTRNoSnoopL1Latency" %dw% "1"
call :reg "%pClass%" "BGM_LTRSnoopL0Latency" %dw% "1"
call :reg "%pClass%" "BGM_LTRSnoopL1Latency" %dw% "1"
call :reg "%pClass%" "DalAllowDPrefSwitchingForGLSync" %dw% "0"
call :reg "%pClass%" "DalAllowDirectMemoryAccessTrig" %dw% "1"
call :reg "%pClass%" "DalNBLatencyForUnderFlow" %dw% "1"
call :reg "%pClass%" "DalUrgentLatencyNs" %dw% "1"
call :reg "%pClass%" "DisableBlockWrite" %dw% "0"
call :reg "%pClass%" "DisableDMACopy" %dw% "1"
call :reg "%pClass%" "DisableDrmdmaPowerGating" %dw% "1"
call :reg "%pClass%" "DisableEarlySamuInit" %dw% "1"
call :reg "%pClass%" "DisableFBCForFullScreenApp" "0" REG_SZ
call :reg "%pClass%" "DisableFBCSupport" %dw% "0"
call :reg "%pClass%" "DisablePowerGating" %dw% "1"
call :reg "%pClass%" "DisableSAMUPowerGating" %dw% "1"
call :reg "%pClass%" "DisableUVDPowerGatingDynamic" %dw% "1"
call :reg "%pClass%" "DisableVCEPowerGating" %dw% "1"
call :reg "%pClass%" "EnableUlps" %dw% "0"
call :reg "%pClass%" "EnableUvdClockGating" %dw% "1"
call :reg "%pClass%" "EnableVceSwClockGating" %dw% "1"
call :reg "%pClass%" "GCOOPTION_DisableGPIOPowerSaveMode" %dw% "1"
call :reg "%pClass%" "KMD_DeLagEnabled" %dw% "0"
call :reg "%pClass%" "KMD_EnableComputePreemption" %dw% "0"
call :reg "%pClass%" "KMD_FRTEnabled" %dw% "0"
call :reg "%pClass%" "KMD_MaxUVDSessions" %dw% "32"
call :reg "%pClass%" "KMD_RpmComputeLatency" %dw% "1"
call :reg "%pClass%" "LTRMaxNoSnoopLatency" %dw% "1"
call :reg "%pClass%" "LTRNoSnoopL1Latency" %dw% "1"
call :reg "%pClass%" "LTRSnoopL0Latency" %dw% "1"
call :reg "%pClass%" "LTRSnoopL1Latency" %dw% "1"
call :reg "%pClass%" "PP_ActivityTarget" %dw% "30"
call :reg "%pClass%" "PP_AllGraphicLevel_DownHyst" %dw% "20"
call :reg "%pClass%" "PP_AllGraphicLevel_UpHyst" %dw% "0"
call :reg "%pClass%" "PP_DGBMMMaxTransitionLatencyUvd" %dw% "1"
call :reg "%pClass%" "PP_DGBPMMaxTransitionLatencyGfx" %dw% "1"
call :reg "%pClass%" "PP_GPUPowerDownEnabled" %dw% "0"
call :reg "%pClass%" "PP_MCLKStutterModeThreshold" %dw% "4096"
call :reg "%pClass%" "PP_ODNFeatureEnable" %dw% "1"
call :reg "%pClass%" "PP_RTPMComputeF1Latency" %dw% "1"
call :reg "%pClass%" "PP_SclkDeepSleepDisable" %dw% "1"
call :reg "%pClass%" "PP_ThermalAutoThrottlingEnable" %dw% "0"
call :reg "%pClass%" "StutterMode" %dw% "0"
call :reg "%pClass%" "TVEnableOverscan" %dw% "0"
call :reg "%pClass%" "WmAgpMaxIdleClk" %dw% "32"
cls
echo Successfully applied AMD tweaks
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
goto main

:wingetInstall
cls
echo %cMauve% --------------------------------------------------------%cReset%
echo %cMauve% '%cGreen% Browsers:                                             %cMauve%'%cReset%
echo %cMauve% '%cGrey% [1] Arc                  [2] Zen                      %cMauve%'%cReset%
echo %cMauve% '%cGrey% [3] Thorium              [4] Yandex                   %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Social Media:                                         %cMauve%'%cReset%
echo %cMauve% '%cGrey% [5] AyuGram              [6] Vesktop                  %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Utilities:                                            %cMauve%'%cReset%
echo %cMauve% '%cGrey% [7] UniGetUI             [8] NanaZip                  %cMauve%'%cReset%
echo %cMauve% '%cGrey% [9]                      [10] NVIDIA Broadcast        %cMauve%'%cReset%
echo %cMauve% '%cGrey% [11] NVCleanstall                                     %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Productivity:                                         %cMauve%'%cReset%
echo %cMauve% '%cGrey% [12] ChatGPT             [13] Todoist                 %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Games:                                                %cMauve%'%cReset%
echo %cMauve% '%cGrey% [14] Steam                                            %cMauve%'%cReset%
echo.
echo %cMauve% '%cGreen% Coding:                                               %cMauve%'%cReset%
echo %cMauve% '%cGrey% [15] Python              [16] Cursor                  %cMauve%'%cReset%
echo %cMauve% '%cGrey% [17] Node.js             [18] Visual Studio Code      %cMauve%'%cReset%
echo.
echo %cMauve% '%cGrey% [19] Exit                                             %cMauve%'%cReset%
echo %cMauve% '%cGrey% [20] Search and Install a Package                     %cMauve%'%cReset%
echo %cMauve% --------------------------------------------------------%cReset%
set /p choice="%cSapphire%Select an application to install: %cReset%"

set /a isValid=0
for /l %%i in (1,1,20) do (
    if "%choice%"=="%%i" set /a isValid=1
)
if %isValid%==0 (
    goto wingetInstall
)

if "!choice!"=="1"  (winget install TheBrowserCompany.Arc)
if "!choice!"=="2"  (winget install Zen-Team.Zen-Browser)
if "!choice!"=="3"  (winget install Thorium)
if "!choice!"=="4"  (winget install Yandex.Browser)
if "!choice!"=="5"  (winget install RadolynLabs.AyuGramDesktop)
if "!choice!"=="6"  (winget install Vencord.Vesktop)
if "!choice!"=="7"  (winget install MartiCliment.UniGetUI)
if "!choice!"=="8"  (winget install M2Team.NanaZip)
if "!choice!"=="10" (winget install NVIDIA.Broadcast)
if "!choice!"=="11" (winget install NVCleanstall)
if "!choice!"=="12" (winget install lencx.ChatGPT)
if "!choice!"=="13" (winget install Doist.Todoist)
if "!choice!"=="14" (winget install Valve.Steam)
if "!choice!"=="15" (winget install Python)
if "!choice!"=="16" (winget install Anysphere.Cursor)
if "!choice!"=="17" (winget install OpenJS.NodeJS)
if "!choice!"=="18" (winget install Microsoft.VisualStudioCode)
if "!choice!"=="19" (goto main)
if "!choice!"=="20" (
    cls
    echo Name of the program? (or type exit)
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

goto wingetInstall

:reg
set "key=%~1"
set "valueName=%~2"
set "type=%~3"
set "value=%~4"
if "%type%"=="" set "type=REG_SZ"
reg.exe add "%key%" /v "%valueName%" /t "%type%" /d "%value%" /f
if errorlevel 1 (
    echo Error: Failed to add registry key "%key%" with value "%valueName%".
    goto :eof
)