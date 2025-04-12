#!/bin/bash

# Vosk自动化部署脚本（Linux/macOS）
# 功能：自动安装依赖、下载模型、启动API服务

set -e

# 配置区 ==================================
MODEL_NAME="vosk-model-small-en-us-0.22"  # 默认英文模型
MODEL_LANG="en"                           # 可改为 "zh" 使用中文模型
PORT=8000                                 # API服务端口
# =========================================

echo "[1] 安装系统依赖..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update
    sudo apt-get install -y python3-pip portaudio19-dev ffmpeg
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install portaudio ffmpeg
fi

echo "[2] 安装Python库..."
pip install vosk fastapi "uvicorn[standard]" python-multipart pyaudio

echo "[3] 下载Vosk模型..."
mkdir -p models
if [ "$MODEL_LANG" = "zh" ]; then
    MODEL_NAME="vosk-model-small-zh-cn-0.22"
fi

if [ ! -d "models/$MODEL_NAME" ]; then
    wget "https://alphacephei.com/vosk/models/$MODEL_NAME.zip" -O model.zip
    unzip model.zip -d models/
    rm model.zip
    echo "模型下载完成 → models/$MODEL_NAME"
else
    echo "模型已存在，跳过下载"
fi

echo "[4] 生成FastAPI服务脚本..."
cat > vosk_api.py <<EOF
from fastapi import FastAPI, UploadFile, WebSocket
from vosk import Model, KaldiRecognizer
import pyaudio
import json
import os

app = FastAPI()

# 初始化模型
model_path = os.path.join("models", "$MODEL_NAME")
model = Model(model_path)

# 实时音频流识别
@app.websocket("/ws/recognize")
async def audio_stream(websocket: WebSocket):
    await websocket.accept()
    recognizer = KaldiRecognizer(model, 16000)
    mic = pyaudio.PyAudio()
    stream = mic.open(
        rate=16000,
        channels=1,
        format=pyaudio.paInt16,
        input=True,
        frames_per_buffer=8192
    )
    
    try:
        while True:
            data = stream.read(4096, exception_on_overflow=False)
            if recognizer.AcceptWaveform(data):
                result = json.loads(recognizer.Result())
                await websocket.send_text(result["text"])
    except Exception as e:
        print(f"Error: {e}")
    finally:
        stream.stop_stream()
        stream.close()

# 文件上传识别
@app.post("/api/recognize")
async def recognize_file(file: UploadFile):
    recognizer = KaldiRecognizer(model, 16000)
    result = []
    while True:
        chunk = await file.read(8192)
        if not chunk:
            break
        if recognizer.AcceptWaveform(chunk):
            result.append(json.loads(recognizer.Result())["text"])
    return {"text": " ".join(result)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=$PORT)
EOF

echo "[5] 启动API服务..."
echo "----------------------------------------"
echo "Vosk服务已部署！"
echo "- 实时音频流API: ws://localhost:$PORT/ws/recognize"
echo "- 文件上传API: http://localhost:$PORT/api/recognize"
echo "运行命令: python vosk_api.py"
echo "----------------------------------------"

python vosk_api.py