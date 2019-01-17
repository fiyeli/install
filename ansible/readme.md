## Installation
First, update your hosts file with your server ip.

Then run the Ansible installation script: 
```console
ansible-playbook playbook.yml -i hosts --ask-pass -c paramiko -vv
```

## Troubleshooting
- Mismatch key :
```
fatal: [192.168.43.234]: UNREACHABLE! => {"changed": false, "msg": "host key mismatch for 192.168.43.234", "unreachable": true}
```
Host key of the remote host was changed. Either your are being attacked by a Man-in-the-Middle type attack or you re-installed your raspberry pi without changing it's IP address.

If your are sure to be in the second case (most likely), you can disable Ansible host key checking :
```console
export ANSIBLE_HOST_KEY_CHECKING=False
```
And then run again the network scan (see fiyeli/install README).
