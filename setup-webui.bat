@echo off
setlocal enabledelayedexpansion

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges
) else (
    echo [WARNING] Please run this script as Administrator to ensure proper Docker installation
    echo Right-click on this file and select "Run as administrator"
    pause
    exit /b 1
)

:: Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker Desktop is not installed or not running
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/
    echo Make sure to start Docker Desktop after installation
    pause
    exit /b 1
)

:: Check if Docker is running
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running
    echo Please start Docker Desktop and wait for it to be fully started
    pause
    exit /b 1
)

:menu
cls
echo ===================================================
echo    AI WebUI Setup and Launcher
    echo ===================================================
echo.
echo Please select an option:
echo 1. Stable Diffusion WebUI (AUTOMATIC1111) - Beginner friendly, simple interface
echo 2. Fooocus - Modern UI with optimized defaults for best results
echo 3. ComfyUI - Advanced workflow with node-based interface
echo 4. Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto stable_diffusion
if "%choice%"=="2" goto fooocus
if "%choice%"=="3" goto comfyui
if "%choice%"=="4" exit /b 0

goto menu
:stable_diffusion
    echo.
    echo [*] Setting up Stable Diffusion WebUI...
    
    :: Create required directories
    if not exist Automatic1111\models mkdir Automatic1111\models
    if not exist Automatic1111\outputs mkdir Automatic1111\outputs
    if not exist Automatic1111\extensions mkdir Automatic1111\extensions
    if not exist Automatic1111\embeddings mkdir Automatic1111\embeddings
    if not exist Automatic1111\loras mkdir Automatic1111\loras
    
    :: Check if model exists
    if not exist "Automatic1111\models\v1-5-pruned-emaonly.safetensors" (
        echo [*] Model not found. Starting download...
        cd Automatic1111
        call ..\download-model.bat
        if %errorlevel% neq 0 (
            echo [ERROR] Failed to download model
            pause
            exit /b 1
        )
        cd ..
    )
    
    echo [*] Starting Stable Diffusion WebUI with Docker Compose...
    docker-compose -f docker\docker-compose.automatic1111.yml up -d
    
{{ ... }}
    echo ===================================================
    echo   Stable Diffusion WebUI is starting...
    echo   Access at: http://localhost:7860
    echo.
    echo   To stop: docker-compose -f docker\docker-compose.automatic1111.yml down
    echo ===================================================
    pause
    goto menu

:fooocus
    echo.
    echo [*] Setting up Fooocus...
    
    :: Create required directories
    if not exist Fooocus\data mkdir Fooocus\data
    
    echo [*] Starting Fooocus with Docker Compose...
    docker-compose -f docker\docker-compose.fooocus.yml up -d
    
    echo.
    echo ===================================================
    echo   Fooocus is starting...
    echo   Access at: http://localhost:7865
    echo.
    echo   First run will take longer as it downloads models
    echo   To stop: docker-compose -f docker\docker-compose.fooocus.yml down
    echo ===================================================
    pause
    goto menu

:comfyui
    echo.
    echo [*] Setting up ComfyUI...
    
    :: Create required directories
    if not exist ComfyUI\storage mkdir ComfyUI\storage
    
    echo [*] Starting ComfyUI with Docker Compose...
    docker-compose -f docker\docker-compose.comfyui.yml up -d
    
    echo.
    echo ===================================================
    echo   ComfyUI is starting...
    echo   Access at: http://localhost:8188
    echo.
    echo   First run will take longer as it downloads models
    echo   To stop: docker-compose -f docker\docker-compose.comfyui.yml down
    echo ===================================================
    pause
    goto menu
