FROM ghcr.io/open-webui/open-terminal:latest

USER root

# cache-bust: 2026-06-10

# 1. Dotfiles aus /etc/skel/ entfernen
RUN rm -f /etc/skel/.bashrc \
          /etc/skel/.profile \
          /etc/skel/.bash_logout \
          /etc/skel/.bash_profile \
          /etc/skel/.bash_history && \
    rm -rf /etc/skel/.cache \
           /etc/skel/.config \
           /etc/skel/.local

# 2. Shell-History für alle User dauerhaft deaktivieren
RUN echo 'HISTFILE=/dev/null'  >> /etc/bash.bashrc && \
    echo 'HISTSIZE=0'          >> /etc/bash.bashrc && \
    echo 'unset HISTFILE'      >> /etc/bash.bashrc

# 3. Workspace-Ordner automatisch erstellen + Cleanup bei jeder Session
RUN echo 'mkdir -p ~/workspace 2>/dev/null || true'        >> /etc/bash.bashrc && \
    echo 'workspace-cleanup.sh 2>/dev/null || true'        >> /etc/bash.bashrc

# 4. matplotlib + fontconfig Cache nach /tmp umleiten
ENV MPLCONFIGDIR=/tmp/mpl_cache
ENV XDG_CACHE_HOME=/tmp/xdg_cache

# 5. pip-Warnungen unterdrücken
ENV PIP_ROOT_USER_ACTION=ignore
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# 6. Cleanup-Script
RUN cat > /usr/local/bin/workspace-cleanup.sh <<'EOF'
#!/bin/sh
set -eu
BASE_DIR="${CLEANUP_BASE_DIR:-/home}"
RETENTION_DAYS="${CLEANUP_RETENTION_DAYS:-3}"
echo "[cleanup] started: base=$BASE_DIR retention=${RETENTION_DAYS}d"

# A) Temporäre und Script-Dateien immer löschen
find "$BASE_DIR" -mindepth 2 -type f \( \
  -name "*.py"   -o \
  -name "*.pyc"  -o \
  -name "*.pyo"  -o \
  -name "*.tmp"  -o \
  -name "*.temp" -o \
  -name "*.log"  -o \
  -name "*.bak"  -o \
  -name "*.swp"  -o \
  -name "*.swo"  -o \
  -name ".DS_Store" \
\) -delete 2>/dev/null || true

# B) Temporäre Cache-Ordner immer löschen
find "$BASE_DIR" -mindepth 2 -type d \( \
  -name "__pycache__"        -o \
  -name ".pytest_cache"      -o \
  -name ".mypy_cache"        -o \
  -name ".ruff_cache"        -o \
  -name ".cache"             -o \
  -name ".ipynb_checkpoints" -o \
  -name ".tmp"               -o \
  -name ".temp" \
\) -exec rm -rf {} + 2>/dev/null || true

# C) Alte Dateien > RETENTION_DAYS löschen
#    Geschützt: Office, PDF, Text, Archiv, Bilder
find "$BASE_DIR" -mindepth 2 -mtime +"$RETENTION_DAYS" \
  ! \( \
    -iname "*.doc"  -o -iname "*.docx" -o -iname "*.dot"  -o -iname "*.dotx" -o \
    -iname "*.xls"  -o -iname "*.xlsx" -o -iname "*.xlsm" -o -iname "*.csv"  -o -iname "*.tsv" -o \
    -iname "*.ppt"  -o -iname "*.pptx" -o -iname "*.pps"  -o -iname "*.ppsx" -o \
    -iname "*.pdf"  -o \
    -iname "*.txt"  -o -iname "*.rtf"  -o -iname "*.md"   -o \
    -iname "*.odt"  -o -iname "*.ods"  -o -iname "*.odp"  -o \
    -iname "*.zip"  -o -iname "*.7z"   -o -iname "*.rar"  -o \
    -iname "*.png"  -o -iname "*.jpg"  -o -iname "*.jpeg" -o \
    -iname "*.gif"  -o -iname "*.webp" -o -iname "*.svg" \
  \) \
  -delete 2>/dev/null || true

# D) Leere Ordner bereinigen
find "$BASE_DIR" -mindepth 2 -type d -empty \
  -delete 2>/dev/null || true

echo "[cleanup] finished"
EOF

RUN chmod +x /usr/local/bin/workspace-cleanup.sh

USER user
