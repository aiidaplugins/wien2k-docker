WIEN2K_SOURCE ?= WIEN2k_23.2.tar

wien2k:
	cp $(WIEN2K_SOURCE) stack/wien2k
	docker build -t wien2k stack/wien2k --build-arg wien2k_source=$(WIEN2K_SOURCE)
	rm stack/wien2k/$(WIEN2K_SOURCE)

aiida:
	cp $(WIEN2K_SOURCE) stack/wien2k
	WIEN2K_SOURCE=$(WIEN2K_SOURCE) docker-compose -f stack/docker-compose.yaml up -d
	rm stack/wien2k/$(WIEN2K_SOURCE)

run-wien2k:
	docker run -it wien2k /bin/bash

run-aiida:
	docker run -it aiida-wien2k /bin/bash

test-wien2k: wien2k
	@DOCKERID=$$(docker run -d wien2k /bin/bash /home/aiida/wien2k_run/submit.sh) ;\
	docker logs -f $$DOCKERID | tee run.log ;\
	docker cp $$DOCKERID:/home/aiida/wien2k_run .

test-aiida: aiida
	@DOCKERID=$$(docker exec -d aiida-wien2k /bin/bash /home/aiida/aiida_run/submit.sh) ;\
	docker logs -f $$DOCKERID | tee run.log ;\
	docker cp $$DOCKERID:/home/aiida/aiida_run .

clean:
	rm -rf build.log run.log aiida_run wien2k_run
