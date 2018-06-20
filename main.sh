#!/bin/bash

_vw_bin_name="$0"

_vw_version_major="0"
_vw_version_minor="2"
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
        --constraint <path/to/constraint.xdc>
            Override the constraint file appointed in Vivadofile.
        
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

function where_is_him () {
    SOURCE="$1"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    echo -n "$DIR"
 }

function where_am_i () {
    _my_path=`type -p ${_vw_bin_name}`
    where_is_him "$_my_path"
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

function get_constraint_of_module () {
    _mod_name="$1"
    for _ele in "${top_modules[@]}" ; do
        _key=${_ele%%:*}
        _value=${_ele#*:}
        [[ ${_key} == ${_mod_name} ]] && echo -n "${_value}" && return 0
    done
    return 1
}

function generate_real_project () {
    # Create a temp real vivado project in /tmp, link all sources to it, and prepare for future usage.
    cp -r "$my_path/template/project" "$temp_dir/"
    for src in `echo ${sources[@]}`; do
        _unpathed_src=`echo $src | tr '/' '_' | tr ' ' '_'`
        ln -s "$(pwd)/$src" "$temp_dir/project/temp-project.srcs/sources_1/new/$_unpathed_src"
    done
    rm "$temp_dir/project/temp-project.srcs/constrs_1/new/constraint.xdc"
    ln -s "$constr_path" "$temp_dir/project/temp-project.srcs/constrs_1/new/constraint.xdc"
    echo "real_project generated at $temp_dir"
}

function clean_real_project () {
    rm -rf $temp_dir
    echo "real_project cleaned"
}

function do_init () {
    mkdir constraint build
    cp "$my_path"/template/Vivadofile ./Vivadofile
    echo "init done."
}

function do_build () {
    # TODO: Parse cmdline, override top_module and constr
    constr_path="$(pwd)/$(get_constraint_of_module $top_module)"
    generate_real_project

    "$my_path/gen_tcl.sh" build "$temp_dir/project/temp-project.xpr" synth_1 impl_1 write_bitstream "$top_module" $thread_num > $temp_dir/sh.tcl
    "$vivado_exec" -mode batch -source "$temp_dir/sh.tcl" -nojournal -nolog
    _bit_file="$temp_dir/project/temp-project.runs/impl_1/$top_module.bit"
    [[ -e "$_bit_file" ]] && cp "$_bit_file" "$bit_dir/$top_module.bit" || echo "vivado-wrapper: Error: Build failed."

    clean_real_project
}

function burn_file () {
    # TODO: Parse cmdline to get device_name if any.
    file_to_burn="$1"
    "$my_path/gen_tcl.sh" burn-file "$file_to_burn" > $temp_dir/sh.tcl
    "$vivado_exec" -mode batch -source "$temp_dir/sh.tcl" -nojournal -nolog
}

function do_burn () {
    # TODO: Parse cmdline, override top_module and device_name
    burn_file "$bit_dir/$top_module.bit"
}

my_path=`where_am_i`
temp_dir=`mktemp -d`
# If noob user add space character in $1, just truncate it.
vw_cmd=$1
shift

[[ $vw_cmd == '' ]] && show_help && exit 1
[[ $vw_cmd == '--help' ]] && show_help && exit 0
if [[ $vw_cmd == 'build' ]] || [[ $vw_cmd == 'burn' ]] || [[ $vw_cmd == 'gui' ]]; then
    import_vivadofile
    [[ $? != 0 ]] && echo "Vivadofile error reported. Exiting..." && exit 2
fi

case $vw_cmd in
    'init' )
        do_init
        ;;
    'build' )
        do_build
        ;;
    'burn' )
        do_burn
        ;;
    'gui' )
        do_gui &
        ;;
    'burn-file' )
        burn_file $1
        ;;
    * )
        echo "Unknown command '${vw_cmd}', try '${_vw_bin_name} --help'"
        ;;
esac

