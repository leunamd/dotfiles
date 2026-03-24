#!/usr/bin/env python3
import socket, json, struct, uuid, subprocess, time, os, signal, threading, urllib.request, urllib.parse, importlib.util
from datetime import datetime

SOCKET = f"/run/user/{os.getuid()}/discord-ipc-0"
TOKEN_FILE = os.path.expanduser("~/.config/discord-afk-token")
PID_FILE = "/tmp/discord-afk.pid"
AFK_TIMEOUT = 300
SCOPES = ["rpc", "rpc.voice.read", "rpc.voice.write"]

def load_config():
    config_path = os.path.expanduser("~/.config/discord-afk/config.py")
    spec = importlib.util.spec_from_file_location("config", config_path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod

cfg = load_config()
CLIENT_ID = cfg.CLIENT_ID
CLIENT_SECRET = cfg.CLIENT_SECRET
REDIRECT_URI = cfg.REDIRECT_URI
AFK_CHANNELS = cfg.AFK_CHANNELS

is_afk = False
move_back_timer = None
current_guild_id = None
current_channel_id = None
sock = None

def log(msg):
    print(f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}: {msg}", flush=True)

def send_ipc(s, opcode, payload):
    data = json.dumps(payload).encode()
    s.send(struct.pack('<II', opcode, len(data)) + data)

def recv_ipc(s):
    header = s.recv(8)
    if len(header) < 8:
        raise ConnectionError("Socket closed")
    opcode, length = struct.unpack('<II', header)
    data = b''
    while len(data) < length:
        chunk = s.recv(length - len(data))
        if not chunk:
            raise ConnectionError("Socket closed")
        data += chunk
    return opcode, json.loads(data)

def ipc_cmd(s, cmd, args):
    n = str(uuid.uuid4())
    send_ipc(s, 1, {"nonce": n, "cmd": cmd, "args": args})
    return recv_ipc(s)

def load_token():
    if os.path.exists(TOKEN_FILE):
        with open(TOKEN_FILE) as f:
            return f.read().strip()
    return None

def save_token(token):
    os.makedirs(os.path.dirname(TOKEN_FILE), exist_ok=True)
    with open(TOKEN_FILE, 'w') as f:
        f.write(token)
    log(f"Token saved to {TOKEN_FILE}")

def exchange_code(code):
    data = urllib.parse.urlencode({
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": REDIRECT_URI
    }).encode()
    req = urllib.request.Request(
        "https://discord.com/api/oauth2/token",
        data=data,
        method="POST",
        headers={
            "Content-Type": "application/x-www-form-urlencoded",
            "User-Agent": "DiscordBot (http://127.0.0.1, 1) Python/3",
            "Accept": "application/json",
        }
    )
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read())["access_token"]
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        log(f"Token exchange failed {e.code}: {body}")
        raise

def authenticate(s):
    token = load_token()
    if token:
        log("Trying saved token...")
        _, resp = ipc_cmd(s, "AUTHENTICATE", {"access_token": token})
        if resp.get("evt") != "ERROR":
            log("Authenticated with saved token")
            return True
        log("Saved token invalid, re-authorizing...")

    log("Requesting authorization from Discord...")
    _, resp = ipc_cmd(s, "AUTHORIZE", {
        "client_id": CLIENT_ID,
        "scopes": SCOPES,
    })
    if resp.get("evt") == "ERROR":
        log(f"Authorization failed: {resp}")
        return False

    code = resp.get("data", {}).get("code")
    if not code:
        log(f"No code in response: {resp}")
        return False

    log("Got code, exchanging for token...")
    token = exchange_code(code)
    save_token(token)

    _, resp = ipc_cmd(s, "AUTHENTICATE", {"access_token": token})
    if resp.get("evt") == "ERROR":
        log(f"Authentication failed: {resp}")
        return False

    log("Authenticated successfully")
    return True

def move_to_afk():
    global sock, current_guild_id
    if current_guild_id is None:
        log("Not in any guild, skipping AFK move")
        return
    afk_channel = AFK_CHANNELS.get(current_guild_id)
    if afk_channel is None:
        log(f"Guild {current_guild_id} not in AFK_CHANNELS, skipping")
        return
    if current_channel_id == afk_channel:
        log("Already in AFK channel, skipping")
        return
    log(f"Moving to AFK channel {afk_channel}")
    ipc_cmd(sock, "SELECT_VOICE_CHANNEL", {"channel_id": afk_channel, "force": True})
    time.sleep(1)
    default_source = subprocess.check_output(["pactl", "get-default-source"]).decode().strip()
    mute = subprocess.run(["pactl", "get-source-mute", default_source],
                          capture_output=True, text=True).stdout
    if "no" in mute:
        log("Deafening")
        ipc_cmd(sock, "SET_VOICE_SETTINGS", {"deaf": True})

def schedule_move_back():
    global move_back_timer
    cancel_move_back()
    log(f"Scheduling move back to AFK in {AFK_TIMEOUT}s")
    move_back_timer = threading.Timer(AFK_TIMEOUT, move_to_afk)
    move_back_timer.daemon = True
    move_back_timer.start()

def cancel_move_back():
    global move_back_timer
    if move_back_timer:
        move_back_timer.cancel()
        move_back_timer = None
        log("Cancelled move back timer")

def on_afk(signum, frame):
    global is_afk
    is_afk = True
    log("AFK mode activated")
    move_to_afk()

def on_active(signum, frame):
    global is_afk
    is_afk = False
    cancel_move_back()
    log("AFK mode deactivated")

signal.signal(signal.SIGUSR1, on_afk)
signal.signal(signal.SIGUSR2, on_active)

with open(PID_FILE, "w") as f:
    f.write(str(os.getpid()))
log(f"Daemon started, PID {os.getpid()}")

while True:
    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(SOCKET)

        send_ipc(sock, 0, {"v": 1, "client_id": CLIENT_ID})
        opcode, resp = recv_ipc(sock)
        user = resp.get("data", {}).get("user", {}).get("username", "unknown")
        log(f"Connected as {user}")

        if not authenticate(sock):
            log("Auth failed, retrying in 30s...")
            time.sleep(30)
            continue

        _, resp = ipc_cmd(sock, "GET_SELECTED_VOICE_CHANNEL", {})
        voice_data = resp.get("data") or {}
        if voice_data:
            current_channel_id = voice_data.get("id")
            current_guild_id = voice_data.get("guild_id")
            log(f"Currently in channel {current_channel_id}, guild {current_guild_id}")
        else:
            log("Not currently in a voice channel")

        send_ipc(sock, 1, {
            "nonce": str(uuid.uuid4()),
            "cmd": "SUBSCRIBE",
            "evt": "VOICE_CHANNEL_SELECT",
            "args": {}
        })
        opcode, resp = recv_ipc(sock)
        if resp.get("evt") == "ERROR":
            log(f"Subscribe failed: {resp}")
        else:
            log("Subscribed to VOICE_CHANNEL_SELECT")

        while True:
            opcode, msg = recv_ipc(sock)
            if msg.get("evt") == "VOICE_CHANNEL_SELECT":
                data = msg.get("data", {})
                new_channel = data.get("channel_id")
                new_guild = data.get("guild_id")
                log(f"Voice channel changed: guild={new_guild} channel={new_channel}")
                current_channel_id = new_channel
                current_guild_id = new_guild

                afk_channel = AFK_CHANNELS.get(new_guild) if new_guild else None
                if is_afk and new_channel != afk_channel and new_channel is not None:
                    log("Moved out of AFK while AFK, scheduling return")
                    schedule_move_back()
                elif new_channel == afk_channel or new_channel is None:
                    cancel_move_back()

    except Exception as e:
        log(f"Connection error: {e}, retrying in 5s...")
        time.sleep(5)
