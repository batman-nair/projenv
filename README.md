# projenv
Script to save and reopen application window layouts

A handy script to remove the hassle of having to reopen and resize your windows everytime you work on a specific project.

## Installing
This script requires wmctrl and xwininfo for its working, so first install it like
```bash
sudo apt install wmctrl
```
To make the script accessible from anywhere in the system
```bash
sudo mv projenv /usr/bin/projenv
```

## Usage

To save the current layout for future use
```bash
./projenv -s filename
```
To open a previously saved layout
```bash
./projenv -o filename
```

Or for quick use just do
```bash
./projenv

./projenv -o
```

The project environment saves are in your $HOME/.projenv folder

You can edit and create custom files for use there

The format for the file is as follows ended with line-break
```text
command-name	desktop-number positioning
```
The positioning can be worded as "top", "right", "top-right", "bottom-left" and so on or specified with "X Y Width Height" numbers.

## Troubleshooting
If the script has permission problems for executing, go to the folder containing the script and do
```bash
chmod +x projenv
```
