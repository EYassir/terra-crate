# CrateDB

CrateDB is a distributed SQL database management system that integrates a fully searchable document-oriented data store. It is open-source, written in Java, based on a shared-nothing architecture, and designed for high scalability. CrateDB includes components from Presto, Lucene, Elasticsearch and Netty.

---

title: crateDB
link: https://crate.io

---

## Description

This is a terraform project that setup a full autoscaled cratedb on AWS

- **How does it work?**
  By using ec2 API

---

title: EC2 API
link: https://docs.aws.amazon.com/AWSEC2/latest/APIReference/Welcome.html

---

- **What is the goal of this project?**

Setup up a full test and production ready CrateDB cluster on aws with terraform

## Requirements

- **AWS account**
- **S3 bucket & dynamodb table** ( will be used as remote backend )
- **A template of the crate.yml file**

## Build

    $ terraform init
    $ terraform apply

##
