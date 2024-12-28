# maven-nexus-sonarQube-demo
Integrating mvn with nexus and sonarQube


# Setup Prerequisite 

For this demo, create 3 ubuntu servers of size t3.medium,  with below specifications
- ensure instances are public 
- attach a keypair for ssh connections



a) Create Maven server

- tag instance : maven_demo

- open port SSH : 22 

NB: maven will run as background service so no service ingress ports on SG required. 
    
Install JAVA (a prerequisite for Jenkins)

     sudo apt update && sudo apt install openjdk-17-jre -y

Verify Java Installation: 

    java -version 

Install Maven: 

    sudo apt install -y maven

    mvn -h 



b) Create [Nexus-Server](https://help.sonatype.com/en/sonatype-nexus-repository.html): 

- create an EC2 server for nexus with above specifications 

- tag instance: nexus

- use the ***install_nexus.sh*** script as userdata to install nexus

-  nexus is available on port default port 8081, open this port on SG attached to server

 - Access nexus on **http://`<server-pub-ip>`:`8081`** 

    
    
### configure nexus

- create credential: On the Nexus UI, click on ***SignIn*** and follow instructions to obtain the initial creds for the admin user

- Follow instructions on the ***Setup Wizard***
- optional Create custome repos



c) Create EC2 and [Install-SonarQube](https://www.sonarsource.com/products/sonarqube/downloads/)

- create an EC2 server for nexus with above specifications 

- tag instance: sonarQube

- use the script ***sonarQube.sh*** to install sonarqube as userdata. 

- Sonarqube is avaiable on default port 9000. Allow this port on SG attaached to server.

- Access sonarqube on **http://`<server-pub-ip>`:`9000`** 


### configure sonarQube

- By default, sonarQube has default credentials `admin : admin` for ***usernmame : password***

# configure a project and generate a token. 

- select ***Projects***  on the Sonar UI and create a project. Ensure the branch manin corresponds to the name of branch.

- Click on ***locally** to generate project token. 

- click on `continue` , select the build type `maven` and generate token for local testing on the maven server. 





# Demo

1) fork repo  `https://github.com/mecbob/maven-nexus-sonarQube-demo/tree/main`  and 

update the following detains in the ***`settings.xml`*** and ***`pom.xml`*** files.  (use gitHub UI for the updates)

- nexus credentials

- server IPs for nexus and sonarServer

2) (OPTIONAL) 
This is just to show how java project templates are generated). Create a simple Java project using the command below. 
If done, you will have to update the pom.xml file. 


    mvn archetype:generate -DgroupId=com.example.demo -DartifactId=demoApp -DarchetypeArtifactId=maven-archetype-quickstart -DarchetypeVersion=1.5 -DinteractiveMode=false


3) Clone your repository on the maven server, where mvn can build the javabased project. 

4) Update place holders with server IPs in pom.xml and settings.xml

Move the settings.xml file to ~/.m2 directory

     mv settings.xml ~/.m2 

5) cd into the Java project directory **demoApp** (folder with pom.xml and src directory)

6) build and push the maven artifact to nexus using the deploy [build lifecycle](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html) command.

    mvn clean deploy 


7) Push to SonarQube using the command gotten from the sonar configuration step above. `Example` command below 

    mvn clean verify sonar:sonar \
    -Dsonar.projectKey=newproject \
    -Dsonar.host.url=http://3.84.240.100:9000 \
    -Dsonar.login=sqp_d25f55645a981ef20e2885cbe25344f6dd7e43d3





