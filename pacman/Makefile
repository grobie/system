sync: /etc/pacman.d/hooks/02-boot-update-deny.hook
sync: install-packages

/etc/pacman.d/hooks/%: %
	sudo mkdir -p $(dir $@)
	sudo ln -s $(abspath $<) $@

install-packages: SHELL:=/bin/bash
install-packages: packages
	@comm -13 \
		<(cat <(pacman -Qg | cut -d\  -f1 | uniq) <(pacman -Qq) | sort) \
		<(cat $< | grep -v '^#\|^$$' | sort) \
	| yay -S -

setup:
