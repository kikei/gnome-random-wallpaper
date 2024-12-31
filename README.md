# gnome-random-wallpaper

A lightweight script that periodically sets a random GNOME wallpaper from
[wallhaven.cc](https://wallhaven.cc). Just pick your favorite keyword, and let
the script handle everything.

## Usage

1. Edit the query

Open `random_wallpaper.sh` and change the keyword to whatever you like:

```sh
QUERY="cats"
```

2. Install the script

```sh
cp random_wallpaper.sh ~/.local/bin/random_wallpaper.sh
chmod +x ~/.local/bin/random_wallpaper.sh
```

3. Register systemd service and timer

Create a timer and service under `~/.config/systemd/user/`, or copy them to
`/etc/systemd/system/`. Example (user-level):

```sh
cat <<EOF | tee ~/.config/systemd/user/random_wallpaper.timer
[Unit]
Description=Random wallpaper timer

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
EOF

cat <<EOF | tee ~/.config/systemd/user/random_wallpaper.service
[Unit]
Description=Random wallpaper service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/random_wallpaper.sh

[Install]
WantedBy=graphical.target
EOF
```

Then enable and start them:

```sh
systemctl --user daemon-reload
systemctl --user enable random_wallpaper.timer
systemctl --user start random_wallpaper.timer
```

(If you prefer system-level services, copy the files to `/etc/systemd/system/`
and remove `--user`.)

## Notes

- Requires `curl`, `jq`, and a GNOME environment.
- By default, it checks for images every hour (`OnCalendar=hourly`).
- Old wallpapers accumulate in `/tmp/random_wallpaper/`; clean it up
  periodically if you like.
