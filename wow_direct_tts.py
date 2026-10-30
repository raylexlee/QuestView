import os
import sys
import time
import subprocess
import json
import urllib.request
import ctypes
from websocket import create_connection

# --- Windows 剪貼簿 API 宣告 ---
user32 = ctypes.windll.user32
kernel32 = ctypes.windll.kernel32
CF_UNICODETEXT = 13

def get_clipboard_text():
    """安全地從 Windows 系統剪貼簿讀取 Unicode 內文"""
    if not user32.OpenClipboard(None):
        return None
    try:
        handle = user32.GetClipboardData(CF_UNICODETEXT)
        if not handle: return None
        src = kernel32.GlobalLock(handle)
        if not src: return None
        text = ctypes.wstring_at(src)
        kernel32.GlobalUnlock(handle)
        return text
    except: return None
    finally: user32.CloseClipboard()

# --- 主程式 ---
def main():
    # 設定參數（沿用你原本的設定）
    GAME_NAME = "WorldOfAnvil" # 這裡可以隨意指定一個識別代號
    TARGET_URL = f"http://127.0.0{GAME_NAME}"
    EDGE_EXE = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    DEBUG_PORT = 9222
    USER_DATA_DIR = r"C:\Users\Raylex Lee\edge-debug-profile"

    print(f"[WoW TTS] 正在啟動獨立偵錯 Edge: {TARGET_URL}")
    
    # 啟動 Edge 偵錯沙盒
    edge_cmd = [
        EDGE_EXE,
        f"--remote-debugging-port={DEBUG_PORT}",
        "--remote-allow-origins=*",
        f"--user-data-dir={USER_DATA_DIR}",
        TARGET_URL
    ]
    subprocess.Popen(edge_cmd)

    print("[WoW TTS] 請在瀏覽器內任意點擊一下以解鎖音訊權限...")
    time.sleep(3)

    # 連接 Edge 的 CDP 遙控通道
    ws_url = None
    try:
        with urllib.request.urlopen(f"http://127.0.0.1:{DEBUG_PORT}/json", timeout=2) as response:
            pages = json.loads(response.read().decode())
            for page in pages:
                if 'tts.html' in page.get('url', ''):
                    ws_url = page.get('webSocketDebuggerUrl')
                    break
    except Exception as e:
        print(f"[WoW TTS 錯誤] 無法連線至 Edge 偵錯連接埠: {e}")
        sys.exit(1)

    if not ws_url:
        print(f"[WoW TTS 錯誤] 在 Edge 中找不到語音網頁分頁！")
        sys.exit(1)

    ws = create_connection(ws_url)
    print("🎉 [WoW TTS] CDP 記憶體直連通訊成功綁定！")

    def execute_js_via_cdp(js_code):
        payload = {"id": 1, "method": "Runtime.evaluate", "params": {"expression": js_code}}
        try:
            ws.send(json.dumps(payload))
            ws.recv()
        except: pass

    # 初始化預設聲線（如果你網頁有 characterMap，這裡指定給 Narrator 說書人）
    # 先查詢是否有對應聲線，有的話就更換
    js_get_voice = "window.characterMap['Narrator'] || ''"
    payload_query = {"id": 2, "method": "Runtime.evaluate", "params": {"expression": js_get_voice, "returnByValue": True}}
    try:
        ws.send(json.dumps(payload_query))
        res = json.loads(ws.recv())
        target_voice = res.get('result', {}).get('result', {}).get('value', '')
        if target_voice:
            execute_js_via_cdp(f"window.currentVoiceName = '{target_voice}';")
            print(f"🎙️ 已成功自動綁定說書人聲線: {target_voice}")
    except: pass

    print("\n🎧 語音姬就緒！請在魔獸世界中開啟任務視窗並按下 Ctrl+C 即可朗讀。")
    
    last_clip_content = ""

    # 100ms 輕量輪詢剪貼簿
    try:
        while True:
            current_clip = get_clipboard_text()
            
            if current_clip and current_clip != last_clip_content:
                last_clip_content = current_clip
                
                # 清洗文本並過濾空字串
                text = current_clip.strip().replace('\n', ' ')
                
                if text:
                    print(f"\n🗣️ 偵測到複製！直連播放: {text[:30]}...")
                    
                    # 轉義安全字元（防止特殊符號弄壞 JS 字串）
                    safe_text = text.replace('"', '\\"').replace("'", "\\'")
                    
                    # 💡 核心優化：直接跳過硬碟，用 CDP 直播語音！
                    execute_js_via_cdp(f"window.speak('{safe_text}');")
                    
            time.sleep(0.1) # 100ms 速度極快且完全不吃 CPU
    except KeyboardInterrupt:
        print("\n[WoW TTS] 語音姬已關閉。")
    finally:
        try: ws.close()
        except: pass

if __name__ == "__main__":
    main()

