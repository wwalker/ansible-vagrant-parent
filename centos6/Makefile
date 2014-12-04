aping:
	ansible all -m ping

ansible:
	ansible-playbook -v -f 4 playbook.yml

fsdock:
	sudo docker build -t naelyn/fileserve .

fsrun:
	sudo docker run -d --net=host -v $(PWD)/data:/data naelyn/fileserve

.PHONY: aping ansible fsdock fsrun
