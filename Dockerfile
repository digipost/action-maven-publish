FROM maven:3.8.7-openjdk-18

# Copy Bash script and Maven settings
COPY ./entrypoint.sh /entrypoint.sh
COPY ./settings.xml /settings.xml

# Make Bash script executable
RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]
