@echo off
setlocal enabledelayedexpansion
title AI Generator - One-Click Launcher

REM ============================================================
REM Change to script directory
REM ============================================================
cd /d "%~dp0"

REM ============================================================
REM STEP 0: UI Configuration Management
REM ============================================================
set "WEBUI_TYPE="
set "VALID_UIS=AUTOMATIC1111 COMFYUI FOOOCUS"

REM Check if .ui-config exists and read it
if exist ".ui-config" (
    set /p WEBUI_TYPE=<.ui-config
    
    REM Trim whitespace
    for /f "tokens=* delims= " %%a in ("!WEBUI_TYPE!") do set WEBUI_TYPE=%%a
    
    REM Validate the UI type
    set "UI_VALID=0"
    for %%U in (%VALID_UIS%) do (
        if /i "!WEBUI_TYPE!"=="%%U" set "UI_VALID=1"
    )
    
    if "!UI_VALID!"=="0" (
        echo [WARNING] Invalid UI configuration found: [!WEBUI_TYPE!]
        set "WEBUI_TYPE="
    )
)

REM If no valid UI type, run selector
if "!WEBUI_TYPE!"=="" (
    echo [*] No valid UI configuration found
    echo [*] Running UI selection...
    echo.
    
    if not exist "select-ui.cmd" (
        echo [ERROR] select-ui.cmd is missing!
        echo [SUGGESTION] Restore select-ui.cmd from the original package
        pause
        exit /b 1
    )
    
    call select-ui.cmd
    if errorlevel 1 (
        echo [ERROR] UI selection failed
        pause
        exit /b 1
    )
    
    REM Read the newly saved configuration
    if exist ".ui-config" (
        set /p WEBUI_TYPE=<.ui-config
        for /f "tokens=* delims= " %%a in ("!WEBUI_TYPE!") do set WEBUI_TYPE=%%a
    ) else (
        echo [ERROR] UI configuration was not saved
        pause
        exit /b 1
    )
)

REM ============================================================
REM DOCKER-BASED UIs (Automatic1111, ComfyUI, FOOOCUS)
REM ============================================================

REM Set port and config based on UI type
if /i "!WEBUI_TYPE!"=="COMFYUI" (
    set "WEBUI_PORT=8188"
    set "COMPOSE_FILE=docker-compose.comfyui.yml"
    set "CONTAINER_NAME=comfyui"
) else if /i "!WEBUI_TYPE!"=="FOOOCUS" (    
    set "WEBUI_PORT=7865"
    set "CONTAINER_NAME=fooocus"
    
    echo ============================================================
    echo   Setting up Fooocus with Docker
    echo ============================================================
    echo.
) 
    if not exist "fooocus" (
        echo [*] Cloning Fooocus repository...
        git clone https://github.com/lllyasviel/Fooocus.git fooocus
        if errorlevel 1 (
            echo [ERROR] Failed to clone Fooocus repository
            exit /b 1
        )
        cd fooocus
        git pull
        cd ..
    )
    
cd fooocus
echo [*] Starting Fooocus with Docker...
echo [*] This will take 5-10 minutes on first run...
echo.

echo ============================================================
echo   AI Generator - One-Click Launcher
echo   UI: !WEBUI_TYPE! ^| Port: !WEBUI_PORT!
echo ============================================================
echo.

echo [*] Building and starting Fooocus container...
docker compose up -d --build

if %errorlevel% equ 0 (
    echo.
    echo ============================================================
    echo    SUCCESS! FOOOCUS is Running
    echo ============================================================
    echo.
    echo    Access URL: http://localhost:!WEBUI_PORT!
    echo.
    echo    TIPS:
    echo    - First startup may take 2-5 minutes - If it hasn't loaded yet, wait 1 minute and refresh
    echo    - To stop: Close Docker Desktop or run: docker compose down
    echo    - To view logs: docker compose logs -f
    echo    - To switch UI: Close this window and run select-ui.cmd
    echo.
    echo ============================================================
    echo.
    
    start "" http://localhost:!WEBUI_PORT!
    echo [*] Opening browser...
    echo.
) else (
    echo.
    echo ============================================================
    echo    ERROR: Failed to start Fooocus container
    echo ============================================================
    echo.
    echo    Please check the error messages above for details.
    echo.
)

pause
exit /b 0

REM ============================================================
REM STEP 0: Detect Docker Compose version
REM ============================================================
echo [*] Detecting Docker Compose version...
docker compose version >nul 2>&1
if %errorlevel% equ 0 (
    set "COMPOSE_CMD=docker compose"
    echo [OK] Using Docker Compose V2
) else (
    docker-compose --version >nul 2>&1
    if %errorlevel% equ 0 (
        set "COMPOSE_CMD=docker-compose"
        echo [OK] Using Docker Compose V1
     )  else (
        echo [ERROR] Docker Compose not found
        pause
        exit /b 1
    )
)
echo.

REM ============================================================
REM STEP 1: Check if Docker is running
REM ============================================================
echo [STEP 1/4] Checking if Docker is running...
docker info >nul 2>&1
if %errorlevel% neq 0 goto DOCKER_NOT_RUNNING
echo [OK] Docker is running
echo.
goto DOCKER_RUNNING
{{ ... }}
:DOCKER_NOT_RUNNING
echo [*] Docker is not running. Attempting to start Docker Desktop...

REM Try to start Docker Desktop
if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" (
    start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
    echo [*] Docker Desktop launch initiated...
    goto DOCKER_WAIT
)
if exist "%ProgramW6432%\Docker\Docker\Docker Desktop.exe" (
    start "" "%ProgramW6432%\Docker\Docker\Docker Desktop.exe"
    echo [*] Docker Desktop launch initiated...
    goto DOCKER_WAIT
)
echo [ERROR] Could not find Docker Desktop executable

:DOCKER_WAIT
echo [*] Waiting for Docker to start...
set DOCKER_RETRIES=0

:DOCKER_WAIT_LOOP
timeout /t 5 /nobreak >nul
docker info >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker is now running!
    goto DOCKER_RUNNING
)

set /a DOCKER_RETRIES+=1
if !DOCKER_RETRIES! lss 12 (
    echo [*] Still waiting... (attempt !DOCKER_RETRIES!/12)
    goto DOCKER_WAIT_LOOP
)

echo.
echo ============================================================
echo [ERROR] Docker failed to start automatically
echo ============================================================
echo.
echo SOLUTION:
echo 1. Manually open Docker Desktop from Start Menu
echo 2. Wait for Docker to fully start
echo 3. Run this script again
pause
exit /b 1

:DOCKER_RUNNING

REM ============================================================
REM STEP 1: Setup directories
REM ============================================================
echo [STEP 1/4] Setting up directories...
if not exist "models" mkdir models
if not exist "outputs" mkdir outputs
if not exist "extensions" mkdir extensions
echo [OK] Directories ready
echo.

REM ============================================================
REM STEP 2: Check for models (recursive)
REM ============================================================
echo [STEP 2/4] Checking for AI models...

if /i "!WEBUI_TYPE!"=="FOOOCUS" (
    echo [*] Checking for Fooocus models...
    set "FOOOCUS_MODEL=0"
    set "FOOOCUS_VAE=0"
    
    if exist "models\fooocus_diffusion.safetensors" set "FOOOCUS_MODEL=1"
    if exist "models\fooocus_v2.1.safetensors" set "FOOOCUS_VAE=1"
    
    if !FOOOCUS_MODEL! equ 1 if !FOOOCUS_VAE! equ 1 (
        echo [OK] All required Fooocus models found
        echo.
        goto MODEL_CHECK_DONE
    )
    
    echo [WARNING] Some Fooocus models are missing:
    if !FOOOCUS_MODEL! equ 0 echo  - fooocus_diffusion.safetensors (main model, ~4GB)
    if !FOOOCUS_VAE! equ 0 echo  - fooocus_v2.1.safetensors (VAE, ~3GB)
    echo.
    echo [*] These models are required for Fooocus to work properly.
    echo.
    choice /C YN /N /M "Download missing Fooocus models now? (~7GB total) [Y/N]: "
    if errorlevel 2 (
        echo [*] Skipping model download
        echo [WARNING] Fooocus will not work without these models
        goto MODEL_CHECK_DONE
    )
    
    call "%~dp0download-fooocus-model.bat"
    if errorlevel 1 (
        echo [ERROR] Failed to download Fooocus models
        pause
        exit /b 1
    )
    goto MODEL_CHECK_DONE
) else (
    REM Standard model check for other UIs
set MODEL_FOUND=0

dir /b /s "models\*.safetensors" >nul 2>&1
if %errorlevel% equ 0 set MODEL_FOUND=1

dir /b /s "models\*.ckpt" >nul 2>&1
if %errorlevel% equ 0 set MODEL_FOUND=1

if !MODEL_FOUND! equ 1 (
    echo [OK] Model files found
    echo.
    goto MODEL_CHECK_DONE
)

echo [*] No model files found
echo.
choice /C YN /N /M "Download default Stable Diffusion v1.5 model (~4.3GB)? [Y/N]: "
    if errorlevel 2 (
        echo [*] Skipping model download
        echo [WARNING] You will need a model to generate images
        goto MODEL_CHECK_DONE
    )

call "%~dp0download-model.bat"
if errorlevel 1 (
    echo [ERROR] Model download failed
    pause
    exit /b 1
)
)

:MODEL_CHECK_DONE
echo.

REM ============================================================
REM STEP 3: Check port availability
REM ============================================================
echo [STEP 3/4] Checking port !WEBUI_PORT! availability...
netstat -ano | findstr :!WEBUI_PORT! >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARNING] Port !WEBUI_PORT! is already in use
    echo.
{{ ... }}
) else (
    echo [OK] Port !WEBUI_PORT! is available
)
echo.

REM ============================================================
REM Clean up stopped containers
REM ============================================================
echo [*] Cleaning up stopped containers...
docker ps -a --filter "name=!CONTAINER_NAME!" --filter "status=exited" --format "{{.Names}}" 2>nul | findstr /C:"!CONTAINER_NAME!" >nul 2>&1
if %errorlevel% equ 0 (
    docker rm !CONTAINER_NAME! >nul 2>&1
    echo [OK] Stopped container removed
)
echo.

REM ============================================================
REM Start Docker container
REM ============================================================
echo [*] Starting !WEBUI_TYPE! container...
echo [*] This may take a few minutes on first run...
echo.

!COMPOSE_CMD! -f !COMPOSE_FILE! up -d 2>docker-error.log
if %errorlevel% neq 0 (
{{ ... }}
    echo ============================================================
    echo [ERROR] Failed to start container
    echo ============================================================
    type docker-error.log 2>nul
    echo.
    echo SUGGESTIONS:
    echo 1. Update NVIDIA GPU drivers
    echo 2. Enable GPU in Docker Desktop Settings
    echo 3. Run debug-sd.bat for detailed diagnostics
    echo ============================================================
    pause
    exit /b 1
)

echo [OK] Container started successfully
echo [*] Waiting for initialization (15 seconds)...
timeout /t 15 /nobreak >nul

REM Verify container is running
docker ps --filter "name=!CONTAINER_NAME!" --filter "status=running" --format "{{.Names}}" 2>nul | findstr /C:"!CONTAINER_NAME!" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [WARNING] Container may not be running properly
    echo [*] Checking logs...
    docker logs !CONTAINER_NAME! --tail 30
    pause
    exit /b 1
)

REM Clean up error log
if exist "docker-error.log" del "docker-error.log" >nul 2>&1

:SUCCESS_MESSAGE
echo.
echo ============================================================
echo   SUCCESS! !WEBUI_TYPE! is Running
echo ============================================================
echo.
echo   Access URL: http://localhost:!WEBUI_PORT!
echo.
echo   TIPS:
echo   - First startup may take 5-10 minutes
echo   - To stop: !COMPOSE_CMD! -f !COMPOSE_FILE! down or close Docker Desktop.
echo   - To view logs: docker logs !CONTAINER_NAME! -f
echo   - To switch UI: Run select-ui.cmd
echo.
echo ============================================================
echo.

REM Open browser
start "" http://localhost:!WEBUI_PORT!
echo [*] Opening browser...
echo.

pause
exit /b 0