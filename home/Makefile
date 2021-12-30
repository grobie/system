SOURCES     = $(shell find . ! -type d ! -path ./Makefile)
DESTINATION = $(HOME)
SYNCABLES   = $(patsubst ./%, $(DESTINATION)/%, $(SOURCES))

setup: bluetooth-toggle-headphones ~/.tmux/plugins/tpm

sync: $(SYNCABLES)

$(DESTINATION)/%: %
	mkdir -p $(dir $@)
	ln -fs $(abspath $<) $@

KEYBINDING_PATH = /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/toggle-headphones/
bluetooth-toggle-headphones: $(DESTINATION)/code/bin/toggle-headphones
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(KEYBINDING_PATH) name 'Toggle Headphones'
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(KEYBINDING_PATH) binding 'Bluetooth'
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(KEYBINDING_PATH) command '$<'
	gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$(KEYBINDING_PATH)']"
	# gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill-bluetooth-static "[]"

~/.tmux/plugins/tpm:
	git clone https://github.com/tmux-plugins/tpm $@
