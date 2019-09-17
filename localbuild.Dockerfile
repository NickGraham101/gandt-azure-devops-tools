FROM mcr.microsoft.com/powershell:ubuntu-16.04 AS agent
SHELL ["pwsh", "-Command"]
RUN Install-Module Pester -Force
WORKDIR /module
COPY . .
CMD Tests/Invoke-Tests.ps1