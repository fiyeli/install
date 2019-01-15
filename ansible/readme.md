update your hosts file with your server ip
and run 
```
ansible-playbook playbook.yml -i hosts --ask-pass -c paramiko -vv
```
