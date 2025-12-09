FROM jenkins/inbound-agent:3355.v388858a_47b_33

USER root
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*
USER jenkins
