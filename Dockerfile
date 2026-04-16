# https://hub.docker.com/layers/library/python/3.12-slim/images
# Currently uses Debian 12, so use those parameters below for wget
FROM python:3.12-slim

# Install nbconvert dependencies and prereqs for PowerShell (wget)
# https://nbconvert.readthedocs.io/en/latest/install.html
RUN apt update && \
    apt install -y \
        pandoc \
        texlive \
        texlive-xetex \
        texlive-fonts-recommended \
        texlive-plain-generic \
        texlive-latex-extra \
        wget && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Install PowerShell
# https://learn.microsoft.com/en-us/powershell/scripting/install/install-debian
RUN wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt update && \
    apt install -y powershell && \
    rm -rf /var/lib/apt/lists/*

# Install Jupyter and nbconvert
RUN pip install --no-cache-dir jupyter nbconvert

COPY entrypoint.ps1 /entrypoint.ps1
ENTRYPOINT ["pwsh", "-File", "/entrypoint.ps1"]
