PGUSER ?= lopocs

.PHONY: dump
dump: lopocs.dump

lopocs.dump:
	pg_dump -F custom -d lopocs -U lopocs -f lopocs.dump

.PHONY: list
list: lopocs.list

lopocs.list: lopocs.dump
	pg_restore -l $< > $@

.PHONY: pull
pull:
	docker pull elemoine/pointcloud

.PHONY: run
run:
	docker run --name pointcloud -p 9999:5432 -d elemoine/pointcloud

.PHONY: restore
restore: lopocs.dump
	pg_restore -F custom -c -C -O --if-exists -L lopocs.list -U postgres -h localhost -p 9999 -d template1 $<

.PHONY: psql
psql:
	psql -U postgres -h localhost -p 9999 -d lopocs

.PHONY: stop
stop:
	docker stop pointcloud && docker rm pointcloud

clean:
	rm -f lopocs.dump
	rm -f lopocs.list
