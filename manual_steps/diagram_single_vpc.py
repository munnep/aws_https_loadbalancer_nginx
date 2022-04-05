from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC, PrivateSubnet, PublicSubnet, InternetGateway, NATGateway, ElbApplicationLoadBalancer
from diagrams.onprem.compute import Server

# Variables
title = "Webserver in AWS"
outformat = "png"
filename = "webserver-diagram"
direction = "LR"


with Diagram(
    name=title,
    direction=direction,
    filename=filename,
    outformat=outformat,
) as diag:
    # Non Clustered
    user = Server("user")

    # Cluster 
    with Cluster("default VPC"):
        ec2_server_web_server = EC2("web_server")
 
    # Diagram
    user >> ec2_server_web_server 

diag
