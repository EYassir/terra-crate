#!/bin/bash
touch /home/ubuntu/test.txt
crate_port=4300
apt update
apt install awscli -y
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
aws ec2 describe-instances \
--region $EC2_REGION \
--filters Name=tag:Project,Values=cratedb \
--query "Reservations[*].Instances[*].PrivateIpAddress" \
--output text > /home/ubuntu/nodes.txt
# Download the CrateDB GPG key
wget https://cdn.crate.io/downloads/deb/DEB-GPG-KEY-crate
# Add the key to Apt
apt-key add DEB-GPG-KEY-crate
# Add CrateDB repositories to Apt
# `lsb_release -cs` returns the codename of your OS
add-apt-repository "deb https://cdn.crate.io/downloads/deb/stable/ $(lsb_release -cs) main"
# Add yq repository
add-apt-repository -y ppa:rmescandon/yq
#install cratedb
apt update
apt install crate yq -y
#stop crate
systemctl stop crate
#configure crate
memory=$(free -h | grep Mem | awk '{print $2}')
GI='Gi'
MI='Mi'
if [[ "$memory" == *"$GI"* ]]; then
  memory=$(echo $memory | sed 's/Gi//')
  memory=$(echo $memory*1000 | bc)
  memory=$${memory%.*}
  echo "CRATE_HEAP_SIZE=$(((memory * 25)/100))m" >> /etc/default/crate
elif [[ "$memory" == *"$MI"* ]]; then
  memory=$(echo $memory | sed 's/Mi//')
  echo "CRATE_HEAP_SIZE=$(((memory * 25)/100))m" >> /etc/default/crate
fi

#get crate cluster conf
aws s3 cp s3://eyassir-cratedb-bucket-state/crate-cluster-conf/crate.yml /etc/crate/crate.yml
#clear seeds
yq w -i /etc/crate/crate.yml "discovery.seed_hosts"
#clear masters
yq w -i /etc/crate/crate.yml "cluster.initial_master_nodes"
#edit seed hosts and masters
nodes_count=0
for node in $(cat /home/ubuntu/nodes.txt)
do
  yq w -i /etc/crate/crate.yml "discovery.seed_hosts[+]" $node":"$crate_port
  yq w -i /etc/crate/crate.yml "cluster.initial_master_nodes[+]" $node":"$crate_port
  nodes_count=$(($nodes_count+1))
done
#Update number of expected nodes
yq w -i /etc/crate/crate.yml "gateway.expected_nodes" $nodes_count #$(wc -l /home/ubuntu/nodes.txt | awk '{print $1}')
yq w -i /etc/crate/crate.yml "gateway.recover_after_nodes" $(($nodes_count - 1))
#start crate
systemctl start crate
#upload new conf
aws s3 cp /etc/crate/crate.yml s3://eyassir-cratedb-bucket-state/crate-cluster-conf/crate.yml

#Sync nodes 
aws ssm send-command \
        --document-name "AWS-RunShellScript" \
        --parameters 'commands=["aws s3 cp s3://eyassir-cratedb-bucket-state/crate-cluster-conf/crate.yml /etc/crate/crate.yml","systemctl stop crate","systemctl start crate"]' \
        --targets "Key=tag:Project,Values=cratedb" \
        --comment "Sync cratedb nodes" \
        --region $EC2_REGION
