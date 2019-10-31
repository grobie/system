#!/usr/bin/fish

function gogo
  set repository $argv[1]
  if test -z $repository
    echo "usage: gogo <repository>"
    return 1
  end

  set base $GOPATH
  if test -z $base
    set base "$HOME/code"
  end

  set path $base/src/github.com/$repository
  if ! test -d $path
    set url git@github.com:$repository.git
    if git ls-remote --exit-code $url >/dev/null 2>&1
      git clone $url $path
    else
      mkdir -p $path
    end
  end

  code $path
end

function __gogo
  # Support only one argument
  if test (count (commandline -cp | string split " ")) -gt 2
    return 0
  end

  set base $HOME/code/src/github.com
  set query (commandline -ct)

  set path $base/$query
  if ! test -d $path
    set path (dirname $path)
  end

  if echo $query | grep -q /
    find $path -maxdepth 1 -type d ! -path $path | string replace $base/ ""
  else
    find $path -maxdepth 1 -type d ! -path $path | string replace $base/ "" | string replace -r \$ /
  end
end

complete -c gogo -d repository -x -a '(__gogo)'
