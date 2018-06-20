#!/bin/bash

_vw_bin_name="$0"

_vw_version_major="0"
_vw_version_minor="1"
_vw_version="${_vw_version_major}.${_vw_version_minor}"

[[ $_vw_version_major == 0 ]] && echo "Vivado wrapper is unfinished, and unable to work." && exit 11
[[ $_vw_bin_name == '' ]] && _vw_bin_name=vivado-wrapper

function show_help () {
    echo "Vivado wrapper ${_vw_version}
Usage:
    ${_vw_bin_name} <SubCommand> [Args ...]
        Run SubCommand.
    ${_vw_bin_name} --help
        Show this help message.
    
    You must set environment variable 'vivado_exec' properly.

SubCommands:
    init
        Init a new, empty project directory, with Vivadofile template and build/constrain directory.

    build (Vivadofile required)
        Build current project, using ./Vivadofile as configuration file.
        --top <top_module_name>
            Override top module appointed in Vivadofile.
        --constrain <path/to/constrain.xdc>
            Override the constrain file appointed in Vivadofile.
        
    burn (Vivadofile required)
        Burn compiled top_module bit file into hardware board.
        --top <top_module_name>
            Override top module appointed in Vivadofile.
        --device <device_name>
            Device name to burn into. Auto-detect if not appointed.

    gui (Vivadofile required)
        Launch vivado GUI, which has opened this project. Your modification to sources in vivado GUI
          will be saved to the origin project. Your modification to other project-level configurations
          will be discarded.

    burn-file <file_name>
        Burn a bit file into hardware board.
        --device <device_name>
            Device name to burn into. Auto-detect if not appointed.

Examples:
    ${_vw_bin_name} init
    ${_vw_bin_name} build
    ${_vw_bin_name} burn
    ${_vw_bin_name} build --top some_other_module
    ${_vw_bin_name} burn-file build/another_module.bit
    "
}

function import_vivadofile_impl () {
    [[ -e ./Vivadofile ]] && source ./Vivadofile && return 0
    [[ -e ./vivadofile ]] && source ./vivadofile && return 0
    [[ -e ./VivadoFile ]] && source ./VivadoFile && return 0
    return 1
}

function import_vivadofile () {
    import_vivadofile_impl
    [[ $? == 1 ]] && echo 'Vivadofile, vivadofile, VivadoFile not found.' && return 1
    [[ -e ${vivado_exec} ]] && echo "vivado_exec '${vivado_exec}' not found." && return 1
    [[ -x ${vivado_exec} ]] && echo "vivado_exec '${vivado_exec}' not executable." && return 1
    [[ "${thread_num}" == '' ]] && thread_num=1
    [[ "${sources[*]}" == '' ]] && echo "sources not provided." && return 1
    [[ "${bit_dir}" == '' ]] && echo "bit_dir not provided." && return 1
    [[ "${top_modules[*]}" == '' ]] && echo "top_modules not provided." && return 1
    [[ "${top_module}" == '' ]] && echo "top_module not provided." && return 1
}

function get_constrain_of_module () {
    _mod_name="$1"
    for _ele in "${top_modules[@]}" ; do
        _key=${_ele%%:*}
        _value=${_ele#*:}
        [[ ${_key} == ${_mod_name} ]] && echo -n "${_value}" && return 0
    done
    return 1
}

vw_cmd="$1"

[[ $vw_cmd == '' ]] && show_help && exit 1
[[ $vw_cmd == '--help' ]] && show_help && exit 0
if [[ $vw_cmd == 'build' ]] || [[ $vw_cmd == 'burn' ]] || [[ $vw_cmd == 'gui' ]]; then
    import_vivadofile
    [[ $? != 0 ]] && echo "Vivadofile error reported. Exiting..." && exit 2
fi


