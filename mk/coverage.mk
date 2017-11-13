# Goveralls dependency
GOVERALLS_BIN := $(GOPATH)/bin/goveralls
GOVERALLS := $(shell [ -x $(GOVERALLS_BIN) ] && echo $(GOVERALLS_BIN) || echo '')

cover: $(COVERAGE_PROFILE) ## to run test with coverage and report that out to profile.

coverage-html: $(COVERAGE_HTML) ## to export coverage results to html format"$(COVERAGE_PATH)/index.html".
	@open "$(COVERAGE_HTML)"

# Send the results to coveralls
coverage-send: $(COVERAGE_PROFILE)
	@$(if $(GOVERALLS), , $(error Please install goveralls: go get github.com/mattn/goveralls))
	@$(GOVERALLS) -service travis-ci -coverprofile="$(COVERAGE_PROFILE)"

coverage-serve: $(COVERAGE_HTML) ## to serve coverage results over http - useful only if building remote/headless
	@cd "$(COVERAGE_PATH)" && python -m SimpleHTTPServer 8000

# Clean up coverage output.
clean-coverage: ## to clean coverage generated files.
	@echo "$(WARN_COLOR)$(MSG_PREFIX) Cleaning up coverage generated files $(MSG_SUFFIX)$(NO_COLOR)"
	@rm -Rf "$(COVERAGE_PATH)"

$(COVERAGE_PROFILE):
	@echo "$(WARN_COLOR)$(MSG_PREFIX) Coverage check $(MSG_SUFFIX)$(NO_COLOR)"
	@if [ ! -d $(COVERAGE_PATH) ] ; then mktemp -d $(COVERAGE_PATH) ; fi
	@$(GO) test -cover -parallel $(PARALLEL_TESTS) -timeout $(TEST_TIMEOUT) -covermode=$(COVERAGE_MODE) -coverprofile $(COVERAGE_PATH)/app.part $(GO_FLAGS) ./app
	@$(GO) test -cover -parallel $(PARALLEL_TESTS) -timeout $(TEST_TIMEOUT) -covermode=$(COVERAGE_MODE) -coverprofile $(COVERAGE_PATH)/handlers.part $(GO_FLAGS) ./handlers
	@$(GO) test -cover -parallel $(PARALLEL_TESTS) -timeout $(TEST_TIMEOUT) -covermode=$(COVERAGE_MODE) -coverprofile $(COVERAGE_PATH)/persistence.part $(GO_FLAGS) ./persistence
	@echo "mode: $(COVERAGE_MODE)" > $(COVERAGE_PROFILE)
	@grep -h -v "mode: $(COVERAGE_MODE)" $(COVERAGE_PATH)/*.part >> "$(COVERAGE_PROFILE)"

$(COVERAGE_HTML): $(COVERAGE_PROFILE)
	@echo "$(WARN_COLOR)$(MSG_PREFIX) Coverage web view export $(MSG_SUFFIX)$(NO_COLOR)"
	@if [ ! -d $(COVERAGE_PATH) ] ; then $(MAKE) $(COVERAGE_PATH) ; fi
	@$(GO) tool cover  -html="$(COVERAGE_PROFILE)" -o "$(COVERAGE_HTML)" $(GO_FLAGS)
