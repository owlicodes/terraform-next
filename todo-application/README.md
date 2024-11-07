# Todo Application - Terraform

The purpose of this project is to be the application that will be deployed in the terraform-nextjs project.

Once you apply the resources on the terraform-nextjs project, you can manually deploy this project on the EC2 instances that the terraform project created. To do the manual deploy, follow the manual deploy instructions below.

## Manual Deploy

First, SSH into each of the EC2 instances, remember, the terraform project will create 2 EC2 instances for redundancy, you need to SSH into both of them.

```bash
ssh -i ~/.ssh/nextjs-deployer ec2-user@<instance_public_ip>
```

Run the commands below while inside the instance to install nodejs.

```bash
sudo yum update
sudo yum check-update
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs
```

Install pm2

```bash
sudo npm install -g pm2
```

Next, you can exit out of your EC2 instance and build your Next.js application.

```bash
npm run build
```

After that, there is a deploy.sh file in the root of the project, run the script.

To run, you need to make the script executable first.

```bash
chmod +x deploy.sh
```

To run the script, run the command below.

```bash
./deploy.sh
```

To check if the application is running on each instance, execute the command below.

```bash
ssh -i ~/.ssh/nextjs-deployer ec2-user@<instance-ip> "pm2 status"
```

To test the application in the browser, you can go to your AWS Console, go to EC2 Service, go to Load Balancers, here you should see the load balancer for your Next.js application. Copy the **DNS Name** and paste it in the browser.

Example of DNS Name: nextjs-alb-1597703553.ap-southeast-1.elb.amazonaws.com
