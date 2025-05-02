# maven:3.8.7-openjdk-18, published Feb 8, 2023 at 9:46 pm
FROM digipost.azurecr.io/docker/library/maven@sha256:f22971fa3103b6a5145741dd80cc1660490bef93deb6400276c96dadf5bfd75f

# Copy Bash script and Maven settings
COPY ./entrypoint.sh /entrypoint.sh
COPY ./settings.xml /settings.xml

# Make Bash script executable
RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]
