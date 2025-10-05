@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo  Fooocus Installer
echo ============================================================
echo.
echo This script will download and install Fooocus.
echo The total download size is approximately 7GB.
echo.

set "FOOOCUS_URL=https://github.com/lllyasviel/Fooocus/releases/download/v2.5.0/Fooocus_win64_2-5-0.7z"
set "FOOOCUS_FILE=Fooocus_win64_2-5-0.7z"
set "EXTRACT_DIR=."

REM ============================================================
REM Check if Fooocus is already installed
REM ============================================================
if exist "Fooocus" (
    echo [*] Fooocus directory already exists
    echo.
    choice /C YN /N /M "Re-download and reinstall Fooocus? [Y/N]: "
    if errorlevel 2 (
        echo [*] Installation cancelled
        pause
        exit /b 0
    )
    echo [*] Removing existing Fooocus directory...
    rmdir /s /q "Fooocus" 2>nul
)

REM ============================================================
REM Step 1: Download Fooocus
REM ============================================================
echo [*] Starting download of Fooocus (~7GB)...
echo [*] URL: %FOOOCUS_URL%
echo [*] This may take a while depending on your internet connection...
echo.

if exist "%FOOOCUS_FILE%" (
    echo [*] Fooocus archive already exists
    choice /C YN /N /M "Use existing file? [Y/N]: "
    if errorlevel 2 (
        echo [*] Deleting existing file and re-downloading...
        del "%FOOOCUS_FILE%" >nul 2>&1
        goto DOWNLOAD
    )
    echo [*] Using existing file
    goto EXTRACT
)

:DOWNLOAD
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {$ProgressPreference = 'SilentlyContinue'; try { Write-Host '[*] Downloading Fooocus...'; $webClient = New-Object System.Net.WebClient; $webClient.Headers.Add('User-Agent', 'Mozilla/5.0'); $webClient.DownloadFile('%FOOOCUS_URL%', '%FOOOCUS_FILE%'); if (Test-Path '%FOOOCUS_FILE%') { $fileSize = (Get-Item '%FOOOCUS_FILE%').Length; Write-Host '[OK] Download completed ('$fileSize' bytes)'; exit 0 } else { Write-Host '[ERROR] Download completed but file not found'; exit 1 } } catch { Write-Host '[ERROR] Download failed:' $_.Exception.Message; exit 1 }}"

if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo [ERROR] Download Failed
    echo ============================================================
    echo.
    echo POSSIBLE CAUSES:
    echo - No internet connection
    echo - Firewall blocking the download
    echo - GitHub server is down
    echo - Insufficient disk space
    echo.
    echo SUGGESTIONS:
    echo 1. Check your internet connection
    echo 2. Disable antivirus/firewall temporarily
    echo 3. Ensure you have at least 10GB free disk space
    echo 4. Try again in a few minutes
    echo ============================================================
    pause
    exit /b 1
)

:EXTRACT
echo.
echo ============================================================
echo  Extracting Fooocus
echo ============================================================
echo.

REM ============================================================
REM Step 2: Check for 7zr.exe
REM ============================================================
if not exist "7zr.exe" (
    echo [ERROR] 7zr.exe not found!
    echo [*] This file should be included in the repository
    echo.
    echo SOLUTION:
    echo 1. Download from: https://www.7-zip.org/a/7zr.exe
    echo 2. Place in the same folder as this script
    echo 3. Run this script again
    echo.
    pause
    exit /b 1
)

echo [*] Using included 7zr.exe for extraction
echo [*] Extracting to: %CD%
echo [*] This may take several minutes...
echo.

REM ============================================================
REM Step 3: Extract to root directory
REM ============================================================
7zr.exe x "%FOOOCUS_FILE%" -o"%EXTRACT_DIR%" -y

if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo [ERROR] Extraction Failed
    echo ============================================================
    echo Error code: %errorlevel%
    echo.
    echo POSSIBLE CAUSES:
    echo - Downloaded file is corrupted (re-download)
    echo - Insufficient disk space
    echo - Antivirus interfering with extraction
    echo - Archive is damaged
    echo.
    echo SUGGESTIONS:
    echo 1. Delete the .7z file and run this script again
    echo 2. Check available disk space (need ~10GB)
    echo 3. Temporarily disable antivirus
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Extraction complete!

REM ============================================================
REM Step 4: Verify installation
REM ============================================================
echo.
echo [*] Verifying installation...

if exist "Fooocus\run.bat" (
    echo [OK] Fooocus installation verified
) else if exist "Fooocus" (
    echo [WARNING] Fooocus folder found but run.bat is missing
    echo [*] Installation may be incomplete
) else (
    echo [ERROR] Fooocus folder not found after extraction
    echo [*] Extraction may have failed
    pause
    exit /b 1
)

REM ============================================================
REM Step 5: Cleanup
REM ============================================================
echo.
choice /C YN /N /M "Delete downloaded archive to save space? [Y/N]: "
if errorlevel 2 goto SKIP_CLEANUP

echo [*] Cleaning up...
if exist "%FOOOCUS_FILE%" (
    del "%FOOOCUS_FILE%"
    echo [OK] Archive deleted
)

:SKIP_CLEANUP
echo.
echo ============================================================
echo   INSTALLATION COMPLETE!
echo ============================================================
echo.
echo [*] Fooocus has been installed to: %CD%\Fooocus
echo.
echo NEXT STEPS:
echo 1. Run 'start-sd.bat'
echo 2. Select option [3] for Fooocus
echo 3. Wait for models to download on first run
echo.
echo OR manually start Fooocus:
echo   cd Fooocus
echo   run.bat, run_anime.bat, or run_realistic.bat
echo.
echo ============================================================
pause
exit /b 0