# Vivado Wrapper

> Run vivado natively in linux command line.

## Installation

```sh
git clone https://github.com/recolic/vivado-wrapper
export vivado_exec="/path/to/your/vivado" # Bash
set -Ux vivado_exec "/path/to/your/vivado" # Fish
```

Or if you want to make yourself happier:

```sh
set -Ux PATH $PATH (pwd)/vivado-wrapper # Fish
export PATH="$PATH:$(pwd)/vivado-wrapper" # Bash
alias vivadow=vivado-wrapper # I'll use this wrapper in the doc below.
```

## Usage

- Create Project

```sh
mkdir my_project && cd my_project
vivadow init
code . # Or any editor you prefer.
vim Vivadofile # To tell vivado-wrapper about your module~constraint relationship.
```

- Build Project

Warning: this project will use `xc7a100tcsg324-1` (for HUST) as your board. Please fork and modify template if you'd like to use other board. We can easily support changing board by Vivadofile, if you can solve the TODO in ./vivado-wrapper:line5.

```sh
cd vivado-wrapper/example
vivadow build
# Plug in your board now
vivadow burn
```

Or you can easily burn a pre-built bitstream:

```sh
vivadow burn-file ./build/other_mod.bit
```

- Run Simulation (Or other GUI-only Tasks)

Warning: All modification to sources/constraints will be saved to origin project. All modification to other project-level configurations, adding or removing sources, will be discarded.

```sh
vivadow gui
```

## Remote access (security concern)

This is a bash script, so it can be easily injected. Never trust Vivadofile uploaded by others!
