#! make

PWD := $(shell pwd)
NOW := $(shell date +%Y%m%d-%H%M%S)

include .env

all: build up
.PHONY: all

build:
	docker build -t bioatlas/geoserver-test:latest .

up:
	@echo "Starting services..."
	@docker-compose up -d

stop:
	@echo "Stopping services..."
	@docker-compose stop

clean:
	docker-compose down

browse:
	firefox http://test.infrabas.se/geoserver &
			
db-shell:
	@docker exec -it geoserver-docker_postgis_1 \
		sh -c "psql -U $(POSTGRES_USER)"

backup:

	mkdir -p backups

	docker run --rm --volumes-from geoserver-docker_geoserver_1 \
		-v $(PWD)/backups:/tmp alpine \
		sh -c "tar czf /tmp/geoserver-files-$(NOW).tgz -C /opt/geoserver/data_dir ./"

	docker exec -t geoserver-docker_postgis_1 bash -c \
		"pg_dumpall -c -U $(POSTGRES_USER)" | gzip > backups/postgis-$(NOW).sql.gz

	cp backups/geoserver-files-$(NOW).tgz backups/geoserver-files-latest.tgz
	cp backups/postgis-$(NOW).sql.gz backups/postgis-latest.sql.gz

restore:

	docker run --rm --volumes-from geoserver-docker_geoserver_1 \
		-v $(PWD)/backups:/tmp alpine \
		sh -c "cd /opt/geoserver/data_dir && tar xvf /tmp/geoserver-files-latest.tgz"

	gunzip -c backups/postgis-latest.sql.gz | docker exec -i geoserver-docker_postgis_1 \
		psql -U $(POSTGRES_USER)

