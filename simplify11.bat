@echo off
setlocal EnableDelayedExpansion
net session >nul 2>&1 || (powershell start -verb runas '%~0' & exit)
cls
title Simplify11
echo.
echo.
echo   "Before using any of the options, please make a system restore point,
echo   I do not take any responsibility if you break your system, lose data,
echo   or have a performance decrease, thank you for understanding"
echo.
echo   I tried as hard as possible to make the script universal for everyone!
echo.
echo.
pause

:backup
set /p backupChoice="Would you like to create a system restore point before proceeding? (Y/N): "
if /i "%backupChoice%"=="Y" (
    echo Creating system restore point...
    powershell -Command "Checkpoint-Computer -Description 'Pre-Script Restore Point' -RestorePointType 'MODIFY_SETTINGS'"
    if %errorlevel%==0 (
        echo Restore point created successfully.
    ) else (
        echo Failed to create restore point. Please check your system settings and try again.
    )
) else if /i "%backupChoice%"=="N" (
    echo Skipping restore point creation.
) else (
    echo Invalid choice. Please enter Y or N.
    goto backup
)

:main
cls
echo.
echo  ──────────────────────────────────────────────────────────────────────
echo  │ Inspired by every "Win Tweaker", this script reveals a simpler way │
echo  ──────────────────────────────────────────────────────────────────────
echo  │ [1] Apply Performance Tweaks                                       │
echo  │ [2] Custom GPU and RAM Tweaks                                      │
echo  │ [3] Free Up Space                                                  │
echo  │ [4] Launch WinUtil - Install Programs and Tweaks                   │
echo  │ [5] Exit                                                           │
echo  ──────────────────────────────────────────────────────────────────────
choice /C 12345 /N /M "Select an option: "
goto option%errorlevel%

:option1
call :applyPerformanceTweaks
goto main

:option2
call :customGPUTweaks
goto main

:option3
call :freeUpSpace
goto main

:option4
call :launchWinUtil
goto main

:option5
exit

:applyPerformanceTweaks
:: Mouse & Keyboard Tweaks
call :setReg "HKCU\Control Panel\Mouse" "MouseSpeed" "0"
call :setReg "HKCU\Control Panel\Mouse" "MouseThreshold1" "0"
call :setReg "HKCU\Control Panel\Mouse" "MouseThreshold2" "0"

:: Hardware Data Queue Size
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" "MouseDataQueueSize" "20" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" "KeyboardDataQueueSize" "20" REG_DWORD

:: Disable StickyKeys
call :setReg "HKCU\Control Panel\Accessibility" "StickyKeys" "506"
call :setReg "HKCU\Control Panel\Accessibility\ToggleKeys" "Flags" "58"
call :setReg "HKCU\Control Panel\Accessibility\Keyboard Response" "DelayBeforeAcceptance" "0"
call :setReg "HKCU\Control Panel\Accessibility\Keyboard Response" "AutoRepeatRate" "0"
call :setReg "HKCU\Control Panel\Accessibility\Keyboard Response" "AutoRepeatDelay" "0"
call :setReg "HKCU\Control Panel\Accessibility\Keyboard Response" "Flags" "122"

:: GPU Tweaks
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" "2" REG_DWORD
call :setReg "HKLM\SYSTEM\ControlSet001\Control\GraphicsDrivers\Scheduler" "EnablePreemption" "0" REG_DWORD

:: Network Tweaks
call :setReg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" "10" REG_DWORD
call :setReg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "SystemResponsiveness" "10" REG_DWORD
call :setReg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NoLazyMode" "1" REG_DWORD

:: CPU Tweaks
call :setReg "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "LazyModeTimeout" "10000" REG_DWORD

:: Power Tweaks
call :setReg "HKLM\SYSTEM\ControlSet001\Control\Power\PowerThrottling" "PowerThrottlingOff" "1" REG_DWORD
call :setReg "HKLM\System\CurrentControlSet\Control\Power" "EnergyEstimationEnabled" "0" REG_DWORD
call :setReg "HKLM\System\CurrentControlSet\Control\Power" "EventProcessorEnabled" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Power" "PlatformAoAcOverride" "0" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Power" "CsEnabled" "0" REG_DWORD

:: Disable USB Power Saving
for /f "tokens=*" %%i in ('wmic PATH Win32_PnPEntity GET DeviceID ^| findstr "USB\VID_"') do (
    call :setReg "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" "EnhancedPowerManagementEnabled" "0" REG_DWORD
    call :setReg "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" "AllowIdleIrpInD3" "0" REG_DWORD
    call :setReg "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" "EnableSelectiveSuspend" "0" REG_DWORD
    call :setReg "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" "DeviceSelectiveSuspended" "0" REG_DWORD
    call :setReg "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" "SelectiveSuspendEnabled" "0" REG_DWORD
    call :setReg "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" "SelectiveSuspendOn" "0" REG_DWORD
    call :setReg "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" "D3ColdSupported" "0" REG_DWORD
)

:: Activate Hidden Ultimate Performance Power Plan
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee
powercfg -setactive eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee

:: Other Tweaks
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

:: Applying BCD Tweaks for lower Input Delay
bcdedit /set disabledynamictick yes
bcdedit /deletevalue useplatformclock
bcdedit /set useplatformtick yes

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
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "LargeSystemCache" "1" REG_DWORD
call :setReg "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" "DisablePagingCombining" "1" REG_DWORD
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
choice /C 1234567 /N /M "Select an option: "
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
choice /C 123 /N /M "Select an option: "
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
rd /s /q %systemdrive%\SoftwareDistribution
md %systemdrive%\SoftwareDistribution

goto main

:launchWinUtil
cls
powershell -Command "irm 'https://christitus.com/win' | iex"
goto main

:setReg
:: Function to set registry values
:: Usage: call :setReg <key> <valueName> <value> [type]
set "key=%~1"
set "valueName=%~2"
set "value=%~3"
set "type=%~4"

if "%type%"=="" set "type=REG_SZ"
reg.exe add "%key%" /v "%valueName%" /t "%type%" /d "%value%" /f
goto :eof