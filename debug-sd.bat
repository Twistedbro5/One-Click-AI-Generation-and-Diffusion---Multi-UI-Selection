@echo off
setlocal enabledelayedexpansion
title Stable Diffusion - DEBUG MODE

echo ============================================================
echo   STABLE DIFFUSION DEBUG MODE
echo ============================================================
echo This script provides detailed diagnostic information
echo ============================================================
echo.

REM Change directory to the folder where this script is located
cd /d "%~dp0"

echo [DEBUG] Working Directory: %CD%
echo [DEBUG] Timestamp: %date% %time%
echo.

echo ============================================================
echo STEP 1: System Information
echo ============================================================
echo [DEBUG] Windows Version:
ver
echo.
echo [DEBUG] System Architecture:
wmic os get osarchitecture
echo.

echo ============================================================
echo STEP 2: Docker Installation Check
echo ============================================================
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not found in PATH
    echo [DEBUG] Docker installation directory not found
    pause
    goto :END
) else (
    echo [OK] Docker executable found
    for /f "tokens=*" %%i in ('where docker') do echo [DEBUG] Docker path: %%i
)
echo.

echo ============================================================
echo STEP 3: UI Configuration Check
echo ============================================================
if exist ".ui-config" (
    set /p WEBUI_TYPE=<.ui-config 2>nul
    echo [OK] UI Configuration found: %WEBUI_TYPE%
    if "%WEBUI_TYPE%"=="COMFYUI" (
        echo [INFO] ComfyUI configuration detected
        if not exist "docker-compose.comfyui.yml" (
            echo [WARNING] docker-compose.comfyui.yml not found!
        )
    )
) else (
    echo [WARNING] No UI configuration found (.ui-config missing)
    echo [INFO] Run start-sd.bat to configure UI selection
)

echo ============================================================
echo STEP 4: Docker Compose Version Detection
echo ============================================================
docker compose version >nul 2>&1
if %errorlevel% equ 0 (
    set COMPOSE_CMD=docker compose
    echo [OK] Docker Compose V2 detected
    docker compose version
) else (
    set COMPOSE_CMD=docker-compose
    echo [OK] Docker Compose V1 detected
    docker-compose --version
)
echo.

echo ============================================================
echo STEP 4: Docker Daemon Check
echo ============================================================
echo [*] Testing Docker daemon connection...
docker info
set DOCKER_STATUS=%errorlevel%
echo.
echo [DEBUG] Docker info exit code: %DOCKER_STATUS%

if %DOCKER_STATUS% neq 0 (
    echo [ERROR] Docker daemon is not running or not accessible
    echo [SUGGESTION] Start Docker Desktop manually and try again
    pause
echo [OK] Docker daemon is running
echo.

echo ============================================================
echo STEP 8: Directory Structure
echo ============================================================
echo [*] Checking project directories...
if exist "models" (
    echo [OK] models\ directory exists
    dir "models" /a-d /b 2>nul | find /c /v "" > temp_count.txt
    set /p MODEL_COUNT=<temp_count.txt
    del temp_count.txt
    echo [DEBUG] Files in models\: !MODEL_COUNT!
) else (
    echo [WARNING] models\ directory not found
)

if exist "outputs" (
    echo [OK] outputs\ directory exists
) else (
    echo [WARNING] outputs\ directory not found
)

if exist "extensions" (
    echo [OK] extensions\ directory exists
) else (
    echo [WARNING] extensions\ directory not found
)
echo.

echo ============================================================
echo STEP 9: Model Files Check
echo ============================================================
echo [INFO] Checking for model files in: %CD%\models\
echo.

echo [*] Checking for model files...
set MODEL_FOUND=0

if exist "models\*.safetensors" (
    echo [OK] Found .safetensors file(s):
    dir /b "models\*.safetensors"
    set MODEL_FOUND=1
) else (
    echo [WARNING] No .safetensors files found in models folder
)

if exist "models\*.ckpt" (
    echo [OK] Found .ckpt file(s):
    dir /b "models\*.ckpt"
    set MODEL_FOUND=1
) else (
    echo [WARNING] No .ckpt files found in models folder
)

if %MODEL_FOUND% equ 0 (
    echo [ERROR] No model files found! The WebUI may not work without models.
    echo [INFO] Place .safetensors or .ckpt files in the models\ folder
)
set MODEL_FOUND=0

echo [*] Checking for .safetensors files...
dir /b /s "models\*.safetensors" 2>nul
if %errorlevel% equ 0 (
    set MODEL_FOUND=1
    echo [OK] .safetensors model(s) found
    for %%F in ("models\*.safetensors") do (
        echo [DEBUG] File: %%~nxF
        echo [DEBUG] Size: %%~zF bytes
        echo [DEBUG] Modified: %%~tF
        echo.
    )
) else (
    echo [INFO] No .safetensors files found
)

echo [*] Checking for .ckpt files...
dir /b /s "models\*.ckpt" 2>nul
if %errorlevel% equ 0 (
    set MODEL_FOUND=1
    echo [OK] .ckpt model(s) found
    for %%F in ("models\*.ckpt") do (
        echo [DEBUG] File: %%~nxF
        echo [DEBUG] Size: %%~zF bytes
        echo [DEBUG] Modified: %%~tF
        echo.
    )
) else (
    echo [INFO] No .ckpt files found
)

if %MODEL_FOUND% equ 0 (
    echo [WARNING] No model files found in models folder
    echo [INFO] Place .safetensors or .ckpt files in the models\ folder
)
echo.

echo ============================================================
echo STEP 10: UI Configuration Check
echo ============================================================
if exist ".ui-config" (
    set /p WEBUI_TYPE=<.ui-config 2>nul
    echo [OK] UI Configuration found: %WEBUI_TYPE%
    if "%WEBUI_TYPE%"=="COMFYUI" (
        echo [INFO] ComfyUI configuration detected
        if not exist "docker-compose.comfyui.yml" (
            echo [WARNING] docker-compose.comfyui.yml not found!
        )
    )
) else (
    echo [WARNING] No UI configuration found (.ui-config missing)
    echo [INFO] Run start-sd.bat to configure UI selection
)

echo ============================================================
echo STEP 11: Docker Compose Version Detection
echo ============================================================
docker compose version >nul 2>&1
if %errorlevel% equ 0 (
    set COMPOSE_CMD=docker compose
    echo [OK] Docker Compose V2 detected
    docker compose version
) else (
    set COMPOSE_CMD=docker-compose
    echo [OK] Docker Compose V1 detected
    docker-compose --version
)
echo.

echo ============================================================
echo STEP 12: Docker Daemon Check
echo ============================================================
echo [*] Testing Docker daemon connection...
docker info
set DOCKER_STATUS=%errorlevel%
echo.
echo [DEBUG] Docker info exit code: %DOCKER_STATUS%

if %DOCKER_STATUS% neq 0 (
    echo [ERROR] Docker daemon is not running or not accessible
    echo [SUGGESTION] Start Docker Desktop manually and try again
    pause
    goto :END
)
echo [OK] Docker daemon is running
echo.

echo ============================================================
echo STEP 13: Docker Network Check
echo ============================================================
echo [*] Checking Docker networks...
docker network ls
echo.

echo ============================================================
echo STEP 14: Container Status
echo ============================================================
echo [*] Checking for stable-diffusion container...
docker ps -a --filter "name=stable-diffusion" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.

echo ============================================================
echo STEP 15: Port Availability Check
echo ============================================================
echo [*] Checking if port 7860 is available...
netstat -ano | findstr :7860 >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARNING] Port 7860 is already in use:
    netstat -ano | findstr :7860
    echo.
    echo [SUGGESTION] Close the application using port 7860, or
    echo [SUGGESTION] Edit docker-compose.automatic1111.yml to use a different port
) else (
    echo [OK] Port 7860 is available
)
echo.

echo ============================================================
echo STEP 14: Disk Space Check
echo ============================================================
echo [*] Checking available disk space...
for /f "tokens=3" %%a in ('dir /-c "%~d0" ^| findstr /C:"bytes free"') do set FREE_SPACE=%%a
echo [DEBUG] Free space on %~d0: %FREE_SPACE% bytes
echo.

echo ============================================================
echo STEP 15: NVIDIA Driver Check
echo ============================================================
echo [*] Checking for NVIDIA drivers on host...
nvidia-smi >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] NVIDIA drivers detected on Windows host
    nvidia-smi
) else (
    echo [WARNING] nvidia-smi not found on Windows host
    echo [SUGGESTION] Install latest NVIDIA GPU drivers from:
    echo [SUGGESTION] https://www.nvidia.com/Download/index.aspx
)
echo.

echo ============================================================
echo DEBUG SESSION COMPLETE
echo ============================================================
echo [*] If the WebUI is running, access it at: http://localhost:7860
echo [*] Review the output above for any errors or warnings
echo.
echo SUMMARY:
if %MODEL_FOUND% equ 1 (
    echo - Models: OK
) else (
    echo - Models: MISSING
)

docker ps --filter "name=stable-diffusion" --filter "status=running" >nul 2>&1
if %errorlevel% equ 0 (
    echo - Container: RUNNING
) else (
    echo - Container: NOT RUNNING
)

if exist "docker\docker-compose.automatic1111.yml" (
    echo - Configuration: OK
) else (
    echo - Configuration: MISSING
)
echo.

:END
pause