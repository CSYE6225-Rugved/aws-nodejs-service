# webapp
## Prerequsites
1. Node.js (v16 or higher)
2. MySQL (v8.0 or higher)

## Setup

### 1. Clone the Repository
```sh
git clone git@github.com:CSYE6225-Rugved/webapp.git
cd webapp
```
### 2. Install Dependencies
```sh
npm install
```
### 3. Set Up the .env File
Create a .env file in the directory and add the following
```sh
PORT=8080
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=yourpassword
DB_NAME=HealthCheck
DB_DIALECT=mysql
```
replace yourpassword with your MySQL root password. If no password, leave it empty.

### 4. Cretae Database
```sh
CREATE DATABASE HealthCheck;
```
### 5. Start server
```sh
node app.js
```
### Run Test Cases
```sh
NODE_ENV=test npm test
```
### To create and AMI from packer template
Install Packer and run below commands
```sh
packer init .
packer fmt .
packer validate .
packer build aws-ubuntu.pkr.hcl
```
