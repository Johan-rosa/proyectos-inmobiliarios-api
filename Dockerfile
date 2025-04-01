# Use a multi-architecture R base image
FROM --platform=linux/amd64 rocker/verse:4.2.0

# Set working directory
WORKDIR /app

# Install system dependencies including Chrome for Linux
RUN apt-get update && apt-get install -y \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    libatspi2.0-0 \
    libgtk-3-0 \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome directly from Google's servers
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update \
    && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm ./google-chrome-stable_current_amd64.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R packages from CRAN
RUN R -e "install.packages(c('aws.s3', 'glue', 'knitr', 'tidyr', 'dplyr', 'scales', 'config', 'pagedown', 'jsonlite', 'rmarkdown', 'kableExtra', 'plumber', 'box'), repos='https://cloud.r-project.org/')"

# Install fireData from GitHub (separate step for easier debugging)
RUN R -e "install.packages('remotes', repos='https://cloud.r-project.org/')"
RUN R -e "remotes::install_github('Kohze/fireData')"

# Copy the application files
COPY payment-plan/ /app/

# Expose the port that Plumber will run on
EXPOSE 8000

# Start the Plumber API
CMD ["R", "-e", "library(plumber); pr <- plumb('plumber.R'); pr$run(host='0.0.0.0', port=8000, swagger=TRUE)"]