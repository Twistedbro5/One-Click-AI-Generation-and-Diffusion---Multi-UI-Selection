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
set "COMFY_PORTABLE_DIR=%ROOT_DIR%ComfyUI\ComfyUI_windows_portable\"
set "COMFY_BAT=%COMFY_PORTABLE_DIR%run_nvidia_gpu.bat"
set "DOWNLOAD_FILE=%ROOT_DIR%ComfyUI_portable_nvidia.7z"
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
REM STEP 2: Check if 7z file already exists
REM ============================================================
set ARCHIVE_EXISTS=0
set ARCHIVE_VALID=0

if exist "%DOWNLOAD_FILE%" (
    echo [*] Found existing archive: %DOWNLOAD_FILE%
    echo [*] Verifying file integrity...
    
    REM Check file size (should be at least 1 GB for ComfyUI portable)
    for %%A in ("%DOWNLOAD_FILE%") do set FILE_SIZE=%%~zA
    
    REM If file size is less than 500MB (524288000 bytes), it's likely corrupted
    if !FILE_SIZE! lss 524288000 (
        echo [WARNING] Archive appears too small (%%~zA bytes^)
        echo [*] File may be corrupted or incomplete
        echo [*] Deleting corrupted archive...
        del "%DOWNLOAD_FILE%" 2>nul
    ) else (
        echo [OK] Archive appears valid (size: !FILE_SIZE! bytes^)
        set ARCHIVE_EXISTS=1
        set ARCHIVE_VALID=1
    )
    echo.
)

REM ============================================================
REM STEP 3: Download ComfyUI portable if needed
REM ============================================================
if !ARCHIVE_VALID! equ 0 (
    echo [*] ComfyUI portable archive not found or invalid
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
        pause
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
        pause
        exit /b 1
    )
    
    echo [OK] Download complete
    echo.
) else (
    echo [*] Using existing valid archive
    echo.
)

REM ============================================================
REM STEP 4: Extract the 7z file
REM ============================================================
echo [*] Extracting ComfyUI portable...
echo [*] This may take a few minutes...
echo.

REM Ensure ComfyUI directory exists
if not exist "%ROOT_DIR%ComfyUI" mkdir "%ROOT_DIR%ComfyUI"

REM Check if 7z is available
where 7z >nul 2>&1
if !errorlevel! equ 0 (
    echo [*] Using 7-Zip command line...
    7z x "%DOWNLOAD_FILE%" -o"%ROOT_DIR%ComfyUI" -y
    set EXTRACT_RESULT=!errorlevel!
) else (
    REM Try to use 7-Zip GUI executable
    if exist "C:\Program Files\7-Zip\7z.exe" (
        echo [*] Using 7-Zip from Program Files...
        "C:\Program Files\7-Zip\7z.exe" x "%DOWNLOAD_FILE%" -o"%ROOT_DIR%ComfyUI" -y
        set EXTRACT_RESULT=!errorlevel!
    ) else if exist "C:\Program Files (x86)\7-Zip\7z.exe" (
        echo [*] Using 7-Zip from Program Files (x86)...
        "C:\Program Files (x86)\7-Zip\7z.exe" x "%DOWNLOAD_FILE%" -o"%ROOT_DIR%ComfyUI" -y
        set EXTRACT_RESULT=!errorlevel!
    ) else (
        REM Using tar (built into Windows 10+)
        echo [*] Using Windows built-in tar extractor...
        echo [*] Note: Progress tracking not available with tar
        echo.
        
        REM Change to extraction directory
        pushd "%ROOT_DIR%ComfyUI"
        
        REM Start extraction
        tar -xf "%DOWNLOAD_FILE%"
        set EXTRACT_RESULT=!errorlevel!
        
        popd
        
        echo.
        echo [*] Extraction process completed
    )
)

if !EXTRACT_RESULT! neq 0 (
    echo.
    echo [ERROR] Extraction failed (error code: !EXTRACT_RESULT!)
    echo.
    echo SUGGESTIONS:
    echo 1. Install 7-Zip from: https://www.7-zip.org/
    echo 2. Or manually extract: %DOWNLOAD_FILE%
    echo 3. Extract to: %ROOT_DIR%ComfyUI\
    echo 4. Ensure the folder structure is:
    echo    %ROOT_DIR%ComfyUI\ComfyUI_windows_portable_nvidia\run_nvidia_gpu.bat
    echo 5. Run this script again
    echo.
    pause
    exit /b 1
)

echo [OK] Extraction complete!
echo.

REM ============================================================
REM STEP 5: Delete the downloaded archive
REM ============================================================
echo [*] Cleaning up...
if exist "%DOWNLOAD_FILE%" (
    del "%DOWNLOAD_FILE%"
    if exist "%DOWNLOAD_FILE%" (
        echo [WARNING] Could not delete archive (file may be in use)
        echo [*] You can manually delete: %DOWNLOAD_FILE%
    ) else (
        echo [OK] Archive deleted
    )
) else (
    echo [INFO] Archive file not found (may have been deleted already)
)
echo.

REM ============================================================
REM STEP 6: Verify installation
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
    echo     ComfyUI_windows_portable_nvidia\
    echo       run_nvidia_gpu.bat
    echo.
    echo Current directory contents:
    dir /b "%ROOT_DIR%ComfyUI\" 2>nul
    echo.
    echo Please verify the folder structure matches the expected layout.
    echo.
    pause
    exit /b 1
)

echo [OK] ComfyUI portable installed successfully
echo     Installation location: %COMFY_PORTABLE_DIR%
echo.

REM ============================================================
REM STEP 7: Run ComfyUI
REM ============================================================
:RUN_COMFYUI
echo [*] Launching ComfyUI...
echo.

REM Check if bat file exists (redundant but safe)
if not exist "%COMFY_BAT%" (
    echo [ERROR] ComfyUI batch file not found at: %COMFY_BAT%
    echo [*] Please ensure ComfyUI portable is properly installed
    pause
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
echo   Auto-Loading ComfyUI at: http://localhost:8188
echo   Press Ctrl+C in this window to stop ComfyUI
echo ============================================================
echo.

REM Run ComfyUI - this blocks until ComfyUI exits
call "%COMFY_BAT%"

if !errorlevel! neq 0 (
    echo.
    echo ============================================================
    echo [ERROR] ComfyUI exited with error code: !errorlevel!
    echo ============================================================
    echo.
    echo SUGGESTIONS:
    echo 1. Check if NVIDIA drivers are installed and up to date
    echo 2. Ensure you have an NVIDIA GPU
    echo 3. Try running manually: %COMFY_BAT%
    echo 4. Check the error messages above for more details
    echo.
    pause
    exit /b 1
)

REM Note: The above call blocks and shows all output in this terminal
REM The script will only reach here if ComfyUI exits normally

echo.
echo ============================================================
echo [*] ComfyUI has stopped normally
echo ============================================================
cd /d "%ROOT_DIR%"
exit /b 0