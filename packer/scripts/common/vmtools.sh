#!/bin/bash

case "$PACKER_BUILDER_TYPE" in

virtualbox-iso|virtualbox-ovf)
    mkdir /tmp/vbox
    VER=$(cat /home/vagrant/.vbox_version)
    mount -o loop /home/vagrant/VBoxGuestAdditions_$VER.iso /tmp/vbox
    sh /tmp/vbox/VBoxLinuxAdditions.run
    umount /tmp/vbox
    rmdir /tmp/vbox
    rm /home/vagrant/*.iso
    ;;

vmware-iso|vmware-vmx)
    mkdir /tmp/vmfusion
    mkdir /tmp/vmfusion-archive
    mount -o loop /home/vagrant/linux.iso /tmp/vmfusion
    tar xzf /tmp/vmfusion/VMwareTools-*.tar.gz -C /tmp/vmfusion-archive
    /tmp/vmfusion-archive/vmware-tools-distrib/vmware-install.pl --default
    umount /tmp/vmfusion
    rm -rf  /tmp/vmfusion
    rm -rf  /tmp/vmfusion-archive
    rm /home/vagrant/*.iso
    ;;

parallels-iso|parallels-pvm)
    mkdir /tmp/parallels
    mount -o loop /home/vagrant/prl-tools-lin.iso /tmp/parallels
    /tmp/parallels/install --install-unattended-with-deps
    umount /tmp/parallels
    rmdir /tmp/parallels
    rm /home/vagrant/*.iso
    ;;

qemu)
    echo "NOZEROCONF=yes" >> /etc/sysconfig/network
    sed -i '$d' /etc/rc.d/rc.local
    cat << EOF >> /etc/rc.d/rc.local
    if [ ! -d /home/vagrant/.ssh ]; then 
      mkdir -p /home/vagrant/.ssh 
      chmod 700 /home/vagrant/.ssh
    fi 
    # Fetch public key using HTTP 
    curl -f http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key > /home/vagrant/metadata-key 2> /dev/null 
    if [ $? -eq 0 ]; then 
      cat /home/vagrant/metadata-key >> /home/vagrant/.ssh/authorized_keys
      rm -f /home/vagrant/metadata-key 
      echo 'Successfully retrieved public key from instance metadata'
      echo '*****************'
      echo 'AUTHORIZED KEYS'
      echo '*****************'
      cat /home/vagrant/.ssh/authorized_keys
      echo '*****************'
    fi
    touch /var/lock/subsys/local
EOF
    ;;

*)
    echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected."
    echo "Known are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm."
    ;;

esac
