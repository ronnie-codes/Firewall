#!/bin/bash

# === FILE PERMISSIONS ===

# Ensure new files are only rwx by the user who created them
umask_script="/etc/profile.d/solidcore_umask.sh"

# Create the umask script
echo '#!/bin/bash' | tee "$umask_script" > /dev/null
echo 'umask 0077' | tee -a "$umask_script" > /dev/null

# Make the script executable
chmod +x "$umask_script"

echo "Newly created files now only readable by user that created them"
