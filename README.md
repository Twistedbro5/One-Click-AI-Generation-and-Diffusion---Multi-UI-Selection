# Stable Diffusion Local Setup - Win11+Nvidia

**One-Click Solution** for running Stable Diffusion and other AI Models locally using Docker on Windows 11 with NVIDIA GPU support. This setup is containerized, user-friendly, and fully offline after initial setup.

## Features

✅ **One-Click Launch** - Just run `start-sd.bat` and everything is handled automatically  
✅ **Comprehensive Error Handling** - Clear error messages with solutions, never closes on failure  
✅ **Fully Offline** - After initial setup, works completely offline (no internet required)  
✅ **Auto-Recovery** - Automatically attempts to start Docker Desktop if not running  
✅ **Debug Mode** - Includes detailed diagnostic tool (`debug-sd.bat`)  
✅ **Containerized** - Doesn't affect your system, everything stays in the Docker container  
✅ **GPU Accelerated** - Optimized for NVIDIA GPUs with CUDA support  

## Prerequisites

- **Windows 11** (Pro, Enterprise, or Education - NOT Home version) (64-bit)
- **Docker Desktop** with WSL 2 backend ([Download here](https://www.docker.com/products/docker-desktop))
- **NVIDIA GPU** with at least 4GB VRAM
- **NVIDIA Drivers** - Latest version recommended
- **WSL 2** - Usually installed with Docker Desktop

## Getting Started

### First Time Setup

1. **Install Docker Desktop**
   - Download from: https://www.docker.com/products/docker-desktop
   - Install and restart your computer
   - Open Docker Desktop and wait for it to fully start

2. **Place Files**
   - Place this folder at: `C:\Stablediffusion`
   - ⚠️ **Important**: Must be exactly this path (or update paths in `docker-compose.yml`)

3. **Run the Launcher**
   - Double-click `start-sd.bat` (NO admin rights needed)
   - First run will:
     - Check Docker installation and start it if needed
     - Create necessary folders (`models/Stable-diffusion`, `models/Lora`, `models/VAE`, `outputs`, `extensions`)
     - Download Stable Diffusion v1.5 model (~4.3GB) to `models/Stable-diffusion/`
     - Start the WebUI container
   - **Total time**: 2-15 minutes depending on internet speed

4. **Access the WebUI**
   - Browser will open automatically to: http://localhost:7860
   - First container startup may take 2-5 minutes to initialize
   - If page shows "connection refused", wait a bit longer

## WebUI Comparison: Automatic1111 vs ComfyUI

### Feature Comparison

| Feature | Automatic1111 (WebUI) | ComfyUI |
|---------|----------------------|---------|
| **Ease of Use** | ✅ Beginner-friendly UI with sliders and presets | ⚠️ Steeper learning curve (node-based workflow) |
| **Performance** | Good, but can be slower with many extensions | ⚡ More efficient, better for low-VRAM systems |
| **Extensions** | 🔌 Huge ecosystem (100+ extensions) | 🧩 Fewer but growing number of custom nodes |
| **Workflow** | Linear (generate → refine → upscale) | 🧠 Visual node-based (complete control over pipeline) |
| **Batch Processing** | ✅ Built-in batch tools | 🚀 More powerful with custom workflows |
| **Text-to-Video** | Requires extensions (AnimateDiff, SVD) | Better native support for video workflows |
| **Memory Usage** | Higher (Python overhead) | Lower (pure PyTorch implementation) |
| **Customization** | Limited by UI | 🎛️ Endless customization with nodes |
| **Stability** | Can crash with many extensions | More stable for complex workflows |

### When to Choose Which?

#### Automatic1111 is better if:
- You're new to Stable Diffusion
- You want a simple, intuitive interface
- You rely on community extensions
- You prefer a "generate and refine" workflow

#### ComfyUI is better if:
- You need maximum control over the generation process
- You're working with video or complex workflows
- You have limited VRAM (runs better on 6-8GB GPUs)
- You want to create reusable pipelines

### Performance Notes
- **For video generation**: ComfyUI generally provides better performance and control
- **For beginners**: Automatic1111's WebUI is more approachable for first-time users

---

### Subsequent Usage

- Simply run `start-sd.bat` - it will:
  - Check if Docker is running (start it if not)
  - Verify all files are present
  - Start the container
  - Open browser
- **Works completely offline** after first setup!

## File Structure

```
C:\Stablediffusion\
├── .ui-config                # Stores the selected UI (AUTOMATIC1111 or COMFYUI)
├── start-sd.bat              # Main launcher (use this!)
├── debug-sd.bat              # Diagnostic tool for troubleshooting
├── select-ui.cmd             # UI selection script
├── download-model.bat        # Model downloader (called by start-sd.bat)
├── docker-compose.yml        # Docker config for Automatic1111 WebUI
├── docker-compose.comfyui.yml # Docker config for ComfyUI
├── README.md                 # This file
├── models\                   # AI model files (shared between UIs)
│   ├── Stable-diffusion\     # Base models (.safetensors, .ckpt)
│   ├── VAE\                  # VAE models
│   └── Lora\                 # LoRA models
├── outputs\                  # Generated images
│   ├── automatic1111\        # Outputs from Automatic1111
│   └── comfyui\              # Outputs from ComfyUI
├── config\                   # Configuration files
│   └── comfy\                # ComfyUI configuration
└── extensions\               # WebUI extensions (Automatic1111 only)
```

## Managing the Application

### Starting
```batch
start-sd.bat
```

### Stopping
Option 1: Use Docker Desktop GUI  
Option 2: Run in command prompt:
```batch
docker-compose down
```

### Updating the WebUI
```batch
docker-compose pull
docker-compose up -d
```

### Viewing Logs
```batch
docker logs stable-diffusion
```

## Managing Models

### Adding New Models
1. Download your desired `.ckpt` or `.safetensors` model files (e.g. https://civitai.com )
2. Place them in the `models` folder
3. Restart the container using the batch file

### Default Model
- Stable Diffusion v1.5
- This is the most basic model, but it is the most stable and easy to run on GPU's with as low as 4GB of VRAM.

### Customize Install
- You can customize the install by editing the `docker-compose.yml` file.
- You can customize the UI and initial install location by editing the `start-sd.bat` file.

## Troubleshooting

### Using debug-sd.bat
If you encounter issues, run `debug-sd.bat` for comprehensive diagnostics including:
- System information
- Docker installation and status
- Directory structure verification
- Model file checks
- Container status and logs
- GPU accessibility test

### Common Issues

#### "Docker is not installed or not in PATH"
**Solution:**
1. Install Docker Desktop: https://www.docker.com/products/docker-desktop
2. Restart your computer
3. Run `start-sd.bat` again

#### "Docker failed to start automatically"
**Solutions:**
- Manually open Docker Desktop from Start Menu
- Wait for whale icon in system tray to stop animating
- Check WSL 2 is installed: `wsl --status` in PowerShell
- Enable virtualization in BIOS/UEFI settings
- Enable Windows features:
  - Press `Win + R`, type: `optionalfeatures`
  - Enable: Virtual Machine Platform, Windows Subsystem for Linux, Hyper-V

#### "Failed to start Docker container"
**Common Causes:**
1. **NVIDIA drivers outdated**
   - Update drivers from: https://www.nvidia.com/Download/index.aspx
   
2. **Docker GPU access not enabled**
   - Open Docker Desktop
   - Settings → Resources → WSL Integration
   - Enable GPU support
   
3. **Port 7860 already in use**
   - Close other applications using the port
   - Or edit `docker-compose.yml` to change port (e.g., "7861:7860")
   
4. **Insufficient VRAM**
   - Edit `docker-compose.yml`
   - Change `--medvram` to `--lowvram` in COMMANDLINE_ARGS

#### "HuggingFace Authentication Required" (during model download)
**Solutions:**
1. **Manual Download:**
   - Visit: https://huggingface.co/runwayml/stable-diffusion-v1-5
   - Click "Files and versions"
   - Download `v1-5-pruned-emaonly.safetensors`
   - Place in `C:\Stablediffusion\models\`

2. **Alternative Models:**
   - Use any compatible `.safetensors` or `.ckpt` file
   - Place in `models\` folder
   - Model will appear in WebUI dropdown

#### "Container started but WebUI not accessible"
**Solutions:**
- Wait 2-5 minutes for full initialization
- Check container logs: `docker logs stable-diffusion`
- Run `debug-sd.bat` to see detailed status
- Verify GPU is detected: Check debug output

#### "Out of Memory" errors in WebUI
**Solutions:**
1. Edit `docker-compose.yml`
2. Modify COMMANDLINE_ARGS:
   - For 4GB VRAM: `--lowvram`
   - For 6-8GB VRAM: `--medvram` (default)
   - For 12GB+ VRAM: Remove `--medvram`
3. Restart container: `docker-compose restart`

## Advanced Configuration

### Changing Installation Directory
1. Move entire `C:\Stablediffusion` folder to new location
2. All scripts use relative paths, so no changes needed!
3. Just run `start-sd.bat` from the new location

### Customizing WebUI Settings
Edit `docker-compose.yml` and modify `COMMANDLINE_ARGS`:
```yaml
# Example customizations:
- COMMANDLINE_ARGS=--medvram --opt-sdp-attention --api --listen --port 7860 --theme dark --xformers
```

Common flags:
- `--lowvram` - For GPUs with 4GB or less VRAM
- `--medvram` - For GPUs with 4-8GB VRAM
- `--xformers` - Better memory efficiency (if supported)
- `--theme dark` - Dark theme
- `--api` - Enable API access
- `--share` - Create public gradio.live URL (⚠️ security risk)

### Adding Extensions
1. Place extension folders in `extensions\` directory
2. Restart container: `docker-compose restart`
3. Extensions will appear in WebUI

## Performance Tips

- **First image generation**: May take longer (model loading)
- **Batch sizes**: Start with 1, increase if you have VRAM
- **Resolution**: Lower resolution = faster generation
- **Steps**: 20-30 steps is usually sufficient
- **Samplers**: Euler a and DPM++ are fast

## Offline Usage

After initial setup, the system is **fully offline**:
✅ No internet connection required  
✅ All dependencies are containerized  
✅ Models are stored locally in `models/Stable-diffusion/` (e.g., `v1-5-pruned-emaonly.safetensors`)  
✅ Generate images without any external calls  

**Note**: You still need Docker Desktop running, but it doesn't need internet.

## Security Notes
- WebUI runs on **localhost only** by default (not accessible from internet)
- To expose to network, modify port binding in `docker-compose.yml` (not recommended)
- Never use `--share` flag unless you understand the risks
- Container is isolated from your main system

## Outputs

All generated images are automatically saved to: `C:\Stablediffusion\outputs\`

Images are organized by:
- Date and time
- Text2img vs Img2img
- Includes generation parameters in filename/metadata

## Uninstalling

1. Stop container: `docker-compose down`
2. Remove images: `docker rmi ghcr.io/ai-dock/stable-diffusion-webui:latest-cuda`
3. Delete folder: `C:\Stablediffusion`
4. (Optional) Uninstall Docker Desktop if not needed for other projects

## Credits & License

- **Stable Diffusion**: CompVis, Stability AI, and LAION
- **Stable Diffusion WebUI**: AUTOMATIC1111
- **Docker Image**: ai-dock
- **This Setup**: Custom integration for Windows 11 + NVIDIA

This setup uses the Stable Diffusion WebUI which is licensed under the AGPL-3.0 License.

## Support

If you encounter issues:
1. Run `debug-sd.bat` and review output
2. Check the Troubleshooting section above
3. Review container logs: `docker logs stable-diffusion`
4. Ensure all prerequisites are met (Windows 11 Pro+, NVIDIA GPU, Docker Desktop)

---

**Ready to create amazing AI-generated images? Run `start-sd.bat` and enjoy! 🎨**
