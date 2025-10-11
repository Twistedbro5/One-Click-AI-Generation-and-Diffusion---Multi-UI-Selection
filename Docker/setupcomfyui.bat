@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM ComfyUI Hybrid Setup Script
REM SDXL + Refiner + Wan2.2 Video Model Integration
REM ============================================================

echo [*] ComfyUI Hybrid Docker Setup
echo [*] SDXL + Refiner + Wan2.2 Video Model Integration
echo.

REM === Path handling ===
set "DOCKER_DIR=%~dp0"
cd /d "%DOCKER_DIR%"

REM Go up one directory to project root (C:/MyFolder/)
cd ..
set "ROOT_DIR=%CD%\"
set "COMFY_DIR=%ROOT_DIR%ComfyUI\"
set "WAN_MODEL_DIR=%COMFY_DIR%models\Wan2.2"
set "WAN_MODEL_FILE=%WAN_MODEL_DIR%\Wan2.2-TI2V-5B.safetensors"

REM ============================================================
REM STEP 1: Verify directory structure
REM ============================================================
echo [*] Verifying directory structure...
if not exist "%COMFY_DIR%" mkdir "%COMFY_DIR%"
if not exist "%COMFY_DIR%models" mkdir "%COMFY_DIR%models"
if not exist "%COMFY_DIR%custom_nodes" mkdir "%COMFY_DIR%custom_nodes"
if not exist "%COMFY_DIR%input" mkdir "%COMFY_DIR%input"
if not exist "%COMFY_DIR%output" mkdir "%COMFY_DIR%output"
echo [OK] Directory structure verified
echo.

REM ============================================================
REM STEP 2: Check for existing container
REM ============================================================
echo [*] Checking for existing ComfyUI container...
docker ps -a --filter "name=comfyui_hybrid" --format "{{.Names}}" 2>nul | findstr /C:"comfyui_hybrid" >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Found existing container
    
    REM Check if it's running
    docker ps --filter "name=comfyui_hybrid" --filter "status=running" --format "{{.Names}}" 2>nul | findstr /C:"comfyui_hybrid" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] ComfyUI container is not running after setup
        echo [*] Please check Docker logs for more information: docker logs comfyui_hybrid
        echo [*] You can also try restarting Docker Desktop and running the setup again
        pause
        exit /b 1
    )
    echo [OK] ComfyUI container is running
    echo.
)

REM ============================================================
REM STEP 3: Check for Wan2.2 model
REM ============================================================
echo [*] Checking for Wan2.2 model...
if not exist "%WAN_MODEL_FILE%" (
    echo [!] Wan2.2 model not found locally
    echo.
    echo ============================================================
    echo   Wan2.2 Model Download Required
    echo ============================================================
    echo.
    echo This model is required for video generation capabilities.
    echo Download size: ~10-15 GB
    echo Estimated time: 5-15 minutes (depending on connection)
    echo.
    
    choice /C YN /N /M "Would you like to download the Wan2.2 model now? [Y/N]: "
    if errorlevel 2 (
        echo.
        echo [INFO] Skipping model download
        echo [INFO] You can download it later using:
        echo        hf download Wan-AI/Wan2.2-TI2V-5B --local-dir "%WAN_MODEL_DIR%"
        echo.
        echo [*] ComfyUI will still work for image generation without this model
    ) else (
        echo.
        echo [*] Preparing to download Wan2.2 model...
        
        REM Check for huggingface-cli first (fastest method)
        where hf >nul 2>&1
        if !errorlevel! equ 0 (
            echo [*] Found huggingface-cli, using it for download...
            if not exist "%WAN_MODEL_DIR%" mkdir "%WAN_MODEL_DIR%"
            hf download Wan-AI/Wan2.2-TI2V-5B --local-dir "%WAN_MODEL_DIR%" --local-dir-use-symlinks False
            if !errorlevel! equ 0 (
                echo [OK] Model downloaded successfully using huggingface-cli
                goto MODEL_DOWNLOAD_SUCCESS
            )
            echo [WARNING] huggingface-cli download failed, falling back to Python method...
        )
        
        REM Check if Python is available
        python --version >nul 2>&1
        if !errorlevel! neq 0 (
            echo [WARNING] Python not found - attempting to download using Docker
            echo [*] This method may be slower but doesn't require Python on your system
            
            REM Create temp script for Docker download with progress
            echo import os > "%TEMP%\download_wan.py"
            echo from huggingface_hub import hf_hub_download >> "%TEMP%\download_wan.py"
            echo from tqdm.auto import tqdm >> "%TEMP%\download_wan.py"
            echo import sys >> "%TEMP%\download_wan.py"
            echo. >> "%TEMP%\download_wan.py"
            echo class ProgressBar(tqdm): >> "%TEMP%\download_wan.py"
            echo     def update_to(self, b=1, bsize=1, tsize=None): >> "%TEMP%\download_wan.py"
            echo         if tsize is not None: >> "%TEMP%\download_wan.py"
            echo             self.total = tsize >> "%TEMP%\download_wan.py"
            echo         return self.update(b * bsize - self.n) >> "%TEMP%\download_wan.py"
            echo. >> "%TEMP%\download_wan.py"
            echo try: >> "%TEMP%\download_wan.py"
            echo     print("[*] Starting download with progress...") >> "%TEMP%\download_wan.py"
            echo     hf_hub_download( >> "%TEMP%\download_wan.py"
            echo         repo_id="Wan-AI/Wan2.2-TI2V-5B", >> "%TEMP%\download_wan.py"
            echo         filename="Wan2.2-TI2V-5B.safetensors", >> "%TEMP%\download_wan.py"
            echo         local_dir="/models/Wan2.2", >> "%TEMP%\download_wan.py"
            echo         local_dir_use_symlinks=False, >> "%TEMP%\download_wan.py"
            echo         progress=ProgressBar(unit='B', unit_scale=True, miniters=1, desc="Downloading") >> "%TEMP%\download_wan.py"
            echo     ) >> "%TEMP%\download_wan.py"
            echo     print("\\n[OK] Download complete!") >> "%TEMP%\download_wan.py"
            echo except Exception as e: >> "%TEMP%\download_wan.py"
            echo     print(f"\\n[ERROR] Download failed: {e}") >> "%TEMP%\download_wan.py"
            echo     sys.exit(1) >> "%TEMP%\download_wan.py"
            
            REM Ensure directory exists
            if not exist "%WAN_MODEL_DIR%" mkdir "%WAN_MODEL_DIR%"
            
            REM Run download in temporary Python container with progress
            echo [*] Starting download via Docker (this may take several minutes)...
            docker run --rm -v "%WAN_MODEL_DIR%:/models/Wan2.2" -v "%TEMP%\download_wan.py:/download.py" python:3.10-slim bash -c "pip install -q huggingface_hub tqdm && python /download.py"
            
            if !errorlevel! neq 0 (
                echo [ERROR] Failed to download model via Docker
                echo.
                echo [INFO] You can download it manually later using any of these methods:
                echo        1. Install huggingface-cli and run again
                echo        2. Or install Python and run:
                echo           pip install huggingface_hub
                echo           python -c "from huggingface_hub import hf_hub_download; hf_hub_download(repo_id='Wan-AI/Wan2.2-TI2V-5B', filename='Wan2.2-TI2V-5B.safetensors', local_dir=r'%WAN_MODEL_DIR%', local_dir_use_symlinks=False)"
                del "%TEMP%\download_wan.py" >nul 2>&1
                exit /b 1
            ) else (
                echo [OK] Model downloaded successfully
                del "%TEMP%\download_wan.py" >nul 2>&1
                goto MODEL_DOWNLOAD_SUCCESS
            )
        ) else (
            REM Check for required Python packages
            echo [*] Checking for required Python packages...
            python -c "import huggingface_hub, tqdm" >nul 2>&1
            if !errorlevel! neq 0 (
                echo [*] Installing required packages...
                python -m pip install -q --upgrade huggingface_hub tqdm
                if !errorlevel! neq 0 (
                    echo [ERROR] Failed to install required packages
                    echo [INFO] You can install them manually: pip install huggingface_hub tqdm
                    goto SKIP_MODEL_DOWNLOAD
                )
            )
            
            REM Download using Python with progress
            if not exist "%WAN_MODEL_DIR%" mkdir "%WAN_MODEL_DIR%"
            
            echo [*] Starting download with progress (this may take several minutes)...
            python -c "
import os
from huggingface_hub import hf_hub_download
from tqdm.auto import tqdm

class ProgressBar(tqdm):
    def update_to(self, b=1, bsize=1, tsize=None):
        if tsize is not None:
            self.total = tsize
        return self.update(b * bsize - self.n)

try:
    print('[*] Starting download with progress...')
    hf_hub_download(
        repo_id='Wan-AI/Wan2.2-TI2V-5B',
        filename='Wan2.2-TI2V-5B.safetensors',
        local_dir=r'%WAN_MODEL_DIR%',
        local_dir_use_symlinks=False,
        progress=ProgressBar(unit='B', unit_scale=True, miniters=1, desc='Downloading')
    )
    print('\\n[OK] Download complete!')
    exit(0)
except Exception as e:
    print(f'\\n[ERROR] Download failed: {e}')
    exit(1)
"
            
            if !errorlevel! neq 0 (
                echo [ERROR] Download failed
                echo [INFO] You can try downloading manually using the methods above
                goto SKIP_MODEL_DOWNLOAD
            ) else (
                echo [OK] Wan2.2 model downloaded successfully
                goto MODEL_DOWNLOAD_SUCCESS
            )
        )
    )
) else (
    echo [OK] Wan2.2 model found
)

:MODEL_DOWNLOAD_SUCCESS
    echo [OK] Wan2.2 model is ready
    echo.
    
:SKIP_MODEL_DOWNLOAD
echo.

REM ============================================================
REM STEP 4: Check for image updates
REM ============================================================
echo [*] Checking for base image updates...

REM First check if image exists locally
docker images saladtechnologies/comfyui:comfy0.3.40-api1.9.0-torch2.7.1-cuda12.6-sdxl-with-refiner --format "{{.Repository}}" 2>nul | findstr "saladtechnologies" >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Base image not found locally - will download
    set NEED_BUILD=1
) else (
    echo [*] Base image found locally
    echo [*] Checking for updates...
    
    REM Pull latest version to check for updates
    docker pull saladtechnologies/comfyui:comfy0.3.40-api1.9.0-torch2.7.1-cuda12.6-sdxl-with-refiner 2>&1 | findstr /C:"Image is up to date" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Base image is up to date
        
        REM Check if our custom image exists
        docker images comfyui_hybrid:latest --format "{{.Repository}}" 2>nul | findstr "comfyui_hybrid" >nul 2>&1
        if %errorlevel% neq 0 (
            echo [*] Custom ComfyUI image not found - will build
            set NEED_BUILD=1
        ) else (
            echo [OK] Custom ComfyUI image exists
            set NEED_BUILD=0
        )
    ) else (
        echo [*] Update available for base image
        
        choice /C YN /N /M "Would you like to update and rebuild? [Y/N]: "
        if errorlevel 2 (
            echo [*] Skipping update - using existing image
            set NEED_BUILD=0
        ) else (
            echo [*] Will rebuild with updated base image
            set NEED_BUILD=1
        )
    )
)
echo.

REM ============================================================
REM STEP 5: Build custom image if needed
REM ============================================================
if !NEED_BUILD! equ 1 (
    echo [*] Building custom ComfyUI image...
    echo [*] This may take several minutes...
    echo.
    echo ============================================================
    
    cd /d "%DOCKER_DIR%"
    docker compose -f docker-compose.comfyui.yml build --pull
    
    if !errorlevel! neq 0 (
        echo.
        echo ============================================================
        echo [ERROR] Failed to build ComfyUI image
        echo ============================================================
        echo.
        echo SUGGESTIONS:
        echo 1. Check Docker logs for detailed error messages
        echo 2. Ensure you have enough disk space
        echo 3. Try restarting Docker Desktop
        echo 4. Check your internet connection
        echo.
        exit /b 1
    )
    
    echo ============================================================
    echo [OK] ComfyUI image built successfully
    echo.
) else (
    echo [*] Using existing ComfyUI image
    echo.
)

REM ============================================================
REM STEP 6: Start the container
REM ============================================================
echo [*] Starting ComfyUI container...

cd /d "%DOCKER_DIR%"
docker compose -f docker-compose.comfyui.yml up -d

if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo [ERROR] Failed to start ComfyUI container
    echo ============================================================
    echo.
    echo SUGGESTIONS:
    echo 1. Check if port 8188 is already in use
    echo 2. Ensure Docker Desktop is running
    echo 3. Check NVIDIA GPU drivers are up to date
    echo 4. Verify WSL2 is properly configured
    echo.
    echo [*] Checking logs...
    docker logs comfyui_hybrid --tail 20 2>nul
    echo.
    exit /b 1
)

echo [OK] ComfyUI container started successfully
echo.

REM Return to root directory
cd /d "%ROOT_DIR%"

exit /b 0