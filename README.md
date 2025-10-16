# AI Generation Suite - One-Click Local Setup

**All-in-One Solution** for running Stable Diffusion, ComfyUI, and Fooocus locally using Docker on Windows 11 with NVIDIA GPU support. Containerized, user-friendly, and fully offline after initial setup.

## Features

🚀 **Multi-UI Support** - Switch between Automatic1111, ComfyUI, and Fooocus with a single launcher  
🎛️ **Unified Management** - Start, stop, and manage all AI services from one place  
🔒 **Containerized** - Isolated environments that don't affect your system  
⚡ **GPU Accelerated** - Optimized for NVIDIA GPUs with CUDA support  
🔍 **Comprehensive Error Handling** - Clear error messages with solutions  
📊 **System Monitoring** - Real-time resource usage and status  
🔄 **Auto-Recovery** - Automatic service restarts and Docker management  
📂 **Organized File Structure** - Clean separation of models, outputs, and configurations  

## What's New (v1.1.5)

- **Interactive Container Management**: New in-app menu for managing running containers, including options to view logs, restart, or recreate.
- **Improved Reliability**: Fixed syntax errors, enhanced Docker startup, and better error handling for smoother operation.
- **Extended Health Checks**: Longer wait times for service readiness, ensuring better compatibility with slower systems.
- **User-Friendly Updates**: Simplified prompts and clearer troubleshooting for common issues.

## Prerequisites

**This Program can install Docker, Git, WSL2, and enable Virtual Machine Platform on your first launch only after your clear approval**

- **Windows 11** (64-bit)
  - CPU Virtualization must be enabled in BIOS
  - Windows Features must have "Virtual Machine Platform" and "Windows Subsystem for Linux" enabled (Automatic)
    - OR you can do it manually:
    - Win+R, type "optionalfeatures", Press Enter - Check "Virtual Machine Platform" and "Windows Subsystem for Linux" - Click "OK" - Restart your computer
       
- **Docker Desktop** with WSL 2 backend ([Download here](https://www.docker.com/products/docker-desktop))
  - Or copy/paste `winget install --id Docker.DockerDesktop -e --source winget` into Terminal. (Automatic)
- **WSL 2** - Usually installed with Docker Desktop

- **Git** - ([Download here](https://git-scm.com/download/win))
  - Or copy/paste `winget install --id Git.Git -e --source winget` into Terminal. (Automatic)    

- **NVIDIA GPU** with at least 4GB VRAM
- **NVIDIA Drivers** - Latest version recommended ([Download here](https://www.nvidia.com/Download/index.aspx))
  - *This Program will NOT do this for you, you must install Graphics Drivers manualy.*


## Getting Started

### First Time Setup

1. **Run the Launcher**
   - Double-click `start-sd.bat` (NO admin rights)
   - First run will:
     - Check Docker installation and start it if needed
     - Create necessary folders (`models/Stable-diffusion`, `models/Lora`, `models/VAE`, `outputs`, `extensions`)
     - Download Stable Diffusion v1.5 model (~4.3GB) to `models/Stable-diffusion/`
     - Start the WebUI container
   - **Total time**: 2-15 minutes depending on internet speed

2. **Access the WebUI**
   - Browser will open automatically
   - First container startup may take 2-5 minutes to initialize
   - If page shows "connection refused", wait a bit longer

## WebUI Comparison: Automatic1111 vs ComfyUI

### Feature Comparison

| Feature | Automatic1111 (WebUI) | ComfyUI | Fooocus |
|---------|----------------------|---------|---------|
| **Ease of Use** | ✅ Beginner-friendly with sliders | ⚠️ Steeper learning curve (node-based) | ⭐ Extremely Learnable, Curated Training |
| **Performance** | Good raw, slow with many extensions | ⚡ Efficient, better for low-VRAM systems | 🚀 Optimized speed and quality balance |
| **Extensions** | 🔌 Huge ecosystem (100+ extensions) | 🧩 Few but growing number of custom nodes | 🔧 Carefully curated features |
| **Workflow** | Linear (generate → refine → upscale) | 🧠 Visual node-based (complete control) | 🎯 Streamlined with smart defaults |
| **Batch Processing** | ✅ Built-in batch tools | 🚀 More powerful with custom workflows | ⏱️ Simple, extensive generation presets |
| **Text-to-Video** | Requires extensions (AnimateDiff, SVD) | Good native support for video workflows | ❌ Not supported by default |
| **Memory Usage** | Higher (Python overhead) | Lower (pure PyTorch implementation) | Medium (optimized defaults) |
| **Customization** | Limited by UI | 🎛️ Endless complete customization with nodes | 🎨 Focused on quality presets |
| **Stability** | Can crash with too many extensions | More stable for complex workflows | 💎 Rock-solid for standard generation |
| **Best For** | Beginners, Specific Extensions | Advanced, Node-Workflows, Tech Savvy | Ease-of-Use, High-Quality Results, Intermediate Users |

### When to Choose Which?

#### Automatic1111 is better if:
- You're new to Stable Diffusion, or AI in general
- You want a simple, intuitive interface
- You rely on specific community extensions
- You prefer a "generate and refine" workflow
- *You are New to AI Generation, or an Advanced user with very specific extension setups*

#### ComfyUI is better if:
- You need maximum control over the generation process
- You're working with video or complex workflows
- You have limited VRAM (runs better on 6-8GB GPUs)
- You want to create reusable pipelines
- *You Know What You Are Doing*

#### Fooocus is better if:
- You want high-quality results with minimal setup and built-in prompt engineering, training, styles, ect
- You prefer a clean, distraction-free interface
- You value smart defaults and presets
- You want to focus on creativity rather than technical details
- You need a balance between power and simplicity
- *You have a basic understanding of AI and Computer Logic*

### Performance Notes
- **For video generation**: ComfyUI generally provides better performance and control
- **For beginners**: Automatic1111's WebUI is more approachable for first-time users
- **For general use**: Fooocus provides a balance between power and simplicity
---

### Subsequent Usage

- Simply run `Start-WebUI.bat` - it will:
  - Check if Docker/Git is running (start it if not)
  - Check for updates
  - Verify all files are present
  - Start the container
  - Open browser WebUI
- **Works completely offline** after first setup!

## File Structure

```
StableDev/
├── docker/
│   ├── docker-compose.Automatic1111.yml  # Automatic1111
│   ├── docker-compose.fooocus.yml        # Fooocus
│   └── docker-compose.comfyui.yml        # ComfyUI
├── Automatic1111/                   # Automatic1111 data
│   ├── models/
│   ├── outputs/
│   └── extensions/
├── Fooocus/                         # Fooocus data
│   ├── data/
│   └── outputs/
└── ComfyUI/                         # ComfyUI data
    ├── models/
    ├── outputs/
    ├── config/
    ├── input/
    └── custom_nodes/
```

## Managing the Application

### Starting
```batch
Start-WebUI.bat
```

### Stopping
Option 1: Use Docker Desktop GUI to Stop the Container
Option 2: Close Docker Desktop
Option 3: Run in command prompt:
```batch
docker-compose down
```

### Updating the WebUI
- This happens automatically, but you can also do it manually:
```batch
docker-compose pull
```

### Adding More Models
1. Visit https://civitai.com or https://huggingface.co
2. Download Base Models - `.safetensors` or `.ckpt` files
3. Put them in the `models\` (or `models\checkpoints\`) Folder of your selected AI
4. Restart or Refresh the WebUI to load the new model
5. Select from dropdown in WebUI

### Default Models
**Automatic1111:**
- Stable Diffusion v1.5
  - This is the most *Basic Model*, but it is the most stable and easy to run on GPU's with as low as 4GB of VRAM.

**Fooocus:**
- JuggernautXL 
  - This is a *Powerful Advanced Model*, it is very stable and runs well with other AI's or Training Data in tandem, and takes up more space.

**ComfyUI:**
- A Lot of Models
  - This is the most *Advanced Model Cluster*, and includes many of the latest most powerful models, takes up more space and is useless without some knowledge of AI and Computer Logic.

### Customize Install (Advanced Users)
- You can customize the install by editing the the `docker-compose.yml` files.
- You can customize the initial install location by editing the `Start-Webui.bat` file.

## Troubleshooting
- Using debug-sd.bat
- If you encounter issues, run `debug-sd.bat` for comprehensive diagnostics including:
  - System information
  - Docker installation and status
  - Directory structure verification
  - Model file checks
  - Container status and logs
  - GPU accessibility test

### Common Issues

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
   - Visit: https://huggingface.co/
   - Click "Files and versions"
   - Download `.safetensors` or `.ckpt` file
   - Place in `models\` or `models\checkpoints\` folder

2. **Alternative Models:**
   - Use any compatible `.safetensors` or `.ckpt` file
   - Place in (e.g.`models\loras\`) or appropriate folder
   - Will appear in WebUI dropdowns

#### "Container started but WebUI not accessible"
**Solutions:**
- Wait 2-5 minutes for full initialization
- Check container logs: `docker logs <container_name>`
- Run `debug-sd.bat` to see detailed status
- Verify GPU is detected: Check debug output

#### "Out of Memory" errors in WebUI
**Solutions:**
1. Edit `docker-compose.yml`
2. Modify COMMANDLINE_ARGS:
   - For 4GB or less VRAM: `--lowvram`
   - For 4GB-8GB VRAM: `--medvram` (default)
   - For 8GB or more VRAM: Remove `--medvram` (No Argument)
3. Restart container: `docker-compose restart`

## Advanced Configuration

### Changing Installation Directory
1. Move entire `C:\This_Folder` folder to new location
2. All scripts use relative paths, so no changes needed!
3. Just run `Start-WebUI.bat` from the new location

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

**NOT RECOMMENDED**
**(⚠️ SECURITY RISK)** - `--share` - Create public gradio.live URL **(SECURITY RISK ⚠️)**

### Adding Extensions
1. Place extension folders in `extensions\` directory
2. Restart container: `docker-compose restart`
3. Extensions will appear in WebUI

## Performance Tips

- **First image generation**: May take longer (model loading)
- **Batch sizes**: Start with 1, increase if you have VRAM
- **Resolution**: Lower resolution = faster generation
- **Steps**: 20-30 steps is usually sufficient for simple usage, 50-60 steps is usually sufficient for complex usage. 200 steps for the brave!
- **Samplers**: 'Euler a' and 'DPM++' are fast, but may not be as good as 'Euler o' or 'DPM++ 2M'.

## Offline Usage

After initial setup, the system is **fully offline**:
✅ No internet connection required  
✅ All dependencies are containerized  
✅ Models are stored locally in `models/Stable-diffusion/` (e.g., `v1-5-pruned-emaonly.safetensors`)  
✅ Generate images without any external calls  

**Note**: You still need Docker Desktop running, but it doesn't need internet.

## Security Notes
- WebUI runs on **localhost only** by default (not accessible from internet)
- To expose to network, modify port binding in `docker-compose.yml` and open the port in your router *(NOT RECOMMENDED)* - Use a VPN instead.
- Never use `--share` flag unless you understand the risks
- Container is isolated from your main system unless you expose it, or run it as administrator.

## Outputs

Automatic1111 generated images are automatically saved to: (e.g.`C:\This_Folder\outputs\`)
Foocuss/Comfy save images to: (e.g.`C:\This_Folder\'Fooocus'\data\outputs\`)
Images are organized by:
- Date and time
- Text2img vs Img2img
- Includes generation parameters in filename/metadata

## Uninstalling

1. Stop container: Docker Desktop *click Stop button* or `docker-compose down`
2. Remove images: Docker Desktop *click Trash button* or (e.g. `docker rmi ghcr.io/ai-dock/stable-diffusion-webui:latest-cuda`)
3. Delete folder: Delete (e.g.`C:\This_Folder`)
4. (Optional) Uninstall Docker Desktop/Git if not needed for other projects

## Credits & License

- **Stable Diffusion**: CompVis, Stability AI, and LAION
- **Stable Diffusion WebUI**: AUTOMATIC1111
- **Fooocus**: Fooocus
- **ComfyUI**: ComfyUI
- **Docker Image/ComfyUI Help**: ai-dock, https://www.johnaldred.com
- **This Setup**: Custom integration for Windows 11 + NVIDIA
- **MIT License**: This setup is licensed under the MIT License.
- **AGPL-3.0 License**: The Stable Diffusion WebUI is licensed under the AGPL-3.0 License.

## Support

If you encounter major issues in custom setups:
1. Run `debug-sd.bat` and review output
2. Check the Troubleshooting section above
3. Review container logs: `docker logs <container name>`
4. Ensure all prerequisites are met (Windows 11, NVIDIA GPU, Docker Desktop, Git)

---

**Ready to create amazing AI-generated images? Run `Start-WebUI.bat` and enjoy! 🎨**
