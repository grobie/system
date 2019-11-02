#!/usr/bin/fish

complete -c cryptboot -f
complete -c cryptboot -n __fish_is_first_arg -a mount  -d 'Mount cryptboot device'
complete -c cryptboot -n __fish_is_first_arg -a status -d 'Show cryptboot device status'
complete -c cryptboot -n __fish_is_first_arg -a umount -d 'Unmount cryptboot device'
