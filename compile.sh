#!/bin/bash

## Lambda Function (github-events.zip)
RUNTIME='python3.12'
find ${PWD} -type f -name '*.zip' | xargs rm -rf {}
find ${PWD} -type d -name 'lambda-env' | xargs rm -rf {}
python3 -m venv lambda-env
source lambda-env/bin/activate
pip3 install --upgrade pip
# pip3 install python_terraform
# pip3 install boto3
cd lambda-env/lib/${RUNTIME}/site-packages/
zip -r ${OLDPWD}/github-events.zip .
cd ${OLDPWD}
zip -g -r github-events.zip github-events.py

## Lambda Layer (lambda-layer.zip)
cd lambda-layer
zip -r lambda-layer.zip .
zip -g -r lambda-layer.zip .ssh
