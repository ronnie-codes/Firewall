systemctl stop wsdd
systemctl status wsdd
systemctl disable wsdd
systemctl mask wsdd
systemctl stop systemd-resolved
systemctl disable systemd-resolved
systemctl msk systemd-resolved
systemctl mask systemd-resolved
systemctl stop avahi-daemon.service 
systemctl disable avahi-daemon.service 
systemctl mask avahi-daemon.service 
systemctl stop chronyd
systemctl disable chronyd
systemctl mask chronyd
systemctl stop cups
systemctl disable cups
systemctl mask cups