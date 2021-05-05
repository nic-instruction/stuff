## App Automation

The goal of this excercise is to take a hopelessly flawed app and build maximum security into the architecture and way it is deployed.  Eventually it would need to be rebuilt and retooled, which is fine, but we're studying how to protect it and deploy it in various manners, including multiple back-ends, load ballancing, clustering, etc.
It is a 'native cloud' app in the sense that all data is seperated from the application.  It is currently stored in a MySQL instance, but we will explore MongoDB, Cloud SQL, Redis, and others.

## Files

* front_end_template.sh automates two instance groups of the app across two zones (within a single region).  Each instance group has a template from which the machines are generated and starts by requiring 2 f1-micros per group.  Both are managed by a backend-service and a passthrough load ballancer, meaning that traffic is routed to each machine with unchanged packets and the machine opens its own connections to the client, bypassing the load balancer.  Firwall rules for traffic are managed by the tags of the instance groups and machines.  A routing rule is in place to route traffic from the load ballancer to the backend services.  They are logically on the same vpc as the MySQL server.  The next step will be to make this setup more secure with a seperate VPC networks to isolate instances and front-end from back-end, and making the back-end highly available.
