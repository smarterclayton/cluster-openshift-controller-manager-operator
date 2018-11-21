IMAGE ?= docker.io/openshift/origin-cluster-openshift-controller-manager-operator
TAG ?= latest
PROG  := cluster-openshift-controller-manager-operator
GOFLAGS :=

all: build build-image verify
.PHONY: all
build:
	go build $(GOFLAGS) ./cmd/cluster-openshift-controller-manager-operator
.PHONY: build

image:
	docker build -t "$(IMAGE):$(TAG)" .
.PHONY: build-image

test: test-unit test-e2e
.PHONY: test

test-unit:
ifndef JUNITFILE
	go test $(GOFLAGS) -race ./...
else
ifeq (, $(shell which gotest2junit 2>/dev/null))
$(error gotest2junit not found! Get it by `go get -u github.com/openshift/release/tools/gotest2junit`.)
endif
	GOCACHE=off go test $(GOFLAGS) -race -json ./... | gotest2junit > $(JUNITFILE)
endif
.PHONY: test-unit

test-e2e:
	GOCACHE=off go test -v ./test/e2e/...
.PHONY: test-e2e
	
verify: verify-govet
	hack/verify-gofmt.sh
	hack/verify-codegen.sh
	hack/verify-generated-bindata.sh
.PHONY: verify

verify-govet:
	go vet $(GOFLAGS) ./...
.PHONY: verify-govet

clean:
	rm -- "$(PROG)"
.PHONY: clean
