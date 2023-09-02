image_name := aiida-wien2k

build:
	docker build -t $(image_name) . 2>&1 | tee build.log

run:
	docker run -it $(image_name) /bin/bash

test: build
	@DOCKERID=$$(docker run -d $(image_name) /bin/bash /home/aiida/testrun/submit.sh) ;\
	docker logs -f $$DOCKERID | tee run.log ;\
	docker cp $$DOCKERID:/home/aiida/testrun .

clean:
	rm -rf build.log run.log testrun

prune:
	docker system prune -fa --volumes

purge: clean prune

