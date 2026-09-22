# vpsinit

vpsinit is a Debian/Ubuntu VPS initialization script that installs common tools, Zsh, Oh My Zsh, Docker, and enables BBR when supported.

## Usage

```bash
sudo -i
curl -fsSL https://raw.githubusercontent.com/smallsun107/vpsinit/main/init.sh | bash
```

To install 3x-ui with Docker as well:

```bash
curl -fsSL https://raw.githubusercontent.com/smallsun107/vpsinit/main/init.sh | bash -s -- 3xui
```
