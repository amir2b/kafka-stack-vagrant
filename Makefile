#!/usr/bin/env make

NODE=kafka1

all: destroy up

clean: destroy
	@rm -f *.log
	@rm -rf .vagrant/

update:
	@echo
	vagrant box update
	@echo
	vagrant plugin update

init:
	@echo
	vagrant plugin install vagrant-env

up:
	@echo
	vagrant up

destroy:
	@echo
	vagrant destroy --force

halt:
	@echo
	vagrant halt

ssh:
	@echo
	vagrant ssh ${NODE}
