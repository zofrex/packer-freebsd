build:
	packer build freebsd.json

add-box:
	vagrant box add --force --name freebsd-10.2 packer_vmware-iso_vmware.box
