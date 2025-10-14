# Changelog

All notable changes to this project will be documented in this file.

## [1.1.4] - 2025-10-13
### Added
- **Enhanced ComfyUI Setup**: Improved error handling and reliability in setupcomfyui.bat
- **Automatic Port Management**: Better handling of port conflicts for all services
- **System Resource Monitoring**: Added real-time monitoring of GPU/CPU usage
- **Documentation Overhaul**: Complete rewrite of README with better organization and clarity

### Changed
- **Start-WebUI.bat**: 
  - Streamlined UI selection process
  - Improved error recovery and logging
  - Better handling of service dependencies
- **Docker Configuration**: 
  - Optimized resource allocation
  - Updated base images for better performance

### Fixed
- Resolved issues with service startup sequence
- Fixed path handling in setup scripts
- Addressed permission issues with mounted volumes

## [1.1.3] - 2025-10-10
### Added
- **ComfyUI Integration**: Complete workflow integration with Start-WebUI.bat
- **Setup Script**: New `setupcomfyui.bat` for handling ComfyUI installation and configuration
- **Error Handling**: Improved error recovery and user feedback during ComfyUI setup
- **Health Checks**: Enhanced service readiness verification

### Changed
- **Start-WebUI.bat**: 
  - Fixed ComfyUI workflow to ensure all operations flow through the main terminal
  - Added proper error handling with retry options for setup failures
  - Improved health check loop implementation
- **Docker Configuration**: 
  - Updated `dockerfile_comfyuihybrid` with better tooling and permissions
  - Optimized `docker-compose.comfyui.yml` for better container management

### Fixed
- Resolved issues with directory handling in setup scripts
- Fixed container startup sequence for better reliability
- Addressed permission issues with mounted volumes

## [1.1.2] - 2025-10-08
### Added
- **Improved Port Management**: Better handling of port conflicts with clear user guidance
- **Container Management**: Enhanced container status checking and recovery
- **Configuration System**: New `webui_config.cfg` for storing UI preferences
- **User Experience**: More intuitive menus and better error messages

### Changed
- **Simplified Scripts**: Removed complex file parsing in favor of config files
- **Better Error Handling**: More robust error recovery and user feedback
- **Container Lifecycle**: Improved handling of container start/stop/restart operations
- **Documentation**: Updated README and help text for clarity

### Fixed
- Fixed issues with container detection and management
- Resolved port conflict handling
- Improved script stability and reliability

## [1.1.1] - 2025-10-07
### Added
- **Unified Launcher**: Complete solution for managing all three UIs through a single interface:
  - Automatic1111
  - ComfyUI
  - Fooocus
- **Automatic Dependency Management**:
  - Detects and offers to install Git if missing
  - Detects and offers to install Docker Desktop if missing
- **Enhanced Error Handling**: Improved error detection and user feedback throughout the launcher
- **Automatic Updates**: Docker Compose now checks for image updates before starting containers

### Changed
- **Docker Configuration**:
  - Reorganized into separate files for each UI: `docker-compose.automatic1111.yml`, `docker-compose.comfyui.yml`, `docker-compose.fooocus.yml`
  - Improved container health checks and configurations
  - Containers are now reused instead of being deleted and recreated
- **Code Structure**:
  - Implemented common interfaces for UI management
  - Modular design allows for easy addition of future UIs
  - Centralized configuration management
  - Unified logic for UI management while maintaining unique handling for each UI
- **Launcher Behavior**:
  - Terminal window now stays open after container starts
  - Success message displayed before closing

### Removed
- **Redundant Scripts**: Removed `download-model.bat`, `download-fooocus-model.bat`, and `setup-webui.bat`
  - Docker Compose now handles all image pulling and model downloads automatically
  - Simplified codebase with fewer files to maintain

## [1.1.0] - 2025-10-05
### Added
- Integrated Fooocus as a third UI option alongside Automatic1111 and ComfyUI
- Added support for Fooocus model management
- Implemented automatic browser launch after successful Fooocus startup
- Added port 7865 as the default for Fooocus UI

## [1.0.0] - 2025-10-04
### Added
- Initial release of Stable Diffusion WebUI One-Click Launcher
- Support for both Automatic1111 and ComfyUI interfaces
- Docker-based installation for easy setup
- Comprehensive error handling and debugging tools
- Offline operation capability
- GPU acceleration support
- Model management system
- Automatic updates check

### Changed
- Switched to local configuration file storage
- Improved error messages and user feedback
- Optimized Docker container configurations

### Fixed
- Fixed path resolution issues in launcher scripts
- Improved cross-version compatibility
- Resolved permission issues with configuration files

## [Pre-release]
### Added
- Initial development and testing phase
- Basic launcher functionality
- Core Docker configurations
- Documentation and guides
