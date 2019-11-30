SOURCES     = $(shell find . -type f ! -path ./Makefile)
DESTINATION = $(HOME)
SYNCABLES   = $(patsubst ./%, $(DESTINATION)/%, $(SOURCES))

setup: bluetooth-toggle-vpn

sync: $(SYNCABLES)

$(DESTINATION)/%: %
	mkdir -p $(dir $@)
	ln -fs $(abspath $<) $@

KEYBINDING_PATH = /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/toggle-vpn/
bluetooth-toggle-vpn: $(DESTINATION)/code/bin/toggle-vpn
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(KEYBINDING_PATH) name 'Toggle VPN'
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(KEYBINDING_PATH) binding 'Bluetooth'
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$(KEYBINDING_PATH) command '$<'
	gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$(KEYBINDING_PATH)']"
	gsettings set org.gnome.settings-daemon.plugins.media-keys rfkill-bluetooth-static "[]"
