echo '=== SRV ==================================='
echo '-------- ~/.ssh ---------------------------'
ls -l ~/.ssh
echo '-------- /etc/ssh -------------------------'
ls -l /etc/ssh
echo '-------- ~/.ssh/known-hosts ---------------'
cat ~/.ssh/known_hosts
echo '-------- k e y s --------------------------'
ssh-keygen -lf ~/.ssh/known_hosts
echo '--------         authorized_keys ----------'
cat ~/.ssh/authorized_keys
echo '-------- k e y s --------------------------'
sudo ssh-keygen -lf ~/.ssh/authorized_keys
echo '-------- /etc/ssh/known-hosts -------------'
cat /etc/ssh/ssh_known_hosts
echo '-------- k e y s --------------------------'
sudo ssh-keygen -lf /etc/ssh/ssh_known_hosts
echo '-------- rsa dsa ecdsa ed25519 -----------'
sudo ssh-keygen -lf /etc/ssh/ssh_host_rsa_key
sudo ssh-keygen -lf /etc/ssh/ssh_host_dsa_key
sudo ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key
sudo ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key

echo '=== RPI 9f55bbfd =========================='
echo '-------- ~/.ssh ---------------------------'
ls -l /nfs/9f55bbfd/home/jo/.ssh
echo '-------- /etc/ssh -------------------------'
ls -l /nfs/9f55bbfd/etc/ssh
echo '-------- ~/.ssh/known-hosts ---------------'
cat /nfs/9f55bbfd/home/jo/.ssh/known_hosts
echo '-------- k e y s --------------------------'
sudo ssh-keygen -lf /nfs/9f55bbfd/home/jo/.ssh/known_hosts
echo '--------         authorized_keys ----------'
cat /nfs/9f55bbfd/home/jo/.ssh/authorized_keys
echo '-------- k e y s --------------------------'
sudo ssh-keygen -lf /nfs/9f55bbfd/home/jo/.ssh/authorized_keys
echo '-------- /etc/ssh/known-hosts -------------'
cat /nfs/9f55bbfd/etc/ssh/ssh_known_hosts
echo '-------- k e y s --------------------------'
sudo ssh-keygen -lf /nfs/9f55bbfd/etc/ssh/ssh_known_hosts
echo '-------- rsa dsa ecdsa ed25519 -----------'
sudo ssh-keygen -lf /nfs/9f55bbfd/etc/ssh/ssh_host_rsa_key
sudo ssh-keygen -lf /nfs/9f55bbfd/etc/ssh/ssh_host_dsa_key
sudo ssh-keygen -lf /nfs/9f55bbfd/etc/ssh/ssh_host_ecdsa_key
sudo ssh-keygen -lf /nfs/9f55bbfd/etc/ssh/ssh_host_ed25519_key

echo '=== RPI a10cd2e5 =========================='
echo '-------- ~/.ssh ---------------------------'
ls -l /nfs/a10cd2e5/home/jo/.ssh
echo '-------- /etc/ssh -------------------------'
ls -l /nfs/a10cd2e5/etc/ssh
echo '-------- ~/.ssh/known-hosts ---------------'
cat /nfs/a10cd2e5/home/jo/.ssh/known_hosts
echo '-------- k e y s --------------------------'
sudo ssh-keygen -lf /nfs/a10cd2e5/home/jo/.ssh/known_hosts
echo '--------         authorized_keys ----------'
cat /nfs/a10cd2e5/home/jo/.ssh/authorized_keys
echo '-------- k e y s --------------------------'
sudo ssh-keygen -lf /nfs/a10cd2e5/home/jo/.ssh/authorized_keys
echo '-------- /etc/ssh/known-hosts -------------'
cat /nfs/a10cd2e5/etc/ssh/ssh_known_hosts
echo '-------- k e y s --------------------------'
sudo ssh-keygen -lf /nfs/a10cd2e5/etc/ssh/ssh_known_hosts
echo '-------- rsa dsa ecdsa ed25519 -----------'
sudo ssh-keygen -lf /nfs/a10cd2e5/etc/ssh/ssh_host_rsa_key
sudo ssh-keygen -lf /nfs/a10cd2e5/etc/ssh/ssh_host_dsa_key
sudo ssh-keygen -lf /nfs/a10cd2e5/etc/ssh/ssh_host_ecdsa_key
sudo ssh-keygen -lf /nfs/a10cd2e5/etc/ssh/ssh_host_ed25519_key

