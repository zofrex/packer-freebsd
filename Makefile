build:
	packer build freebsd.json

add-box:
	vagrant box add --force --name freebsd-10.2 packer_vmware-iso_vmware.box

proxy-start:
	tmux new-session -d -s polipo polipo

proxy-attach:
	tmux attach-session -t polipo

proxy-stop:
	tmux kill-session -t polipo
