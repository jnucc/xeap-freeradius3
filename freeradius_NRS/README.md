FreeRADIUS 3   Simple Hands on lab 

Installation
http://wiki.eduroam.kr/display/EKW/Deploying+FreeRADIUS+for+eduroam

Base configuration 
Configuration files that have been edited in /etc/freeradius
radiusd.conf
clients.conf 
proxy.conf
mods-config/files/authrorize   #new location for /etc/freeradius/users  symbolic link
mods-available/eap

1. radiusd.conf
The main configuration file is /etc/freeradius/radiusd.conf; it does not require changes from the shipped default.

The following lines are important for eduroam operation: a server status probing mechanism called Status-Server is enabled in the security section. Make sure the config file contains the following security stanza

security {
           max_attributes = 200
           reject_delay = 1
           status_server = yes
} 
proxy_requests      = yes


2. clients.conf 
 FreeRADIUS defines the connected RADIUS clients in the file /etc/freeradius/clients.conf. This file needs to hold all your connected Access Points and/or wired eduroam-enabled switches. You set a shared secret for each client and define these in the config file.

modify => ip, secretkey, realm

3. proxy.conf
 FreeRADIUS contains a wealth of options to define how requests are forwarded. These options are defined in the file /etc/freeradius/proxy.conf. For a single eduroam SP, these may seem overkill, but the required definitions for that purpose are rather static. Assuming you have two upstream servers to forward requests to, the following configuration will set these up - you only need to change the IP addresses and shared secrets in home_server stanzas.

You would need to delete the DEFAULT realm and replace it with the following regular expression realm statement *at the end of your proxy.conf

realm "~.+$" {
...

}

modify => ip, secret, realm strip.....

4. users
This lab is with out backend database
FreeRADIUS+AD manual  : https://docs.google.com/document/d/14LnsBznOw0w2fR7xgBJhzyWp1OztlKO6D5fws0XpjBI/edit

5. F-Ticks
F-Ticks is using syslog to deliver user login statistics. You can enable syslog logging for login events by defining a linelog module. In the /etc/freeradius/mods-available/ subdirectory, create a new file "f_ticks":


6. filtering rule
/etc/freeradius/sites-available/default 
 => include  authorize section 
"/etc/freeradius/eduroam-realm-checks"

7. eap
 Self Singing CA
/etc/freeradius/mods-available/eap

8. Operator Name
Operator Name IS SP Role
- client.conf  ap client define, OR
- Virtual Vertual Server default section 
authorize {
                if ("%{client:shortname}" != "clients.conf shortname e.g flr") {
                   update request {
                           Operator-Name := "1yourdomain.tld"
                            # the literal number "1" above is an important prefix! Do not change it!
                   }
                }
                auth_log
                suffix
                eap
        }

 
9. CUI (idp role)
Mandating or forbidding use of anonymous outer identity

eduroam at large supports anonymous outer identities for user logins. It is at the discretion of eduroam IdPs whether they want to
?mandate that their users use an anonymous outer identity
?forbid their users to  use an anonymous outer identity
?be agnostic in that respect

Configuring any one of the three choices is done with only a few lines of configuration. The easiest choice is being agnostic: no configuration is necessary, since there is no link between the inner and outer User-Name attribute in FreeRADIUS.

If you want to mandate the use of anonymous outer identities, the recommended way is using the identity "@realm" (i.e. the part left of the @ sign should be empty). You can enforce that only this outer User-Name is allowed to proceed to EAP authentication by adding the following to the authenticate section:


if ( User-Name != "@realm" ) {
      fail
}

If you want to forbid usage of anonymous outer identities, you can do this by comparing the two presented User-Name attributes of the outer and inner authentication. You can only do this in the eduroam-inner-tunnel virtual server obviously, since only that server has access to the inner identity. Put the following into the "authenticate" section of eduroam-inner-tunnel:

if ( User-Name != outer.User-Name ) {
     fail
}

 