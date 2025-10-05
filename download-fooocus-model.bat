@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo  Fooocus Model Downloader
echo ============================================================
echo.
echo This script will download the required models for Fooocus.
echo The total download size is approximately 7GB.
echo.

set "MODEL_URL=https://huggingface.co/lllyasviel/fav_models/resolve/main/fav/fooocus_diffusion.safetensors"
set "MODEL_PATH=models\fooocus_diffusion.safetensors"
set "VAE_URL=https://huggingface.co/lllyasviel/fav_models/resolve/main/fav/fooocus_v2.1.safetensors"
set "VAE_PATH=models\fooocus_v2.1.safetensors"

REM Create models directory if it doesn't exist
if not exist "models" (
    mkdir models
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to create models directory
        pause
        exit /b 1
    )
)

echo [*] Starting download of Fooocus models...
echo.

REM Download main model
if not exist "%MODEL_PATH%" (
    echo [*] Downloading Fooocus model (3.97GB)...
    curl -L "%MODEL_URL%" -o "%MODEL_PATH%" --progress-bar
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to download Fooocus model
        if exist "%MODEL_PATH%" del "%MODEL_PATH%"
        pause
        exit /b 1
    )
    echo [*] Fooocus model downloaded successfully
) else (
    echo [*] Fooocus model already exists, skipping download
)

REM Download VAE
if not exist "%VAE_PATH%" (
    echo [*] Downloading VAE model (3.05GB)...
    curl -L "%VAE_URL%" -o "%VAE_PATH%" --progress-bar
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to download VAE model
        if exist "%VAE_PATH%" del "%VAE_PATH%"
        pause
        exit /b 1
    )
    echo [*] VAE model downloaded successfully
) else (
    echo [*] VAE model already exists, skipping download
)

echo.
echo ============================================================
echo   DOWNLOAD COMPLETE!
echo ============================================================
echo.
echo [*] Fooocus models have been downloaded to the models\ folder.
echo [*] You can now run 'start-sd.bat' and select Fooocus as your UI.
echo.
echo Press any key to continue...
pause >nul
