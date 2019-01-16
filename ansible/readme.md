update your hosts file with your server ip
and run 
```
ansible-playbook playbook.yml -i hosts --ask-pass -c paramiko -vv
```

to avoid knowhost issue

you can set up 
```
$ export ANSIBLE_HOST_KEY_CHECKING=False
```
