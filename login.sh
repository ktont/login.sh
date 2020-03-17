#!/usr/bin/env bash
prefix=`dirname $0`
prefix=`cd $prefix; pwd`

#stty echo

function Usage() {
  echo 'Usage:'
  echo "  -c COMMAND, require/enum, ssh/telnet"
  echo "  -h HOST, require, support user@host:port scheme"
  echo "  -u USER, optional, default current username"
  echo "  -p PORT, optional, default 22(ssh) 23(telnet)"
  echo "  -a AUTH, optional/multiple, default empty string, retry multiple passwords until success"
  echo '  -z ZMODEM, optional/boolean, rz/sz file-transfer support'
  exit 1
}

function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            return 0
        fi
    }
    return 1
}

if [ $# -eq 0 ]; then
  Usage
fi

CMD=
USER=
HOST=
PORT=
PASSWORDS=()
ZMODEM=0
while getopts "c:u:h:p:a:z" opt
do
  case $opt in
    c)
      CMD="$OPTARG"
      ;;
    u)
      USER="$OPTARG"
      ;;
    h)
      HOST="$OPTARG"
      ;;
    p)
      PORT="$OPTARG"
      ;;
    a)
      PASSWORDS+=("$OPTARG")
      ;;
    z)
      ZMODEM=1
      ;;
    ?)
      echo "there is unrecognized parameter."
      Usage
      ;;
  esac
done

[ -z "$CMD" ] && Usage
[ -z "$HOST" ] && Usage

if [ "$CMD" != "ssh" ] && [ "$CMD" != "telnet" ]; then
  echo 'ssh/telnet support only'
  exit 1
fi

if [[ $HOST =~ @ ]]; then
  USER=${HOST%@*}
  HOST=${HOST#*@}
fi

if [[ $HOST =~ : ]]; then
  PORT=${HOST#*:}
  HOST=${HOST%:*}
fi

if [ -z "$PORT" ]; then
  [ "$CMD" == "ssh" ] && PORT=22 || PORT=23
fi

if ! contains "${PASSWORDS[@]}" ""; then
  PASSWORDS+=("")
fi

#declare -p PASSWORDS

cd $prefix
if [ "$ZMODEM" -eq 0 ]; then
  expect ./${CMD}.exp "$USER" "$HOST" "$PORT" "$ZMODEM" "${PASSWORDS[@]}"
else
  LC_CTYPE=en_US \
  expect ./${CMD}.exp "$USER" "$HOST" "$PORT" "$ZMODEM" "${PASSWORDS[@]}"
fi

