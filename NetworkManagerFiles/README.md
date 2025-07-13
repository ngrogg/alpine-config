# Network Manager Files

## Files
* **any-user.conf**, Network Manager nm-applet config files. Allows use without polkit. Goes in `/etc/NetworkManager/conf.d/any-user.conf`. Requires restart to use.
* **NetworkManager.conf**, Network Manager config file. Goes in `/etc/NetworkManager/NetworkManager.conf`. Also includes WIFI section, however it assumes the use of "wpa_supplicant backend".
  Check docs if unclear!. <br>
