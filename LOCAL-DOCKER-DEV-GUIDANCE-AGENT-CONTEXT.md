# Local Development with Docker

## Goals

1. To have `Dockerfile.dev` and `docker-compose.dev.yml` files that enable Ruby on Rails development completely in Docker.
1. The developer should be able to run commands such as `bin/rails s` and `bin/rails c`, `bin/rspec `; ideally, we should have some containers that run in `RAILS_ENV=development` and `RAILS_ENV=test`.
1. Some of the database config and other related files were copied from another project, but we need to change this project to use sqlite
1. We shouldn't need any config to AWS, for example, but that might change in the future; for now, I don't think we need any references to AWS in the Docker files.

## Important Details for the compose file:

I'm not sure if sqlite needs database user, password, name, port, host, etc, or if we even need a service for it in Docker. I'm relying on the Copilot Agent for guidance on this.

We need the following ENV variables:

- ${RAILS_ENV}
- DOCKER_CONTAINER: true

## Definition of Done:

1. Successful build of the image from a Dockerfile.dev
1. Successful execution of `docker compose up` using our `docker-compose.dev.yml`
1. This Rails app is reconfigured to use SQLITE
1. A user can `docker exec -it <app_name> /bin/bash` to enter:

- A container in `development` environment and execute `bin/rails s`, `bin/rails c`.
- A container in `test` environment and execute `bin/rspec`
