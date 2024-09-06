# === CHRONY CONF ===

# Borrowed from GrapheneOS, keeping license intact
license_url="https://raw.githubusercontent.com/GrapheneOS/infrastructure/main/LICENSE"
chrony_url="https://raw.githubusercontent.com/GrapheneOS/infrastructure/main/chrony.conf"

mkdir -p ./tmp
wget -q -O ./tmp/LICENSE "$license_url"
sed 's/^/# /' ./tmp/LICENSE > ./tmp/LICENSE_temp
wget -q -O ./tmp/chrony.conf "$chrony_url"

systemctl stop chronyd.service
rm -rf /etc/chrony.conf

# Build new chrony.conf
cat ./tmp/LICENSE_temp >> /etc/chrony.conf
cat ./tmp/chrony.conf >> /etc/chrony.conf

# Update chronyd
sed -i 's/^OPTIONS=.*$/OPTIONS='"-F 1"'/' /etc/sysconfig/chronyd

# Clean up
systemctl start chronyd.service
rm -rf ./tmp
echo "Chrony configuration updated (thanks GrapheneOS!)"
