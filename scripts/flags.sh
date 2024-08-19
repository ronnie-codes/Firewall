# KERNEL
sudo sysctl -w kernel.kptr_restrict=2
sudo sysctl -w kernel.dmesg_restrict=1
sudo sysctl -w kernel.printk="3 3 3 3"
sudo sysctl -w kernel.unprivileged_bpf_disabled=1
sudo sysctl -w net.core.bpf_jit_harden=2
sudo sysctl -w dev.tty.ldisc_autoload=0
sudo sysctl -w kernel.kexec_load_disabled=1
sudo sysctl -w kernel.sysrq=0
sudo sysctl -w kernel.perf_event_paranoid=3

# NETWORK
sudo sysctl -w net.ipv4.tcp_syncookies=1
sudo sysctl -w net.ipv4.tcp_rfc1337=1
sudo sysctl -w net.ipv4.conf.all.rp_filter=1
sudo sysctl -w net.ipv4.conf.default.rp_filter=1
sudo sysctl -w net.ipv4.conf.all.accept_redirects=0
sudo sysctl -w net.ipv4.conf.default.accept_redirects=0
sudo sysctl -w net.ipv4.conf.all.secure_redirects=0
sudo sysctl -w net.ipv4.conf.default.secure_redirects=0
sudo sysctl -w net.ipv6.conf.all.accept_redirects=0
sudo sysctl -w net.ipv6.conf.default.accept_redirects=0
sudo sysctl -w net.ipv4.conf.all.send_redirects=0
sudo sysctl -w net.ipv4.conf.default.send_redirects=0
sudo sysctl -w net.ipv4.icmp_echo_ignore_all=1
sudo sysctl -w net.ipv6.conf.all.accept_ra=0
sudo sysctl -w net.ipv6.conf.default.accept_ra=0
sudo sysctl -w net.ipv4.tcp_sack=0
sudo sysctl -w net.ipv4.tcp_dsack=0
sudo sysctl -w net.ipv4.tcp_fack=0
sudo sysctl -w net.ipv4.tcp_timestamps=0
sudo sysctl -w net.ipv6.conf.all.use_tempaddr=2
sudo sysctl -w net.ipv6.conf.default.use_tempaddr=2

# USERSPACE
sudo sysctl -w kernel.yama.ptrace_scope=2
sudo sysctl -w vm.mmap_rnd_bits=32
sudo sysctl -w vm.mmap_rnd_compat_bits=16
sudo sysctl -w fs.protected_fifos=2
sudo sysctl -w fs.protected_regular=2
