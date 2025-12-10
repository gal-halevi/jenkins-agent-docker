# 🐳 Jenkins Docker-Enabled Agent  
*A custom Jenkins inbound agent image with Docker CLI installed.*

---

## 📌 Overview

This repository contains a custom Jenkins **inbound agent** Docker image based on the official:

```
jenkins/inbound-agent
```

It adds the **Docker CLI**, allowing Jenkins Pipeline builds to run Docker commands — including:

- `agent { docker { ... } }` (ephemeral build containers)
- `docker build`, `docker run`, `docker push`, etc.

---

## 🏗️ Building the Image Locally

```bash
docker build -t <your-namespace>/jenkins-agent-docker:<tag>> .
docker tag <your-namespace>/jenkins-agent-docker:<tag>> <your-namespace>/jenkins-agent-docker:latest
```

---

## 📦 Running the Agent (Linux)

```bash
docker run -d  \
--name jenkins-node-1 \
--network jenkins \
--group-add $(stat -c "%g" /var/run/docker.sock) \
-v /var/run/docker.sock:/var/run/docker.sock \
-v jenkins-node-1-home:/home/jenkins \
<your-namespace>/jenkins-agent-docker:0.1.0 \
-url http://jenkins:8080 \
-workDir=/home/jenkins/agent \
-webSocket \
<secret> \
<node-name>
```
---

## 🍏 Running on macOS (Docker Desktop)

macOS requires running the agent **as root** to access Docker:

```bash
docker run -d  \
--name jenkins-node-1 \
--network jenkins \
--user root \
-v /var/run/docker.sock:/var/run/docker.sock \
-v jenkins-node-1-home:/home/jenkins \
<your-namespace>/jenkins-agent-docker:0.1.0 \
-url http://jenkins:8080 \
-workDir=/home/jenkins/agent \
-webSocket \
<secret> \
<node-name>
```

---
