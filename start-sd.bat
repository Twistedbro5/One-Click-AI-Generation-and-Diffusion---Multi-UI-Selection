@echo off
setlocal enabledelayedexpansion
title AI Image Generation - One-Click Launcher

REM Set configuration file path (local)
set "CONFIG_FILE=.ui-config"

REM Change to the script's directory to ensure relative paths work
pushd "%~dp0"

REM Check for UI configuration
if not exist "%CONFIG_FILE%" (
    call "%~dp0select-ui.cmd"
    if errorlevel 1 (
        echo [ERROR] Failed to select UI
        pause
        popd
        exit /b 1
    )
)
set /p WEBUI_TYPE=<"%CONFIG_FILE%"

echo ============================================================
echo   Stable Diffusion WebUI - One-Click Launcher
echo   [%WEBUI_TYPE%] Mode
echo ============================================================
echo.

REM Already changed directory earlier
echo [*] Working Directory: %CD%
echo.

REM ============================================================
REM STEP 0: Detect Docker Compose version
REM ============================================================
docker compose version >nul 2>&1
if %errorlevel% equ 0 (
    set COMPOSE_CMD=docker compose
    echo [*] Using Docker Compose V2
) else (
    set COMPOSE_CMD=docker-compose
    echo [*] Using Docker Compose V1
)
echo.

REM ============================================================
REM STEP 1: Check if Docker is installed
REM ============================================================
echo [STEP 1/5] Checking Docker installation...
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo [ERROR] Docker is not installed or not in PATH
    echo ============================================================
    echo Docker Desktop is required to run this application.
    echo.
    echo SOLUTION:
    echo 1. Download Docker Desktop from:
    echo    https://www.docker.com/products/docker-desktop
    echo 2. Install Docker Desktop
    echo 3. Restart your computer
    echo 4. Run this script again
    echo ============================================================
    pause
    goto :ERROR_EXIT
)
echo [OK] Docker is installed
echo.

REM ============================================================
REM STEP 2: Check if Docker is running
REM ============================================================
echo [STEP 2/5] Checking if Docker is running...
docker info >nul 2>&1
if %errorlevel% neq 0 goto DOCKER_NOT_RUNNING
echo [OK] Docker is running
echo.
goto DOCKER_RUNNING

:DOCKER_NOT_RUNNING
echo [*] Docker is not running. Attempting to start Docker Desktop...

REM Try to start Docker Desktop from common installation paths
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
echo [WARNING] Could not find Docker Desktop executable

:DOCKER_WAIT
echo [*] Waiting for Docker to start (checking every 5 seconds)...
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
    echo [*] Still waiting (attempt !DOCKER_RETRIES!/12)
    goto DOCKER_WAIT_LOOP
)

echo.
echo ============================================================
echo [ERROR] Docker failed to start automatically
echo ============================================================
echo Docker Desktop did not start within 60 seconds.
echo.
echo SOLUTION:
echo 1. Manually open Docker Desktop from your Start Menu
echo 2. Wait for Docker Desktop to fully start (whale icon in system tray)
echo 3. Run this script again
echo.
echo TROUBLESHOOTING:
echo - Make sure WSL 2 is installed and enabled
echo - Check if virtualization is enabled in BIOS
echo - Restart your computer and try again
echo ============================================================
pause
goto :ERROR_EXIT

:DOCKER_RUNNING

REM ============================================================
REM STEP 3: Setup directories
REM ============================================================
echo [STEP 3/5] Setting up directories...
if not exist "models" (
    mkdir models
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to create models directory
        echo [SUGGESTION] Check folder permissions
        pause
        goto :ERROR_EXIT
    )
    echo [*] Created: models\
)
if not exist "outputs" (
    mkdir outputs
    echo [*] Created: outputs\
)
if not exist "extensions" (
    mkdir extensions
    echo [*] Created: extensions\
)
echo [OK] Directories ready
echo.

REM ============================================================
REM STEP 4: Check for model file (FIXED)
REM ============================================================
echo [STEP 4/5] Checking for Stable Diffusion model...

REM Check if any model files exist in the models folder (FIXED LOGIC)
set MODEL_FOUND=0
dir /b /s "models\*.safetensors" >nul 2>&1
if %errorlevel% equ 0 set MODEL_FOUND=1
dir /b /s "models\*.ckpt" >nul 2>&1
if %errorlevel% equ 0 set MODEL_FOUND=1

if %MODEL_FOUND% equ 1 goto MODEL_EXISTS

REM No models found
echo [*] No AI models found in the models\ folder
echo.
echo ============================================================
echo Download the default Stable Diffusion v1.5 model
echo ============================================================
echo This will download approximately 4.3GB - Type Y to Continue
echo. 
echo If you already have a model file, you can:
echo - Press N to skip download
echo - Manually place your .safetensors or .ckpt file in the models\ folder - then run this script again
echo.
choice /C YN /N /M "Download default model now? [Y/N]: "

if errorlevel 2 goto SKIP_MODEL_DOWNLOAD
if errorlevel 1 goto DO_MODEL_DOWNLOAD

:DO_MODEL_DOWNLOAD
echo.
echo [*] Starting download process...
echo.
call "%~dp0download-model.bat"
if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo [ERROR] Model download failed
    echo ============================================================
    echo Please follow the instructions above to resolve the issue.
    echo You can run this script again later, or manually place
    echo a model file in the models\ folder.
    echo ============================================================
    pause
    goto :ERROR_EXIT
)
goto MODEL_CHECK_DONE

:SKIP_MODEL_DOWNLOAD
echo.
echo [*] Skipping model download
echo [*] Note: You will need to place a model file in the models\ folder
echo [*] The WebUI will start, but you won't be able to generate images
echo [*] until you add a model and restart the container
echo.
goto MODEL_CHECK_DONE

:MODEL_EXISTS
echo [OK] Model file(s) found in models\ folder

:MODEL_CHECK_DONE
echo.

REM ============================================================
REM STEP 4.5: Clean up stopped containers (NEW)
REM ============================================================
echo [*] Checking for stopped containers...
REM Clean up stopped containers for all possible container names
for %%c in (stable-diffusion fooocus) do (
    docker ps -a --filter "name=%%c" --filter "status=exited" --format "{{.Names}}" 2>nul | findstr /C:"%%c" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [*] Removing stopped container: %%c
        docker rm %%c >nul 2>&1
    )
)

REM ============================================================
REM STEP 5: Start Docker container
REM ============================================================
echo [STEP 5/5] Starting Stable Diffusion WebUI container...
echo [*] This may take a few minutes on first run...
echo.

if "%WEBUI_TYPE%"=="COMFYUI" (
    set WEBUI_PORT=8188
    %COMPOSE_CMD% -f docker-compose.comfyui.yml up -d 2>docker-error.log
) else if "%WEBUI_TYPE%"=="FOOOCUS" (
    set WEBUI_PORT=7860
    %COMPOSE_CMD% -f docker-compose.fooocus.yml up -d 2>docker-error.log
) else (
    set WEBUI_PORT=7860
    %COMPOSE_CMD% up -d 2>docker-error.log
)
if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo [ERROR] Failed to start Docker container
    echo ============================================================
    echo Docker Compose encountered an error.
    echo.
    echo ERROR DETAILS:
    type docker-error.log 2>nul
    echo.
    echo COMMON CAUSES:
    echo - NVIDIA GPU drivers not installed or outdated
    echo - Docker doesn't have GPU access enabled
    echo - Port 7860 is already in use
    echo - Insufficient system resources
    echo.
    echo SUGGESTIONS:
    echo 1. Update NVIDIA GPU drivers to latest version
    echo 2. In Docker Desktop: Settings ^> Resources ^> Enable GPU
    echo 3. Close other applications using port 7860
    echo 4. Run '%COMPOSE_CMD% logs' for detailed error info
    echo 5. Run debug-sd.bat for detailed diagnostics
    echo ============================================================
    pause
    goto :ERROR_EXIT
)

echo [*] Container started successfully!
echo [*] Waiting for WebUI to initialize (10 seconds)...
timeout /t 10 /nobreak >nul

REM Check if container is actually running
if "%WEBUI_TYPE%"=="FOOOCUS" (
    set CONTAINER_NAME=fooocus
) else (
    set CONTAINER_NAME=stable-diffusion
)
docker ps --filter "name=%CONTAINER_NAME%" --filter "status=running" --format "{{.Names}}" 2>nul | findstr /C:"%CONTAINER_NAME%" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo [WARNING] Container may not be running properly
    echo ============================================================
    echo The container started but may have encountered an error.
    echo.
    echo CHECKING CONTAINER STATUS:
    docker ps -a --filter "name=stable-diffusion"
    echo.
    echo CHECKING CONTAINER LOGS:
    docker logs stable-diffusion --tail 50
    echo.
    echo SUGGESTIONS:
    echo 1. Check the logs above for specific errors
    echo 2. Run debug-sd.bat for detailed diagnostics
    echo 3. Check if GPU is properly detected
    echo ============================================================
    pause
    goto :ERROR_EXIT
)

echo.
if exist "docker-error.log" del "docker-error.log" >nul 2>&1
if "%WEBUI_TYPE%"=="FOOOCUS" (
    set WEBUI_NAME=Fooocus
    set WEBUI_EXTRA=.fooocus
) else if "%WEBUI_TYPE%"=="COMFYUI" (
    set WEBUI_NAME=ComfyUI
    set WEBUI_EXTRA=.comfyui
) else (
    set WEBUI_NAME=Stable Diffusion WebUI
    set WEBUI_EXTRA=
)

echo ============================================================
echo   SUCCESS! %WEBUI_NAME% is Running
echo ============================================================
echo.
echo   Access the WebUI at: http://localhost:%WEBUI_PORT%
echo.
echo   NOTES:
   - First startup may take 2-5 minutes to fully initialize
   - Browser will open automatically
   - If page shows "connection refused", wait a bit longer
echo.
echo   MANAGEMENT:
   - To stop:  %COMPOSE_CMD% -f docker-compose%WEBUI_EXTRA%.yml down
   - To view logs:  docker logs %CONTAINER_NAME%
   - To restart: Run this script again
echo.
echo   The system is now running OFFLINE - no internet required!
echo ============================================================
echo.

{{ ... }}
start "" http://localhost:%WEBUI_PORT%
echo [*] Opening browser to http://localhost:%WEBUI_PORT%...
echo.

popd
pause
exit /b 0

:ERROR_EXIT
popd
echo.
echo [*] Script ended with errors. Press any key to exit.
pause >nul
exit /b 1