@echo off
setlocal enabledelayedexpansion

REM Check for command line arguments
if not "%~1"=="" (
    if /i "%~1"=="/?" (
        echo Usage: %~nx0 [1^|2^|3]
        echo.
        echo Options:
        echo   1    Automatic1111 WebUI
        echo   2    ComfyUI
        echo   3    Fooocus
        echo   /?   Show this help
        echo.
        exit /b 0
    ) else if "%~1"=="1" (
        echo AUTOMATIC1111>.ui-config
        echo [OK] Switched to Automatic1111 WebUI
        exit /b 0
    ) else if "%~1"=="2" (
        echo COMFYUI>.ui-config
        echo [OK] Switched to ComfyUI
        exit /b 0
    ) else if "%~1"=="3" (
        echo FOOOCUS>.ui-config
        echo [OK] Switched to Fooocus
        exit /b 0
    ) else (
        echo [ERROR] Invalid argument: %~1
        echo Use '%~nx0 /?' for help
        exit /b 1
    )
)

REM Interactive menu
:SELECT_UI
cls
echo ============================================================
echo   AI Generator - UI Selection
echo ============================================================
echo.
echo Select which interface to use:
echo.
echo [1] Automatic1111 WebUI (Recommended for beginners)
echo     - Simple, intuitive interface
echo     - Large extension ecosystem
echo     - Great for learning
echo     - Port: 7860
echo.
echo [2] ComfyUI (Advanced node-based workflow)
echo     - Node-based visual workflow
echo     - More control and flexibility
echo     - Better for complex pipelines
echo     - Port: 8188
echo.
echo [3] Fooocus (Modern, Best out-of-the-box, Easy to use-hard to master)
echo     - Clean, minimal interface
echo     - Fast generation
echo     - Built-in styles and presets
echo     - Port: 7860
echo.

set "CHOICE="
set /p "CHOICE=Enter your choice (1-3): "

if "%CHOICE%"=="" (
    echo.
    echo [ERROR] No input received
    timeout /t 2 >nul
    goto SELECT_UI
)

if "%CHOICE%"=="1" (
    echo AUTOMATIC1111>.ui-config
    echo.
    echo [OK] Configured: Automatic1111 WebUI
    echo [*] Access URL: http://localhost:7860
) else if "%CHOICE%"=="2" (
    echo COMFYUI>.ui-config
    echo.
    echo [OK] Configured: ComfyUI
    echo [*] Access URL: http://localhost:8188
) else if "%CHOICE%"=="3" (
    echo FOOOCUS>.ui-config
    echo.
    echo [OK] Configured: Fooocus
    echo [*] Access URL: http://localhost:7860
) else (
    echo.
    echo [ERROR] Invalid choice: %CHOICE%
    timeout /t 2 >nul
    goto SELECT_UI
)

echo.
echo Run 'start-sd.bat' to launch the selected UI
echo.
pause
exit /b 0