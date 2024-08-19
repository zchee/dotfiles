#!/usr/bin/env zsh

# -----------------------------------------------------------------------------
# docker aliases

[[ -n $ZSH_DEBUG ]] && STARTTIME="$(($(gdate +%s%N)/1000000))"
# -----------------------------------------------------------------------------
# images

alias doi="docker image ls --all" # Get images
# containers
alias dpa="docker container ls --all" # Get container process
# alias dl="docker ps -l -q" # Get latest container ID
# alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'" # Get container IP
# alias drmac='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)' # Stop and Remove all containers
# alias dst='docker stop'
# run docker container
# alias drun='docker run --rm'
# run docker container with interactive and allocate a pseudo-tty
# alias druni='docker run --rm -it'
# inspections
# alias drd="docker run -d -P" # Run deamonized container, e.g., $dkd base /bin/echo hello
# alias dri='docker run --rm -i -t -P' # Run interactive container, e.g., $dki base /bin/bash

# -----------------------------------------------------------------------------
# docker functions

# build dockerfile
# dbu() { docker build --rm -t="$1" $2 .; }
# start all containers
# dstart() { "docker" start $("docker" ps -a -q); }
# stop all containers
# dstop() { docker stop "$(docker ps -a -q)"; }
# remove all stop container
drmstop() { docker rm $(docker ps -a | grep -v Up | awk 'NR>1 {print $1}'); }
# remove none tag images
drminone() { docker rmi $(docker images | awk '/<none>/ { print $3 }') || true; }
# docker-machine ssh wrapper
# dms() { MACHINE_DEBUG=0 docker-machine ssh "$1" sudo docker run --rm -it "$2" "$3"; }

# !!dangerous!!
# Remove all containers
# drmall() { docker rm $(docker ps -a -q); }
# Remove all images
# driall() { docker rmi $(docker images -q); }

# nsenter to guest OS
# denter() { docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh; }

# Show all alias related docker
# dalias() { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }

# dihis() { docker image history --no-trunc --format="{{.CreatedBy}}" "$1" | awk -F '/bin/sh -c ' '{print $2}' | sed -E 's|#\(nop\)( )+||' | tac }

# -----------------------------------------------------------------------------
# Tools

# github.com/centurylink/image-graph
# (do)cker (c)ontainer (i)mage (g)raph to stdout
# doig() { docker run --rm -v /var/run/docker.sock:/var/run/docker.sock centurylink/image-graph > docker_images.png; }
# (do)cker (c)ontainer (i)mage (g)raph (w)eb-based on localhost:3000
# doigw() { docker run --rm -d -v /var/run/docker.sock:/var/run/docker.sock -e PORT=3000 -p 3000:3000 "$1"; sleep 3; open 'http://localhost:3000'; }

# -----------------------------------------------------------------------------
[[ -n $ZSH_DEBUG ]] && ENDTIME="$(($(gdate +%s%N)/1000000))" && printf "loaded modules/docker.zsh: %12s\\n" $(($ENDTIME - $STARTTIME))
