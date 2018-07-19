# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.ssh.shell = 'sh'

  # get rid of warnings about overriding VMX settings
  # https://www.vagrantup.com/docs/vmware/boxes.html#vmx-whitelisting
  ["vmware_workstation", "vmware_fusion"].each do |vmware_provider|
    config.vm.provider(vmware_provider) do |vmware|
      vmware.whitelist_verified = true
    end
  end
end
