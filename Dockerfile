FROM ghcr.io/open-webui/open-terminal:latest

USER root

RUN rm -f /etc/skel/.bashrc \
          /etc/skel/.bash_history \
          /etc/skel/.profile \
          /etc/skel/.bash_logout \
          /etc/skel/.bash_profile && \
    rm -rf /etc/skel/.cache \
           /etc/skel/.config \
           /etc/skel/.local

RUN find /home -maxdepth 2 \( \
    -name ".bashrc" -o \
    -name ".profile" -o \
    -name ".bash_logout" -o \
    -name ".bash_profile" -o \
    -name ".cache" -o \
    -name ".config" -o \
    -name ".local" \
    \) -delete 2>/dev/null || true

USER user
