#!/bin/bash

_vw_version_major="0"
_vw_version_minor="1"
_vw_version="${_vw_version_major}.${_vw_version_minor}"

[[ ${_vw_version_major} == 0 ]] && echo "Vivado wrapper is unfinished, and unable to work." && exit 11

function show_help () {
    echo "Vivado wrapper ${_vw_version}
Usage:
    $1 <SubCommand> [Args ...]
        Run SubCommand.
    $1 --help
        Show this help message.

SubCommands:
    build
        Build current project, using ./Vivadofile as configuration file.
        --top <top_module_name>
            Override top module appointed in Vivadofile.
        
    burn
        Burn compiled top_module bit file to hardware board.
        --top <top_module_name>
            Override top module appointed in Vivadofile.
 
    burn-file <file_name>
    "
}

[[ $1 == '' ]] || [[ $1 == '--help' ]] && 

