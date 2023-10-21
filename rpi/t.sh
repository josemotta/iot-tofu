echo '====srv===================================='
echo '-------- ~/.ssh ---------------------------'
ls -l ~/.ssh
echo '-------- /etc/ssh -------------------------'
ls -l /etc/ssh
echo '-------- srv-usr known-hosts --------------'
cat ~/.ssh/known_hosts
echo '--------         authorized_keys ----------'
cat ~/.ssh/authorized_keys
echo '-------- srv-sys known-hosts --------------'
cat /etc/ssh/ssh_known_hosts
echo '====rpi===================================='
echo '-------- ~/.ssh ---------------------------'
ls -l /nfs/9f55bbfd/home/jo/.ssh
echo '-------- /etc/ssh -------------------------'
ls -l /nfs/9f55bbfd/etc/ssh
echo '-------- rpi-usr known-hosts --------------'
cat /nfs/9f55bbfd/home/jo/.ssh/known_hosts
echo '--------         authorized_keys ----------'
cat /nfs/9f55bbfd/home/jo/.ssh/authorized_keys
echo '-------- rpi-sys known-hosts --------------'
cat /nfs/9f55bbfd/etc/ssh/ssh_known_hosts
