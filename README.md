# aws_https_loadbalancer_nginx

In this repository you will deploy a webserver behind an application load balancer with Terraform on AWS. The webserver will be made available over the load balancer with a valid TLS certificate.

Steps involved are: 
- Create a VPC with subnets, routing tables, internet gateway and nat gateway
- Creating an EC2 instance with Ubuntu in a private subnet with no public ip address
- Creating a Security group that allows traffic over port 80 and 443. Loadbalancer listens on port 443 and webserver on port 80
- Create TLS certificates using Let's Encrypt
- Create an application load balancer to handle https traffic to the web server in the private subnet
- Point the DNS name for the website to the load balancer DNS name

Detailed diagram of the environment:  
![](diagram/vpc-diagram.png)     

There is a short [README.md](manual_steps/README.md) on how to do all this manually without Terraform. This is just to give you a better idea on the steps involved. Please use this only if you do not want to use Terraform. 

# Prerequisites

## AWS
We will be using AWS. Make sure you have the following
- AWS account  
- Install AWS cli [See documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

## Install terraform  
See the following documentation [How to install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## TLS certificate
You need to have valid TLS certificates that can be used with the DNS name you will be using to contact the webserver.  
  
The repo assumes you have no certificates and want to create them using Let's Encrypt and that your DNS domain is managed under AWS. 

# How to

- Clone the repository to your local machine
```
git clone https://github.com/munnep/aws_https_loadbalancer_nginx.git
```
- Go to the directory
```
cd aws_https_loadbalancer_nginx
```
- Set your AWS credentials
```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export AWS_SESSION_TOKEN=
```
- create a file called `variables.auto.tfvars` with the following contents and your own values
```
dns_hostname      = "patrick5"
dns_zonename      = "bg.hashicorp-success.com"
tag_prefix        = "patrick"
region            = "eu-west-3"
vpc_cidr          = "10.233.0.0/16"
ami               = "ami-0c6ebbd55ab05f070"
certificate_email = "patrick.munne@hashicorp.com"
```
- Terraform initialize
```
terraform init
```
- Terraform plan
```
terraform plan
```
- Terraform apply
```
terraform apply
```
- Terraform output should create 22 resources and show you the public dns string you can use to connect to the webserver
```
Apply complete! Resources: 28 added, 0 changed, 0 destroyed.

Outputs:

https_link = "https://patrick5.bg.hashicorp-success.com"
```
- You should be able to connect to the https_link with your web browser and see the nginx default webpage. This can take a few minutes before the DNS registration takes effect. 

# done
- [x] create VPC
- [x] create 2 subnets, one for public network, one for private network
- [x] create internet gw and connect to public network with a route table
- [x] create nat gateway, and connect to private network with a route table
- [x] route table association with the subnets 
- [x] security group for allowing port 80 and 443
- [x] create ec2 instance without public ip, only private subnet
- [x] import TLS certificate
- [x] create a LB (check Application Load Balancer or Network Load Balancer)
- [x] publish a service over LB, ie nginx
- [x] create DNS CNAME for website to loadbalancer DNS
- [x] Generate certificates with Let's Encrypt to use

# to do