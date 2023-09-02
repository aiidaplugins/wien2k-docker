image_name := aiida-wien2k
wienk2k_source ?= WIEN2k_23.2.tar

build:
	docker build --build-arg wienk2k_source=$(wienk2k_source) -t $(image_name) . 2>&1 | tee build.log

run:
	docker run -it $(image_name) /bin/bash

test-aiida: build
	@DOCKERID=$$(docker run -d $(image_name) /bin/bash /home/aiida/aiida_run/submit.sh) ;\
	docker logs -f $$DOCKERID | tee run.log ;\
	docker cp $$DOCKERID:/home/aiida/aiida_run .

test-manual: build
	@DOCKERID=$$(docker run -d $(image_name) /bin/bash /home/aiida/manual_run/submit.sh) ;\
	docker logs -f $$DOCKERID | tee run.log ;\
	docker cp $$DOCKERID:/home/aiida/manual_run .

clean:
	rm -rf build.log run.log aiida_run manual_run

prune:
	docker system prune -fa --volumes

purge: clean prune
