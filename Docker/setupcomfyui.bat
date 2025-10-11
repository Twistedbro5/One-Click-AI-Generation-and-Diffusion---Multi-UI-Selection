@echo off
setlocal enabledelayedexpansion

title ComfyUI Hybrid Setup (SDXL + Refiner + Wan2.2)

echo ======================================================
echo   ComfyUI Hybrid Docker Setup
echo   SDXL + Refiner + Wan2.2 Video Model Integration
echo ======================================================
echo.

:init
set "ERROR_MSG="
set "WARNING_MSG="

REM === Path handling ===
set "ROOT_DIR=%~dp0"
if not "%ROOT_DIR:~-1%"=="\" set "ROOT_DIR=%ROOT_DIR%\"
set "DOCKER_DIR=%ROOT_DIR%Docker\"
set "COMFY_DIR=%ROOT_DIR%ComfyUI\"
set "WAN_MODEL_DIR=%COMFY_DIR%models\Wan2.2"
set "WAN_MODEL_FILE=%WAN_MODEL_DIR%\Wan2.2-TI2V-5B.safetensors"

:check_directories
echo [*] Verifying directory structure...
if not exist "%DOCKER_DIR%" mkdir "%DOCKER_DIR%"
if not exist "%COMFY_DIR%" mkdir "%COMFY_DIR%"
if not exist "%COMFY_DIR%models" mkdir "%COMFY_DIR%models"
if not exist "%COMFY_DIR%custom_nodes" mkdir "%COMFY_DIR%custom_nodes"
if not exist "%COMFY_DIR%input" mkdir "%COMFY_DIR%input"
if not exist "%COMFY_DIR%output" mkdir "%COMFY_DIR%output"
echo [OK] Directory structure verified.
echo.

:check_dependencies
echo [*] Checking system dependencies...
set "MISSING_DEPS="
set "WARNING_DEPS="
set "INSTALL_CMD=python -m pip install --upgrade"
set "PYTHON_CMD=python"

REM Check Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    set "MISSING_DEPS=Python (3.8+)"
    set "PYTHON_CMD=python3"
) else (
    REM Check Python version
    for /f "tokens=2 delims= " %%A in ('python -c "import sys; print('{0}.{1}'.format(sys.version_info.major, sys.version_info.minor))" 2^>nul') do (
        if "%%A" lss "3.8" (
            set "MISSING_DEPS=Python 3.8 or higher (found %%A)"
        )
    )
)

REM Check pip
%PYTHON_CMD% -m pip --version >nul 2>&1
if %errorlevel% neq 0 (
    if defined MISSING_DEPS (
        set "MISSING_DEPS=%MISSING_DEPS%, pip"
    ) else (
        set "MISSING_DEPS=pip"
    )
)

REM Check Git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    if defined MISSING_DEPS (
        set "MISSING_DEPS=%MISSING_DEPS%, Git"
    ) else (
        set "MISSING_DEPS=Git"
    )
) else (
    REM Only check Git LFS if Git is installed
    git lfs version >nul 2>&1
    if %errorlevel% neq 0 (
        if defined MISSING_DEPS (
            set "MISSING_DEPS=%MISSING_DEPS%, Git LFS"
        ) else (
            set "MISSING_DEPS=Git LFS"
        )
    )
)

REM Check Hugging Face CLI
%PYTHON_CMD% -m huggingface_hub --version >nul 2>&1
if %errorlevel% neq 0 (
    if defined MISSING_DEPS (
        set "MISSING_DEPS=%MISSING_DEPS%, Hugging Face CLI"
    ) else (
        set "MISSING_DEPS=Hugging Face CLI"
    )
)

REM Handle missing dependencies
if defined MISSING_DEPS (
    echo [WARNING] Missing required dependencies: %MISSING_DEPS%
    echo.
    echo [INFO] Would you like to attempt to install the missing dependencies? (Y/N)
    set /p INSTALL_CHOICE=
    if /i "!INSTALL_CHOICE!"=="Y" (
        if not "%MISSING_DEPS:Python=%"=="%MISSING_DEPS%" (
            echo [INFO] Please install Python 3.8 or higher from https://www.python.org/downloads/
            start "" "https://www.python.org/downloads/"
            set "MISSING_DEPS=%MISSING_DEPS:Python (3.8+)=%"
            set "MISSING_DEPS=%MISSING_DEPS:Python 3.8 or higher (found %MISSING_DEPS:*Python 3.8 or higher (found =%"
            set "MISSING_DEPS=!MISSING_DEPS:)=) !"
            if "%MISSING_DEPS:~0,2%"==", " set "MISSING_DEPS=%MISSING_DEPS:~2%"
        )
        
        if not "%MISSING_DEPS:pip=%"=="%MISSING_DEPS%" (
            echo [*] Installing pip...
            curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
            %PYTHON_CMD% get-pip.py
            if %errorlevel% neq 0 (
                set "ERROR_MSG=Failed to install pip"
                goto :error_handling
            )
            del get-pip.py
            set "MISSING_DEPS=%MISSING_DEPS:pip=%"
            if "%MISSING_DEPS:~0,2%"==", " set "MISSING_DEPS=%MISSING_DEPS:~2%"
        )
        
        if not "%MISSING_DEPS:Hugging Face CLI=%"=="%MISSING_DEPS%" (
            echo [*] Installing Hugging Face CLI...
            %PYTHON_CMD% -m pip install --upgrade "huggingface_hub[cli]" --no-warn-script-location
            if %errorlevel% neq 0 (
                set "ERROR_MSG=Failed to install Hugging Face CLI"
                goto :error_handling
            )
            set "MISSING_DEPS=%MISSING_DEPS:Hugging Face CLI=%"
            if "%MISSING_DEPS:~0,2%"==", " set "MISSING_DEPS=%MISSING_DEPS:~2%"
        )
        
        if defined MISSING_DEPS (
            echo [WARNING] Could not automatically install: %MISSING_DEPS%
            echo [INFO] Please install these dependencies manually and try again.
            pause
            exit /b 1
        )
    ) else (
        echo [ERROR] Missing required dependencies: %MISSING_DEPS%
        echo [INFO] Please install the missing dependencies and try again.
        pause
        exit /b 1
    )
)

REM Handle warning dependencies
if defined WARNING_DEPS (
    echo [WARNING] Optional dependencies not found: %WARNING_DEPS%
    echo [INFO] Some features may not work correctly without these dependencies.
    echo.
    echo [INFO] You can still try...
    echo.
    echo [INFO] Press any key to continue or Ctrl+C to cancel...
    pause >nul
)

echo [OK] All required dependencies are installed.
echo.

:check_wan_model
echo [*] Verifying Wan2.2 model...
if not exist "%WAN_MODEL_FILE%" (
    echo [INFO] Wan2.2 model not found locally.
    echo [INFO] This is a large file (~10–15 GB). Would you like to download it now? (Y/N)
    set /p DOWNLOAD_CHOICE=
    if /i "!DOWNLOAD_CHOICE!"=="Y" (
        echo [*] Starting download...
        if not exist "%WAN_MODEL_DIR%" mkdir "%WAN_MODEL_DIR%"
        pushd "%WAN_MODEL_DIR%"
        echo [*] Downloading Wan2.2 model (this may take a while)...
        hf download Wan-AI/Wan2.2-TI2V-5B --local-dir . --progress
        if %errorlevel% neq 0 (
            set "ERROR_MSG=Failed to download Wan2.2 model"
            popd
            goto :error_handling
        )
        popd
        echo [OK] Wan2.2 model downloaded successfully.
    ) else (
        echo [INFO] Skipping model download. You can download it later and place it in %WAN_MODEL_DIR%
    )
) else (
    echo [OK] Wan2.2 model found in cache.
)
echo.

:check_docker
echo [*] Verifying Docker installation...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    set "ERROR_MSG=Docker is not installed or not in PATH. Please install Docker Desktop from https://www.docker.com/products/docker-desktop/"
    goto :error_handling
)

docker ps >nul 2>&1
if %errorlevel% neq 0 (
    set "ERROR_MSG=Docker daemon is not running. Please start Docker Desktop and ensure it's running."
    goto :error_handling
)
echo [OK] Docker is installed and running.
echo.

:build_docker
echo [*] Pulling base Docker image...
docker pull saladtechnologies/comfyui:comfy0.3.40-api1.9.0-torch2.7.1-cuda12.6-sdxl-with-refiner
if %errorlevel% neq 0 (
    set "ERROR_MSG=Failed to pull base Docker image"
    goto :error_handling
)

echo [*] Building ComfyUI hybrid image (this may take several minutes)...
docker compose -f "%DOCKER_DIR%docker-compose.comfyui.yml" build --no-cache --pull
if %errorlevel% neq 0 (
    set "ERROR_MSG=Failed to build Docker image. Check the Docker logs for details."
    goto :error_handling
)

echo [OK] ComfyUI hybrid image built successfully.
echo.

echo [*] Starting ComfyUI service...
docker compose -f "%DOCKER_DIR%docker-compose.comfyui.yml" up -d
if %errorlevel% neq 0 (
    set "ERROR_MSG=Failed to start ComfyUI service"
    goto :error_handling
)

echo.
echo ======================================================
echo   ComfyUI Hybrid Setup Completed Successfully!
echo ======================================================
echo.
echo [INFO] ComfyUI is now running in the background.
echo [INFO] Access the web interface at: http://localhost:8188
echo.
echo [INFO] To stop the service, run: docker compose -f "%DOCKER_DIR%docker-compose.comfyui.yml" down
echo.
goto :eof

:error_handling
if defined ERROR_MSG (
    echo.
    echo [ERROR] %ERROR_MSG%
    echo.
    if "%ERROR_MSG%"=="Docker is not installed or not in PATH. Please install Docker Desktop from https://www.docker.com/products/docker-desktop/" (
        start "" "https://www.docker.com/products/docker-desktop/"
    )
    pause
    exit /b 1
)

echo.
echo [WARNING] %WARNING_MSG%
echo.

goto :eof
echo.

REM === Launch container ===
echo [*] Launching ComfyUI Hybrid container...
docker compose -f docker-compose.comfyui.yml up -d
if %errorlevel% neq 0 (
    echo [ERROR] Container failed to start. Please check Docker logs.
    pause
    exit /b 1
)
echo [OK] ComfyUI Hybrid is running.
echo.

REM === Show container status ===
docker ps --filter "name=comfyui_hybrid"
echo.
echo ------------------------------------------------------
echo  Access ComfyUI in your browser:
echo     http://localhost:8188
echo ------------------------------------------------------
echo.
pause