# qemu-debian-riscv64

Run a Debian RISC-V 64-bit virtual machine on macOS using QEMU. Downloads a pre-built [DQIB](https://gitlab.com/giomasce/dqib) image, boots it with `qemu-system-riscv64`, and optionally provisions it with common development tools.

## Prerequisites

- macOS with [Homebrew](https://brew.sh)
- ~2 GB disk for the base image (resized to 32 GB qcow2)

## Quick Start

```bash
# Install QEMU and download the disk image
make setup
make image

# Boot the VM (runs in the foreground, Ctrl-A X to quit)
make start

# In another terminal — provision with dev tools (gcc, python3, cmake, git, etc.)
make provision

# Or just SSH in
make ssh
```

## Make Targets

| Target | Description |
|---|---|
| `make setup` | Install QEMU via Homebrew |
| `make image` | Download the DQIB riscv64-virt image and resize it to 32 GB |
| `make start` | Boot the VM (nographic mode, serial console) |
| `make provision` | Wait for SSH, then install build tools and grow the root partition |
| `make ssh` | SSH into the running VM as `root` |
| `make clean` | Delete the `image/` directory and any downloaded zip files |

## VM Details

| Setting | Value |
|---|---|
| Architecture | RISC-V 64-bit (`rv64`) |
| Machine | `virt` |
| RAM | 4 GB |
| CPUs | 4 |
| Disk | 32 GB (qcow2, virtio-blk) |
| Network | User-mode networking, host port `2222` forwarded to guest port `22` |
| Console | Serial (`ttyS0`, nographic) |

## SSH Access

The DQIB image ships with an ED25519 key at `image/ssh_user_ed25519_key`. The VM listens on **localhost:2222**:

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i image/ssh_user_ed25519_key -p 2222 root@localhost
```

Or simply: `make ssh`

## Provisioned Packages

Running `make provision` installs:

- **Build tools** — gcc, g++, make, cmake, autoconf, automake, libtool, pkg-config
- **Python** — python3, pip, venv, dev headers
- **Utilities** — git, curl, wget, vim, gdb, strace, htop, tmux
- **System** — openssh-server, ca-certificates, locales (en_US.UTF-8)

It also grows the root partition to fill the full 32 GB disk.

## Exiting the VM

Press **Ctrl-A** then **X** to terminate QEMU from the serial console.

## License

See [LICENSE](LICENSE) if present.
