#!/bin/bash

clear

echo "=== Shell Setup ==="
echo ""
echo "Please select your preferred default shell."
echo "Note: Changing your shell requires your user password."
echo ""
_isInstalledYay() {
	package="$1"
	check="$(yay -Qs --color always "${package}" | grep "local" | grep "\." | grep "${package} ")"
	if [ -n "${check}" ]; then
		echo 0 #'0' means 'true' in Bash
		return #true
	fi
	echo 1 #'1' means 'false' in Bash
	return #false
}
echo "Please select your preferred shell:"
echo ""
echo "Note: Zsh is recommended for this setup."

shell=$(gum choose "zsh" "bash" "Cancel")

# -----------------------------------------------------
# Activate bash
# -----------------------------------------------------

if [[ $shell == "bash" ]]; then

	# Change shell to bash
	while ! chsh -s $(which bash); do
		echo "ERROR: Authentication failed. Please enter the correct password."
		sleep 1
	done
	echo "Shell is now bash."

	gum spin --spinner dot --title "Please reboot your system." -- sleep 3

# -----------------------------------------------------
# Activate zsh
# -----------------------------------------------------

elif [[ $shell == "zsh" ]]; then

	# Change shell to zsh
	while ! chsh -s $(which zsh); do
		echo "ERROR: Authentication failed. Please enter the correct password."
		sleep 1
	done
	echo "Shell is now zsh."

	# Installing fast-syntax-highlighting
	if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting" ]; then
		echo "Installing fast-syntax-highlighting..."
		git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
	else
		echo "fast-syntax-highlighting already installed."
	fi

	gum spin --spinner dot --title "Please reboot your system." -- sleep 3

# -----------------------------------------------------
# Cancel
# -----------------------------------------------------

else
	echo "Shell change canceled."
	exit
fi
