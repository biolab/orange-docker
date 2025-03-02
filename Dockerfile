ARG MINIFORGE_VERSION=24.11.3-0

FROM condaforge/miniforge3:${MINIFORGE_VERSION}

ARG TIGERVNC_VERSION=1.10.1+dfsg-3ubuntu0.20.04.1
ARG FLUXBOX_VERSION=1.3.5-2build2
ARG UNZIP_VERSION=6.0-25ubuntu1.1
ARG NOVNC_VERSION=1.5.0
ARG ORANGE3_VERSION=3.38.1
ARG PYTHON_VERSION=3.10

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

# install TigerVNC server and fluxbox
RUN apt-get update && apt-get install -y \
    tigervnc-standalone-server=${TIGERVNC_VERSION} \
    fluxbox=${FLUXBOX_VERSION} \
    unzip=${UNZIP_VERSION} \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# install noVNC from github since version in package manager is outdated or requires snap
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.zip && \
    unzip v${NOVNC_VERSION}.zip -d /usr/share && \
    mv -T /usr/share/noVNC-${NOVNC_VERSION} /usr/share/novnc && \
    rm v${NOVNC_VERSION}.zip && \
    apt-get purge -y unzip && apt-get autoremove -y

ENV PATH=/usr/share/novnc/utils:$PATH

# install Orange
RUN conda create python=${PYTHON_VERSION} --yes --name orange3 && \
    conda init bash && \
    bash -c "source activate base && conda activate orange3" && \
    conda install orange3=${ORANGE3_VERSION} "catboost=*=*cpu*" --yes && conda clean -afy
    
ENV PATH=/opt/conda/envs/orange3/bin:$PATH

ENV DISPLAY=:0
EXPOSE 6080
ENV SHARED=0

# copy the data if it exists
COPY ./dat[a]/ /data/

# copy the init script
COPY --chmod=700 init.sh ./init.sh

# create the password file for VNC server
RUN --mount=type=secret,id=noVNC_password \
    mkdir -p ~/.vnc && \
    cat /run/secrets/noVNC_password | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# run the application
ENTRYPOINT ["./init.sh"]
