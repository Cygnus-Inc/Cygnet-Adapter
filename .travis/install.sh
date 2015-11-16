#!/bin/bash

set -e
set -x
set -o pipefail
git clean -f -d -X
rm -r -f $PWD/.pyenv
export PYENV_ROOT="$PWD/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if [[ "$(uname -s)" == 'Darwin' ]]; then
    brew update || brew update
    brew install pyenv
    brew outdated pyenv || brew upgrade pyenv

    if [[ "${OPENSSL}" != "0.9.8" ]]; then
        brew outdated openssl || brew upgrade openssl
    fi

    if which -s pyenv; then
        eval "$(pyenv init -)"
    fi

    case "${TOXENV}" in
        py26)
            curl -O https://bootstrap.pypa.io/get-pip.py
            python get-pip.py --user
            ;;
        py27)
            curl -O https://bootstrap.pypa.io/get-pip.py
            python get-pip.py --user
            ;;
        py33)
            pyenv install 3.3.6
            pyenv global 3.3.6
            ;;
        py34)
            pyenv install 3.4.2
            pyenv global 3.4.2
            ;;
        py35)
            pyenv install 3.5.0
            pyenv global 3.5.0
            ;;
        pypy)
            pyenv install pypy-2.6.1
            pyenv global pypy-2.6.1
            ;;
        pypy-nocover)
            pyenv install pypy-2.6.1
            pyenv global pypy-2.6.1
            ;;
    esac
    pyenv rehash
    python -m pip install --user virtualenv
else
    # temporary pyenv installation to get pypy-2.6 before container infra upgrade
    if [[ "${TOXENV}" == "pypy" ]]; then
        git clone https://github.com/yyuu/pyenv.git ~/.pyenv
        PYENV_ROOT="$HOME/.pyenv"
        PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
        pyenv install pypy-2.6.1
        pyenv global pypy-2.6.1
    fi
    pip install virtualenv
fi

python -m virtualenv ~/.venv
source ~/.venv/bin/activate
pip install tox codecov
