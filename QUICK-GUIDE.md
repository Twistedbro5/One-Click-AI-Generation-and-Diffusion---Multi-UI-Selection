# 🚀 Quick Start Guide - Local Unrestricted Generative AI Setup
*Full AI and UI Download, Update, and Management without installing it on your PC*

## For Non-Technical Users

### What is this?
This is a **one-click solution** to run AI image/video generation (Stable Diffusion) on your computer. 
It's like having Midjourney or DALL-E on your own PC, **completely free and offline!**
You can use it to generate images, videos, and more, as well as installing any AI Model you desire just by placing it in the Models folder.

Some users may need to enable CPU Virtualization in the BIOS, or update their Graphics Drivers, otherwise we take care of everything for you. 
Just Double Click `Start-Webui.bat` and follow the prompts.
---

## ⚡ Quick Start (3 Steps)

### 1️⃣ Make sure you have:
- Windows 11
- CPU Virtualization Enabled in BIOS
- NVIDIA graphics card (GTX 1060 or better)
- Recommended free disk space - 100GB+ Recommended 
  - (Automatic1111 ~5–7 GB, ComfyUI ~11–13 GB, Fooocus ~25-30GB + Outputs & if you want to add more models/extensions)

**This Program can install Docker, Git, WSL2, and enable the Windows Features for you on first start, after your clear approval**
*or you can install manually:*
- Docker Desktop / WSL2 installed - ([Download here](https://www.docker.com/products/docker-desktop))
  - Or copy/paste `winget install --id Docker.DockerDesktop -e --source winget` into Terminal.

- Git installed - ([Download here](https://git-scm.com/download/win))     
  - Or copy/paste `winget install --id Git.Git -e --source winget` into Terminal.

- NVIDIA Drivers installed - ([Download here](https://www.nvidia.com/Download/index.aspx))
  - *This Program will NOT do this for you, you must install Graphics Drivers manualy.*

### 2️⃣ Run the program:
- Double-click `Start-Webui.bat`
  - **DO NOT** run as Administrator
- First time setup will:
  - Check for Docker/Git and offer to install if missing
  - Download the AI model/s of your choosing
  - Set the WebUI and open it for you
- Wait for it to finish (first time: 2-15 minutes based on AI choice)
- **DO NOT close the window if you see errors** - it will tell you what to do!

### 3️⃣ Create:
- A web page will open automatically:
  - **Automatic1111**: http://localhost:7860
  - **ComfyUI**: http://localhost:8188
  - **Fooocus**: http://localhost:7865

- Type what you want to create in the **"Prompt"** box 
  - **(This should be a description of what you want to literally see, not what you want the AI to do)**
  - You can click Image/Video Prompt, Advanced, Enhance, Styles, ect. to add more details to your generation prompts
    - *You can for example upload an image, draw a zone where you want the AI to change, add, remove, transform, enhance, etc.*
  - You can also use negative prompts to describe elements you don't want
  - In *Fooocus*, you can select pre configured Style Training, or you can create your own, such as Cyberpunk, Realistic, Anime, NSFW, etc.

- Click the **Generate** button 
  - Depending on **Difficulty**, Number of **Steps**, and your **Hardware**, this could take seconds, minutes, or hours. 

- The generated image will be saved to the `outputs\` folder and directly downloadable or trashed from the WebUI.
  - *This makes it easy to host on another machine and access to download anywhere in your home*
  - As you familiarize yourself with using the AI, your prompt settings will become fine tuned for specific needs
  

- The generated image will be saved to the `outputs\` folder and directly downloadable or trashed from the WebUI.
  - *This makes it easy to host on another machine and access to create and download anywhere in your home*
- **Only you can see your private history** to reference past prompt settings and outputs, as well as deleting that history
  - Do NOT run this program as Administrator or host it on an actively shared network to ensure it stays secure.

- Should it freeze or crash, you may need to adjust your parameters and restart the container.

---

## 💡 Tips for Best Results

### Writing Prompts
- Be specific: "a red sports car, stationary, in the rain at dusk, in a city street, in the style of a realistic photo, highly detailed" is much better than "a car that looks cool"
- Add detail keywords: "digital art, highly detailed, 4k, cyberpunk, anime, Renaissance, celtic, gothic, etc."
- Negative prompt: Things you DON'T want (like "blurry, low quality, dark, bright, extra fingers, etc.")

### Settings
- **Steps**: 
  - 30 is usually good for simple work like Icons, Sprites, or slight modification
  - 60 is usually good for more complex work like full images, intricate detail, faces, etc.
- **Width/Height**: If in doubt, start with 512x512, increase slowly.
  - Around 1024x1024 is reasonable ceiling even for more powerful GPU's - Then Upscale and make additional passes to improve more.
- **CFG Scale**: 7-12 works well (how closely it follows your prompt)

---

## 📁 What's in this folder?

| File/Folder | What it does |
|-------------|--------------|
| **Start-WebUI.bat** | ⭐ **MAIN LAUNCHER** - Starts your selected AI WebUI |
| **select-ui.cmd** | Change AI interfaces (Automatic1111, ComfyUI, Fooocus) |
| **debug-sd.bat** | Troubleshooting - Attempts to detect and fix issues - Extensive Logs |
| **.ui-config** | Stores selected AI preference |
| **Docker/** | Contains Docker Compose configurations |
| **<AI Name>/** | Where your AI stores its data, models, and where Fooocus stores outputs |
| **outputs/** | Where (e.g. Automatic1111) stores its outputs |
| **docker-error.log** | Created on Failure - Error Logs - Deleted upon Success |

---

## ❓ Common Questions

### How do I switch between UIs?
1. Run `select-ui.cmd` and follow the prompts

### How do I stop it?
Close the Docker Desktop app, just the container, or run this in a Terminal:
```
docker-compose down
```

### Troubleshooting:
1. Run `debug-sd.bat` and read the messages
2. Check the "Common Issues" section below
3. Most errors have clear instructions to fix them

### Do I need internet?
- **First time**: YES (downloads at least ~5GB if no modal is already available)
- **After that**: NO! Works completely offline

### Is it safe?
Yes! Everything runs in a "container" **(isolated from your computer)**. It doesn't install anything permanently on your system.
We do offer to install prerequisites to running this program on your first launch, after your clear approval, if you dont already have it.

The Prerequisites are not directly related to AI, or This Program, and are widely used and documented:
- Docker Desktop (4–6 GB) - Used to run the AI in a secure container, Totally Isolated and Seperate from your system. 
- Git (~200 MB) - Used to download and update the AI/WebUI from official GitHub repositories
- WSL2 (2–5 GB) - Used to run the AI in a Linux container, since you have Windows and not Linux

If you have any concern or doubt about the function or security of this program, or the Prerequisites, please do a quick google search on them to familiarize yourself with them, and see that our program is Open-Source, freely available with every line of code visible for you, and free virus scanning websites to review. https://github.com/Twistedbro5/One-Click-AI-Generation-and-Diffusion---Multi-UI-Selection

---

## 🎨 Next Steps

### Add More Models
1. Visit https://civitai.com or https://huggingface.co
2. Download Base Models - `.safetensors` or `.ckpt` files
3. Put them in the `models\` (or `models\checkpoints\`) Folder of your selected AI
4. Restart or Refresh the WebUI to load the new model
5. Select from dropdown in WebUI

### Add Training to Models
1. Visit https://civitai.com or https://huggingface.co
2. Download Loras Models - `.safetensors` or `.ckpt` files
3. Put them in the `models\loras\` Folder of your selected AI
4. Restart or Refresh the WebUI to load the new model
5. Select from dropdown in WebUI

### Add and Learn More!
1. Visit https://civitai.com or https://huggingface.co
2. Read and Learn about how multiple AI models work together to create better results
3. Download Embeddings/VAE/UpScale/Inpaint/ect Models
4. Put them in the appropriate Folder of your selected AI
5. Restart or Refresh the WebUI to load the new model
6. Select from dropdown in WebUI

---

## 🔧 Common Issues

### "Failed to start Docker container"
**Fix:**
1. Update your NVIDIA graphics drivers
2. In Docker Desktop: Settings → Resources → Enable GPU

### "Model download failed"
**Fix:**
1. Check your internet connection
2. Download the model manually

### "Port 7860/8188 already in use"
**Fix:** 
- Close other programs that might be using these ports
- Restart your computer to clear any stuck processes

### "Out of memory"
**Fix:**
1. Close other programs using your GPU and RAM
2. Restart Docker Desktop
3. Restart your computer
4. For persistent issues, use a smaller image size (try 512x512 and then upscale)

---

## 📞 Help!

**Something's not working?**

1. **First**: Run `debug-sd.bat` - it will show you what's wrong
2. **Second**: Check the error message carefully - it usually tells you how to fix it
3. **Third**: Read the full `README.md` for detailed troubleshooting

**The script never closes on errors** - it always gives you a chance to read what went wrong!

---

**Enjoy creating amazing AI art! 🎨✨**