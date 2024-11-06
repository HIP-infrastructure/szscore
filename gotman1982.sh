#!/bin/sh -e

apt-get install --no-install-recommends -y \
    python3 \
    python3-numpy \
    python3-pip \
    python3-scipy \
    git

pip install --no-cache-dir -U pip

# Gotman 1982 has been packaged for Python >3.12, but this is an Jammy (22.04)
# with Python 3.10.
pip install --no-cache-dir --ignore-requires-python \
    "git+https://github.com/esl-epfl/gotman_1982@master#egg=gotman-1982&subdirectory=gotman_1982"

# Cleanup
apt-get remove -y --purge \
    git
