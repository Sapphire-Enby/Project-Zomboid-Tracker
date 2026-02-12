# Project Zomboid Skill Tracker - Auto-Load Setup

A local web server that automatically loads player data when your PZ dedicated server outputs new data.

## Files

- `server.py` - Python HTTP server with flag-watching API
- `zomboid-tracker.html` - Dashboard that polls for updates
- `playerdata.json` - Symlink to your PZ server output (you create this)
- `update.flag` - Created by PZ server to signal new data ready

## Setup

### 1. Choose a location for the tracker

```bash
# Example: create a dedicated folder
mkdir -p ~/pz-tracker
cp ~/pzchart-server/* ~/pz-tracker/
cd ~/pz-tracker
```

### 2. Symlink playerdata.json from your PZ server

```bash
ln -s /path/to/zomboid/server/output/playerdata.json ./playerdata.json
```

Replace `/path/to/zomboid/server/output/playerdata.json` with the actual path where your dedicated server outputs the JSON.

### 3. Run the server

```bash
python3 server.py
```

Output:
```
Starting Project Zomboid Tracker Server
  Port: 8080
  Flag file: update.flag
  Data file: playerdata.json
  URL: http://localhost:8080/zomboid-tracker.html

Waiting for connections...
```

### 4. Open the dashboard

Navigate to `http://localhost:8080/zomboid-tracker.html` in your browser.

Click **"Start Watching"** to begin polling for updates.

## How It Works

```
┌─────────────────┐     writes      ┌──────────────────┐
│  PZ Dedicated   │ ──────────────> │  playerdata.json │
│     Server      │                 └──────────────────┘
│                 │     creates     ┌──────────────────┐
│                 │ ──────────────> │   update.flag    │
└─────────────────┘                 └──────────────────┘
                                            │
                                            │ detected by
                                            ▼
┌─────────────────┐    polls API    ┌──────────────────┐
│    Browser      │ <────────────── │   server.py      │
│   Dashboard     │                 │                  │
│                 │ <────────────── │  (serves JSON,   │
│                 │   returns data  │  deletes flag)   │
└─────────────────┘                 └──────────────────┘
```

1. Your PZ server outputs `playerdata.json`
2. Your PZ server creates `update.flag` to signal data is ready
3. The dashboard polls `/api/check-flag` every N seconds
4. When flag exists, dashboard fetches `/api/data`
5. Server returns the JSON and deletes the flag
6. Dashboard updates the display

## PZ Server Side

After your server outputs `playerdata.json`, create the flag file:

```bash
touch /path/to/output/update.flag
```

If you're using a script or mod to output the JSON, add this line after writing the file.

### Example wrapper script

```bash
#!/bin/bash
# run-pz-export.sh

# Your existing command that outputs playerdata.json
/path/to/your/export/script

# Signal that new data is ready
touch /path/to/output/update.flag
```

## Configuration

### Server (server.py)

Edit the top of `server.py` to change:

```python
PORT = 8080           # HTTP port
FLAG_FILE = "update.flag"    # Flag filename
DATA_FILE = "playerdata.json"  # Data filename
```

### Dashboard

- **Poll interval**: Select from dropdown (5s, 10s, 30s, 60s)
- **Manual upload**: Still available as fallback via drag-and-drop

## Running as a Systemd Service (Auto-start on boot)

Create `/etc/systemd/system/pz-tracker.service`:

```ini
[Unit]
Description=Project Zomboid Skill Tracker Server
After=network.target

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/path/to/your/tracker
ExecStart=/usr/bin/python3 server.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Then enable it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable pz-tracker
sudo systemctl start pz-tracker
```

Check status:

```bash
sudo systemctl status pz-tracker
```

## Troubleshooting

### "No data file found" error
- Check that the symlink is valid: `ls -la playerdata.json`
- Ensure the source file exists on your PZ server

### Dashboard not updating
- Check browser console for errors (F12)
- Verify the flag file is being created: `ls -la update.flag`
- Ensure server.py is running

### Permission denied on symlink
- Ensure the user running server.py can read the symlinked file
- Check Samba share permissions if crossing network boundaries

### Port already in use
- Change `PORT` in server.py to another value (e.g., 8081)
- Or kill the existing process: `lsof -i :8080`
