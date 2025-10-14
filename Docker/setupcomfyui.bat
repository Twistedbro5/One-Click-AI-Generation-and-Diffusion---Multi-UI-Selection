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
set "COMFY_PORTABLE_DIR=%ROOT_DIR%ComfyUI\ComfyUI_windows_portable_nvidia\"
set "COMFY_BAT=%COMFY_PORTABLE_DIR%run_nvidia_gpu.bat"
set "DOWNLOAD_FILE=%ROOT_DIR%ComfyUI_portable.7z"
set "DOWNLOAD_URL=https://github.com/comfyanonymous/ComfyUI/releases/latest/download/ComfyUI_windows_portable_nvidia.7z"

REM ============================================================
REM STEP 1: Check if ComfyUI is already installed
REM ============================================================
echo [*] Checking for existing ComfyUI installation...
echo [*] Looking for: %COMFY_BAT%
echo.

if exist "%COMFY_BAT%" (
    echo [OK] ComfyUI portable already installed at:
    echo     %COMFY_PORTABLE_DIR%
    echo [*] Starting ComfyUI...
    echo.
    goto RUN_COMFYUI
)

REM Additional check - see if folder exists but bat is missing
if exist "%COMFY_PORTABLE_DIR%" (
    echo [WARNING] ComfyUI directory exists but run_nvidia_gpu.bat is missing
    echo [*] Directory: %COMFY_PORTABLE_DIR%
    echo.
    
    REM Check if this is a partial installation
    if exist "%COMFY_PORTABLE_DIR%\ComfyUI\" (
        echo [INFO] Found partial ComfyUI installation
        choice /C YN /N /M "Would you like to delete and reinstall ComfyUI? [Y/N]: "
        if errorlevel 2 (
            echo [*] Installation cancelled
            exit /b 1
        )
        echo [*] Removing partial installation...
        rmdir /s /q "%COMFY_PORTABLE_DIR%" 2>nul
        if exist "%COMFY_PORTABLE_DIR%" (
            echo [ERROR] Failed to remove directory. Please delete manually:
            echo     %COMFY_PORTABLE_DIR%
            pause
            exit /b 1
        )
        echo [OK] Removed partial installation
        echo.
    )
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

REM Ensure ComfyUI directory exists
if not exist "%ROOT_DIR%ComfyUI" mkdir "%ROOT_DIR%ComfyUI"

REM Check if 7z is available
where 7z >nul 2>&1
if !errorlevel! equ 0 (
    echo [*] Using 7-Zip...
    7z x "%DOWNLOAD_FILE%" -o"%ROOT_DIR%ComfyUI" -y
    set EXTRACT_RESULT=!errorlevel!
) else (
    REM Using tar (built into Windows 10+)
    echo [*] Using Windows built-in extractor...
    echo [*] Progress tracking not available with tar
    echo.
    
    REM Simple spinner animation for tar
    cd /d "%ROOT_DIR%ComfyUI"
    
    REM Start extraction in background
    start /b "" tar -xf "%DOWNLOAD_FILE%"
    
    REM Show spinner while extraction runs
    set "SPINNER=|/-\"
    set "SPIN_INDEX=0"
    
:SPINNER_LOOP
    tasklist /FI "IMAGENAME eq tar.exe" 2>nul | find /i "tar.exe" >nul
    if !errorlevel! equ 0 (
        set /a SPIN_INDEX=!SPIN_INDEX! %% 4
        for /f %%i in ("!SPIN_INDEX!") do set "SPIN_CHAR=!SPINNER:~%%i,1!"
        <nul set /p "=Extracting... !SPIN_CHAR!"
        ping -n 2 127.0.0.1 >nul
        goto SPINNER_LOOP
    )
    
    echo Extracting... Done!
    echo.
    
    set EXTRACT_RESULT=0
)

if !EXTRACT_RESULT! neq 0 (
    echo.
    echo [ERROR] Extraction failed
    echo.
    echo SUGGESTIONS:
    echo 1. Install 7-Zip from: https://www.7-zip.org/
    echo 2. Or manually extract: %DOWNLOAD_FILE%
    echo 3. Extract to: %ROOT_DIR%ComfyUI\
    echo 4. Run this script again
    echo.
    exit /b 1
)

echo [OK] Extraction complete!
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
echo [*] Verifying installation...

if not exist "%COMFY_BAT%" (
    echo [ERROR] Installation verification failed
    echo [*] Expected file not found: %COMFY_BAT%
    echo.
    echo The extracted folder structure may be different than expected.
    echo.
    echo Expected structure:
    echo   %ROOT_DIR%ComfyUI\
    echo     └── ComfyUI_windows_portable_nvidia\
    echo           └── run_nvidia_gpu.bat
    echo.
    echo Please check: %ROOT_DIR%ComfyUI\
    echo.
    echo If the folder structure is different, you may need to:
    echo 1. Move the contents to match the expected structure
    echo 2. Or update this script with the correct path
    echo.
    pause
    exit /b 1
)

echo [OK] ComfyUI portable installed successfully
echo     Installation location: %COMFY_PORTABLE_DIR%
echo.

REM ============================================================
REM STEP 6: Run ComfyUI
REM ============================================================
:RUN_COMFYUI
echo [*] Launching ComfyUI...
echo.

REM Check if bat file exists (redundant but safe)
if not exist "%COMFY_BAT%" (
    echo [ERROR] ComfyUI batch file not found at: %COMFY_BAT%
    echo [*] Please ensure ComfyUI portable is properly installed
    exit /b 1
)

REM Change to ComfyUI directory and run
cd /d "%COMFY_PORTABLE_DIR%"
echo [*] Starting from directory: %CD%
echo [*] Executing: %COMFY_BAT%
echo.
echo ============================================================
echo   ComfyUI Console Output
echo ============================================================
echo.

call "%COMFY_BAT%"

if !errorlevel! neq 0 (
    echo.
    echo ============================================================
    echo [ERROR] Failed to launch ComfyUI
    echo ============================================================
    echo.
    echo Error code: !errorlevel!
    echo.
    echo SUGGESTIONS:
    echo 1. Try running manually: %COMFY_BAT%
    echo 2. Check if NVIDIA drivers are installed
    echo 3. Check if you have an NVIDIA GPU
    echo.
    pause
    exit /b 1
)

REM Note: The above call blocks and shows all output in this terminal
REM The script will only reach here if ComfyUI exits

echo.
echo ============================================================
echo [*] ComfyUI has stopped
echo ============================================================
cd /d "%ROOT_DIR%"
exit /b 0