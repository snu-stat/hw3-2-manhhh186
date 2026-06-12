FROM rocker/tidyverse:4.4.0

USER root

RUN apt-get update && apt-get install -y \
    wget \
    git \
    imagemagick \
    libmagick++-dev \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Python environment
RUN python3 -m venv /opt/r-reticulate && \
    /opt/r-reticulate/bin/pip install --upgrade pip && \
    /opt/r-reticulate/bin/pip install \
        numpy \
        pandas \
        scipy \
        matplotlib \
        statsmodels \
        polars \
        pylahman \
        jupyter \
        notebook

# R packages
RUN R -e "install.packages(c( \
    'reticulate', \
    'NHANES', \
    'mosaic', \
    'Lahman', \
    'knitr', \
    'rmarkdown' \
), repos='https://cloud.r-project.org')"

# reticulate Python path
ENV RETICULATE_PYTHON=/opt/r-reticulate/bin/python

# Binder user
ENV NB_USER=jovyan
ENV NB_UID=1000

RUN usermod -l ${NB_USER} rstudio && \
    usermod -d /home/${NB_USER} -m ${NB_USER} && \
    chown -R ${NB_USER} /opt/r-reticulate /home/${NB_USER}

# Notebook
COPY hw03.ipynb /home/${NB_USER}/hw03.ipynb

RUN chown ${NB_USER}:users /home/${NB_USER}/hw03.ipynb

USER ${NB_USER}
WORKDIR /home/${NB_USER}

EXPOSE 8888

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--NotebookApp.token=''"]