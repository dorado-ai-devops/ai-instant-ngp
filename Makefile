IMAGE_NAME     := nerf-trainer
VERSION        := v3.0.3
REGISTRY       := localhost:5000
HELM_VALUES    := ../devops-ai-lab/manifests/helm-instant-ngp/values.yaml
ARGO_APP_NAME  := nerf-trainer

.PHONY: all build tag push update-values release run

all: release

build:
	docker build  -t $(IMAGE_NAME):$(VERSION) .

tag: build
	docker tag $(IMAGE_NAME):$(VERSION) $(REGISTRY)/$(IMAGE_NAME):$(VERSION)

push: tag
	docker push $(REGISTRY)/$(IMAGE_NAME):$(VERSION)

update-values:
	@echo "Actualizando Helm values para $(IMAGE_NAME)…"
	sed -i "/^image:/,/^resources:/ s|^\(\s*repository:\s*\).*|\1$(REGISTRY)/$(IMAGE_NAME)|" $(HELM_VALUES)
	sed -i "/^image:/,/^resources:/ s|^\(\s*tag:\s*\).*|\1\"$(VERSION)\"|" $(HELM_VALUES)

release: push update-values
	@echo "Release completo: $(REGISTRY)/$(IMAGE_NAME):$(VERSION) desplegado y sincronizado con ArgoCD."

run:
	docker run --rm \
		-v $(PWD)/data:/data \
		--gpus all \
		$(IMAGE_NAME):$(VERSION)
