FROM lmsysorg/sglang:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        init-system-helpers \
        openssh-server \
        rsync \
        jq \
    && mkdir -p /root/.ssh /run/sshd /etc/ssh/sshd_config.d \
    && chmod 700 /root/.ssh \
    && printf '%s\\n' \
        'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSG3vISjWzjlxZDV8w1FbNDa2aEty4hx0b+wq42Viu7 root@DESKTOP-6S75UR7' \
        > /root/.ssh/authorized_keys \
    && chmod 600 /root/.ssh/authorized_keys \
    && printf '%s\\n' \
        'Port 22' \
        'PermitRootLogin prohibit-password' \
        'PubkeyAuthentication yes' \
        'PasswordAuthentication no' \
        'KbdInteractiveAuthentication no' \
        > /etc/ssh/sshd_config.d/00-container.conf \
    && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh

COPY sglang/ /opt/sglang-minimax/

RUN set -eux; \
    command -v sglang; \
    command -v service; \
    command -v sshd; \
    command -v rsync; \
    command -v jq; \
    mkdir -p /etc/init.d; \
    chmod 0755 /opt/sglang-minimax/sgmax /opt/sglang-minimax/start_minimax_h3_ref2va.sh; \
    ln -sfn /opt/sglang-minimax/sgmax /etc/init.d/sgmax; \
    bash -n /opt/sglang-minimax/sgmax; \
    bash -n /opt/sglang-minimax/start_minimax_h3_ref2va.sh; \
    bash -n /usr/local/bin/docker-entrypoint.sh

EXPOSE 22 30010

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
