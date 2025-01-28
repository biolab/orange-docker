FROM continuumio/miniconda3

WORKDIR /app

# install graphical interface and vnc server
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    novnc \
    fluxbox \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# install Orange
RUN conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    conda create python=3.10 --yes --name orange3 && \
    conda init bash && \
    bash -c "source activate base && conda activate orange3" && \
    conda install orange3 --yes && conda clean --all --yes
    
ENV PATH=/opt/conda/envs/orange3/bin:$PATH

ENV DISPLAY=:0
EXPOSE 6080

COPY init.sh init.sh
RUN chmod +x init.sh

RUN --mount=type=secret,id=noVNC_password \
    NOVNC_PASSWORD=$(cat /run/secrets/noVNC_password) && \
    mkdir -p ~/.vnc && \
    x11vnc -storepasswd ${NOVNC_PASSWORD} ~/.vnc/passwd

# run the application
ENTRYPOINT ["./init.sh"]
