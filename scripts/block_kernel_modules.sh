#!/bin/bash

# === BLOCK KERNEL MODULES ===

block_file="/etc/modprobe.d/solidcore-blocklist.conf"

# List of module names to be blocked
modules_to_block=(
    "af_802154"
    "appletalk" # Already blacklisted in Fedora, adding install <module> /bin/true to block re-loading
    "atm" # Already backlisted in Fedora, adding install <module> /bin/true to block re-loading
    "ax25" # Already blacklisted in Fedora, adding install <module> /bin/true to block re-loading
    "can"
    "cdrom"
    "cifs"
    "cramfs"
    "decnet"
    "dccp"
    "econet"
    "freevxfs"
    "gfs2"
    "hfs"
    "hfsplus"
    "ipx"
    "jffs2"
    "ksmbd"
    "mei" # Intel Management Engine
    "mei-me" # Intel Management Engine
    "msr"
    "n-hdlc"
    "netrom" # Already blacklisted in Fedora, adding install <module> /bin/true to block re-loading
    "nfs"
    "nfsv3"
    "nfsv4"
    "p8022"
    "p8023"
    "psnap"
    "rds" # Already blacklisted in Fedora, adding install <module> /bin/true to block re-loading
    "rose" # Already blacklisted in Fedora, adding install <module> /bin/true to block re-loading
    "sctp" # Already blacklisted in Fedora, adding install <module> /bin/true to block re-loading
    "sr_mod"
    "squashfs"
    "tipc"
    "udf"
    "vivid"
    "x25"
)

# Add module names to the blacklist configuration file
echo "# Blocked kernel modules to prevent loading. Created by solidcore script." | tee "$block_file" > /dev/null
for module in "${modules_to_block[@]}"; do
    echo "install $module /bin/true" | tee -a "$block_file" > /dev/null
done

# Additional modules to blacklist, thanks to Kicksecure & Ubuntu
modules_to_blacklist=(
    "amd76x_edac"
    "asus_acpi"
    "ath_pci"
    "aty128fb"
    "atyfb"
    "bcm43xx"
    "cirrusfb"
    "cyber2000fb"
    "cyblafb"
    "de4x5"
    "eepro100"
    "eth1394"
    "evbug"
    "garmin_gps"
    "gx1fb"
    "hgafb"
    "i810fb"
    "intelfb"
    "kyrofb"
    "lxfb"
    "matroxfb_bases"
    "neofb"
    "nvidiafb"
    "pcspkr"
    "pm2fb"
    "prism54"
    "radeonfb"
    "rivafb"
    "s1d13xxxfb"
    "savagefb"
    "sisfb"
    "snd_aw2"
    "snd_intel8x0m"
    "snd_pcsp"
    "sstfb"
    "tdfxfb"
    "tridentfb"
    "udlfb"
    "usbkbd"
    "usbmouse"
    "vesafb"
    "vfb"
    "viafb"
    "vt8623fb"
)

# Add module names to the blacklist configuration file
for module in "${modules_to_blacklist[@]}"; do
    echo "blacklist $module" | tee -a "$block_file" > /dev/null
done

echo "Unsafe and legacy kernel modules blocked"
