DIRNAME = r"%APPDATA%\.minecraft\figura\data" # figura data folder
BITRATE = 8 # thousand
SPEED = 1 # tts voice speed
VOICE = "af_heart"
# Available voices: 
# female: af_heart af_alloy af_aoede af_bella  af_jessica af_kore    af_nicole af_nova af_river af_sarah af_sky
# male:   am_adam  am_echo  am_eric  am_fenrir am_liam    am_michael am_onyx   am_puck am_santa
# see also https://github.com/hexgrad/kokoro/blob/dfb907a02bba8152ca444717ca5d78747ccb4bec/kokoro.js/src/voices.js

#-------------------------------------------------------------------------------

import os
if "SSL_CERT_FILE" in os.environ:
  del os.environ["SSL_CERT_FILE"] # fix for model download not working randomly with broken environment variable

from pathlib import Path
DIRNAME = Path(os.path.expandvars(DIRNAME)).resolve()
if not os.path.exists(DIRNAME):
  os.mkdir(DIRNAME)
tts_dir = DIRNAME/"tts"
if not os.path.exists(tts_dir):
  os.mkdir(tts_dir)

print("Target directory:")
print(tts_dir)
print("Note: If you see a warning about unauthenticated requests, you can safely ignore it.")
print("Starting...")

from scipy.signal import resample_poly
from kokoro import KPipeline
import subprocess
import numpy as np
import base64
import torch
import re
import json
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer

def save_tts(filename, audio):
  audio = np.asarray(audio, dtype=np.float32)

  p = subprocess.Popen([
    "./third_party/ffmpeg", "-y",
    "-f", "f32le",
    "-ar", "24000",
    "-ac", "1",
    "-i", "pipe:0",

    "-af",
    "silenceremove="
    "start_periods=1:"
    "start_duration=0.05:"
    "start_threshold=-45dB,"
    "areverse,"
    "silenceremove="
    "start_periods=1:"
    "start_duration=0.05:"
    "start_threshold=-45dB,"
    "areverse",

    "-ar", str(BITRATE)+"000",
    "-ac", "1",
    "-c:a", "libvorbis",
    "-b:a", str(BITRATE)+"k",

    filename,
  ], stdin=subprocess.PIPE)

  p.communicate(audio.tobytes())

pipeline_en = KPipeline(lang_code='a', repo_id='hexgrad/Kokoro-82M') # 'a' for american

def generate_tts(spoken_text):
  generator = pipeline_en(spoken_text, voice=VOICE, speed=SPEED)
  for i, (gs, ps, audio) in enumerate(generator):
    name = str(tts_dir/"tts.ogg")
    save_tts(name, audio)

class Handler(BaseHTTPRequestHandler):
  def do_GET(self):
    if self.path.startswith("/tts"):
      text = base64.b64decode(self.path.split("/tts?text=")[1]).decode()
      generate_tts(text)
      self.send_response(200)
      self.send_header("Content-Type", "text/plain")
      self.end_headers()
      self.wfile.write(b"ok")
    else:
      self.send_response(404)
      self.end_headers()

server = HTTPServer(("localhost", 80), Handler)
print("\nServer running at http://localhost:80")
server.serve_forever()
