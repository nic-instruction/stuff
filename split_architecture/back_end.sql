CREATE DATABASE back_end;

USE back_end;

CREATE TABLE info (
    name varchar(255), 
    witticism varchar(1000), 
    sarcastic_gloat varchar(1000)
);

GRANT USAGE ON *.* TO 'MyApp'@'%' IDENTIFIED BY PASSWORD '*236023AE71553ECD5E234575E2EEC41C32263119';

GRANT SELECT, INSERT, UPDATE, DELETE ON `back\_end`.* TO 'MyApp'@'%';

# Enable remote connections
# open /etc/my.cnf
# put in 
# bind-address = 0.0.0.0
# right below # instructions in http://fedoraproject.org/wiki/Systemd
# You can automate this via sed with line number insertion
