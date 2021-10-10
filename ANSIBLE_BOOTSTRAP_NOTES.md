# Ansible bootstrap notes

## Configure Ansible control station

### Install pip, ansible, cockpit and tmux
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install python3-pip -y
sudo apt install tmux cockpit -y
sudo apt-get install python-dev libkrb5-dev krb5-user

pip install --upgrade pip --user
pip install ansible --user
pip install pywinrm[kerberos] --user
pip install --upgrade pywinrm[kerberos] --user
```
### Sample /etc/krb5.conf
```bash
[libdefaults]
        default_realm = RJKNET.CA

# The following krb5.conf variables are only for MIT Kerberos.
        kdc_timesync = 1
        ccache_type = 4
        forwardable = true
        proxiable = true

# The following encryption type specification will be used by MIT Kerberos
# if uncommented.  In general, the defaults in the MIT Kerberos code are
# correct and overriding these specifications only serves to disable new
# encryption types as they are added, creating interoperability problems.
#
# The only time when you might need to uncomment these lines and change
# the enctypes is if you have local software that will break on ticket
# caches containing ticket encryption types it doesn't know about (such as
# old versions of Sun Java).

#       default_tgs_enctypes = des3-hmac-sha1
#       default_tkt_enctypes = des3-hmac-sha1
#       permitted_enctypes = des3-hmac-sha1

# The following libdefaults parameters are only for Heimdal Kerberos.
        fcc-mit-ticketflags = true

[realms]
        RJKNET.CA = {
                kdc = win01.rjknet.ca
        }

[domain_realm]
        .rjknet.ca = RJKNET.CA
```

## Windows Server configuration
```powershell
Enable-PSRemoting
```
add user RJKNET\zs_ansible to Domain Administrators group (or local admin on each host)  

### Example inventory file invjw for Windows WinRM hosts
```bash
[windows]
win01.rjknet.ca
win02.rjknet.ca
win03.rjknet.ca

[windows:vars]
ansible_user="zs_ansible@RJKNET.CA"
ansible_password=Sup3rS3cr3t
ansible_connection=winrm
ansible_winrm_scheme=http
ansible_port=5985
ansible_winrm_transport=kerberos
```
## Example Ansible ad-hoc commands

#### Apply Windows Updates
```bash
ansible windows -i invjw -m win_updates -a "category_names=["CriticalUpdates","SecurityUpdates","UpdateRollups","DefinitionUpdates"] state=installed reboot=yes"
```
#### Apply Windows Defender Definition Updates
```bash
ansible windows -i invjw -m win_updates -a "category_names=DefinitionUpdates state=installed reboot=yes"
```


## References
* https://www.ansible.com/blog/windows-updates-and-ansible
* https://aventistech.com/kb/ansible-with-kerberos-authentication/
