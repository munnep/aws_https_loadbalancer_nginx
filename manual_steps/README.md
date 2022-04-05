# Manual steps

This document describes the manual steps for creating a webserver behind a loadbalancer which you can then connect to over the internet using https. The webserver is in a private subnet

See below diagram for how the setup is:
![vpc-diagram.png](vpc-diagram.png)




- Create a VPC with cidr block ```10.233.0.0/16```  
![](media/2021-12-08-13-51-43.png)  
- Create 3 subnets. 2 public subnets and 1 private subnet
    - patrick-public1-subnet (ip: ```10.233.1.0/24``` availability zone: ```us-east-1a```)  
    - patrick-public2-subnet (ip: ```10.233.2.0/24``` availability zone: ```us-east-1b```)  
    - patrick-private1-subnet (ip: ```10.233.11.0/24``` availability zone: ```us-east-1a```)  
![](media/2021-12-08-14-05-39.png)  
![](media/2021-12-08-14-05-55.png)  
![](media/2021-12-08-14-06-08.png)  
![](media/2021-12-08-14-06-23.png)  
- create an internet gateway  
![](media/2021-12-08-14-07-45.png)    
![](media/2021-12-08-14-08-09.png)  
- create a nat gateway which you attach to ```patrick-public1-subnet```   
![](media/2021-12-08-15-20-55.png)  
- create routing table for public  
![](media/2021-12-08-14-10-55.png)  
   - edit the routing table for internet access to the internet gateway
   ![](media/2021-12-08-14-12-18.png)  
- create routing table for private  
   ![](media/2021-12-08-14-13-32.png)  
   - edit the routing table for internet access to the nat gateway  
   ![](media/2021-12-08-14-14-41.png)   
- attach routing tables to subnets  
    - patrick-public-route to public subnets      
    ![](media/2021-12-08-14-16-18.png)      
    - patrick-private-route to private subnet   
     ![](media/2021-12-08-14-17-53.png)    
- create a security group that allows http and https from all locations    
![](media/2021-12-08-14-20-11.png)    
- create an ec2 instance that install nginx software from the start  
![](media/2021-12-08-14-21-49.png)      
![](media/2021-12-08-14-22-07.png)    
![](media/2021-12-08-14-24-34.png)    
    - Use the following code to automatically install and start the nginx server
```
#cloud-config
runcmd:
  - apt-get install -y nginx
  - systemctl enable --no-block nginx 
  - systemctl start --no-block nginx 
````
![](media/2021-12-08-14-25-06.png)    
![](media/2021-12-08-14-25-55.png)    
![](media/2021-12-08-14-26-09.png)    

![](media/2021-12-08-14-26-32.png)    
![](media/2021-12-08-14-27-07.png)  
- loadbalancer create a target group  
![](media/2021-12-08-14-32-27.png)    
![](media/2021-12-08-14-31-55.png)    
![](media/2021-12-08-14-33-05.png)    
- loadbalancer create a appplication load balancer  
![](media/2021-12-08-14-29-33.png)    
![](media/2021-12-08-14-30-02.png)    
![](media/2021-12-08-14-30-26.png)    
![](media/2021-12-08-14-30-47.png)    
![](media/2021-12-08-14-33-33.png)    
- loadbalancer generated a DNS name which you can use to connect to the application server  
![](media/2021-12-08-15-36-38.png)  
[patrick-loadbalancer-1479571194.us-east-1.elb.amazonaws.com](patrick-loadbalancer-1479571194.us-east-1.elb.amazonaws.com)









