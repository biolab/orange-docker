FROM consol/ubuntu-xfce-vnc

USER root

# conda install requires bzip
RUN apt-get update && apt-get install -y python3-pip python3-dev python-virtualenv bzip2 g++ git sudo 
RUN apt-get install -y xfce4-terminal software-properties-common python-numpy

# browsers
RUN rm /usr/share/xfce4/helpers/debian-sensible-browser.desktop
RUN add-apt-repository --yes ppa:mozillateam/ppa && apt-get update
RUN apt-get remove -y --purge firefox && apt-get install -y firefox-esr

ENV USER orange
ENV PASSWORD orange
ENV HOME /home/${USER}
ENV CONDA_DIR /home/${USER}/.conda

RUN useradd -m -s /bin/bash ${USER}
RUN echo "${USER}:${PASSWORD}" | chpasswd
RUN gpasswd -a ${USER} sudo

USER orange
WORKDIR ${HOME}

RUN wget -q -O anaconda.sh https://repo.anaconda.com/archive/Anaconda3-2021.11-Linux-x86_64.sh
RUN bash anaconda.sh -b -p ~/.conda && rm anaconda.sh
RUN $CONDA_DIR/bin/conda create python=3.8 --name orange3
RUN bash -c "source $CONDA_DIR/bin/activate orange3 && $CONDA_DIR/bin/conda install pyqt=5.12.* orange3 Orange3-Text Orange3-ImageAnalytics -c conda-forge"
RUN echo 'export PATH=~/.conda/bin:$PATH' >> /home/orange/.bashrc
RUN bash -c "source $CONDA_DIR/bin/activate orange3"

ADD ./icons/orange.png /usr/share/backgrounds/images/orange.png
ADD ./icons/orange.png .conda/share/orange3/orange.png
ADD ./orange/orange-canvas.desktop Desktop/orange-canvas.desktop
ADD ./config/xfce4 .config/xfce4
ADD ./install/chromium-wrapper install/chromium-wrapper

USER root
RUN chown -R orange:orange .config Desktop install

ADD ./install/add-geometry.sh /dockerstartup/add-resolution.sh
RUN chmod a+x /dockerstartup/add-resolution.sh

USER orange

# Prepare for external settings volume
RUN mkdir .config/biolab.si

ENV VNC_COL_DEPTH 24
ENV VNC_RESOLUTION 1920x1080
ENV VNC_PW orange

RUN cp /headless/wm_startup.sh ${HOME}


ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--tail-log"]