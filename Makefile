#! make

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


