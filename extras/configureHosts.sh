stack=$1
n=$(($2 - 1))

echo "Retrieving all hostname and IP values from stack"
pdsh -N -w centos@${stack}[0-$n].field.hortonworks.com 'myip=$(hostname -I); myname=$(hostname -f); echo $myip $myname' > hadoop_hosts

cluster=$(cat hadoop_hosts | awk '{print $2}')

echo "Saving original /etc/hosts values"
pdsh -w centos@${stack}[0-$n].field.hortonworks.com "sudo cp /etc/hosts /etc/hosts.orig"

echo "Uploading new hosts entries to append to all instances in stack"
for host in $cluster; do scp hadoop_hosts centos@$host:; done

echo "Appending new hosts entries with original for all instances in stack"
pdsh -w centos@${stack}[0-$n].field.hortonworks.com "sudo cat /etc/hosts.orig hadoop_hosts >> /etc/hosts"
