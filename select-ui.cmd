@echo off
setlocal enabledelayedexpansion

:check_args
REM Check for command line arguments
if not "%~1"=="" (
    if /i "%~1"=="/?" (
        echo Usage: %~nx0 [1^|2^|3]
        echo.
        echo Options:
        echo   1    Switch to Automatic1111 WebUI
        echo   2    Switch to ComfyUI
        echo   3    Switch to Fooocus
        echo   /?   Show this help
        echo.
        echo If no argument is provided, shows interactive menu.
        exit /b 0
    ) else if "%~1"=="1" (
        echo AUTOMATIC1111 > .ui-config
        echo Switched to Automatic1111 WebUI
        echo Run 'start-sd.bat' to start the selected UI
        exit /b 0
    ) else if "%~1"=="2" (
        echo COMFYUI > .ui-config
        echo Switched to ComfyUI
        echo Run 'start-sd.bat' to start the selected UI
        exit /b 0
    ) else if "%~1"=="3" (
        echo FOOOCUS > .ui-config
        echo Switched to Fooocus
        echo Run 'start-sd.bat' to start Fooocus
        exit /b 0
    ) else (
        echo Invalid argument: %~1
        echo Use 'select-ui.cmd /?' for help
        exit /b 1
    )
)

:select_ui
cls
echo ===================================
echo  AI Image Generation UI Selection
echo ===================================
echo.
echo Please select which UI to use:
echo.
echo [1] Automatic1111 (Recommended for beginners)
echo    - Best for beginners
    - Simple interface
    - Many extensions available
echo.
echo [2] ComfyUI (Advanced users)
echo    - Better for complex workflows
echo    - More control over generation
echo    - Lower VRAM usage
echo.
echo [3] Fooocus (Modern UI, Most powerful out of the box, Easy to use)
echo    - Clean and simple interface
echo    - Good for quick generations
echo    - Built-in styles and presets
echo.

set "ui_choice="
set /p "ui_choice=Enter your choice (1-3): "

REM Handle empty input
if "%ui_choice%"=="" (
    echo.
    echo Error: No input received. Please try again.
    timeout /t 2 >nul
    goto select_ui
)

if "%ui_choice%"=="1" (
    echo AUTOMATIC1111 > .ui-config
    echo.
    echo Switched to Automatic1111 WebUI
    echo Run 'start-sd.bat' to start the selected UI
) else if "%ui_choice%"=="2" (
    echo COMFYUI > .ui-config
    echo.
    echo Switched to ComfyUI
    echo Run 'start-sd.bat' to start the selected UI
) else if "%ui_choice%"=="3" (
    echo FOOOCUS > .ui-config
    echo.
    echo Switched to Fooocus
    echo Run 'start-sd.bat' to start Fooocus
) else (
    echo.
    echo Invalid choice. Please enter 1, 2, or 3.
    timeout /t 2 >nul
    goto select_ui
)