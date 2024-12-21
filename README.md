# LauschLaus

A kid-friendly audio player system built for Raspberry Pi, featuring a React kiosk UI and Mopidy for audio playback.

## Installation
run

```bash
curl -fsSL https://raw.githubusercontent.com/gnorbsl/LauschLaus/master/get.sh | bash
```

## Troubleshooting

```bash
   sudo journalctl -u mopidy -f
sudo journalctl -u lausch-laus-frontend -f
sudo journalctl -u filebrowser -f
```

## Uninstall

```bash
./uninstall.sh
```
