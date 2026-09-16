all:
	@mkdir -p /home/csimonne/data/mariadb
	@mkdir -p /home/csimonne/data/wordpress
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down

start:
	docker compose -f srcs/docker-compose.yml start

stop:
	docker compose -f srcs/docker-compose.yml stop

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	docker system prune -af
	sudo rm -rf /home/csimonne/data/mariadb/*
	sudo rm -rf /home/csimonne/data/wordpress/*

re: fclean all

.PHONY: all down start stop clean fclean re