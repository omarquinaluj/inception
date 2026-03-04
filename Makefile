NAME = inception

all: up

up:
	docker compose -f docker-compose.yml up --build -d

down:
	docker compose -f docker-compose.yml down

clean:
	docker compose -f docker-compose.yml down -v

fclean:
	docker compose -f docker-compose.yml down -v --rmi all

re: fclean up

.PHONY: all up down clean fclean re