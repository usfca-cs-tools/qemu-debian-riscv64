.PHONY: all setup image start provision ssh clean

all: setup image

setup:
	@echo "==> Installing QEMU via Homebrew..."
	brew install qemu
	@echo "==> Verifying qemu-system-riscv64..."
	qemu-system-riscv64 --version

image:
	@echo "==> Downloading and preparing DQIB image..."
	./scripts/fetch-image.sh

start:
	@echo "==> Booting QEMU VM..."
	./scripts/start.sh

provision:
	@echo "==> Provisioning VM with dev tools..."
	./scripts/provision.sh

ssh:
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i image/ssh_user_ed25519_key -p 2222 root@localhost

clean:
	rm -rf image/ *.zip
