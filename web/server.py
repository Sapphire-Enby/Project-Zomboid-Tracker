#!/usr/bin/env python3

"""     ABOUT: SERVER.PY
Simple server for Project Zomboid skill tracker.
Handles Server Side Requests for API regarding flag checking and data scraping
Handles proper protocol responces and Returns Flag Status, Scraped Data, and Errors
"""
## Dependancies and Configurations
"""     ABOUT: DEPs and CONFs

Required Dependancies:
    http.Server
        for serving the webpage and hadling HTTP Requests
    json
        for Reading playerdata.json file and sending responces to webpage
    os
        Changing directory to parent directory (unsure reason)
    Path 
        (from pathlib)
     Handling filepaths (existance, deletion)


Config:
    PORT
        port denotion for webpage hosting
    
    FLAG_FILE 
        (update.flag)
        filename of Indicator Flag (created on write for player data)
    
    DATA_FILE 
        (playerdata.json) 
        collection of data regarding player's skills and kills
"""

# Dependancies
import http.server  # 
import json
import os
from pathlib import Path

# Configuration
PORT = 8080
FLAG_FILE = "update.flag"
DATA_FILE = "playerdata.json"


## Helper Classes
"""     ABOUT: TrackerHandler
Custom Class: TrackerHandler
Extends Class: SimpleHTTPRequestHandler from http.server

Functionality:
    do_GET:
        
        if url querys "/api/check-flag"
            Checks to see if FLAG_FILE (indicates fresh data was writen)
            returns JSON{"ready": flag_exists} where flag_exists is results
        
        if querys "/api/data"
            loads data from DATA_FILE
            deletes FLAG_FILE
            sends data back to browser
            
            will raise error if 
                FLAG_FILE isn't present 
                DATA_FILE isn't properly encoded
                general error shit
        else:
            defaults to parent elsewise:

        Functionality of If statments calls helper functions
        
    Helper Functions:
        handle_check_flag // see above
        handle_get_data // see above

        send_json
            handles responce protocol (status, headers, end headsers,)
            then sends encoded dump of data json 
"""
class TrackerHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/api/check-flag":
            self.handle_check_flag()
        elif self.path == "/api/data":
            self.handle_get_data()
        else:
            # Serve static files normally
            super().do_GET()

    def handle_check_flag(self):
        """Check if the update flag exists."""
        flag_exists = Path(FLAG_FILE).exists()
        self.send_json({"ready": flag_exists})

    def handle_get_data(self):
        """Return player data and delete the flag."""
        data_path = Path(DATA_FILE)
        flag_path = Path(FLAG_FILE)

        if not data_path.exists():
            self.send_json({"error": "No data file found"}, status=404)
            return

        try:
            with open(data_path, "r") as f:
                data = json.load(f)

            # Delete the flag file if it exists
            if flag_path.exists():
                flag_path.unlink()
                print(f"[Server] Deleted flag file, served data to client")

            self.send_json(data)

        except json.JSONDecodeError as e:
            self.send_json({"error": f"Invalid JSON: {e}"}, status=500)
        except Exception as e:
            self.send_json({"error": str(e)}, status=500)

    def send_json(self, data, status=200):
        """Send a JSON response."""
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Cache-Control", "no-cache")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def log_message(self, format, *args):
        """Custom logging to reduce noise."""
        if "/api/" in args[0]:
            print(f"[API] {args[0]}")



## Main Class
"""     ABOUT: main() 
Functionality:
    Changes directory to parent folder

    informs configuration for port FLAG_FILE DATA_FILE and url
    informs waiting for communication.

    Afterwards:
        Makes Server:
            HTTPServer object with "", and PORT from configuration
            Denotes TrackerHandler to be handler for server's urls requests
        Has server serve forever until keyboard interupt
"""
def main():
    os.chdir(Path(__file__).parent)

    print(f"Starting Project Zomboid Tracker Server")
    print(f"  Port: {PORT}")
    print(f"  Flag file: {FLAG_FILE}")
    print(f"  Data file: {DATA_FILE}")
    print(f"  URL: http://localhost:{PORT}/zomboid-tracker.html")
    print()
    print("Waiting for connections...")

    with http.server.HTTPServer(("", PORT), TrackerHandler) as server:
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            print("\nShutting down.")


## TOP LEVEL: Always Execute 
if __name__ == "__main__":
    main()
