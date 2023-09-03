WIEN2K_SOURCE ?= WIEN2k_23.2.tar

wien2k:
	cp $(WIEN2K_SOURCE) stack/wien2k
	@source_file=`basename "$$WIEN2K_SOURCE"` ;\
	docker build -t wien2k stack/wien2k --build-arg WIEN2K_SOURCE=$$source_file ;\
	rm stack/wien2k/$$source_file

aiida: wien2k
	docker build -t aiida-wien2k stack/aiida

test-wien2k: wien2k
	@DOCKERID=$$(docker run -d wien2k /bin/bash /home/aiida/wien2k_run/submit.sh) ;\
	docker logs -f $$DOCKERID | tee run.log ;\
	docker cp $$DOCKERID:/home/aiida/wien2k_run .

test-aiida: aiida
	@DOCKERID=$$(docker run -d aiida-wien2k /bin/bash /home/aiida/aiida_run/submit.sh) ;\
	docker logs -f $$DOCKERID | tee run.log ;\
	docker cp $$DOCKERID:/home/aiida/aiida_run .

clean:
	rm -rf run.log aiida_run wien2k_run
