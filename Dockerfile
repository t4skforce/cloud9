FROM node:slim

ARG USER=cloud9
ARG GROUP=cloud9
ENV UID 1000
ENV GID 1000
ENV C9PORT 8181
ENV HOME "/workspace"
ENV ROOT_CA ""
ENV PORT 8080
ENV IP "0.0.0.0"

COPY ./docker-entrypoint.sh /
COPY ./requirements.txt /tmp/
RUN buildDeps='make build-essential g++ gcc' \
 && softDeps='sudo tmux git ssh htop iftop net-tools python python3 python-virtualenv python3-virtualenv python-pip python3-pip' \
 && apt-get update && apt-get upgrade -y \
 && apt-get install -y $buildDeps $softDeps \
 && npm install -g forever && npm cache clean --force \
 && git clone --depth=5 https://github.com/c9/core.git /cloud9 && cd /cloud9 \
 && scripts/install-sdk.sh \
 && sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js \
 && pip install -r /tmp/requirements.txt \
 && mkdir -p /mnt/shared/lib/python2 && /usr/bin/python2 -m virtualenv --python /usr/bin/python2 /mnt/shared/lib/python2 && cd /mnt/shared/lib/python2/ && . bin/activate && pip install --upgrade jedi pylint pylint-flask pylint-django && deactivate && chown -R ${UID}:${GID} /mnt/shared/lib/python2 \
 && pip3 install -r /tmp/requirements.txt \
 && mkdir -p /mnt/shared/lib/python3 && /usr/bin/python3 -m virtualenv --python /usr/bin/python3 /mnt/shared/lib/python3 && cd /mnt/shared/lib/python3/ && . bin/activate && pip install --upgrade jedi pylint pylint-flask pylint-django && deactivate && chown -R ${UID}:${GID} /mnt/shared/lib/python3 \
 && apt-get purge -y --auto-remove $buildDeps \
 && apt-get autoremove -y && apt-get autoclean -y && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && npm cache clean --force \
 && cd /cloud9 && git reset --hard \
 && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
 && mkdir -p ${HOME} \
 && deluser --remove-home node \
 && groupadd --system --gid ${GID} ${GROUP} \
 && useradd --system --uid ${UID} -g ${GROUP} ${USER} --shell /bin/bash --home ${HOME} \
 && usermod -aG sudo ${USER} \
 && echo "${USER}:$(openssl rand 512 | openssl sha256 | awk '{print $2}')" | chpasswd \
 && chown -R ${USER}:${GROUP} ${HOME} /cloud9 \
 && chmod +x /docker-entrypoint.sh
 
VOLUME ${HOME}
EXPOSE ${C9PORT} ${PORT}

USER ${USER}
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "--auth", "c9:c9", "--packed", "--useBrowserCache" ]
