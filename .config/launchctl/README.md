# launchctl

## Usage

```console
$ ln -s ~/.config/launchctl/com.dotfiles.launchctl.maxfiles.plist /Library/LaunchDaemons/
$ sudo chown root:wheel /Library/LaunchDaemons/com.dotfiles.launchctl.maxfiles.plist
$ sudo launchctl load -wF /Library/LaunchDaemons/com.dotfiles.launchctl.maxfiles.plist
$ sudo reboot
```
