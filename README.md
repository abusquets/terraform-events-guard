# terraform-events-guard


# Terraform

```
terraform apply -var="enable_k3s_setup=false"
terraform apply -var="enable_k3s_setup=true"
```


## Tips

Force apply ressource

```
terraform apply -var="enable_k3s_setup=true" -replace="null_resource.k3s_setup_kubectl_ingress[0]"
```