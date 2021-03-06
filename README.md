# s2i-cloud-image

s2i-cloud-image is an OpenShift S2I build container for building Linux
VM images suitable for deployment in cloud environments like Azure,
AWS, and GCE.

# What?

OpenShift's S2I and BuildConfig features are more commonly used to
automate the creation of container images from source code.  Benefits
include full build automation in a way that is fully reproducibile and
auditable.

s2i-cloud-image takes advantage of these same technologies, but
produces no container image.  We leverage a build container
(s2i-cloud-image), fully loaded with all of the tools required to
build and deploy VM images to create VHD, AMIs, or whatever else is
required by the provider.  The definition of VM image is maintained
like source code in a git repo, and OpenShift is configured to build
and record VM images triggered by git webhooks.

s2i-cloud-image is flexible.  It provides a basic framework and examples of
 * how to build and harden images,
 * how to leverage Vault to manage in-image secrets and service credentials,
 * how to audit resulting images with OpenSCAP,
 * and how to record all relevant metadata about the images, including digital signatures, audit results, and more in a git repo forever tied to the resulting VM image file.

# Why?

Because... [finish this].


## Getting started  

### Files and Directories  
| File                   | Required? | Description                                                  |
|------------------------|-----------|--------------------------------------------------------------|
| Dockerfile             | Yes       | Defines the base builder image                               |
| s2i/bin/assemble       | Yes       | Script that builds the application                           |
| s2i/bin/usage          | No        | Script that prints the usage of the builder                  |
| s2i/bin/run            | Yes       | Script that runs the application                             |
| s2i/bin/save-artifacts | No        | Script for incremental builds that saves the built artifacts |
| test/run               | No        | Test script for the builder image                            |
| test/test-app          | Yes       | Test application source code                                 |

#### Dockerfile
Create a *Dockerfile* that installs all of the necessary tools and libraries that are needed to build and run our application.  This file will also handle copying the s2i scripts into the created image.

#### S2I scripts

##### assemble
Create an *assemble* script that will build our application, e.g.:
- build python modules
- bundle install ruby gems
- setup application specific configuration

The script can also specify a way to restore any saved artifacts from the previous image.   

##### run
Create a *run* script that will start the application. 

##### save-artifacts (optional)
Create a *save-artifacts* script which allows a new build to reuse content from a previous version of the application image.

##### usage (optional) 
Create a *usage* script that will print out instructions on how to use the image.

##### Make the scripts executable 
Make sure that all of the scripts are executable by running *chmod +x s2i/bin/**

#### Create the builder image
The following command will create a builder image named rhel7 based on the Dockerfile that was created previously.
```
docker build -t rhel7 .
```
The builder image can also be created by using the *make* command since a *Makefile* is included.

Once the image has finished building, the command *s2i usage rhel7* will print out the help info that was defined in the *usage* script.

#### Testing the builder image
The builder image can be tested using the following commands:
```
docker build -t rhel7-candidate .
IMAGE_NAME=rhel7-candidate test/run
```
The builder image can also be tested by using the *make test* command since a *Makefile* is included.

#### Creating the application image
The application image combines the builder image with your applications source code, which is served using whatever application is installed via the *Dockerfile*, compiled using the *assemble* script, and run using the *run* script.
The following command will create the application image:
```
s2i build test/test-app rhel7 rhel7-app
---> Building and installing application from source...
```
Using the logic defined in the *assemble* script, s2i will now create an application image using the builder image as a base and including the source code from the test/test-app directory. 

#### Running the application image
Running the application image is as simple as invoking the docker run command:
```
docker run -d -p 8080:8080 rhel7-app
```
The application, which consists of a simple static web page, should now be accessible at  [http://localhost:8080](http://localhost:8080).

#### Using the saved artifacts script
Rebuilding the application using the saved artifacts can be accomplished using the following command:
```
s2i build --incremental=true test/test-app nginx-centos7 nginx-app
---> Restoring build artifacts...
---> Building and installing application from source...
```
This will run the *save-artifacts* script which includes the custom code to backup the currently running application source, rebuild the application image, and then re-deploy the previously saved source using the *assemble* script.
