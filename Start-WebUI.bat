@echo off
setlocal enabledelayedexpansion
title Generative AI WebUI Launcher - One-Click Solution
color 0A

REM ============================================================
REM MAIN SCRIPT START
REM ============================================================
:MAIN

REM Enable ANSI escape sequences for colored output
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

REM Define color codes
set "CYAN=[96m"
set "BOLD=[1m"
set "RESET=[0m"

REM Change to script directory
cd /d "%~dp0"

REM ============================================================
REM WELCOME SCREEN
REM ============================================================
cls
echo.
echo ============================================================
echo            Generative AI WebUI Launcher - Welcome!
echo ============================================================
echo This is a **one-click solution** to run AI Image/Video Generation and Editing on your computer.
echo It's like having Midjourney or DALL-E on your own PC, completely free and offline!
echo You can use it to Edit/Generate **any** Style of Image or Video, as well as installing any AI Model you desire.
echo.
echo [*] Initializing system checks...
echo.
timeout /t 2 /nobreak >nul

:PREREQUISITES_CHECK
REM ============================================================
REM STEP 1: Check Git (always needed)
REM ============================================================
title AI WebUI Launcher - Checking Prerequisites
cls
echo.
echo ============================================================
echo            AI WebUI Launcher - System Check
echo ============================================================
echo.
echo [STEP 1/6] Checking prerequisites...
echo.

set GIT_INSTALLED=0
set NEED_GIT_INSTALL=0

REM Check for Git
echo [*] Checking for Git...
git --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Git is installed
    set GIT_INSTALLED=1
) else (
    echo [!] Git is NOT installed
    set NEED_GIT_INSTALL=1
)

echo.

REM If Git is missing, offer to install
if "%NEED_GIT_INSTALL%"=="1" (
    echo ============================================================
    echo   Git Installation Required
    echo ============================================================
    echo.
    echo Git is required for all AI WebUIs to function properly.
    echo.
    echo I can install it for you quickly and safely using Windows Package Manager.
    echo.
    choice /C YN /N /M "Would you like me to install Git? [Y/N]: "
    if errorlevel 2 (
        echo.
        echo [*] Installation cancelled
        echo [*] To use this program, please install Git from: https://git-scm.com/download/win
        echo [*] Then run Start-WebUI.bat again
        pause
        exit /b 0
    )
    
    echo.
    echo [*] Installing Git using Windows Package Manager...
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    
    REM Add a small delay to ensure installation completes
    timeout /t 3 /nobreak >nul
    
    REM Refresh environment variables
    call :RefreshEnv
    
    REM Verify installation
    git --version >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Git installed successfully
        set GIT_INSTALLED=1
    ) else (
        echo [ERROR] Git installation may have failed
        echo [*] You may need to restart your computer
        echo [*] Or install Git manually from: https://git-scm.com/
        pause
        exit /b 1
    )
    echo.
    
    REM Git requires script restart
    echo ============================================================
    echo   Restart Required
    echo ============================================================
    echo.
    echo Git was installed successfully.
    echo.
    echo [!] Please close this Terminal and run Start-WebUI.bat again for changes to take effect.
    echo.
    pause
    exit /b 0
)

echo [OK] Git is ready
echo.

REM ============================================================
REM STEP 2: UI Configuration Management
REM ============================================================
title AI WebUI Launcher - Selecting UI...
echo [STEP 2/6] Configuring UI selection...
echo.

set "WEBUI_TYPE="
set "VALID_UIS=AUTOMATIC1111 COMFYUI FOOOCUS"
set "CONFIG_FILE=webui_config.cfg"

REM Check if config file exists and read it
if exist "%CONFIG_FILE%" (
    for /f "usebackq tokens=2 delims==" %%a in (`findstr /b /i "DEFAULT_UI" "%CONFIG_FILE%" 2^>nul`) do (
        set "WEBUI_TYPE=%%a"
        REM Remove quotes and trim spaces
        set "WEBUI_TYPE=!WEBUI_TYPE:"=!"
        for /f "tokens=*" %%b in ("!WEBUI_TYPE!") do set "WEBUI_TYPE=%%~b"
        echo [DEBUG] Read WEBUI_TYPE from config: [!WEBUI_TYPE!]
    )
) else (
    echo [ERROR] Config file not found at: %CD%\%CONFIG_FILE%
)

REM Validate the UI type
if defined WEBUI_TYPE (
    set UI_VALID=0
    for %%U in (%VALID_UIS%) do (
        if /i "!WEBUI_TYPE!"=="%%U" set UI_VALID=1
    )
    if !UI_VALID! equ 0 (
        echo [WARNING] Invalid UI configuration found: [!WEBUI_TYPE!]
        set "WEBUI_TYPE="
    )
)

REM If no valid UI type, show selection menu
if not defined WEBUI_TYPE (
    :UI_SELECTION_MENU
    cls
    echo.
    echo ============================================================
    echo            AI WebUI Launcher - UI Selection
    echo ============================================================
    echo.
    echo Please select an AI interface:
    echo.
    echo 1. AUTOMATIC1111 ~5GB
    echo    - Includes Stable Diffusion 1.5
    echo    - Simple, Small, Beginner Friendly for low specs
    echo    - Can be expanded with better AI models and Extensions
    echo.
    echo 2. Fooocus ~25-30GB - ^(RECOMMENDED^)
    echo    - Includes JuggernautXL
    echo    - Modern UI, optimized defaults
    echo    - Pre-Trained Style selection, best results out-of-box
    echo.
    echo 3. ComfyUI ~6GB
    echo    - Includes the Base for Professional Video/Image/Music/Animation Processing
    echo    - Node-based Workflow Interface for ADVANCED users
    echo    - Complete Control with Blueprint-style workflows
    echo.
    
    :GET_UI_CHOICE
    set "choice="
    set /p "choice=Enter your choice (1-3): "
    
    if not defined choice (
        echo [ERROR] No input received. Please enter a number between 1 and 3.
        timeout /t 1 >nul
        goto GET_UI_CHOICE
    )
    
    set "choice=!choice: =!"
    
    if "!choice!"=="1" (
        set "WEBUI_TYPE=AUTOMATIC1111"
    ) else if "!choice!"=="2" (
        set "WEBUI_TYPE=FOOOCUS"
    ) else if "!choice!"=="3" (
        set "WEBUI_TYPE=COMFYUI"
    ) else (
        echo [ERROR] Invalid selection: !choice!. Please enter 1, 2, or 3.
        timeout /t 1 >nul
        goto UI_SELECTION_MENU
    )
    
    REM Save to config file
    echo # AI WebUI Configuration> "%CONFIG_FILE%"
    echo # This file stores the user's preferred WebUI selection>> "%CONFIG_FILE%"
    echo # Do not modify this file manually>> "%CONFIG_FILE%"
    echo.>> "%CONFIG_FILE%"
    echo DEFAULT_UI=!WEBUI_TYPE!>> "%CONFIG_FILE%"
)

echo [OK] Using UI: !WEBUI_TYPE!
echo.

REM Go To the correct section based on UI type
if /i "!WEBUI_TYPE!"=="COMFYUI" goto Handle_ComfyUI

REM Set port and config based on UI type
if /i "!WEBUI_TYPE!"=="AUTOMATIC1111" (
    set "WEBUI_PORT=7860"
    set "COMPOSE_FILE=Docker\docker-compose.automatic1111.yml"
    set "CONTAINER_NAME=stable-diffusion"
    set "DATA_DIR=Automatic1111"
    set "NEEDS_DOCKER=1"
)
if /i "!WEBUI_TYPE!"=="FOOOCUS" (
    set "WEBUI_PORT=7865"
    set "COMPOSE_FILE=Docker\docker-compose.fooocus.yml"
    set "CONTAINER_NAME=fooocus"
    set "DATA_DIR=Fooocus"
    set "NEEDS_DOCKER=1"
)

REM ============================================================
REM STEP 2.5: Check Docker (only if needed)
REM ============================================================
if not "!NEEDS_DOCKER!"=="1" goto DOCKER_VERIFIED

echo [STEP 2.5/6] Checking Docker - Required for !WEBUI_TYPE!
echo.

REM Check for Docker
echo [*] Checking for Docker...
docker --version >nul 2>&1
if errorlevel 1 goto INSTALL_DOCKER

echo [OK] Docker is installed
goto CHECK_DOCKER_RUNNING

:INSTALL_DOCKER
echo [!] Docker is NOT installed
echo.
echo ============================================================
echo   Docker Desktop Required
echo ============================================================
echo.
echo Docker Desktop is required to run !WEBUI_TYPE!.
echo Download size: approx. 5 GB - This is to seperate the service from the rest of your system
echo.
echo I can install it for you quickly and safely.
echo.
choice /C YN /N /M "Would you like me to install Docker Desktop? [Y/N]: "
if errorlevel 2 (
    echo.
    echo [*] Docker installation cancelled
    echo [*] Install manually from: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

echo.
echo [*] Checking for Windows Package Manager...
winget --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Windows Package Manager not available
    echo [*] Install manually from: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

echo [OK] Winget available
echo.
echo [*] Installing Docker Desktop...
echo [!] This may take several minutes...
winget install --id Docker.DockerDesktop -e --source winget --accept-package-agreements --accept-source-agreements

timeout /t 5 /nobreak >nul
call :RefreshEnv

docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker installation may have failed
    echo [*] Restart your computer and run this script again
    echo [*] Or install manually from: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

echo [OK] Docker Desktop installed successfully
echo [!] RESTART REQUIRED - Please restart your computer
pause
exit /b 0

:CHECK_DOCKER_RUNNING
REM ============================================================
REM Check WSL 2
REM ============================================================
echo [*] Checking for WSL 2...
where wsl >nul 2>&1
if errorlevel 1 (
    echo [!] WSL 2 is NOT installed
    echo [*] Installing WSL 2...
    wsl --install --no-distribution
    if not errorlevel 1 (
        echo [OK] WSL 2 installed
        echo [!] RESTART REQUIRED - Please restart your computer
        pause
        exit /b 0
    )
    echo [WARNING] WSL 2 installation may have failed
    echo [INFO] Install manually: Open PowerShell as Admin and run: wsl --install --no-distribution
    echo.
) else (
    echo [OK] WSL 2 is installed
)

REM ============================================================
REM Check Virtual Machine Platform
REM ============================================================
echo [*] Checking Virtual Machine Platform...
wsl --status >nul 2>&1
if errorlevel 1 (
    echo [INFO] Cannot verify Virtual Machine Platform
    echo [INFO] If Docker fails, enable it manually:
    echo        1. Press Win+R and type: optionalfeatures
    echo        2. Check "Virtual Machine Platform"
    echo        3. Restart your computer
    echo.
) else (
    echo [OK] Virtual Machine Platform enabled
)

echo [OK] Docker prerequisites ready
echo.
  
REM ============================================================
REM Check Docker Status and Start if Needed
REM ============================================================
echo [*] Verifying Docker status...

:CHECK_DOCKER_RUNNING
docker info >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker is running
    goto DOCKER_READY
)

echo [!] Docker is not running
echo [*] Attempting to start Docker Desktop...

REM Method 1: Try direct executable first
if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" (
    echo [*] Starting Docker Desktop directly... Hit 'skip' if it asks for login... One Moment!
    start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
    set errorlevel=0
    timeout /t 10 /nobreak >nul
    
    REM Check if Docker started
    docker info >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Docker started successfully! Hit 'skip' if it asks for login...
        goto DOCKER_READY
    )
)

REM Method 2: Fallback to winget
echo [*] Trying to start Docker via winget...
set errorlevel=0
winget run --id Docker.DockerDesktop >nul 2>&1
timeout /t 5 /nobreak >nul

REM Final check
docker info >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker started via winget
    goto DOCKER_READY
)

echo [ERROR] Failed to start Docker
echo.
echo Please try starting Docker Desktop manually and run this script again.
pause
exit /b 1

:DOCKER_READY
echo [OK] Docker is ready
echo.

REM ============================================================
REM Verify Docker Compose
REM ============================================================
echo [*] Verifying Docker Compose...

REM Try V2 first (newer syntax)
docker compose version >nul 2>&1
if %errorlevel% equ 0 (
    set "COMPOSE_CMD=docker compose"
    echo [OK] Using Docker Compose V2
    echo.
    goto DOCKER_VERIFIED
)

REM Fall back to V1 if V2 not available
docker-compose --version >nul 2>&1
if %errorlevel% equ 0 (
    set "COMPOSE_CMD=docker-compose"
    echo [OK] Using Docker Compose V1
    echo.
    goto DOCKER_VERIFIED
)

echo [ERROR] Docker Compose not found
echo [*] Docker Compose should be included with Docker Desktop
echo.
echo SUGGESTIONS:
echo 1. Update Docker Desktop to the latest version
echo 2. Reinstall Docker Desktop
echo 3. Check PATH environment variable
echo.
pause
exit /b 1

:Handle_ComfyUI
REM ============================================================
REM STEP 3: Handle ComfyUI (portable, no Docker)
REM ============================================================
if /i "!WEBUI_TYPE!"=="COMFYUI" (
    echo.
    echo ============================================================
    echo [STEP 3/6] Setting up ComfyUI...
    echo ============================================================
    echo.
    
 REM Call setupcomfyui.bat from Docker directory
    pushd "%~dp0Docker"
    call setupcomfyui.bat
    set "SETUP_RESULT=!errorlevel!"
    popd
    
    
    if !SETUP_RESULT! neq 0 (
        :RETRY_PROMPT
        echo.
        echo ============================================================
        echo [ERROR] ComfyUI setup failed with error code: !SETUP_RESULT!
        echo ============================================================
        echo.
        echo What would you like to do?
        echo   1. Retry the setup
        echo   2. Exit
        echo.
        set "retry_choice="
        set /p "retry_choice=Enter your choice (1-2): "
        
        if "!retry_choice!"=="1" (
            echo [*] Retrying ComfyUI setup...
            goto Handle_ComfyUI
        ) else (
            exit /b 0
        )
    )
    
    echo [OK] ComfyUI setup complete
    echo.

    
    REM ComfyUI portable output runs in this terminal, script ends here
    pause
    exit /b 1
)
:DOCKER_VERIFIED
REM ============================================================
REM STEP 3: Check if UI is installed
REM ============================================================
echo [STEP 3/6] Verifying !WEBUI_TYPE! installation...

set UI_INSTALLED=0

if /i "!WEBUI_TYPE!"=="AUTOMATIC1111" (
    if exist "Automatic1111\models" if exist "Automatic1111\outputs" set UI_INSTALLED=1
)
if /i "!WEBUI_TYPE!"=="FOOOCUS" (
    if exist "Fooocus/data" set UI_INSTALLED=1
)

if !UI_INSTALLED! equ 1 (
    echo [OK] !WEBUI_TYPE! is installed
    goto SETUP_DIRECTORIES
)

echo [!] !WEBUI_TYPE! is not yet installed
echo.
echo ===================================================================
echo   AI Download Required
echo ===================================================================
echo.

if /i "!WEBUI_TYPE!"=="AUTOMATIC1111" (
    echo Stable Diffusion WebUI - Download size: ~5-7 GB
    echo Estimated time: 3-6 minutes
)
if /i "!WEBUI_TYPE!"=="FOOOCUS" (
    echo Fooocus - Download size: ~15-20 GB
    echo Estimated time: 6-12 minutes
)

echo.
choice /C YN /N /M "Would you like to download !WEBUI_TYPE! now? [Y/N]: "
if errorlevel 2 (
    echo.
    echo [*] Installation cancelled
    pause
    exit /b 0
)

echo.
echo [OK] Starting installation...

:SETUP_DIRECTORIES
echo.
REM ============================================================
REM STEP 4: Setup directories
REM ============================================================
echo [STEP 4/6] Setting up directories...

if /i "!WEBUI_TYPE!"=="AUTOMATIC1111" (
    if not exist "Automatic1111\models" mkdir "Automatic1111\models"
    if not exist "Automatic1111\outputs" mkdir "Automatic1111\outputs"
    if not exist "Automatic1111\extensions" mkdir "Automatic1111\extensions"
    if not exist "Automatic1111\embeddings" mkdir "Automatic1111\embeddings"
    if not exist "Automatic1111\loras" mkdir "Automatic1111\loras"
) else if /i "!WEBUI_TYPE!"=="FOOOCUS" (
    if not exist "Fooocus\data" mkdir "Fooocus\data"
)

echo [OK] Directories ready
echo.

REM ============================================================
REM STEP 5: Check container and port status
REM ============================================================
echo [STEP 5/6] Checking container and port status...
echo.

set CONTAINER_RUNNING=0
set CONTAINER_EXISTS=0

REM Check if container is running
docker ps --filter "name=!CONTAINER_NAME!" --filter "status=running" --format "{{.Names}}" 2>nul | findstr /C:"!CONTAINER_NAME!" >nul 2>&1
if %errorlevel% equ 0 (
    set CONTAINER_RUNNING=1
    echo [OK] Container !CONTAINER_NAME! is already running on port !WEBUI_PORT!
    goto SHOW_MENU
)

REM Check if container exists but is stopped
docker ps -a --filter "name=!CONTAINER_NAME!" --format "{{.Names}}" 2>nul | findstr /C:"!CONTAINER_NAME!" >nul 2>&1
if %errorlevel% equ 0 (
    set CONTAINER_EXISTS=1
    echo [INFO] Found stopped container !CONTAINER_NAME!
    echo [*] Starting existing container...
    docker start !CONTAINER_NAME!
    if errorlevel 1 (
        echo [WARNING] Failed to start existing container, will recreate
        docker rm -f !CONTAINER_NAME! >nul 2>&1
        goto CHECK_PORT
    )
    echo [OK] Container started successfully
    goto HEALTH_CHECK_LOOP
)

:CHECK_PORT
REM Check if port is available
netstat -ano | findstr :!WEBUI_PORT! >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARNING] Port !WEBUI_PORT! is already in use
    echo.
    echo The WebUI might already be running at: http://localhost:!WEBUI_PORT!
    echo Or another application is using this port.
    echo.
    echo Options:
    echo   1. Continue anyway (may fail if port is truly blocked)
    echo   2. Exit and check what's using the port
    echo.
    choice /C 12 /N /M "Enter choice (1-2): "
    if errorlevel 2 exit /b 0
    echo [*] Continuing...
    echo.
)

echo [OK] Port !WEBUI_PORT! appears available
echo [*] Will create new container
echo.
goto START_CONTAINER

REM ============================================================
REM Container Management Menu (for running containers)
REM ============================================================
:SHOW_MENU
echo.
echo =========================================================================
echo   !WEBUI_TYPE! is running at http://localhost:!WEBUI_PORT!
echo =========================================================================
echo.
echo What would you like to do?
echo.
echo   1. Open in browser
echo   2. View container logs
echo   3. Restart container
echo   4. Delete and recreate container
echo   5. Exit
echo.

choice /C 12345 /N /M "Enter choice (1-5): "

if errorlevel 5 exit /b 0
if errorlevel 4 goto RECREATE_CONTAINER
if errorlevel 3 goto RESTART_CONTAINER
if errorlevel 2 goto SHOW_LOGS
if errorlevel 1 goto SUCCESS_MESSAGE

:SHOW_LOGS
echo.
echo ============================================================
echo   Container Logs (press Ctrl+C to stop)
echo ============================================================
echo.
docker logs -f !CONTAINER_NAME!
echo.
goto SHOW_MENU

:RESTART_CONTAINER
echo.
echo [*] Restarting !WEBUI_TYPE! container...
docker restart !CONTAINER_NAME!
if errorlevel 1 (
    echo [ERROR] Failed to restart container
    echo [*] You may need to delete and recreate (option 4)
    pause
    goto SHOW_MENU
)
echo [OK] Container restarted
goto HEALTH_CHECK_LOOP

:RECREATE_CONTAINER
echo.
echo [*] Removing existing container...
docker rm -f !CONTAINER_NAME! >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Failed to remove container
    echo [*] Check Docker Desktop for manual removal
    pause
    goto SHOW_MENU
)
echo [OK] Container removed
echo [*] Creating new container...
goto START_CONTAINER

REM ============================================================
REM STEP 6: Start the container
REM ============================================================
:START_CONTAINER
echo.
echo [STEP 6/6] Starting !WEBUI_TYPE!...
echo.

REM Check for image updates
echo [*] Checking for updates (skipped if already up-to-date)...
!COMPOSE_CMD! -p ai-webui -f !COMPOSE_FILE! pull
if errorlevel 1 (
    echo [WARNING] Could not check for updates, using local image
) else (
    echo [OK] Image is up-to-date
)

echo.
echo [*] Starting container...
echo [*] First run may take a few minutes to initialize...
echo.

REM Start the container
!COMPOSE_CMD! -p ai-webui -f !COMPOSE_FILE! up -d 2>docker-error.log
if errorlevel 1 (
    echo [ERROR] Failed to start container
    echo.
    type docker-error.log 2>nul
    echo.
    
    REM Try automatic fix
    echo [*] Attempting to fix and retry...
    docker rm -f !CONTAINER_NAME! >nul 2>&1
    !COMPOSE_CMD! -p ai-webui -f !COMPOSE_FILE! up -d 2>docker-error.log
    
    if errorlevel 1 (
        echo [ERROR] Still failed after retry
        echo.
        type docker-error.log 2>nul
        echo.
        echo TROUBLESHOOTING:
        echo   - Update NVIDIA drivers: https://www.nvidia.com/Download/index.aspx
        echo   - Enable GPU in Docker Desktop: Settings ^> Resources
        echo   - Restart Docker Desktop
        echo   - Run: wsl --update
        echo   - Check logs: docker logs !CONTAINER_NAME!
        echo.
        pause
        exit /b 1
    )
)

echo [OK] Container started
echo.

REM Verify it's actually running
timeout /t 2 /nobreak >nul
docker ps --filter "name=!CONTAINER_NAME!" --filter "status=running" --format "{{.Names}}" 2>nul | findstr /C:"!CONTAINER_NAME!" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Container is not running
    echo.
    echo The container started but then stopped. Check logs:
    echo   docker logs !CONTAINER_NAME!
    echo.
    pause
    exit /b 1
)

REM Clean up error logs on success
del docker-error.log >nul 2>&1

echo [OK] Container is running
goto HEALTH_CHECK_LOOP

REM ============================================================
REM Health Check Loop
REM ============================================================
:HEALTH_CHECK_LOOP
title AI WebUI Launcher - Waiting for !WEBUI_TYPE! to be ready...
echo [*] Waiting for !WEBUI_TYPE! to initialize...
echo.

REM Quick container verification
docker ps --filter "name=!CONTAINER_NAME!" --filter "status=running" --format "{{.Names}}" 2>nul | findstr /C:"!CONTAINER_NAME!" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Container stopped unexpectedly
    echo.
    echo Last 30 lines of logs:
    docker logs !CONTAINER_NAME! --tail 30
    echo.
    pause
    exit /b 1
)

REM Check if curl is available for health checks
curl --version >nul 2>&1
if errorlevel 1 (
    echo [INFO] Health check tool not available, waiting 60 seconds...
    timeout /t 60 /nobreak >nul
    goto SUCCESS_MESSAGE
)

REM Try health checks for up to 2 minutes (24 attempts at 5 sec intervals)
set HEALTH_RETRIES=0
set MAX_RETRIES=24

:HEALTH_CHECK_RETRY
timeout /t 5 /nobreak >nul

curl -f http://localhost:!WEBUI_PORT! >nul 2>&1
if not errorlevel 1 (
    echo [OK] Service is ready!
    goto SUCCESS_MESSAGE
)

set /a HEALTH_RETRIES+=1
echo [*] Waiting for service... (attempt !HEALTH_RETRIES!/!MAX_RETRIES!)

if !HEALTH_RETRIES! lss !MAX_RETRIES! goto HEALTH_CHECK_RETRY

REM Timeout - give it more time before opening browser
echo.
echo [INFO] Service taking longer than expected to start
echo [*] This is normal for first-time setup or large models
echo [*] Opening browser in 30 seconds...
timeout /t 30 /nobreak >nul
goto SUCCESS_MESSAGE

:HEALTH_CHECK_DONE

REM Clean up error logs
if exist "docker-error.log" del "docker-error.log" >nul 2>&1
if exist "docker-error-retry.log" del "docker-error-retry.log" >nul 2>&1

:SUCCESS_MESSAGE
title AI WebUI Launcher - !WEBUI_TYPE! is Ready!
echo.
echo ============================================================
echo   SUCCESS: !WEBUI_TYPE! is Running!
echo ============================================================
echo.
echo   Access URL: http://localhost:!WEBUI_PORT!
echo.
echo   TIPS:
echo   - First startup may take 5-10 minutes to download models
echo   - To switch UI: Run Select-UI or Delete webui_config.cfg and run this script
echo   - To stop: Close Docker Desktop or stop the container
echo   - To view logs: docker logs !CONTAINER_NAME! -f
echo.
echo ============================================================
echo.

if !SERVICE_READY! equ 1 (
    echo [*] Service is ready! Opening browser...
    start "" http://localhost:!WEBUI_PORT!
    echo [OK] Browser opened - !WEBUI_TYPE! is ready to use!
) else (
    echo [*] Opening browser...
    start "" http://localhost:!WEBUI_PORT!
    echo [OK] Browser opened - It will be ready soon!
    echo.
    echo [*] If the page is not ready yet, wait a few minutes.
)

echo.
echo Press any key to exit the launcher...
pause >nul
exit /b 0

REM ============================================================
REM Error Handlers
REM ============================================================

:DOCKER_DECLINED
echo.
echo ============================================================
echo   Docker Declined
echo ============================================================
echo.
echo You have chosen not to install Docker Desktop.
echo.
echo Docker is required for running !WEBUI_TYPE! in a container.
echo You can install it manually from:
echo https://www.docker.com/products/docker-desktop/
echo.
echo After installing Docker Desktop, run this script again.
echo.
pause
exit /b 0

:PREREQUISITES_MISSING
echo.
echo ============================================================
echo   Prerequisites Installation Failed
echo ============================================================
echo.
echo One or more prerequisites failed to install automatically.
echo.
echo Please install them manually:
if !GIT_INSTALLED! equ 0 echo   - Git: https://git-scm.com/
if !DOCKER_INSTALLED! equ 0 echo   - Docker: https://www.docker.com/products/docker-desktop/
echo.
echo After installation, run this script again.
echo.
pause
exit /b 1

goto :eof

:RefreshEnv
REM ============================================================
REM Function to refresh environment variables
REM ============================================================
set "TEMP_REFRESH_ENV=%RANDOM%"
setx TEMP_REFRESH_ENV "%TEMP_REFRESH_ENV%" >nul 2>&1

for /f "skip=2 tokens=3*" %%a in ('reg query "HKCU\Environment" /v PATH 2^>nul') do (
    set "user_path=%%a %%b"
)

reg add "HKCU\Environment" /v PATH /f /d "%PATH%" >nul 2>&1
setx PATH "%PATH%" >nul 2>&1
timeout /t 1 /nobreak >nul

goto :eof