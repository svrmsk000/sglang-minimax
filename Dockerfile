FROM lmsysorg/sglang:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends init-system-helpers \
    && rm -rf /var/lib/apt/lists/*

COPY sglang/ /opt/sglang-minimax/

RUN set -eux; \
    command -v sglang; \
    command -v service; \
    mkdir -p /etc/init.d; \
    chmod 0755 /opt/sglang-minimax/sgmax /opt/sglang-minimax/start_minimax_h3_ref2va.sh; \
    ln -sfn /opt/sglang-minimax/sgmax /etc/init.d/sgmax; \
    bash -n /opt/sglang-minimax/sgmax; \
    bash -n /opt/sglang-minimax/start_minimax_h3_ref2va.sh

EXPOSE 30010
