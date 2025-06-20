# Docker Install Script

Quick script to install the latest Docker and Docker Compose plugin on Ubuntu.

## Usage
Run on terminal : 
```bash
curl -fsSL https://raw.githubusercontent.com/isach5/docker.sh/main/install_docker.sh | sudo bash
```

# OR

Save the Script:

Create a new file (e.g., install_docker.sh) and paste the script into it.

Make It Executable and Run it as Root:
```
chmod +x install_docker.sh

sudo ./install_docker.sh
```
Log Out/In (If User Group Was Modified):

If you added a user to the Docker group, log out and back in so that group changes take effect.

