image: ## to build a docker image.
	@echo "$(WARN_COLOR)$(MSG_PREFIX) Creating Docker Image $(MSG_SUFFIX)$(NO_COLOR)"
	@$(DOCKER) build ${DOCKER_BUILD_FLAGS} -t $(REGISTRY_REPO):$(DOCKER_TAG) -f $(DOCKER_FILE) $(args)

deploy: ## to deploy a docker container.
	@echo "$(WARN_COLOR)$(MSG_PREFIX) Deploying Docker Container $(MSG_SUFFIX)$(NO_COLOR)"
	@$(SUDO) bash ./deploy.sh $(args)

publish: ## to publish the docker image to dockerhub repository.
	@echo "$(WARN_COLOR)$(MSG_PREFIX) Pushing Docker Image to $(REGISTRY_REPO):$(DOCKER_TAG) $(MSG_SUFFIX)$(NO_COLOR)"
	@$(DOCKER) push $(REGISTRY_REPO):$(DOCKER_TAG)
