# Check if solidcore-firstboot.sh exists in the working directory
if [ -e "$PWD/solidcore-firstboot.sh" ]; then
    :
else
    # Download solidcore-firstboot.sh
    wget -q https://raw.githubusercontent.com/solidc0re/solidcore-scripts/main/solidcore-firstboot.sh
fi

# Make solidcore-firstboot.sh executable
chmod +x solidcore-firstboot.sh

# Create the directory if it doesn't exist
mkdir -p /etc/solidcore

# Move the file to /etc/solidcore/
mv -f "solidcore-firstboot.sh" "/etc/solidcore/"

# Create first boot loader
cat > /etc/solidcore/solidcore-welcome.sh << EOF
