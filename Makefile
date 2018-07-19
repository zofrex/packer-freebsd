build:
	packer build -on-error=ask freebsd.json

add-box:
	vagrant box add --force --name freebsd-10.2 packer_vmware-iso_vmware.box

proxy-start:
	tmux new-session -d -s polipo polipo
	@echo export HOST_HTTP_PROXY=$(shell ipconfig getifaddr en0):8123

proxy-attach:
	tmux attach-session -t polipo

proxy-stop:
	tmux kill-session -t polipo
