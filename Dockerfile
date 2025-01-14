FROM continuumio/miniconda3

WORKDIR /app

# install dependencies and missing packages (libxcb-icccm4, libxcb-image0, libxcb-keysyms1, libxcb-render-util0) for Orange3
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    novnc \
    xauth \
    xorg \
    fluxbox \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# install Orange
RUN conda create python=3.10 --yes --name orange3
RUN conda init bash
RUN bash -c "source activate base && conda activate orange3"
ENV PATH=/opt/conda/envs/orange3/bin:$PATH
RUN conda install orange3 --yes

ENV DISPLAY=:0
EXPOSE 6080

COPY init.sh init.sh
RUN chmod +x init.sh

RUN --mount=type=secret,id=noVNC_password \
    NOVNC_PASSWORD=$(cat /run/secrets/noVNC_password) && \
    echo ${NOVNC_PASSWORD} >> /secret.txt

# run the application
ENTRYPOINT ["./init.sh"]
