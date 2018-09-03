#!/bin/bash

function backup_var () {
    _var_name="$1"
    export "_vivado_wrapper_backup_$_var_name"="$$$_var_name"
    unset "$_var_name"
}
function recover_var () {
     _var_name="$1"
    export "$_var_name"="$$_vivado_wrapper_backup_$_var_name"
    unset "_vivado_wrapper_backup_$_var_name"
}

backup_var a

