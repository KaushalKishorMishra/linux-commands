#! /bin/bash

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo "Enter the version for nvm you want to use:"
read version
echo "nvm use $version"
nvm use $version
