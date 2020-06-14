build: disk1.vdi disk2.vdi disk3.vdi disk4.vdi disk5.vdi
	packer build -on-error=ask freebsd.json

add-box:
	vagrant box add --force --name freebsd-12.1-5disk-pkg packer_virtualbox-iso_virtualbox.box

proxy-start:
	tmux new-session -d -s polipo polipo
	@echo export HOST_HTTP_PROXY=$(shell ipconfig getifaddr en0):8123

proxy-attach:
	tmux attach-session -t polipo

proxy-stop:
	tmux kill-session -t polipo

disk%.vdi:
	VBoxManage createhd --filename $@ --size 10240
