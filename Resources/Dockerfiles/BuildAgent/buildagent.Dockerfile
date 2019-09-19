FROM mcr.microsoft.com/powershell:ubuntu-16.04 AS agent
SHELL ["pwsh", "-Command"]
RUN Install-Module Pester -Force
SHELL ["/bin/sh", "-c"]
# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update 
RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    git \
    iputils-ping \
    libcurl3 \
    libicu55 \
    libunwind8 \
    netcat

WORKDIR /azp

COPY Scripts/install-agent.sh .
RUN chmod +x install-agent.sh

CMD ["./install-agent.sh"]
