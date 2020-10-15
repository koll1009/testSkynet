#! /bin/bash


if [ "$1" == "test" ]; then
    gcc -o packet-quic packet-quic.c crypto.c -lcrypto -DTEST
    echo "test"
else
    gcc -o packet-quic packet-quic.c crypto.c -lcrypto
    echo "release"
fi
