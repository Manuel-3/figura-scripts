# Figura TTS Text To Speech

Text to speech for your chat messages.

## How to use

**Initial setup**

> [!] If you downloaded the zip file, unzip it first!!

One of two options are **required**, do either:

- Recommended: Get Miniconda https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html

- Alternative (not recommended): Install the required dependencies manually, you can find them in `environment.yml`.


Open a terminal in this directory. If you have vscode, you can simply press `Ctrl+Shift+P` and type `terminal` and select the "Create new terminal" option.

Run these two commands in the terminal: First `conda init` and then `conda create --file environment.yml`

Start Minecraft and join a world, open the Figura menu. Go to the settings tab and type "network" into the search bar. Enable "Allow Networking". Set "Networking Restriction" to "Whitelist". Click on "Network Filter" and then "Add Filter Entry", add `localhost` as a filter. Press escape to exit this menu.

In the same Figura settings search bar, type "chat". Set "Chat Messages" to "On".

**Starting the project**

Open the terminal.

To start the project run these two commands: First `conda activate figura-tts` and then `python tts.py`

If it is successful, you should see `Server running at http://localhost:80` in the terminal.

To stop the server you can press `Ctrl+C`

**Configuration**

> [!] The default Figura cloud is very slow. If possible you should use FSB for faster pings streaming.

At the top of the `tts.py` file you can change:

- The path to the figura data folder.

- The bit rate of the audio.

- Voice of the tts

Lower bit rate means smaller size, quicker streaming for multiplayer, but also decreased quality. Increase it to have better voice quality.

At the top of the `tts.lua` file you can change:

- The ping rate limits

Lower means more stable, but also slower streaming. Higher ping rate limit means sending the audio more quickly, but risks being canceled by the figura cloud. **If you get a single "too many pings" or "ping too large" error, the audio will not be heard in multiplayer!**
