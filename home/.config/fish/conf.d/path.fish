set -gx GOPATH ~/code
if not echo $PATH | grep -q $GOPATH/bin
    set -gx PATH $GOPATH/bin $PATH
end

if command -sq gem
    set -l gem_path (gem env gempath | cut -d: -f1)/bin
    if not echo $PATH | grep -q $gem_path
        set -gx PATH $gem_path $PATH
    end
end
