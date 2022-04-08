This directory should contain your keys and certificates used to connect to your website with TLS

`privkey.pem`  : the private key for your certificate.
`fullchain.pem`: the certificate file used in most server software.
`chain.pem`    : Certificate chain
`cert.pem`     : Certificate body

## TLS certificate
You need to have valid TLS certificates that can be used with the DNS name you will be using to contact the webserver.  
  
If you don't have valid SSL certificates you can create one for free using Let's Encrypt. This repository includes an instruction on how to do this. [See documentation](manual_steps/nginx_create_certificate/README.md) This documentation will use Vagrant to create a server that can be used to create the SSL certificates. If you have SSL certificates you can skip this manual.    

Your TLS certificates should be placed in the ```certificates``` folder