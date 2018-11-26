#!/bin/sh

if [ ! -z "$ROOT_CA" ]; then
  if [ -f "${ROOT_CA}" ]; then
    if [ ! -f '/usr/local/share/ca-certificates/ca.crt' ]; then
      cp "${ROOT_CA}" '/usr/local/share/ca-certificates/ca.crt'
      update-ca-certificates
      echo "CA '${ROOT_CA}' installed successfully."
    else
      echo "CA '${ROOT_CA}' is already installed"
    fi
  else
    echo "file '${ROOT_CA}' does not exist!"
  fi
fi
if [[ "$(stat -c '%u' /cloud9)" != "${UID}" ]]; then
  chown -R ${UID}:${GID} /cloud9
fi
if [[ "$(stat -c '%u' ${HOME})" != "${UID}" ]]; then
  chown -R ${UID}:${GID} ${HOME}
fi
export NODE_ENV='production'
sudo --preserve-env -u "#${UID}" forever -- /cloud9/server.js -w ${HOME} -p ${C9PORT} --listen 0.0.0.0 $@
