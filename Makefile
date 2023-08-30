test: 
	docker build -t aiida-wien2k . 2>&1 | tee build.log
	@DOCKERID=$$(docker run -d aiida-wien2k /bin/bash); \
	docker logs -f $$DOCKERID ; \
	docker cp $$DOCKERID:/home/aiida/testrun .

clean:
	rm -rf build.log testrun
