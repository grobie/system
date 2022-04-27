function terraform-switch --argument-names env
    if test -z "$env"
        echo "usage: "(status current-function)" <environment>" >&2
        return 1
    end
    set workspace (echo "$env" | sed s/production/default/)
    set config "$env.tfvars"
    echo "Switching to Terraform workspace $workspace (env: $env)" >&2
    if ! terraform workspace select "$workspace" >/dev/null
        return 1
    end
    if [ ! -f "$config" ]
        echo "No $config config file available" >&2
        return 0
    end
    for setting in $(tr -d ' ' < "$config" | tr -d ' "')
        export TF_VAR_$setting
    end
end
