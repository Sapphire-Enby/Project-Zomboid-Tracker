# PZChart Auto WebServer

A local web dashboard for tracking and visualizing Project Zomboid player skill progression over time.

## Overview

This project is a lightweight, self-contained web application that monitors a `playerdata.json` file produced by a Project Zomboid server mod. It polls for new data using a flag-file mechanism, stores historical snapshots in the browser's localStorage, and renders skill progression as interactive line charts.

## Architecture

The system has two components:

### server.py — Python HTTP Server

A minimal Python 3 HTTP server (no external dependencies) that serves the dashboard and exposes two API endpoints:

- **`GET /api/check-flag`** — Returns `{"ready": true/false}` indicating whether `update.flag` exists. The flag file is created externally (by the PZ server mod) whenever fresh player data has been written to `playerdata.json`.
- **`GET /api/data`** — Returns the contents of `playerdata.json` as JSON and deletes `update.flag` so the dashboard knows it has consumed the update.
- All other requests fall through to standard static file serving (i.e. the HTML dashboard).

**Configuration:**
| Setting | Value |
|---------|-------|
| Port | `8080` |
| Flag file | `update.flag` |
| Data file | `playerdata.json` |

### zomboid-tracker.html — Browser Dashboard

A single-page HTML/CSS/JS application (using Chart.js via CDN) that provides:

**Data Ingestion:**
- **Auto-polling** — "Start Watching" polls `/api/check-flag` at a configurable interval (5s / 10s / 30s / 60s). When the flag is detected, it fetches `/api/data` automatically.
- **Manual load** — "Load Now" button fetches `/api/data` on demand.
- **File upload fallback** — Drag-and-drop or file picker for manually uploading a `playerdata.json`.

**Data Storage:**
- All received snapshots are stored in `localStorage` keyed by player username, with timestamps.
- Duplicate/unchanged data is detected and skipped to avoid redundant entries.

**Visualization & Controls:**
- **Character selection** — Multi-select dropdown listing all tracked players with record counts. Supports comparison mode for overlaying multiple characters.
- **Skill category filters** — Toggle groups: Combat, Firearms, Crafting, Survival, Passive.
- **Individual skill filters** — Fine-grained checkboxes for each skill (auto-populated from data). Excludes parent-category skills (Combat, Crafting, Survivalist, Passiv).
- **Stats panel** — Cards showing zombie kills and top 5 highest skills for the selected character.
- **Line chart** — Chart.js line graph plotting skill levels over time, with smooth curves and color-coded datasets.

**Data Management:**
- **Export** — Downloads full history as a timestamped JSON file.
- **Clear** — Wipes all localStorage history (with confirmation).
- **Record counter** — Displays total snapshot count across all characters.

**Status Indicators:**
- Live status dot (green = watching, yellow = loading, red = stopped) with pulse animation.
- Last update timestamp display.

## Data Flow

```
PZ Server Mod
    |
    v
writes playerdata.json + creates update.flag
    |
    v
server.py (port 8080)
    |
    ├─ /api/check-flag  -->  browser polls this
    └─ /api/data        -->  browser fetches data, server deletes flag
                                |
                                v
                     zomboid-tracker.html
                        stores in localStorage
                        renders chart + stats
```

## Expected playerdata.json Format

Supports two formats:

**Single player:**
```json
{
  "username": "PlayerName",
  "kills": 150,
  "skills": {
    "Axe": 3,
    "Cooking": 5,
    "Fitness": 2
  }
}
```

**Multi-player:**
```json
{
  "PlayerOne": {
    "kills": 150,
    "skills": { "Axe": 3, "Cooking": 5 }
  },
  "PlayerTwo": {
    "kills": 80,
    "skills": { "Firearm": 2, "Aiming": 4 }
  }
}
```

## Usage

1. Start the server: `python3 server.py`
2. Open `http://localhost:8080/zomboid-tracker.html` in a browser
3. Click "Start Watching" to begin auto-polling for new data
4. The PZ server mod writes `playerdata.json` and creates `update.flag` — the dashboard picks it up automatically

## Dependencies

- **Server:** Python 3 standard library only (`http.server`, `json`, `os`, `pathlib`)
- **Client:** Chart.js (loaded from CDN)
