SOURCES     = $(shell find . -type f ! -path ./Makefile)
DESTINATION = $(HOME)/code/bin
SYNCABLES   = $(patsubst ./%, $(DESTINATION)/%, $(SOURCES))

sync: $(SYNCABLES)

setup: bluetooth-toggle-vpn

$(DESTINATION)/%: %
	mkdir -p $(dir $@)
	ln -s $(abspath $<) $@

KEYBINDING_PATH = /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/toggle-vpn/
bluetooth-toggle-vpn: $(DESTINATION)/toggle-vpn
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(KEYBINDING_PATH) name 'Toggle VPN'
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(KEYBINDING_PATH) binding 'Bluetooth'
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(KEYBINDING_PATH) command '$<'
	gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$(KEYBINDING_PATH)']"
	# Necessary?
	gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill-bluetooth-static "['']"
