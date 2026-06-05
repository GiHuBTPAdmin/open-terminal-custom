FROM ghcr.io/open-webui/open-terminal:latest

USER root

# /etc/skel/ bereinigen — wird beim Anlegen neuer User-Homes kopiert
RUN rm -f /etc/skel/.bashrc \
          /etc/skel/.profile \
          /etc/skel/.bash_logout \
          /etc/skel/.bash_profile \
          /etc/skel/.bash_history && \
    rm -rf /etc/skel/.cache \
           /etc/skel/.config \
           /etc/skel/.local

# Bestehende Dotfiles in /home bereinigen (Image-Layer, nicht Volume)
RUN find /home -maxdepth 2 \( \
    -name ".bashrc" -o \
    -name ".profile" -o \
    -name ".bash_logout" -o \
    -name ".bash_profile" -o \
    -name ".bash_history" -o \
    -name ".cache" -o \
    -name ".config" -o \
    -name ".local" \
    \) -delete 2>/dev/null || true

# .bash_history unterdrücken — Shell-History dauerhaft deaktivieren
RUN echo 'HISTFILE=/dev/null' >> /etc/bash.bashrc && \
    echo 'HISTSIZE=0' >> /etc/bash.bashrc && \
    echo 'unset HISTFILE' >> /etc/bash.bashrc

USER user
