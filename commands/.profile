# Make .bashrc available to non interactive shells (.sh scripts)
export BASH_ENV=~/.bashrc
# export ENV=$BASH_ENV

# If the file referred to exists then run it:
if [ -f $BASH_ENV ]; then . $BASH_ENV; fi