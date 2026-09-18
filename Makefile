RED     = \033[0;31m
YELLOW  = \033[0;33m
RESET   = \033[0m

# ========================================================== #

DATA_PATH = $(HOME)/data

all:
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	echo "\n$(RED)===*^* 1. Composition of Docker will launch in ... *^*===$(RESET)\n"; \
	docker compose -f srcs/docker-compose.yml up -d --build
	@if [ -f ./instructions.sh ]; then ./instructions.sh; fi
# REMOVE this last one after DEVELOPPING !!!


rebuild :
	docker compose -f srcs/docker-compose.yml up -d

#### -------- UNMOUNT --------  ####

down:
	docker compose -f srcs/docker-compose.yml down

#### -------- PLAY/PAUSE --------  ####

start:
	docker compose -f srcs/docker-compose.yml start

stop:
	docker compose -f srcs/docker-compose.yml stop


#### -------- DIAGNOSIS --------  ####

check:
check:
	@read -p "Type [log] [status] [volumes] [user] [images] or [versions]: " ans; \
	case "$${ans:-N}" in \
		log) \
			read -p "Type [nginx] [mariadb] or [wp]: " ans; \
			case "$${ans:-N}" in \
				nginx) \
					docker compose -f srcs/docker-compose.yml logs -f nginx ;; \
				wp) \
					docker compose -f srcs/docker-compose.yml logs -f wordpress ;; \
				mariadb) \
					docker compose -f srcs/docker-compose.yml logs -f mariadb ;; \
				*) \
					echo "Unknown option: $${ans}" ;; \
			esac ;; \
		volumes) \
			echo "\n$(RED)=== 1. Named volumes enregistres dans Docker ===$(RESET)\n"; \
			docker volume ls; \
			echo "\n$(RED)=== 2. Point de montage vers l'hote (/home/csimonne/data) ===$(RESET)\n"; \
			docker volume inspect mariadb_data wordpress_data | grep -E "(device|Name)"; \
			echo "\n$(RED)=== 3. Fichiers reels presents sur le disque hote ===\$(RESET)\n"; \
			echo "$(YELLOW)--- MariaDB ---$(RESET)"; \
			ls -la /home/csimonne/data/mariadb; \
			echo "$(YELLOW)--- WordPress ---$(RESET)"; \
			ls -la /home/csimonne/data/wordpress ;; \
		status) \
			docker compose -f srcs/docker-compose.yml ps ;; \
		user) \
			docker exec -it wordpress whoami; \
			docker compose -f srcs/docker-compose.yml exec wordpress wp user list --allow-root --path=/var/www/html ;; \
		images) \
			docker images ;; \
		versions) \
			grep -i "FROM" srcs/requirements/*/Dockerfile ;; \
		*) \
			echo "Unknown option: $${ans}" ;; \
	esac



#### -------- CLEANING --------  ####

#clean:
 #	@read -p : "Are you sure you want to erase all volumes and data ? [y/N]" ans && [ $${ans:-N} = y ]
#	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	docker system prune -af
	sudo rm -rf /home/csimonne/data/mariadb/*
	sudo rm -rf /home/csimonne/data/wordpress/*

re: fclean all

.PHONY: all down start stop clean fclean re