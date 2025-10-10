@echo off
setlocal enabledelayedexpansion

REM Check if git is available
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Git is not installed or not in PATH. Please install Git first.
    exit /b 1
)

REM Ensure ComfyUI/custom_nodes exists relative to Docker folder
if not exist "..\ComfyUI\custom_nodes" (
    mkdir "..\ComfyUI\custom_nodes"
)

REM Function to update or clone a repository
:update_repo
set "repo_url=%~1"
set "target_dir=%~2"
set "repo_name=%~nx2"

if exist "!target_dir!\.git" (
    echo Updating !repo_name!...
    pushd "!target_dir!"
    git pull || echo Warning: Failed to update !repo_name!, continuing with existing version...
    popd
) else (
    echo Cloning !repo_name!...
    git clone --depth 1 "!repo_url!" "!target_dir!" || (
        echo Warning: Failed to clone !repo_name!, skipping...
        exit /b 1
    )
)
echo ✓ !repo_name! is up to date
exit /b 0

echo.
echo Installing/updating video extension nodes...
echo =========================================

call :update_repo "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git" "..\ComfyUI\custom_nodes\ComfyUI-VideoHelperSuite"
call :update_repo "https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git" "..\ComfyUI\custom_nodes\ComfyUI-Advanced-ControlNet"
call :update_repo "https://github.com/Lightricks/ComfyUI-LTXVideo.git" "..\ComfyUI\custom_nodes\ComfyUI-LTXVideo"
call :update_repo "https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved.git" "..\ComfyUI\custom_nodes\ComfyUI-AnimateDiff-Evolved"
call :update_repo "https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git" "..\ComfyUI\custom_nodes\ComfyUI-Frame-Interpolation"
call :update_repo "https://github.com/PowerHouseMan/ComfyUI-AdvancedLivePortrait.git" "..\ComfyUI\custom_nodes\ComfyUI-AdvancedLivePortrait"

echo.
echo ✓ Setup complete - Custom nodes have been updated
endlocal
