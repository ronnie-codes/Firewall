# Define Boot Parameters
boot_parameters=(
    "slab_nomerge"
    "init_on_alloc=1"
    "init_on_free=1"
    "page_alloc.shuffle=1"
    "pti=on"
    "randomize_kstack_offset=on"
    "vsyscall=none"
    "debugfs=off"
    "quiet loglevel=0"
    "random.trust_cpu=off"
    "random.trust_bootloader=off"
    "efi=disable_early_pci_dma"
    "mitigations=auto"
    "iommu.passthrough=0"
    "iommu.strict=1"
    "extra_latent_entropy"
)

# Check CPU vendor using lscpu
cpu_vendor=$(lscpu | awk '/Vendor/ {print $3}')

# Add IOMMU parameter based on CPU vendor
case "$cpu_vendor" in
    GenuineIntel*) boot_parameters+=("intel_iommu=on") ;;
    AuthenticAMD*) boot_parameters+=("amd_iommu=on") ;;
    *) echo "[Notice] CPU vendor doesn't match GenuineIntel or AuthenticAMD. CPU Vendor currently recorded as: $cpu_vendor" ;;
esac

# Backup existing kargs and keep new kargs for uninstall process
sudo rpm-ostree kargs > /etc/solidcore/kargs-orig_sc.bak
printf "%s\n" "${boot_parameters[@]}" > /etc/solidcore/kargs-added_sc.bak

# Construct a single string with all the parameters
param_string=""
for param in "${boot_parameters[@]}"; do
    param_string+="--append-if-missing=$param "
done

# Remove the trailing space
param_string="${param_string%" "}"

# Cancel any current rpm-ostree operations and append boot parameters
sudo rpm-ostree cancel -q
sudo rpm-ostree kargs -q $param_string > /dev/null
