# Test answers

### I create this repo with the purpouse of sharing my answers
### I just put the first words of each question
*********
>Write down Dockerfile

You can find the Dockerfile instructions in the [Dockerfile](https://github.com/h3mx/undostres/blob/master/Dockerfile) in the root repo,
it's possible to clone the repo and build the image and running in your local
machine.

Note: I'm not claiming be the owner of the code of the Go app but it helps me
to understand and build the Dockerfile in conjunction with the PHP and Nginx app.

##### Instructions after cloning the repo and assuming you are inside the repo directory
`docker build -t undostres/test:1.0 `
`docker run --rm --name undostres -p 8083:8083 -p 8082:8082 undostres/test:1.0`

********
>Name the metrics to analyze

In a microservices architecture we need to monitor not only the containers and the applications they run but also the instances that hosts the containers (masters, workers) and possibly the container registry if any, at the end of the day containers use resources from the system host. So the metrics to monitor and analyze are the consumption of CPU, Memory and Disk and network usage and number of processes.
In AWS we can install the Cloudwatch agent on EC2 instances to monitor all this metrics and create an alarm for a specific parameter.
At VPC, subnet level we can use VPC flowlogs to analyze the direction of the packets and maybe detect if some services are not receiving traffic.
Other solutions could be Grafana or Nagios but it requires to setup a complete infrastructure and without guaranties of availability or elasticity so Cloudwatch is the preferred method to analyze metrics.

To create a more lightweight docker image we can use multi stages at the time we define our Dockerfile, for example in the case of the golang app we can compile our binary using golang:alpine as the base image and even if that image is lightweight maybe we don’t need all the configurations and software of that image so we can import the binary in another docker image using docker –from in the same Dockerfile

*********
>Propose an architecture

At the front we can use Global Accelerator with Route53 to use edge locations as a point of entrance to requests from users to our infrastructure in AWS, using global accelerator we can reduce the latency because we are using the global network of AWS, then we can associate it with and ELB that will route requests between an autoscaling group of EC2 instances that will receive the requests pass them to an SQS que and have another ELB that will route requests to a pool of EC2 instances that process the requests. 
Using SQS we guarantee that messages don’t lose or if some transaction node fails while processing, the message will be available to be taken by another node and terminates the processing and put the information to a database like Aurora(RDS) or DynamoDB (NoSQL), both of them are provides fault tolerant and strong consistency.

- Using ASG we solve the problem if one node fails and we provide availability to process more requests. I think that using ASG we can manage the problem of CAP at processing level, providing consitency and partition.

- We can create custom metrics using Cloudwatch to establish some auto scaling policies based on the consumption of CPU or RAM, we can choose between a target scaling policy or step scaling policy both are beneficial but I would prefer target scaling policy because it tries to maintain a certain amount of instances based on the metric of a resource. 

- To perform backups of logs we can upload them to S3 buckets and store them as a S3Glacier type, it will depend if we perform some kind of analysis regularly or we just store them for future access. In the case of backup of a database always is preferable to perform them at night or in hours where the number of transactions is low. Another point to take into account is to make them over RDS replicas in that way we don’t put more stress to the master database. 

For an RDS database we can use Aurora using this we forget about creating Read Replicas for Single AZ or MultiAZ RDS databases, the nature of Aurora is to have replicas of the primary DB in case of a failure it promotes a replica as the new primary database.
For a NoSql service we can use DynamoDB, in this case will depend of the nature of our application and if its designed to work with. As a serverless service we forget about the maintenance and scalability.

- Maybe we can reduce costs implementing the services provided by AWS using for example Nginx as a LoadBalacer,
instead of using a RDS, Aurora or DynamoDB we have the option to install our own databases but it increments the
difficulty to manage and backup, instead of using Cloudwatch we can implement our own monitoring system maybe 
using Grafana, ELK or something similar.
The benefit is that you are in full control of your infrastructure, possibly you can reduce costs, if you want
to migrate to another Cloud provider is easier but all of this at the cost of investing a huge amount of time.
