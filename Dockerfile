FROM ubuntu:xenial
ENV DEBIAN_FRONTEND noninteractive

USER root

RUN apt-get update && apt-get install -y python3-pip python3-dev python-virtualenv \
    bzip2 g++ git sudo vim wget net-tools locales bzip2 \
    xfce4-terminal software-properties-common python-numpy \
    supervisor xrdp htop ssh

# Browsers
RUN rm /usr/share/xfce4/helpers/debian-sensible-browser.desktop && \
    add-apt-repository --yes ppa:jonathonf/firefox-esr && apt-get update && \
    apt-get remove -y --purge firefox && apt-get install -y firefox-esr

RUN apt-get install -y chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg && \
    ln -s /usr/bin/chromium-browser /usr/bin/google-chrome

# Desktop environment
RUN apt-get install -y xfce4 xfce4-terminal xterm gettext
RUN apt-get purge -y pm-utils xscreensaver*

# Allow all users to connect via RDP.
RUN sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini && \
    sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini

# Some gui applications for users
RUN apt-get install -y gedit libreoffice nautilus mirage

# Create user
ENV USER orange
ENV PASSWORD orange
ENV HOME /home/${USER}
ENV CONDA_DIR /home/${USER}/.conda

RUN useradd -m -s /bin/bash ${USER}
RUN echo "${USER}:${PASSWORD}" | chpasswd
RUN gpasswd -a ${USER} sudo

USER $USER
WORKDIR ${HOME}

# Install orange
RUN wget -q -O anaconda.sh https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh
RUN bash anaconda.sh -b -p ~/.conda && rm anaconda.sh
RUN $CONDA_DIR/bin/conda create python=3.6 --name orange3
RUN $CONDA_DIR/bin/conda config --add channels conda-forge
RUN bash -c "source $CONDA_DIR/bin/activate orange3 && $CONDA_DIR/bin/conda install orange3"
RUN echo 'export PATH=~/.conda/bin:$PATH' >> /home/orange/.bashrc
RUN bash -c "source $CONDA_DIR/bin/activate orange3 && pip install Orange3-Text Orange3-ImageAnalytics Orange3-Network Orange-Bioinformatics"

# Icons and XFCE config
ADD ./icons/orange.png .conda/share/orange3/orange.png
ADD ./Desktop/orange-canvas.desktop Desktop/orange-canvas.desktop
ADD ./config/xfce4 .config/xfce4
ADD ./install/chromium-wrapper install/chromium-wrapper

USER root

# Autostart Xrdp
ADD ./etc/supervisor/conf.d/xrdp.conf /etc/supervisor/conf.d/xrdp.conf
RUN xrdp-keygen xrdp auto

# Fix permissions
RUN mkdir ${HOME}/share
RUN chown -R $USER:$USER /home/orange/.config /home/orange/Desktop /home/orange/install /home/$USER/share
ADD ./etc/xrdp/startwm.sh /etc/xrdp/startwm.sh
ADD ./etc/sudoers /etc/sudoers 

CMD ["/usr/bin/supervisord", "-n"]
