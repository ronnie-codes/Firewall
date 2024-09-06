# === HIDEPID ===

# Create service to remount /proc, /dev/shm and /tmp

cat > /etc/systemd/system/solidcore-remount.service << EOF
# Inspired by Kicksecure's proc-hidepid.service
# https://raw.githubusercontent.com/Kicksecure/security-misc/master/lib/systemd/system/proc-hidepid.service

[Unit]
Description=Remounts existing /proc, /dev/shm and /tmp
DefaultDependencies=no
Before=sysinit.target
Requires=local-fs.target
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/bin/mount -o remount,hidepid=2 /proc
ExecStart=/bin/mount -o remount,noexec /dev/shm
ExecStart=/bin/mount -o remount,noexec /tmp
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
EOF

systemctl daemon-reload
systemctl enable solidcore-remount.service > /dev/null 2>&1

echo "hidepid enabled for /proc"
