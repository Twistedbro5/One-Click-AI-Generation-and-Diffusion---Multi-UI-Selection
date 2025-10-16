@echo off
setlocal enabledelayedexpansion
title AI Generation Suite - Comprehensive Debug Mode

echo ============================================================
echo   AI GENERATION SUITE - COMPREHENSIVE DEBUG MODE
echo ============================================================
echo This script provides detailed diagnostic information for the
echo Start-WebUI.bat launcher and all supported UIs (Automatic1111,
echo ComfyUI, Fooocus). Run this if Start-WebUI.bat fails.
echo ============================================================
echo.

REM Change directory to the folder where this script is located
cd /d "%~dp0"

echo [DEBUG] Working Directory: %CD%
echo [DEBUG] Timestamp: %date% %time%
echo [INFO] If issues are found, run Start-WebUI.bat to attempt fixes.
echo.

REM ============================================================
REM STEP 1: System Information
REM ============================================================
echo ============================================================
echo STEP 1: System Information
echo ============================================================
echo [DEBUG] Windows Version:
ver
echo.
echo [DEBUG] System Architecture:
wmic os get osarchitecture
echo.
echo [DEBUG] Checking CPU Virtualization Support:
systeminfo | findstr /C:"Hyper-V" || echo [INFO] Hyper-V not detected (may need enabling in BIOS).
echo.

REM ============================================================
REM STEP 2: Prerequisites Check
REM ============================================================
echo ============================================================
echo STEP 2: Prerequisites Check
echo ============================================================
echo [INFO] Checking for Git...
git --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Git is installed
    for /f "tokens=3" %%v in ('git --version') do echo [DEBUG] Version: %%v
) else (
    echo [ERROR] Git is NOT installed
    echo [SUGGESTION] Install Git from https://git-scm.com/ or run Start-WebUI.bat to install it.
)
echo.

echo [INFO] Checking for Docker...
docker --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker is installed
    for /f "tokens=3" %%v in ('docker --version') do echo [DEBUG] Version: %%v
) else (
    echo [ERROR] Docker is NOT installed
    echo [SUGGESTION] Install Docker Desktop from https://www.docker.com/ or run Start-WebUI.bat to install it.
)
echo.

echo [INFO] Checking for WSL2...
wsl --status >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] WSL2 is installed and configured
    wsl --status
) else (
    echo [WARNING] WSL2 may not be installed or configured
    echo [SUGGESTION] Run Start-WebUI.bat to install WSL2 or enable it manually.
)
echo.

echo [INFO] Checking for NVIDIA GPU...
nvidia-smi >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] NVIDIA GPU detected
    echo [DEBUG] NVIDIA SMI Output:
    nvidia-smi
) else (
    echo [WARNING] NVIDIA GPU not detected or drivers missing
    echo [SUGGESTION] Install NVIDIA drivers from https://www.nvidia.com/Download/index.aspx.
)
echo.

REM ============================================================
REM STEP 3: Directory Structure Check
REM ============================================================
echo ============================================================
echo STEP 3: Directory Structure Check
echo ============================================================
echo [INFO] Checking required directories for all UIs...

REM Check Automatic1111 directories
if exist "Automatic1111\models" (
    echo [OK] Automatic1111\models exists
) else (
    echo [WARNING] Automatic1111\models missing (will be created by Start-WebUI.bat)
)
if exist "Automatic1111\outputs" (
    echo [OK] Automatic1111\outputs exists
) else (
    echo [WARNING] Automatic1111\outputs missing (will be created by Start-WebUI.bat)
)
if exist "Automatic1111\extensions" (
    echo [OK] Automatic1111\extensions exists
) else (
    echo [WARNING] Automatic1111\extensions missing (will be created by Start-WebUI.bat)
)

REM Check Fooocus directories
if exist "Fooocus\data" (
    echo [OK] Fooocus\data exists
) else (
    echo [WARNING] Fooocus\data missing (will be created by Start-WebUI.bat)
)

REM Check ComfyUI directories
if exist "ComfyUI\models" (
    echo [OK] ComfyUI\models exists
) else (
    echo [WARNING] ComfyUI\models missing (will be created by Start-WebUI.bat)
)
if exist "ComfyUI\outputs" (
    echo [OK] ComfyUI\outputs exists
) else (
    echo [WARNING] ComfyUI\outputs missing (will be created by Start-WebUI.bat)
)
echo.

REM ============================================================
REM STEP 4: Configuration Check
REM ============================================================
echo ============================================================
echo STEP 4: Configuration Check
echo ============================================================
if exist "webui_config.cfg" (
    echo [OK] webui_config.cfg found
    echo [DEBUG] Contents:
    type webui_config.cfg
) else (
    echo [WARNING] webui_config.cfg not found (will be created by Start-WebUI.bat)
)
echo.

REM ============================================================
REM STEP 5: Docker Compose Files Check
REM ============================================================
echo ============================================================
echo STEP 5: Docker Compose Files Check
echo ============================================================
set COMPOSE_V2=0
set COMPOSE_V1=0

docker compose version >nul 2>&1
if %errorlevel% equ 0 (
    set COMPOSE_CMD=docker compose
    set COMPOSE_V2=1
    echo [OK] Docker Compose V2 detected
) else (
    docker-compose --version >nul 2>&1
    if %errorlevel% equ 0 (
        set COMPOSE_CMD=docker-compose
        set COMPOSE_V1=1
        echo [OK] Docker Compose V1 detected
    ) else (
        echo [ERROR] Docker Compose not found
        echo [SUGGESTION] Ensure Docker Desktop includes Compose or install it separately.
    )
)

echo.

if exist "Docker\docker-compose.automatic1111.yml" (
    echo [OK] Docker\docker-compose.automatic1111.yml exists
) else (
    echo [ERROR] Docker\docker-compose.automatic1111.yml missing
    echo [SUGGESTION] Restore from backup or re-download.
)

if exist "Docker\docker-compose.fooocus.yml" (
    echo [OK] Docker\docker-compose.fooocus.yml exists
) else (
    echo [ERROR] Docker\docker-compose.fooocus.yml missing
    echo [SUGGESTION] Restore from backup or re-download.
)

if exist "Docker\setupcomfyui.bat" (
    echo [OK] Docker\setupcomfyui.bat exists
) else (
    echo [WARNING] Docker\setupcomfyui.bat missing (required for ComfyUI)
    echo [SUGGESTION] Restore from backup.
)
echo.

REM ============================================================
REM STEP 6: Docker Daemon and Network Check
REM ============================================================
echo ============================================================
echo STEP 6: Docker Daemon and Network Check
echo ============================================================
echo [INFO] Testing Docker daemon...
docker info >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker daemon is running
    echo [DEBUG] Docker info:
    docker info
) else (
    echo [ERROR] Docker daemon not running
    echo [SUGGESTION] Start Docker Desktop and run Start-WebUI.bat to auto-start it.
)
echo.

echo [INFO] Checking Docker networks...
docker network ls
echo.

REM ============================================================
REM STEP 7: Container Status Check
REM ============================================================
echo ============================================================
echo STEP 7: Container Status Check
echo ============================================================
echo [INFO] Checking for Automatic1111 container (stable-diffusion)...
docker ps -a --filter "name=stable-diffusion" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>nul
if %errorlevel% neq 0 (
    echo [INFO] No stable-diffusion container found.
)
echo.

echo [INFO] Checking for Fooocus container (fooocus)...
docker ps -a --filter "name=fooocus" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>nul
if %errorlevel% neq 0 (
    echo [INFO] No fooocus container found.
)
echo.

echo [INFO] Checking for ComfyUI container (comfyui)...
docker ps -a --filter "name=comfyui" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>nul
if %errorlevel% neq 0 (
    echo [INFO] No comfyui container found.
)
echo.

REM ============================================================
REM STEP 8: Port Availability Check
REM ============================================================
echo ============================================================
echo STEP 8: Port Availability Check
REM ============================================================
echo [INFO] Checking port 7860 (Automatic1111)...
netstat -ano | findstr :7860 >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARNING] Port 7860 is in use:
    netstat -ano | findstr :7860
    echo [SUGGESTION] Close conflicting apps or edit docker-compose.automatic1111.yml.
) else (
    echo [OK] Port 7860 is available.
)

echo [INFO] Checking port 7865 (Fooocus)...
netstat -ano | findstr :7865 >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARNING] Port 7865 is in use:
    netstat -ano | findstr :7865
    echo [SUGGESTION] Close conflicting apps or edit docker-compose.fooocus.yml.
) else (
    echo [OK] Port 7865 is available.
)

echo [INFO] Checking port 8188 (ComfyUI)...
netstat -ano | findstr :8188 >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARNING] Port 8188 is in use:
    netstat -ano | findstr :8188
    echo [SUGGESTION] Close conflicting apps or edit docker-compose.comfyui.yml.
) else (
    echo [OK] Port 8188 is available.
)
echo.

REM ============================================================
REM STEP 9: Model Files Check
REM ============================================================
echo ============================================================
echo STEP 9: Model Files Check
echo ============================================================
echo [INFO] Checking for models in Automatic1111\models...
if exist "Automatic1111\models\*.safetensors" (
    echo [OK] .safetensors files in Automatic1111\models:
    dir /b "Automatic1111\models\*.safetensors"
) else (
    echo [WARNING] No .safetensors in Automatic1111\models
)

if exist "Automatic1111\models\*.ckpt" (
    echo [OK] .ckpt files in Automatic1111\models:
    dir /b "Automatic1111\models\*.ckpt"
) else (
    echo [WARNING] No .ckpt in Automatic1111\models
)
echo.

echo [INFO] Checking for models in ComfyUI\ComfyUI_windows_portable\ComfyUI\models...
if exist "ComfyUI\ComfyUI_windows_portable\ComfyUI\models\*.safetensors" (
    echo [OK] .safetensors files in ComfyUI portable models:
    dir /b "ComfyUI\ComfyUI_windows_portable\ComfyUI\models\*.safetensors"
) else (
    echo [WARNING] No .safetensors in ComfyUI portable models
)

if exist "ComfyUI\ComfyUI_windows_portable\ComfyUI\models\*.ckpt" (
    echo [OK] .ckpt files in ComfyUI portable models:
    dir /b "ComfyUI\ComfyUI_windows_portable\ComfyUI\models\*.ckpt"
) else (
    echo [WARNING] No .ckpt in ComfyUI portable models
)
echo.

REM ============================================================
REM STEP 10: Log Analysis
REM ============================================================
echo ============================================================
echo STEP 10: Log Analysis
echo ============================================================
echo [INFO] Checking for error logs...
if exist "docker-error.log" (
    echo [WARNING] docker-error.log found (from failed runs):
    echo [DEBUG] Contents:
    type docker-error.log
    del docker-error.log >nul 2>&1
    echo [INFO] Log cleaned up.
) else (
    echo [OK] No docker-error.log found.
)
echo.

echo [INFO] Checking recent container logs...
echo [DEBUG] Recent logs for stable-diffusion:
docker logs --tail 20 stable-diffusion 2>nul || echo [INFO] No stable-diffusion logs.
echo.
echo [DEBUG] Recent logs for fooocus:
docker logs --tail 20 fooocus 2>nul || echo [INFO] No fooocus logs.
echo.
echo [DEBUG] Recent logs for comfyui:
docker logs --tail 20 comfyui 2>nul || echo [INFO] No comfyui logs.
echo.

REM ============================================================
REM STEP 11: Final Summary and Suggestions
REM ============================================================
echo ============================================================
echo STEP 11: Final Summary and Suggestions
echo ============================================================
echo [SUMMARY] Debug complete. Key checks:
echo - Prerequisites: Git, Docker, WSL2, NVIDIA GPU
echo - Directories: Created by Start-WebUI.bat if missing
echo - Containers: Check status above
echo - Ports: Ensure availability
echo - Models: Add to respective \models folders
echo - Logs: Reviewed above
echo.
echo [ACTION] If issues persist, run Start-WebUI.bat - it will attempt to fix many problems automatically.
echo [INFO] Access URLs after running Start-WebUI.bat:
echo   - Automatic1111: http://localhost:7860
echo   - Fooocus: http://localhost:7865
echo   - ComfyUI: http://localhost:8188
echo.
echo Press any key to exit...
pause >nul
exit /b 0