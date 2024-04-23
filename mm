#!/usr/bin/env bash
#
# Copyright (C) 2020 MemVerge Inc.
#
# Script for launching user command on Memory Machine
#
MM_CONF_PATH="/etc/memverge"
MVMALLOC_CONF_PATH="$MM_CONF_PATH/mvmalloc.yml"
MM_YML_PATH="$MM_CONF_PATH/mm.yml"
INSTALL_DIR_PREFIX=""
MVMALLOC_SO_PATH=""
MM_BIN_NAME="mvmallocd"

# Print out an error message started with "ERROR: "
error() {
    echo -e "ERROR: $1"
}

# Echo termination message and exit with error code 1.
bye() {
    error "Failed to launch command $USER_CMD."
    exit 1
}

# Make sure mvmalloc.yml and mm.yml exist.
check_conf() {
    if [[ ! -e $MVMALLOC_CONF_PATH ]]; then
        error "$MVMALLOC_CONF_PATH does not exist."
        bye
    fi
    
    if [[ ! -e $MM_YML_PATH ]]; then
        error "mm.yml does not exist in $MM_CONF_PATH."
        bye
    fi
}

# Make sure there is a running Memory Machine
check_mm_liveness() {
    pgrep $MM_BIN_NAME > /dev/null 
    if [ $? -ne 0 ]; then
        error "A running Memory Machine is not detected."
        error "Please start mvmallocd first."
        bye
    else
        return 0
    fi
}

# Retrieve installation directory from mm.yml
get_install_dir() {
    line=$(grep "InstallDir:" $MM_YML_PATH)
    if [ $? -ne 0 ]; then
        error "Failed to retrieve the installation path from $MM_YML_PATH."
        bye
    fi
    INSTALL_DIR_PREFIX=$(echo "$line" |  tr -d '[:space:]' | cut -d ":" -f 2)
    if [ $? -ne 0 ]; then
        # the entry is malformed for some reason.
        error "Failed to parse $MM_YML_PATH, configuration is malformed."
        bye
    fi
    return 0
}

# Retreive the installation path of mvmalloc.so
get_mvmalloc_so_path() {
    get_install_dir    
    MVMALLOC_SO_PATH="$INSTALL_DIR_PREFIX/lib64/mvmalloc.so"
}

# Read /etc/memverge/mm.yml and
# calcualte the path to the installed mvmalloc.so
get_ld_preload_string() {

    get_mvmalloc_so_path    
    if [[ ! -e $MVMALLOC_SO_PATH ]]; then
        error "mvmalloc.so does not exist in $INSTALL_DIR_PREFIX/lib64"
        bye
    fi
    return 0
}

USER_CMD=""
# parse user input
parse_user_input() {
    # parse user input, if contains -c|--config, it must be the first argument
    # all user input after that will be taken as memory machine command
    if [[ $# -gt 2 && ("$1" == "-c" || "$1" == "--config") ]]; then
        MVMALLOC_CONF_PATH="$2"
        USER_CMD=${*:3}
    else 
        USER_CMD=${*}
    fi
}

USER_INPUT="$*"
# Launch user application on Memory Machine
launch() {
    if [ -z "$USER_INPUT" ]; then
        # Print out usage if no parameter is given.
        echo "Execute command on MemVerge Memory Machine."
        echo "Note: Memory Machine must be properly installed,\
 and mvmallocd must be running."
        echo "Usage:"
        echo "    mm [options] app-cmd [app-cmd-args]"
        echo "Options:"
        echo "    -c|--config <path/to/mvmalloc.yml>"     
        echo "        path to mvmalloc.so configuration file. \
Default: /etc/memverge/mvmalloc.yml"
        return 0
    fi
    parse_user_input $USER_INPUT
    check_conf
    check_mm_liveness
    get_ld_preload_string
    LD_PRELOAD=./mvmalloc.so
    export LD_PRELOAD
    MVMALLOC_CONFIG=$MVMALLOC_CONF_PATH
    export MVMALLOC_CONFIG
    exec $USER_CMD
}

launch
