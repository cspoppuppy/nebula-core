# Development

Update k3s
```shell
# Update
ansible-playbook -i inventory.ini k3s-install.yml -K

# Verfiy
ansible -i inventory.ini masters -a "sudo systemctl status k3s" -b -K
ansible -i inventory.ini workers -a "sudo systemctl status k3s-agent" -b -K
```