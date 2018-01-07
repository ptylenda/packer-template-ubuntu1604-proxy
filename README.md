1. There is a limitation for Boot Options length that can be used when installing Ubuntu using QEMU. This means that there may be not enough place to type all commands connected with keyboard, but you can use auto-install/enable=true and feed them from preseed.cfg
2. Downloading preseed.cfg from preseed/url is sensitive to proxy settings set in mirror/http/proxy (which seems contrary to description of this parameter). Fortunately setting an environment variable no_proxy from boot parameters is enough to force no proxy for Packer http server for wget
3. For Hyper-V if you would like to use Gen. 2 machines, you can't use floppies (https://technet.microsoft.com/en-us/library/dn282285(v=ws.11).aspx), therefore you have to stick to preseed/url method for providing preseed.cfg.
4. Using "choose-mirror-bin mirror/http/proxy string addr" in preseed.cfg is different from using "mirror/http/proxy=addr" from boot parameters - the second one also affects downloading preseed.cfg from http server.
5. In case of Hyper-V it is important to perform "d-i preseed/late_command string in-target apt-get install -y --install-recommends linux-virtual-lts-xenial linux-tools-virtual-lts-xenial linux-cloud-tools-virtual-lts-xenial;", directly in preseed.cfg, BEFORE any provisioner runs. These packages are needed in order to discover IP address of VM properly so that Packer can connect via SSH. Otherwise it will be waiting for IP address forever. More details can be found in "Notes" in https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v
6. For shell provisioners and propagation of proxy settings, use:
"environment_vars": [
    "FTP_PROXY={{ user `ftp_proxy` }}",
    "HTTPS_PROXY={{ user `https_proxy` }}",
    "HTTP_PROXY={{ user `http_proxy` }}",
    "INSTALL_VAGRANT_KEY={{ user `install_vagrant_key` }}",
    "NO_PROXY={{ user `no_proxy` }}",
    "ftp_proxy={{ user `ftp_proxy` }}",
    "http_proxy={{ user `http_proxy` }}",
    "https_proxy={{ user `https_proxy` }}",
    "no_proxy={{ user `no_proxy` }}"
  ]
7. For ansible-local provisioner use:
"extra_arguments": [
    "--extra-vars",
    "{'\"http_proxy\":\"{{ user `http_proxy` }}\", \"https_proxy\":\"{{ user `https_proxy` }}\", \"no_proxy\":\"{{ user `no_proxy` }}\", \"ftp_proxy\":\"{{ user `ftp_proxy` }}\"}'"
  ]
Then handle these variables appropriately in playbook, set environment variables, etc.
8. In case of ansible-local there are problems when specifying inventory_groups: even though connection type passed to ansible is "local", it gets ignored and regular SSH connection is used. This causes problems due to unauthorized key for passwordless login to localhost. As a workaround you have to specify inventory_file with ansible_connection specified explicitly, for example:
[linux]
127.0.0.1 ansible_connection=local
