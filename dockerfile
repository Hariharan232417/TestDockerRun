# Use the official Maven image with JDK 11
FROM maven:3.8.1-jdk-11

# Set the working directory
WORKDIR /seleniumrun

COPY pom.xml .
COPY testng.xml .
COPY reports/ ./reports/
COPY data/ ./data/
COPY src/ ./src/

# Debug: List the contents of the cloned repository
RUN ls -la /seleniumrun

# Debug: List the contents of the project directory
RUN ls -la .

# Install dependencies required for headless Chrome
RUN apt-get update && apt-get install -y xvfb wget unzip curl \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Install XVFB
RUN apt install -y xvfb

# Start XVFB on display :99
RUN Xvfb :99 -screen 0 1920x1080x24 &

# Export the display
ENV DISPLAY=:99

# Create a unique Chrome user profile directory
RUN mkdir -p /tmp/chrome-user-data && chmod -R 777 /tmp/chrome-user-data

# Set environment variable for Chrome user data directory
ENV CHROME_USER_DATA_DIR="/tmp/chrome-user-data"

# Download and install Chrome manually
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i google-chrome-stable_current_amd64.deb || apt --fix-broken install -y \
    && rm google-chrome-stable_current_amd64.deb

# Install AWS CLI to push reports to S3
RUN apt-get update && apt-get install -y awscli && rm -rf /var/lib/apt/lists/*

# Run tests using Maven
CMD mvn clean test
