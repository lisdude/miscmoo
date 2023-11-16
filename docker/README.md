This is a very minimal Docker image for Toaststunt intended to reduce the attack surface as much as possible by including as little as possible.

# Quick Start
1. Run the command `./moo_docker bootstrap`
2. Start / stop your MOO by running: `./moo_docker <moo_name_no_spaces>`

If you want to start from a database other than ToastCore, you'll need to edit the `compose.yaml` file.

# Basic Operation
1. Copy all of these files into your ToastStunt directory. (Be sure `src/docker` makes it to the right place.)
2. Edit `options.h` to your liking. *NOTE* In the Docker container, your data will be in `/moo`. Plan accordingly.
3. Edit `compose.yaml` to your liking.
4. Copy your database into the ToastStunt directory. (The one specified in `compose.yaml`)
5. Start and stop your MOO by running: `./moo_docker <moo_name_no_spaces>`

That's about it. Run `./moo_docker` with no arguments for a rundown of what it can do.
