NAME = inception

COMPOSE = docker compose -p $(NAME) --env-file srcs/.env -f srcs/docker-compose.yml

all: up

up:
	$(COMPOSE) up --build -d

ps:
	$(COMPOSE) ps

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

fclean:
	$(COMPOSE) down -v --rmi all

re: fclean up

.PHONY: all up down clean fclean re
