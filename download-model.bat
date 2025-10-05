@echo off
setlocal enabledelayedexpansion
echo [*] Downloading Stable Diffusion model...

set MODEL_URL=https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors
set MODEL_PATH=models\v1-5-pruned-emaonly.safetensors

if exist "%MODEL_PATH%" (
    echo [*] Model already exists at %MODEL_PATH%
    exit /b 0
)

if not exist models mkdir models

echo.
echo [*] This will download approximately 4.3GB. Please be patient...
echo [*] Download URL: %MODEL_URL%
echo.

REM Use PowerShell with better error handling and progress display
powershell -Command "& {$ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '%MODEL_URL%' -OutFile '%MODEL_PATH%' -UseBasicParsing -MaximumRedirection 5 -ErrorAction Stop; exit 0 } catch { if ($_.Exception.Response.StatusCode -eq 401 -or $_.Exception.Response.StatusCode -eq 403) { Write-Host '[ERROR] Access Denied: This model requires HuggingFace authentication.'; exit 2 } else { Write-Host '[ERROR] Download failed:' $_.Exception.Message; exit 1 } }}"

set DOWNLOAD_RESULT=%errorlevel%

if %DOWNLOAD_RESULT% equ 0 (
    if exist "%MODEL_PATH%" (
        echo.
        echo ============================================================
        echo   DOWNLOAD COMPLETE!
        echo ============================================================
        echo.
        echo [*] Model has been downloaded to the models\ folder.
        echo [*] You can now run 'start-sd.bat' to start the application.
        echo.
        echo Press any key to continue...
        pause >nul
        exit /b 0
    ) else (
        echo.
        echo [ERROR] Download reported success but file not found at %MODEL_PATH%
        echo [SUGGESTION] Check disk space and permissions
        pause
        exit /b 1
    )
) else if %DOWNLOAD_RESULT% equ 2 (
    echo.
    echo ============================================================
    echo [ERROR] HuggingFace Authentication Required
    echo ============================================================
    echo This model requires you to be logged into HuggingFace.
    echo.
    echo SOLUTION:
    echo 1. Visit: https://huggingface.co/runwayml/stable-diffusion-v1-5
    echo 2. Create a free account and accept the model license
    echo 3. Download the model manually:
    echo    - Click on 'Files and versions'
    echo    - Download 'v1-5-pruned-emaonly.safetensors'
    echo 4. Place the file in: %CD%\%MODEL_PATH%
    echo.
    echo OR use a different model that doesn't require authentication
    echo ============================================================
    pause
    exit /b 2
) else (
    echo.
    echo ============================================================
    echo [ERROR] Download Failed
    echo ============================================================
    echo The model download encountered an error.
    echo.
    echo POSSIBLE CAUSES:
    echo - No internet connection
    echo - Firewall blocking the download
    echo - HuggingFace server is down
    echo - Insufficient disk space
    echo.
    echo SUGGESTIONS:
    echo 1. Check your internet connection
    echo 2. Disable antivirus/firewall temporarily and try again
    echo 3. Download manually from:
    echo    https://huggingface.co/runwayml/stable-diffusion-v1-5
    echo 4. Place the file in: %CD%\%MODEL_PATH%
    echo ============================================================
    pause
    exit /b 1
)
