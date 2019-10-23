function fish_prompt
  set success $status

	test $SSH_TTY
  and printf (set_color red)$USER(set_color brwhite)'@'(set_color yellow)(prompt_hostname)' '
  test $USER = 'root'
  and echo (set_color red)"#"

  # Main
  if test $success -eq 0
    echo -n (set_color cyan)(prompt_pwd) (set_color red)'❯'(set_color yellow)'❯'(set_color green)'❯ '
  else
    echo -n (set_color cyan)(prompt_pwd) (set_color red)'❯'(set_color red)'❯'(set_color red)'❯ '
  end
end
