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
echo This is a **one-click solution** to run AI Image/Video Generation and Editing on your computer. It's like having Midjourney or DALL-E on your own PC, completely free and offline!
echo You can use it to Edit/Generate **any** Style of Image or Video, as well as installing any AI Model you desire, without any restriction whatsoever aside from your own equipment power.
echo.
echo [*] Initializing system checks...
echo.
timeout /t 2 /nobreak >nul

REM ============================================================
REM STEP 1: Check Prerequisites (Git and Docker)
REM ============================================================
title AI WebUI Launcher - Checking Prerequisites...
cls
echo.
echo ============================================================
echo            AI WebUI Launcher - System Check
echo ============================================================
echo.
echo [STEP 1/6] Checking prerequisites...
echo.

set GIT_INSTALLED=0
set DOCKER_INSTALLED=0
set NEED_INSTALL=0

REM Check for Git
echo [*] Checking for Git...
git --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Git is installed
    set "GIT_INSTALLED=1"
) else (
    echo [!] Git is NOT installed
    set "NEED_INSTALL=1"
)

REM Check for Docker
echo [*] Checking for Docker...
docker --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker is installed
    set "DOCKER_INSTALLED=1"
) else (
    echo [!] Docker is NOT installed
    set "NEED_INSTALL=1"
)

echo.

REM If prerequisites are missing, offer to install
if "!NEED_INSTALL!"=="1" (
    echo ============================================================
    echo   Prerequisites Required
    echo ============================================================
    echo.
    echo The following tools are required to use this program:
    echo.
    if "!GIT_INSTALLED!"=="0" echo   - Git ^(version control^)  ~ 350 MB
    if "!DOCKER_INSTALLED!"=="0" echo   - Docker Desktop ^(container UI^)  ~ 5 GB
    echo.
    echo I can install these for you quickly and safely.
    echo.
    choice /C YN /N /M "Would you like me to install the missing prerequisites? [Y/N]: "
    if errorlevel 2 goto PREREQUISITES_DECLINED
    
    echo.
    echo [*] Starting installation process...
    echo.
    
    REM Check if winget is available
    echo [*] Checking for Windows Package Manager (winget)...
    winget --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Windows Package Manager (winget) is not available
        echo [*] Winget requires Windows 10 1809 or later
        echo.
        echo ALTERNATIVE: Install manually then Run Start-WebUI again. Get them from:
        if "!GIT_INSTALLED!"=="0" echo   - Git: https://git-scm.com/
        if "!DOCKER_INSTALLED!"=="0" echo   - Docker Desktop: https://www.docker.com/products/docker-desktop/
        echo.
        pause
        exit /b 1
    )
    echo [OK] Winget is available
    echo.
    
    REM Install Git if needed
    if "!GIT_INSTALLED!"=="0" (
        echo [*] Installing Git using Windows Package Manager...
        winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
        
        REM Refresh environment variables (Git adds itself to PATH)
        call :RefreshEnv
        
        REM Verify installation
        git --version >nul 2>&1
        if %errorlevel% equ 0 (
            echo [OK] Git installed successfully
            set "GIT_INSTALLED=1"
        ) else (
            echo [ERROR] Git installation may have failed
            echo [*] You may need to restart your computer
            echo [*] Or install Git manually from: https://git-scm.com/
        )
        echo.
    )
    
    REM Install Docker if needed
    if "!DOCKER_INSTALLED!"=="0" (
        echo [*] Installing Docker Desktop using Windows Package Manager...
        echo [!] This may take several minutes...
        winget install --id Docker.DockerDesktop -e --source winget --accept-package-agreements --accept-source-agreements
        
        REM Refresh environment variables
        call :RefreshEnv
        
        REM Verify installation
        docker --version >nul 2>&1
        if %errorlevel% equ 0 (
            echo [OK] Docker Desktop installed successfully
            set "DOCKER_INSTALLED=1"
        ) else (
            echo [ERROR] Docker Desktop installation may have failed
            echo [*] You may need to restart your computer
            echo [*] Or install Docker Desktop manually from: https://www.docker.com/products/docker-desktop/
        )
        echo.
    )
    
    REM Final check
    if "!GIT_INSTALLED!"=="0" goto PREREQUISITES_MISSING
    if "!DOCKER_INSTALLED!"=="0" goto PREREQUISITES_MISSING
)

REM Track if anything requiring restart was installed
set "NEED_RESTART=0"
set "NEED_SCRIPT_RESTART=0"
set "WSL_INSTALLED=0"
set "VMP_ENABLED=0"

REM ============================================================
REM Check WSL 2 Installation
REM ============================================================
echo [*] Checking for WSL 2...
wsl --status >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] WSL 2 is NOT installed - But should come with docker
    echo [*] Installing WSL 2...
    echo [!] This may take several minutes...
    wsl --install --no-distribution
    if %errorlevel% equ 0 (
        echo [OK] WSL 2 installed successfully
        set "WSL_INSTALLED=1"
        set "NEED_RESTART=1"
    ) else (
        echo [WARNING] WSL 2 installation may have failed
        echo [*] You may need to enable it manually
        echo [*] Run: wsl --install
    )
    echo.
) else (
    echo [OK] WSL 2 is installed
)

REM ============================================================
REM Check Virtual Machine Platform
REM ============================================================
echo [*] Checking Virtual Machine Platform...
dism.exe /online /get-featureinfo /featurename:VirtualMachinePlatform | findstr /C:"State : Enabled" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Virtual Machine Platform is NOT enabled
    echo [*] Enabling Virtual Machine Platform...
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    if %errorlevel% equ 0 (
        echo [OK] Virtual Machine Platform enabled successfully
        set "VMP_ENABLED=1"
        set "NEED_RESTART=1"
    ) else (
        echo [WARNING] Virtual Machine Platform enablement may have failed
        echo [*] You may need to enable it manually
    )
    echo.
) else (
    echo [OK] Virtual Machine Platform is enabled
)

echo.

REM ============================================================
REM Handle restarts
REM ============================================================
if "!NEED_INSTALL!"=="1" (
    REM Something was installed, determine what kind of restart is needed
    if "!DOCKER_INSTALLED!"=="1" set "NEED_RESTART=1"
    if "!WSL_INSTALLED!"=="1" set "NEED_RESTART=1"
    if "!VMP_ENABLED!"=="1" set "NEED_RESTART=1"
    
    REM If only Git was installed and nothing else changed
    if "!GIT_INSTALLED!"=="1" if "!NEED_RESTART!"=="0" set "NEED_SCRIPT_RESTART=1"
    
    if "!NEED_RESTART!"=="1" (
        echo ============================================================
        echo   System Restart Required
        echo ============================================================
        echo.
        echo Changes were made that require a system restart:
        if "!DOCKER_INSTALLED!"=="1" echo   - Docker Desktop was installed
        if "!WSL_INSTALLED!"=="1" echo   - WSL 2 was installed
        if "!VMP_ENABLED!"=="1" echo   - Virtual Machine Platform was enabled
        echo.
        echo [!] Please restart your computer and run Start-WebUI.bat again.
        echo.
        pause
        exit /b 0
    )
    
    if "!NEED_SCRIPT_RESTART!"=="1" (
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
)

echo [OK] All prerequisites are installed and configured
echo.

REM ============================================================
REM Check if Docker is running and get Docker Compose
REM ============================================================
echo [*] Checking if Docker is running...
docker info >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker is running
) else (
    echo [!] Docker is not running
    echo [*] Attempting to start Docker Desktop...
    
    REM Try method 1: winget run
    winget run Docker.DockerDesktop >nul 2>&1
    timeout /t 3 /nobreak >nul
    
    docker info >nul 2>&1
    if %errorlevel% neq 0 (
        REM Try method 2: Direct executable with --minimized
        if exist "C:\Program Files\Docker\Docker\Docker Desktop.exe" (
            start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe" --minimized
            echo [*] Docker Desktop is starting...
            echo [*] Waiting for Docker to initialize...
            timeout /t 10 /nobreak >nul
            
            docker info >nul 2>&1
            if %errorlevel% neq 0 (
                echo [ERROR] Docker failed to start
                echo.
                echo SOLUTION:
                echo 1. Manually open Docker Desktop from Start Menu
                echo 2. Wait for Docker to fully start
                echo 3. Run this script again
                echo.
                pause
                exit /b 1
            )
        ) else (
            echo [ERROR] Could not find Docker Desktop
            echo [*] Start Docker or install Docker Desktop from: https://www.docker.com/products/docker-desktop/
            pause
            exit /b 1
        )
    )
    
    echo [OK] Docker is now running
)

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
    ) else (
        echo [ERROR] Docker Compose not found
        echo [*] Docker Compose should be included with Docker Desktop
        echo.
        echo SUGGESTIONS:
        echo 1. Restart Docker Desktop
        echo 2. Reinstall Docker Desktop
        pause
        exit /b 1
    )
)
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
    for /f "usebackq tokens=2 delims==" %%a in (`findstr /b /i "DEFAULT_UI" "%CONFIG_FILE%"`) do (
        set "WEBUI_TYPE=%%a"
        REM Remove quotes and trim spaces
        set "WEBUI_TYPE=!WEBUI_TYPE:"=!"
        for /f "tokens=*" %%b in ("!WEBUI_TYPE!") do set "WEBUI_TYPE=%%~b"
    )
)

REM If no valid UI type, Initiate selection
REM Validate the UI type
if defined WEBUI_TYPE (
    set "UI_VALID=0"
    for %%U in (%VALID_UIS%) do (
        if /i "!WEBUI_TYPE!"=="%%U" set "UI_VALID=1"
    )
    if "!UI_VALID!"=="0" (
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
    echo Please select an option:
    echo.
    echo 1. !BOLD!Stable Diffusion!RESET! WebUI ^(AUTOMATIC1111^) - Simple, Small, Beginner friendly for NON-Technical users
    echo 2. !BOLD!Fooocus!RESET! - Modern UI, optimized defaults, best results out-of-box for Tech Savvy users !CYAN!^(RECOMMENDED^)!RESET!
    echo 3. !BOLD!ComfyUI!RESET! - Workflow node-based interface for Advanced Technical users to build and train their own Blueprints
    echo.
    set "choice="
    set /p "choice=Enter your choice (1-3): "
    
    if "!choice!"=="1" (
        set "WEBUI_TYPE=AUTOMATIC1111"
    ) else if "!choice!"=="2" (
        set "WEBUI_TYPE=FOOOCUS"
    ) else if "!choice!"=="3" (
        set "WEBUI_TYPE=COMFYUI"
    ) else (
        echo [ERROR] Invalid selection
        timeout /t 2 /nobreak >nul
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

REM Set port and config based on UI type
if /i "!WEBUI_TYPE!"=="AUTOMATIC1111" (
    set "WEBUI_PORT=7860"
    set "COMPOSE_FILE=docker\docker-compose.automatic1111.yml"
    set "CONTAINER_NAME=stable-diffusion"
    set "DATA_DIR=Automatic1111"
) else if /i "!WEBUI_TYPE!"=="COMFYUI" (
    set "WEBUI_PORT=8188"
    set "COMPOSE_FILE=docker\docker-compose.comfyui.yml"
    set "CONTAINER_NAME=comfyui"
    set "DATA_DIR=ComfyUI"
) else if /i "!WEBUI_TYPE!"=="FOOOCUS" (
    set "WEBUI_PORT=7865"
    set "COMPOSE_FILE=docker\docker-compose.fooocus.yml"
    set "CONTAINER_NAME=fooocus"
    set "DATA_DIR=Fooocus"
)

REM ============================================================
REM STEP 3: Check if UI is installed
REM ============================================================
echo [STEP 3/6] Verifying !WEBUI_TYPE! installation...
set "UI_INSTALLED=0"

if /i "!WEBUI_TYPE!"=="AUTOMATIC1111" (
    if exist "!DATA_DIR!\models" if exist "!DATA_DIR!\outputs" (
        set "UI_INSTALLED=1"
    )
) else if /i "!WEBUI_TYPE!"=="FOOOCUS" (
    if exist "!DATA_DIR!\data" (
        set "UI_INSTALLED=1"
    )
) else if /i "!WEBUI_TYPE!"=="COMFYUI" (
    if exist "!DATA_DIR!\storage" (
        set "UI_INSTALLED=1"
    )
)

if "!UI_INSTALLED!"=="0" (
    echo [!] !WEBUI_TYPE! is not installed or incomplete
    echo.
    echo ===================================================================
    echo   AI Download Required  - You can add additional AI Models anytime
    echo ===================================================================
    echo.
    
    if /i "!WEBUI_TYPE!"=="AUTOMATIC1111" (
        echo Stable Diffusion WebUI ^(AUTOMATIC1111^) needs to be set up.
        echo.
        echo Download size: ~4-6 GB ^(includes Stable Diffusion v1.5 only^)
        echo Estimated time: 3-6 minutes
    ) else if /i "!WEBUI_TYPE!"=="FOOOCUS" (
        echo Fooocus needs to be set up.
        echo.
        echo Download size: ~15-20 GB ^(includes JuggernautXL and other models/style/training^)
        echo Estimated time: 6-12 minutes
    ) else if /i "!WEBUI_TYPE!"=="COMFYUI" (
        echo ComfyUI needs to be set up.
        echo.
        echo Download size: ~25-30 GB ^(This is a MegaPack of models for professional quality use^)
        echo Estimated time: 10-20 minutes
    )
    
    echo.
    choice /C YN /N /M "Would you like to download and install !WEBUI_TYPE! now? [Y/N]: "
    if errorlevel 2 (
        echo.
        echo [*] Installation cancelled
        echo [*] You can run Start-WebUI.bat again when ready to install
        pause
        exit /b 0
    )
    
    echo.
    echo [OK] Starting installation...
) else (
    echo [OK] !WEBUI_TYPE! is installed
)

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
) else if /i "!WEBUI_TYPE!"=="COMFYUI" (
    if not exist "ComfyUI\storage" mkdir "ComfyUI\storage"
)

echo [OK] Directories ready
echo.

REM ============================================================
REM STEP 5: Check container and port status
REM ============================================================
echo [STEP 5/6] Checking system status...

REM First, check if our container exists and get its port
set "CONTAINER_RUNNING=0"
set "CONTAINER_EXISTS=0"
set "ACTUAL_PORT=!WEBUI_PORT!"

REM Check if container is running
docker ps --filter "name=!CONTAINER_NAME!" --filter "status=running" --format "{{.Names}}" 2>nul | findstr /C:"!CONTAINER_NAME!" >nul 2>&1
if %errorlevel% equ 0 (
    set "CONTAINER_RUNNING=1"
    
    REM Get the actual port the container is using
    for /f "tokens=2 delv=:>" %%p in ('docker port !CONTAINER_NAME! 2^>nul ^| findstr /C:"->"') do (
        for /f "tokens=1" %%a in ("%%p") do set "ACTUAL_PORT=%%a"
    )
    
    REM If the port is different from expected, update it
    if not "!ACTUAL_PORT!"=="!WEBUI_PORT!" (
        echo [INFO] Container is running on port !ACTUAL_PORT! (configured for !WEBUI_PORT!)
        set "WEBUI_PORT=!ACTUAL_PORT!"
    )
    
    echo [OK] Container is already running on port !WEBUI_PORT!
    goto SHOW_MENU
)

REM Check if container exists but stopped
docker ps -a --filter "name=!CONTAINER_NAME!" --format "{{.Names}}" 2>nul | findstr /C:"!CONTAINER_NAME!" >nul 2>&1
if %errorlevel% equ 0 set "CONTAINER_EXISTS=1"

REM Check if port is in use
netstat -ano | findstr :!WEBUI_PORT! >nul 2>&1
if %errorlevel% equ 0 (
    REM Port is in use, but our container isn't running
    if "!CONTAINER_EXISTS!"=="1" (
        echo [WARNING] Port !WEBUI_PORT! is in use, but our container is stopped
        echo [*] Starting the existing container...
        docker start !CONTAINER_NAME! >nul 2>&1
        if %errorlevel% equ 0 (
            echo [OK] Container started successfully
            goto SHOW_MENU
        )
    }
    
    :PORT_CONFLICT
    echo.
    echo ============================================================
    echo   Port !WEBUI_PORT! is already in use
    echo ============================================================
    echo.
    echo SUGGESTIONS:
    echo   - Close the application using port !WEBUI_PORT!
    echo   - The WebUI might already be running - check http://localhost:!WEBUI_PORT!
    echo   - Check Docker Desktop to ensure you dont already have a container running
    echo.
    echo 1. Continue with normal setup (may change port later or close program already using it)
    echo 2. Exit (You can run Start-WebUI anytime to try again)
    echo.
    
    set "port_choice="
    set /p "port_choice=Choose an option (1-2): "
    
    if "!port_choice!"=="1" (
        echo [*] Continuing with normal setup...
        goto PULL_CONTAINER
    ) else if "!port_choice!"=="2" (
        exit /b 0
    ) else (
        echo [*] Invalid choice, please try again
        goto PORT_CONFLICT
    )
    
    REM Future implementation for different port
    REM echo 2. Use a different port (Coming Soon!)
    
) else (
    echo [OK] Port !WEBUI_PORT! is available
)

echo [*] No running container found - proceeding with setup

:PULL_CONTAINER
    
    :SHOW_MENU
    echo.
    echo =========================================================================
    echo   !WEBUI_TYPE! appears to already be running at http://localhost:!WEBUI_PORT!
    echo =========================================================================
    echo.
    echo 1. Open in browser again
    echo 2. Show container logs
    echo 3. Restart container
    echo 4. Delete and recreate container (use if broken)
    echo 5. Exit
    echo.
    set "container_choice="
    set /p "container_choice=Choose an option (1-5, or just close this window to exit): "
    
    if "!container_choice!"=="1" (
        goto SUCCESS_MESSAGE
    ) else if "!container_choice!"=="2" (
        echo.
        echo [*] Showing container logs (press Ctrl+C to return to menu):
        echo ============================================================
        docker logs -f !CONTAINER_NAME!
        echo ============================================================
        goto SHOW_MENU
    ) else if "!container_choice!"=="3" (
        echo [*] Restarting !WEBUI_TYPE! container...
        docker restart !CONTAINER_NAME!
        if errorlevel 1 (
            echo [ERROR] Failed to restart container! You may need to Delete and Recreate with option 4.
            goto SHOW_MENU
        )
        echo [OK] Container restarted
        goto HEALTH_CHECK_LOOP
    ) else if "!container_choice!"=="4" (
        echo [*] Removing existing container...
        docker rm -f !CONTAINER_NAME!
        if errorlevel 1 (
            echo [WARNING] Failed to remove container, attempting to continue... (You can check if it exists in Docker Desktop)
        )
        echo [*] Creating new container...
    ) else if "!container_choice!"=="5" (
        exit /b 0
    ) else (
        goto SUCCESS_MESSAGE
    )
} else {
    REM Check if container exists but is stopped
    docker ps -a --filter "name=!CONTAINER_NAME!" --filter "status=exited" --format "{{.Names}}" 2>nul | findstr /C:"!CONTAINER_NAME!" >nul 2>&1
    if %errorlevel% equ 0 (
        echo [*] Found stopped !WEBUI_TYPE! container - starting it...
        docker start !CONTAINER_NAME!
        if errorlevel 1 (
            echo [ERROR] Failed to start container
            pause
            exit /b 1
        }
        echo [OK] Container started
        start "" "http://localhost:!WEBUI_PORT!"
        goto SHOW_MENU
    } else {
        echo [*] No existing container found - will create new one
    }
}
echo.

:Pull_Container
REM ============================================================
REM STEP 6: Pull latest image and start container
REM ============================================================
title AI WebUI Launcher - Starting !WEBUI_TYPE!...
echo [STEP 6/6] Checking for updates and starting !WEBUI_TYPE!...
echo [*] Pulling latest image (if available)...
!COMPOSE_CMD! -f !COMPOSE_FILE! pull 2>pull-error.log
if %errorlevel% neq 0 (
    echo [WARNING] Could not check for updates:
    type pull-error.log 2>nul
    echo [*] Will continue with local image...
) else (
    echo [OK] Image check complete - you're updated!
)
del /q pull-error.log 2>nul
echo.
echo [*] Starting container...
echo [*] This may take a few minutes on first run...
echo.

!COMPOSE_CMD! -f !COMPOSE_FILE! up -d 2>docker-error.log
if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo [ERROR] Failed to start container
    echo ============================================================
    echo.
    echo Error details:
    type docker-error.log 2>nul
    echo.
    echo [*] Attempting automatic fix...
    
    REM Try to fix common issues
    echo [*] Removing any conflicting containers...
    docker rm -f !CONTAINER_NAME! >nul 2>&1
    
    echo [*] Retrying...
    !COMPOSE_CMD! -f !COMPOSE_FILE! up -d 2>docker-error-retry.log
    if %errorlevel% neq 0 (
        echo [ERROR] Automatic fix failed
        echo.
        type docker-error-retry.log 2>nul
        echo.
        echo SUGGESTIONS:
        echo 1. Update NVIDIA GPU drivers from: https://www.nvidia.com/Download/index.aspx
        echo 2. Enable GPU in Docker Desktop Settings ^(Settings ^> Resources ^> WSL Integration^)
        echo 3. Restart Docker Desktop
        echo 4. Check if you have WSL2 installed ^(wsl --status^)
        echo 5. Run: wsl --update
        echo.
        pause
        exit /b 1
    )
)

echo [OK] Container started successfully
echo.

REM ============================================================
REM Health Check and Browser Launch
REM ============================================================
title AI WebUI Launcher - Waiting for !WEBUI_TYPE! to be ready...
echo [*] Waiting for !WEBUI_TYPE! to be ready...
echo [*] Performing health checks...
echo.

REM Verify container is running
docker ps --filter "name=!CONTAINER_NAME!" --filter "status=running" --format "{{.Names}}" 2>nul | findstr /C:"!CONTAINER_NAME!" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [WARNING] Container may not be running properly
    echo [*] Checking logs...
    docker logs !CONTAINER_NAME! --tail 30
    echo.
    pause
    exit /b 1
)

REM Health check loop - try for up to 1 minute
set "HEALTH_RETRIES=0"
set "SERVICE_READY=0"

:HEALTH_CHECK_LOOP
timeout /t 5 /nobreak >nul

REM Check if curl is available
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Health check unavailable ^(curl not found^)
    echo [*] Opening webpage in 60 seconds... The service is starting up. Please wait a moment.
    timeout /t 60 /nobreak >nul
    goto HEALTH_CHECK_DONE
)

REM Try to check the health endpoint
curl -f http://localhost:!WEBUI_PORT! >nul 2>&1
if %errorlevel% equ 0 (
    set "SERVICE_READY=1"
    goto HEALTH_CHECK_DONE
)

set /a HEALTH_RETRIES+=1
echo [*] Service not ready yet... ^(attempt !HEALTH_RETRIES!/12^)

if !HEALTH_RETRIES! lss 12 goto HEALTH_CHECK_LOOP

REM If health check times out after 1 minute, wait 60 more seconds
echo.
echo [!] Service did not respond to health checks after 1 minute
echo [*] Opening webpage in 60 seconds...
echo [*] The service is starting up. Please wait a moment.
timeout /t 60 /nobreak >nul

:HEALTH_CHECK_DONE

REM Clean up error logs
if exist "docker-error.log" del "docker-error.log" >nul 2>&1
if exist "docker-error-retry.log" del "docker-error-retry.log" >nul 2>&1

:SUCCESS_MESSAGE
title AI WebUI Launcher - !WEBUI_TYPE! is Ready!
cls
echo.
echo ============================================================
echo   SUCCESS: !WEBUI_TYPE! is Running!
echo ============================================================
echo.
echo   Access URL: http://localhost:!WEBUI_PORT!
echo.
echo   TIPS:
echo   - First startup may take 5-10 minutes to download models
echo   - To switch UI: Run select-ui.cmd and then run this script again
echo   - To stop: Close Docker Desktop, or just the container itself
echo   - To view logs: docker logs !CONTAINER_NAME! -f
echo   - Start-WebUI will Auto-Update your WebUI and Included Base Models
echo.
echo ============================================================
echo.

if "!SERVICE_READY!"=="1" (
    echo [*] Service is ready! Opening browser...
    start "" http://localhost:!WEBUI_PORT!
    echo [OK] Browser opened - !WEBUI_TYPE! is ready to use
) else (
    echo [*] Opening browser...
    start "" http://localhost:!WEBUI_PORT!
    echo [OK] Browser opened
    echo.
    echo [*] If the page is not ready yet, wait a few minutes for the service to fully start.
)

echo.
echo ============================================================
echo.
echo Press any key to exit the launcher...
pause >nul
exit /b 0

REM ============================================================
REM Error Handlers
REM ============================================================

:PREREQUISITES_DECLINED
echo.
echo ============================================================
echo   Prerequisites Required
echo ============================================================
echo.
echo Unfortunately, Git and Docker are required to run this application.
echo.
echo Please install them manually:
echo   - Git: https://git-scm.com/
echo   - Docker Desktop: https://www.docker.com/products/docker-desktop/
echo.
echo After installation, run this script again.
echo.
pause
exit /b 1

:PREREQUISITES_MISSING
echo.
echo ============================================================
echo   Prerequisites Installation Failed
echo ============================================================
echo.
echo One or more prerequisites failed to install automatically.
echo.
echo Please install them manually:
if "!GIT_INSTALLED!"=="0" echo   - Git: https://git-scm.com/
if "!DOCKER_INSTALLED!"=="0" echo   - Docker Desktop: https://www.docker.com/products/docker-desktop/
echo.
echo After installation, run this script again.
echo.
pause
exit /b 1

goto :eof