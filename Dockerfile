FROM condaforge/miniforge3

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

# install TigerVNC server and fluxbox for GUI
RUN apt-get update && apt-get install -y \
    tigervnc-standalone-server \
    fluxbox \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# install noVNC from github since version in package manager is outdated or requires snap
RUN wget https://github.com/novnc/noVNC/archive/refs/tags/v1.5.0.zip && \
    unzip v1.5.0.zip -d /usr/share/novnc && \
    rm v1.5.0.zip && \
    apt-get purge -y unzip && apt-get autoremove -y

 # install Orange
RUN conda create python=3.10 --yes --name orange3 && \
    conda init bash && \
    bash -c "source activate base && conda activate orange3" && \
    conda install orange3 --yes && conda clean -afy
    
ENV PATH=/opt/conda/envs/orange3/bin:$PATH

ENV DISPLAY=:0
EXPOSE 6080

COPY init.sh init.sh
RUN chmod +x init.sh

RUN --mount=type=secret,id=noVNC_password \
    mkdir -p ~/.vnc && \
    cat /run/secrets/noVNC_password | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# run the application
ENTRYPOINT ["./init.sh"]
