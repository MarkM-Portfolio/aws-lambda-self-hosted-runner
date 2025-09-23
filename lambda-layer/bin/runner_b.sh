#!/usr/bin/bash

USER="ubuntu"
LABEL="dev-automation--264309510997--B"
sudo hostnamectl set-hostname "$LABEL"

echo -e "\nAdd Docker official GPG key:"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo -e "\nSetup the Docker repository:"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo -e "\nAdd Hashicorp official GPG key:"
curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > hashicorp.gpg

echo -e "\nSetup the Hashicorp repository:"
sudo install -o root -g root -m 644 hashicorp.gpg /etc/apt/trusted.gpg.d/
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com focal main"

echo -e "\nAdd NodeJS repository:"
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

echo -e "\nUpdating apt packages..."
sudo apt -y update

echo -e "\nInstall Docker Engine"
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo -e "\nInstall Terraform and NodeJS"
sudo apt -y install terraform unzip nodejs

echo -e "\nInstall Session Manager Plugin"
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb
rm -rf session-manager-plugin.deb

echo -e "\nCreate the docker group."
sudo groupadd docker

echo -e "\nAdd your user to the docker group."
sudo usermod -aG docker $USER
newgrp docker

echo -e "\nAuthenticate to GitHub.."
sudo apt -y install gh awscli
GET_SECRET=`/usr/bin/aws secretsmanager get-secret-value --region eu-west-2 --secret-id github/secret | grep SecretString | awk '{print$2}' | cut -d : -f2 | tr -d '\\\"},'`
echo $GET_SECRET | /usr/bin/gh auth login --with-token

echo -e "\nGet ID of existing self-hosted runner"
RUNNER_ID=$(curl \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GET_SECRET"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/orgs/SapphireSystems/actions/runners | \
  grep -B1 "$LABEL" | grep -i id | head -n 1 | tr -d -c 0-9)

if [ ! -z $RUNNER_ID ]; then
  echo -e "\nDelete existing runner in Github"
  curl \
    -X DELETE \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GET_SECRET"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/orgs/SapphireSystems/actions/runners/$RUNNER_ID
fi

echo -e "\nCreate a folder under the drive root"
mkdir /home/$USER/actions-runner; cd /home/$USER/actions-runner

echo -e "\nDownload the latest runner package"
curl -o actions-runner-linux-x64-2.317.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-linux-x64-2.317.0.tar.gz

echo -e "\nValidate the hash"
echo "9e883d210df8c6028aff475475a457d380353f9d01877d51cc01a17b2a91161d  actions-runner-linux-x64-2.317.0.tar.gz" | shasum -a 256 -c

echo -e "\nExtract the installer"
tar -xzf ./actions-runner-linux-x64-2.317.0.tar.gz
chown -R $USER:$USER /home/$USER/actions-runner

echo -e "\nCreate the runner and start the configuration experience."
GET_TOKEN=$(curl \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GET_SECRET"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/orgs/SapphireSystems/actions/runners/registration-token | \
  grep "token" | awk '{print$2}' | tr -d '",')
sudo su - $USER -c "/usr/bin/bash /home/$USER/actions-runner/config.sh --labels $LABEL --url https://github.com/SapphireSystems --token $GET_TOKEN"

echo -e "\nAdd self-hosted runner to cronjob to run after a reboot."
sudo su - $USER -c "echo @reboot /home/$USER/actions-runner/run.sh > /home/$USER/actions-runner/job.txt"
sudo su - $USER -c "crontab /home/$USER/actions-runner/job.txt"
rm -rf "/home/$USER/actions-runner/job.txt"

# Run as job
sudo su - $USER -c "/usr/bin/bash /home/$USER/actions-runner/run.sh &"

# Run manually
# sudo su - $USER -c "/usr/bin/bash /home/$USER/actions-runner/run.sh"

# SSH Troubleshooting
# sudo mkdir -p /home/$USER/.ssh
# echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCIHGUEpNur7TTxTw8D1nXUIQuogLhA/vC38e5Sj2Y/vy89yrHmIULqYjgDNoicPRjVQHArEeaFtJZ4GSwUrjzWSdaJyTQsvP6umFbjgs/mG/nDQNnfAPhaFtutiYwkVrFGkWjJ//112I03FGfmVtkRNZzBqz4V8w+BGlNltWMrA0s23wpzT57Ioau8m5usXhwo0epJIQ7M8nsPApVreZla1GZ7r6RU+ClxNWvjD5GBbfmeq/V9MW+QVjzwnmAshZDxaRbwlLkVQPJ8a6YDDrMbqOpa9k9VY9pfuYDjPYOLKWOPKdi9vw1+Yl1pamjvPsld9oA4KIuCLW2Gn5sE7rbT self" >> /home/$USER/.ssh/authorized_keys

# To check userdata logs:
# sudo tail -300 /var/log/cloud-init-output.log
