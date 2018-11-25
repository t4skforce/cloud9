!#/bin/bash

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

su -c 'forever' cloud -- "/cloud9/server.js -w ${HOME} -p ${PORT} --listen 0.0.0.0 $@"
