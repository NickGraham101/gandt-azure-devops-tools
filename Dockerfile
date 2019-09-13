FROM mcr.microsoft.com/powershell:ubuntu-18.04 AS agent
SHELL ["pwsh", "-Command"]
RUN Install-Module Pester -Force
WORKDIR /module
COPY . .
CMD Tests/Invoke-Tests.ps1