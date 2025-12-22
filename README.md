# 🧱 Jenkins Docker Agent (Learning Project)

This repository provides a **pre-baked Jenkins agent Docker image** used in a **local Jenkins setup** for learning and experimentation.

The agent is based on `jenkins/inbound-agent` and extended to support **Docker-in-Docker (via Docker socket)** so Jenkins jobs can run inside containers while still being able to build and run Docker images.

---

## 🎯 Purpose

- Support **containerized Jenkins agents**
- Allow Jenkins pipelines to run:
  - `docker build`
  - `docker run`
  - `docker buildx`
- Mirror real-world CI patterns while staying suitable for **local development**

This setup is intentionally **not production-grade** and is meant for **education and experimentation**.

---

## 🏗 Architecture Overview

- Jenkins **controller** runs locally in Docker
- Jenkins **agents** run as Docker containers
- Jobs run **inside ephemeral containers**
- Docker socket is mounted into the agent container

```
Jenkins Controller (Docker)
        |
        | WebSocket / JNLP
        v
Jenkins Agent (this image)
        |
        | /var/run/docker.sock
        v
Host Docker Daemon
```

---

## 🌐 Docker Network Requirement

Because everything runs locally, Jenkins controller and agents must share the same Docker network.

Create it once:

```bash
docker network create jenkins
```

Run both controller and agents with:

```bash
--network jenkins
```

---

## 🐳 Docker Socket Access

The agent mounts the Docker socket to allow Docker commands inside CI jobs:

```bash
-v /var/run/docker.sock:/var/run/docker.sock
```

This enables:
- `docker build`
- `docker run`
- `docker buildx`

⚠️ Mounting the Docker socket grants **host-level privileges**.  
This is acceptable here **only because this is a learning project**.

---

## 🍎 macOS vs 🐧 Linux Differences

### macOS (Docker Desktop)

On macOS:
- Docker runs inside a VM
- `/var/run/docker.sock` is owned by `root`
- Group permissions do not behave like native Linux

➡️ The agent must run as `root`:

```bash
--user root
```

This is **required** for Docker access on macOS hosts.

---

### Linux Hosts

On Linux:
- Docker runs natively
- The socket has a real group owner (usually `docker`)

You can avoid running as root:

```bash
--group-add $(stat -c "%g" /var/run/docker.sock)
```

This is the **preferred approach** outside of local learning setups.

---

## 📦 How This Image Is Used

This agent image is referenced by Jenkins pipelines to:
- Run jobs in containers
- Spin up ephemeral test environments
- Build and push Docker images
- Use BuildKit and registry-based caching

👉 The CI pipelines that use this image live here:  
https://github.com/gal-halevi/learning-jenkins

---

## 📦 Running the Agent (Linux)

```bash
docker run -d  \
--name jenkins-node-1 \
--network jenkins \
--group-add $(stat -c "%g" /var/run/docker.sock) \
-v /var/run/docker.sock:/var/run/docker.sock \
-v jenkins-node-1-home:/home/jenkins \
galhalevi/jenkins-agent-docker:0.1.0 \
-url http://jenkins:8080 \
-workDir=/home/jenkins/agent \
-webSocket \
<secret> \
<node-name>
```
---

## 🍏 Running on macOS

macOS requires running the agent **as root** to access Docker:

```bash
docker run -d  \
--name jenkins-node-1 \
--network jenkins \
--user root \
-v /var/run/docker.sock:/var/run/docker.sock \
-v jenkins-node-1-home:/home/jenkins \
galhalevi/jenkins-agent-docker:0.1.0 \
-url http://jenkins:8080 \
-workDir=/home/jenkins/agent \
-webSocket \
<secret> \
<node-name>
```
