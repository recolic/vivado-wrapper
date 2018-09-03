# Vivado Wrapper

> Run vivado natively in linux command line.

## Features

- Init, build, burn any vivado project in one command.

- Extremely simple, flexible, and customizable project layout.

- Burn auto saved built binary at anytime and any machine.

- Full vivado GUI support.

- Support every hardware supported by vivado. 

- Theoretically support any vivado version (But latest is the best).

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
vim Vivadofile # To tell vivado-wrapper about your module~constraint relationship, threads, board, etc.
```

- Build Project

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

## Notice

This is a bash script, so it can be easily injected. Never trust Vivadofile uploaded by others!

If you give a wrong top\_module name, *silly vivado* will accept it, and generate bitstream for a **randomly-taken** module(with long time spent), then report error.
