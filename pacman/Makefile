#sync: /etc/pacman.d/hooks/01-boot-update-unlock.hook
#sync: /etc/pacman.d/hooks/01-boot-update-lock.hook
sync: /etc/pacman.d/hooks/02-boot-update-deny.hook

/etc/pacman.d/hooks/%: %
	sudo mkdir -p $(dir $@)
	sudo ln -s $(abspath $<) $@
