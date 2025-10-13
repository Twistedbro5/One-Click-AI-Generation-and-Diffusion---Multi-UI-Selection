@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM ComfyUI Setup Script - Portable Version
REM Downloads, extracts, and runs ComfyUI portable
REM ============================================================

echo [*] ComfyUI Portable Setup
echo.

REM === Path handling ===
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Go up one directory to project root
cd ..
set "ROOT_DIR=%CD%\"
set "COMFY_PORTABLE_DIR=%ROOT_DIR%ComfyUI\"
set "COMFY_BAT=%COMFY_PORTABLE_DIR%run_nvidia_gpu.bat"
set "DOWNLOAD_FILE=%ROOT_DIR%ComfyUI_portable.7z"
set "DOWNLOAD_URL=https://github.com/comfyanonymous/ComfyUI/releases/latest/download/ComfyUI_windows_portable_nvidia.7z"

REM ============================================================
REM STEP 1: Check if ComfyUI is already installed
REM ============================================================
if exist "%COMFY_BAT%" (
    echo [OK] ComfyUI portable already installed
    echo [*] Starting ComfyUI...
    echo.
    goto RUN_COMFYUI
)

REM ============================================================
REM STEP 2: Download ComfyUI portable
REM ============================================================
echo [*] ComfyUI portable not found
echo.
echo ============================================================
echo   ComfyUI Portable Download Required
echo ============================================================
echo.
echo Download size: ~5-7 GB
echo Estimated time: 5-10 minutes (depending on connection)
echo.

set "DOWNLOAD_CHOICE="
set /p DOWNLOAD_CHOICE=Would you like to download ComfyUI portable now? (Y/N): 

if /i "!DOWNLOAD_CHOICE!"=="N" (
    echo.
    echo [INFO] ComfyUI installation cancelled
    echo [*] You can run this script again when ready to install
    exit /b 0
)

if /i not "!DOWNLOAD_CHOICE!"=="Y" (
    echo [ERROR] Invalid choice. Please enter Y or N.
    exit /b 1
)

echo.
echo [*] Downloading ComfyUI portable...
echo [*] This may take 5-10 minutes...
echo.

REM Check if curl is available
curl --version >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR] curl not found
    echo [*] Please download manually from: %DOWNLOAD_URL%
    echo [*] Save as: %DOWNLOAD_FILE%
    echo [*] Then run this script again
    exit /b 1
)

REM Download using curl with progress bar
curl -L -o "%DOWNLOAD_FILE%" --progress-bar "%DOWNLOAD_URL%"
if !errorlevel! neq 0 (
    echo.
    echo [ERROR] Download failed
    echo.
    echo MANUAL DOWNLOAD:
    echo 1. Visit: %DOWNLOAD_URL%
    echo 2. Save file as: %DOWNLOAD_FILE%
    echo 3. Run this script again
    echo.
    exit /b 1
)

echo [OK] Download complete
echo.

REM ============================================================
REM STEP 3: Extract the 7z file
REM ============================================================
echo [*] Extracting ComfyUI portable...
echo [*] This may take a few minutes...
echo.

REM Check if 7z is available
where 7z >nul 2>&1
if !errorlevel! equ 0 (
    echo [*] Using 7-Zip...
    7z x "%DOWNLOAD_FILE%" -o"%ROOT_DIR%" -y
    set EXTRACT_RESULT=!errorlevel!
) else (
    REM Try using tar (built into Windows 10+)
    echo [*] Using Windows built-in extractor...
    cd /d "%ROOT_DIR%"
    mkdir "%ROOT_DIR%ComfyUI\ComfyUI_windows_portable_nvidia" 2>nul
    tar -xf "%DOWNLOAD_FILE%" -C "%ROOT_DIR%ComfyUI\ComfyUI_windows_portable_nvidia"
    set EXTRACT_RESULT=!errorlevel!
)

if !EXTRACT_RESULT! neq 0 (
    echo.
    echo [ERROR] Extraction failed
    echo.
    echo SUGGESTIONS:
    echo 1. Install 7-Zip from: https://www.7-zip.org/
    echo 2. Or manually extract: %DOWNLOAD_FILE%
    echo 3. Extract to: %ROOT_DIR%
    echo 4. Run this script again
    echo.
    exit /b 1
)

echo [OK] Extraction complete
echo.

REM ============================================================
REM STEP 4: Delete the downloaded archive
REM ============================================================
echo [*] Cleaning up...
if exist "%DOWNLOAD_FILE%" (
    del "%DOWNLOAD_FILE%"
    echo [OK] Archive deleted
) else (
    echo [INFO] Archive file not found (may have been deleted already)
)
echo.

REM ============================================================
REM STEP 5: Verify installation
REM ============================================================
if not exist "%COMFY_BAT%" (
    echo [ERROR] Installation verification failed
    echo [*] Expected file not found: %COMFY_BAT%
    echo.
    echo The extracted folder structure may be different than expected.
    echo Please check: %ROOT_DIR%
    echo.
    exit /b 1
)

echo [OK] ComfyUI portable installed successfully
echo.

REM ============================================================
REM STEP 6: Run ComfyUI
REM ============================================================
:RUN_COMFYUI
echo [*] Launching ComfyUI...
echo.

REM Check if bat file exists
if not exist "%COMFY_BAT%" (
    echo [ERROR] ComfyUI batch file not found at: %COMFY_BAT%
    echo [*] Please ensure ComfyUI portable is properly installed
    exit /b 1
)

REM Change to ComfyUI directory and run
cd /d "%COMFY_PORTABLE_DIR%"
call "%COMFY_BAT%"

if !errorlevel! neq 0 (
    echo [ERROR] Failed to launch ComfyUI
    echo [*] Try running manually: %COMFY_BAT%
    exit /b 1
)
REM Note: The above call blocks and shows all output in this terminal
REM The script will only reach here if ComfyUI exits

echo.
echo [*] ComfyUI has stopped
cd /d "%ROOT_DIR%"
exit /b 0