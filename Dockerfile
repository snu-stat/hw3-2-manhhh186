# 1. Base image
FROM rocker/tidyverse:4.4.0

# 2. System dependencies
USER root
RUN apt-get update && apt-get install -y \
    wget \
    git \
    imagemagick \
    libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. Install Miniconda
ENV CONDA_DIR=/opt/conda

RUN wget --quiet \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p ${CONDA_DIR} && \
    rm ~/miniconda.sh

# 4. Create Python environment
ENV PATH=${CONDA_DIR}/bin:${PATH}

RUN conda create -n r-reticulate python=3.10 -y && \
    conda install -n r-reticulate -c conda-forge \
        numpy \
        pandas \
        scipy \
        matplotlib \
        statsmodels \
        polars \
        pip \
        -y && \
    conda run -n r-reticulate pip install pylahman

# 5. Install required R packages
RUN R -e "install.packages(c( \
    'reticulate', \
    'IRkernel', \
    'NHANES', \
    'mosaic', \
    'Lahman' \
), repos='https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(user = FALSE)"

# 6. Fix Python path for reticulate
ENV RETICULATE_PYTHON=/opt/conda/envs/r-reticulate/bin/python

# 7. Create Binder user
ENV NB_USER=jovyan
ENV NB_UID=1000

RUN usermod -l ${NB_USER} rstudio && \
    usermod -d /home/${NB_USER} -m ${NB_USER} && \
    chown -R ${NB_USER} /opt/conda /home/${NB_USER}

# 8. Copy notebook
COPY _site/hw03.ipynb /home/${NB_USER}/hw03.ipynb

RUN chown ${NB_USER}:users /home/${NB_USER}/hw03.ipynb

USER ${NB_USER}
WORKDIR /home/${NB_USER}

# Binder port
EXPOSE 8888