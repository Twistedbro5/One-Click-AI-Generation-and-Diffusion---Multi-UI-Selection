@echo off
setlocal enabledelayedexpansion

title AI WebUI Selector
color 0A

REM Change to script directory
cd /d "%~dp0"

:SELECT_UI
cls
echo.
echo ============================================================
echo            Select Your Preferred AI WebUI
echo ============================================================
echo.
echo Please choose your preferred AI WebUI:
echo.
echo 1. Stable Diffusion WebUI (AUTOMATIC1111) - Simple, Small, Beginner friendly for NON-Technical users
echo 2. Fooocus - Modern UI, optimized defaults, best results out-of-box for Tech Savvy users (RECOMMENDED)
echo 3. ComfyUI - Workflow node-based interface for Advanced Technical users to build and train their own Blueprints
echo 4. Exit without making changes
echo.

set "UI_SELECTED="
set /p "choice=Enter your choice (1-4): "

if "%choice%"=="1" (
    set "UI_SELECTED=AUTOMATIC1111"
    set "UI_NAME=Stable Diffusion WebUI (AUTOMATIC1111)"
) else if "%choice%"=="2" (
    set "UI_SELECTED=FOOOCUS"
    set "UI_NAME=Fooocus"
) else if "%choice%"=="3" (
    set "UI_SELECTED=COMFYUI"
    set "UI_NAME=ComfyUI"
) else if "%choice%"=="4" (
    exit /b 0
) else (
    echo.
    echo [ERROR] Invalid selection. Please try again.
    timeout /t 2 /nobreak >nul
    goto SELECT_UI
)

REM Update the configuration file
set "CONFIG_FILE=webui_config.cfg"
echo # AI WebUI Configuration> "%CONFIG_FILE%"
echo # This file stores the user's preferred WebUI selection>> "%CONFIG_FILE%"
echo # Do not modify this file manually>> "%CONFIG_FILE%"
echo.>> "%CONFIG_FILE%"
echo DEFAULT_UI=%UI_SELECTED%>> "%CONFIG_FILE%"

echo.
echo [SUCCESS] Default WebUI has been set to: %UI_NAME%

set "MESSAGES=To infinity and beyond!|Engage!|Make it so!|Punch it, Chewie!|Set a course for adventure!|Rocket man, burning out his fuse up here alone...|Hold on to your butts!|May the force be with you!|Live long and prosper!|Beam me up!|To boldly go where no one has gone before!"
set /a "index=%RANDOM% %% 11"
set /a "count=0"
for %%m in (%MESSAGES%) do (
    if !count! equ %index% (
        set "message=%%~m"
        goto :MESSAGE_SELECTED
        )
        set /a "count+=1"
    )
    :MESSAGE_SELECTED
    
    echo.
    echo !message!
    echo.
    
    choice /c YN /m "Would you like to start !UI_NAME! now? (Y/N): "
    if errorlevel 2 (
        echo.
        echo You can start it later by running 'Start-WebUI.bat'
        timeout /t 2 /nobreak >nul
    ) else (
        echo.
        echo Starting !UI_NAME! in...
        echo.
        echo    3...
        timeout /t 1 /nobreak >nul
        echo.   2...
        timeout /t 1 /nobreak >nul
        echo.   1...
        timeout /t 1 /nobreak >nul
        cls
        
        rem Select a different random message
        set "new_index=!RANDOM! %% 11"
        set /a "count=0"
        for %%m in (!MESSAGES!) do (
            if !count! equ !new_index! (
                set "new_message=%%~m"
                goto :NEW_MESSAGE_SELECTED
    )
    set /a "count+=1"
        )
        :NEW_MESSAGE_SELECTED
        
        echo.
        echo !new_message!
        timeout /t 1 /nobreak >nul
        start "" "Start-WebUI.bat"
    )
) else (
    echo [ERROR] Could not find where to update the default UI in Start-WebUI.bat
    if exist "%temp_file%" del "%temp_file%"
    pause
    exit /b 1
)

exit /b 0
