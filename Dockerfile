FROM node:slim

ARG USER=cloud9
ARG GROUP=cloud9
ENV UID=1000
ENV GID=1000
ENV HOME=/workspace

RUN buildDeps='make build-essential g++ gcc' 
 && softDeps="sudo tmux git ssh python python3 python-pip python3-pip" \
 && apt-get update && apt-get upgrade -y \
 && apt-get install -y $buildDeps $softDeps \
 && pip install tox \
 && pip3 install tox \
 && npm install -g forever && npm cache clean --force \
 && git clone --depth=5 https://github.com/c9/core.git /cloud9 && cd /cloud9 \
 && scripts/install-sdk.sh \
 && apt-get purge -y --auto-remove $buildDeps \
 && apt-get autoremove -y && apt-get autoclean -y && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && npm cache clean --force \
 && git reset --hard \
 && mkdir -p ${HOME} \
 && groupadd --system --gid ${APPGID} ${GROUP} \
 && useradd --system --uid ${APPUID} -g ${GROUP} ${USER} --home ${HOME} \
 && usermod -aG sudo ${USER} \
 && echo "${USER}:$(openssl rand 512 | openssl sha256 | awk '{print $2}')" | chpasswd \
 && chown -R ${USER}:${GROUP} ${HOME}
 
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat

VOLUME ${HOME}
EXPOSE 8181

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["--auth","c9:c9"]
