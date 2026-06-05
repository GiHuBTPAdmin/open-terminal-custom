FROM ghcr.io/open-webui/open-terminal:latest

USER root

# Dotfiles aus /etc/skel/ entfernen
RUN rm -f /etc/skel/.bashrc \
          /etc/skel/.profile \
          /etc/skel/.bash_logout \
          /etc/skel/.bash_profile \
          /etc/skel/.bash_history && \
    rm -rf /etc/skel/.cache \
           /etc/skel/.config \
           /etc/skel/.local

# Bestehende Dotfiles in /home bereinigen
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

# Shell-History dauerhaft deaktivieren
RUN echo 'HISTFILE=/dev/null' >> /etc/bash.bashrc && \
    echo 'HISTSIZE=0'         >> /etc/bash.bashrc && \
    echo 'unset HISTFILE'     >> /etc/bash.bashrc

# ✅ NEU: Cache-Verzeichnisse nach /tmp umleiten
# → matplotlib und fontconfig schreiben nie mehr in ~/.cache/
RUN echo 'export MPLCONFIGDIR=/tmp/mpl_cache'    >> /etc/bash.bashrc && \
    echo 'export XDG_CACHE_HOME=/tmp/xdg_cache'  >> /etc/bash.bashrc

# Diese ENV-Variablen gelten auch für Python-Skripte (nicht nur Shell)
ENV MPLCONFIGDIR=/tmp/mpl_cache
ENV XDG_CACHE_HOME=/tmp/xdg_cache

USER user
