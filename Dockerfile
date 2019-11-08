FROM ubuntu:xenial
ENV DEBIAN_FRONTEND noninteractive

USER root

RUN apt-get update && apt-get install -y python3-pip python3-dev python-virtualenv \
    bzip2 g++ git sudo vim wget net-tools locales bzip2 \
    xfce4-terminal software-properties-common python-numpy \
    supervisor xrdp htop ssh

### Install custom fonts
RUN apt-get install -y ttf-wqy-zenhei

# browsers
RUN rm /usr/share/xfce4/helpers/debian-sensible-browser.desktop && \
    add-apt-repository --yes ppa:jonathonf/firefox-esr && apt-get update && \
    apt-get remove -y --purge firefox && apt-get install -y firefox-esr

RUN apt-get install -y chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg && \
    ln -s /usr/bin/chromium-browser /usr/bin/google-chrome

RUN apt-get install -y xfce4 xfce4-terminal xterm gettext
RUN apt-get purge -y pm-utils xscreensaver*

ADD xrdp.conf /etc/supervisor/conf.d/xrdp.conf

# Allow all users to connect via RDP.
RUN sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini

RUN xrdp-keygen xrdp auto
RUN apt-get install -y gedit libreoffice nautilus mirage

ENV USER orange
ENV PASSWORD orange
ENV HOME /home/${USER}
ENV CONDA_DIR /home/${USER}/.conda

RUN useradd -m -s /bin/bash ${USER}
RUN echo "${USER}:${PASSWORD}" | chpasswd
RUN gpasswd -a ${USER} sudo

USER $USER
WORKDIR ${HOME}

RUN wget -q -O anaconda.sh https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh
RUN bash anaconda.sh -b -p ~/.conda && rm anaconda.sh
RUN $CONDA_DIR/bin/conda create python=3.6 --name orange3
RUN $CONDA_DIR/bin/conda config --add channels conda-forge
RUN bash -c "source $CONDA_DIR/bin/activate orange3 && $CONDA_DIR/bin/conda install orange3"
RUN echo 'export PATH=~/.conda/bin:$PATH' >> /home/orange/.bashrc
RUN bash -c "source $CONDA_DIR/bin/activate orange3 && pip install Orange3-Text Orange3-ImageAnalytics Orange3-Network Orange-Bioinformatics"


ADD ./icons/orange.png /usr/share/backgrounds/images/orange.png
ADD ./icons/orange.png .conda/share/orange3/orange.png
ADD ./orange/orange-canvas.desktop Desktop/orange-canvas.desktop
ADD ./config/xfce4 .config/xfce4

ADD ./src/common/xfce/ $HOME/
ADD ./install/chromium-wrapper install/chromium-wrapper
ADD ./config/xfce4 .config/xfce4
ADD ./config/thunar.rc $HOME/.gtkrc-thunar-root

USER root
RUN mkdir ${HOME}/share
RUN chown -R $USER:$USER /home/orange/.config /home/orange/Desktop /home/orange/install /home/$USER/share
ADD startwm.sh /etc/xrdp/startwm.sh
ADD ./src/sudoers /etc/sudoers 

CMD ["/usr/bin/supervisord", "-n"]
