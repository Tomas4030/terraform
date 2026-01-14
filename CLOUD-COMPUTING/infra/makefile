init:
	terraform init 

workspace:
	terraform workspace new xiaomi

plan:
	terraform plan -out k8s.plan -var-file=xiaomi.tfvars

apply:
	terraform apply k8s.plan