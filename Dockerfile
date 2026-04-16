# https://hub.docker.com/layers/library/python/3.12-slim/images
# Currently uses Debian 12, so use those parameters below for wget
FROM python:3.12-slim

# Install nbconvert dependencies and prereqs for PowerShell (wget)
# https://nbconvert.readthedocs.io/en/latest/install.html
RUN apt-get update && \
    apt-get install -y \
        pandoc \
        texlive \
        texlive-xetex \
        texlive-fonts-recommended \
        texlive-plain-generic \
        texlive-latex-extra \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install PowerShell directly from GitHub - Microsoft's install method is unstable
ARG POWERSHELL_VERSION=7.6.0
RUN wget -q https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell_${POWERSHELL_VERSION}-1.deb_amd64.deb && \
    apt-get update && \
    apt-get install -y ./powershell_${POWERSHELL_VERSION}-1.deb_amd64.deb && \
    rm powershell_${POWERSHELL_VERSION}-1.deb_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

# Install Jupyter and nbconvert
RUN pip install --no-cache-dir jupyter nbconvert

COPY entrypoint.ps1 /entrypoint.ps1
ENTRYPOINT ["pwsh", "-File", "/entrypoint.ps1"]
