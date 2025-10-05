# 🚀 Quick Start Guide - Stable Diffusion WebUI

## For Non-Technical Users

### What is this?
This is a **one-click solution** to run AI image generation (Stable Diffusion) on your computer. It's like having Midjourney or DALL-E on your own PC, completely free and offline!
You can use it to generate images, videos, and more, as well as installing any AI you desire just by placing it in the Models folder.

---

## ⚡ Quick Start (3 Steps)

### 1️⃣ Make sure you have:
- Windows 11 (Pro or better - NOT Home)
- NVIDIA graphics card (GTX 1060 or better)
- Docker Desktop installed ([Download here](https://www.docker.com/products/docker-desktop))

### 2️⃣ Run the program:
- Double-click `start-sd.bat`
- First time setup will:
  - Create necessary folders
  - Download the AI model to `models/Stable-diffusion/`
  - Set up the WebUI
- Wait for it to finish (first time: 2-15 minutes)
- **DO NOT close the window if you see errors** - it will tell you what to do!

### 3️⃣ Create images:
- A web page will open automatically:
  - **Automatic1111**: http://localhost:7860
  - **ComfyUI**: http://localhost:8188
- Type what you want to create in the "Prompt" box
- Click the orange "Generate" button (or equivalent in ComfyUI)
- Depending on preferences and hardware, this could take seconds, minutes, or more. 
- The generated image will be saved to the `outputs\` folder.
- Should it freeze or crash, you may need to adjust your parameters and restart the container.

---

## 📁 What's in this folder?

| File | What it does |
|------|--------------|
| **start-sd.bat** | ⭐ **USE THIS** - Starts everything |
| **debug-sd.bat** | If something breaks, run this for details |
| **models/Stable-diffusion/** | Main AI models (e.g., `v1-5-pruned-emaonly.safetensors`) |
| **models/Lora/** | For smaller, specialized models |
| **models/VAE/** | For image quality improvements |
| **outputs\\** | Your generated images are saved here |
| **extensions\\** | Add-ons for extra features |

---

## ❓ Common Questions

### How do I start it?
Double-click `start-sd.bat`
- First time: You'll be asked to choose between **Automatic1111** (easier) or **ComfyUI** (advanced)
- The script will remember your choice for future starts

### How do I switch between UIs?

**Method 1: Using the menu**
1. Run `select-ui.cmd` and follow the prompts

**Method 2: Manual (advanced)**
1. Edit the `.ui-config` file and change the value to either `AUTOMATIC1111` or `COMFYUI`

After switching, run `start-sd.bat` to start the selected UI.

### How do I stop it?
Close the Docker Desktop app, or run this in Command Prompt:
```
docker-compose down
```

### Where are my images saved?
- All images are saved in the `outputs\` folder
- Both UIs can access the same output folder

### It says "Docker is not running"
1. Open Docker Desktop from your Start Menu
2. Wait for the whale icon in your taskbar to stop spinning
3. Run `start-sd.bat` again

### It won't start / shows errors
1. Run `debug-sd.bat` and read the messages
2. Check the "Common Issues" section below
3. Most errors have clear instructions to fix them

### Do I need internet?
- **First time**: YES (downloads ~5GB if no modal is already available)
- **After that**: NO! Works completely offline

### Is it safe?
Yes! Everything runs in a "container" (isolated from your computer). It doesn't install anything permanently on your system.

---

## 🎨 Next Steps

### Add More Models
1. Visit https://civitai.com or https://huggingface.co
2. Download `.safetensors` or `.ckpt` files
3. Put them in the `models\` folder
4. Restart: `docker-compose restart`
5. Select from dropdown in WebUI

### Add Extensions
1. Find extensions online (search "stable diffusion webui extensions")
2. Put extension folders in `extensions\` folder
3. Restart the container

---

## 💡 Tips for Best Results

### Writing Prompts
- Be specific: "a red sports car in the rain" is better than "car"
- Add details: "digital art, highly detailed, 4k"
- Negative prompt: Things you DON'T want (like "blurry, low quality")

### Settings
- **Steps**: 20-30 is usually good (higher = slower but better quality)
- **Width/Height**: Start with 512x512, increase if you have a powerful GPU
- **CFG Scale**: 7-12 works well (how closely it follows your prompt)

### Speed Up Generation
- Lower resolution (512x512 instead of 1024x1024)
- Fewer steps (20 instead of 50)
- Use "Euler a" or "DPM++ 2M" sampler

---

## 🔧 Common Issues

### "Failed to start Docker container"
**Fix:**
1. Update your NVIDIA graphics drivers
2. In Docker Desktop: Settings → Resources → Enable GPU

### "Model download failed"
**Fix:**
1. Check your internet connection
2. Or download the model manually:
   - Go to: https://huggingface.co/runwayml/stable-diffusion-v1-5
   - Download `v1-5-pruned-emaonly.safetensors`
   - Put it in the `models\` folder

### "Port 7860/8188 already in use"
**Fix:** 
- Close other programs that might be using these ports
- Or restart your computer to clear any stuck processes

### "Out of memory"
**Fix:** 
1. Right-click `docker-compose.yml` → Edit
2. Find the line with `--medvram`
3. Change it to `--lowvram`
4. Save and run `start-sd.bat` again

---

## 📞 Help!

**Something's not working?**

1. **First**: Run `debug-sd.bat` - it will show you what's wrong
2. **Second**: Check the error message carefully - it usually tells you how to fix it
3. **Third**: Read the full `README.md` for detailed troubleshooting

**The script never closes on errors** - it always gives you a chance to read what went wrong!

---

## 🎯 Remember

- ✅ Run `start-sd.bat` to start
- ✅ Access WebUI at: http://localhost:7860 or http://localhost:8188
- ✅ Images save to: `outputs\` folder
- ✅ Run `debug-sd.bat` if you have problems
- ✅ First startup takes longer (model loading)
- ✅ Works offline after first setup!

**Enjoy creating amazing AI art! 🎨✨**
