# Ingeniería en Computación

Español · [English](README.md)

Aplicación web de la carrera de Ingeniería en Computación, construida con Ruby
on Rails. El trabajo se guía por historias de usuario (`US-XXX`) y se entrega
mediante pull requests pequeños y testeados.

## Stack

| Área                 | Herramientas                                             |
| -------------------- | -------------------------------------------------------- |
| Lenguaje / framework | Ruby 4.0.9, Rails 8.1                                    |
| Base de datos        | PostgreSQL 17 (Solid Queue, Cache y Cable en producción) |
| Front end            | Hotwire, Tailwind CSS 4 + daisyUI, ViewComponent         |
| Autenticación        | Devise, Pundit, Rolify                                   |
| Tests                | RSpec, Cucumber, Capybara + Cuprite, SimpleCov           |
| Linters              | RuboCop, ERB Lint, markdownlint, yamllint, cuke_linter   |
| Análisis             | i18n-tasks, Reek, Rails Best Practices                   |
| Seguridad            | Brakeman, bundler-audit                                  |
| Herramientas         | Docker Compose, Lefthook, GitHub Actions                 |

## Requisitos

Recomendado (Docker):

- Git
- Docker con Compose v2

Opcional, para trabajar sin Docker:

- [mise](https://mise.jdx.dev) (o rbenv/asdf) con el Ruby de `.ruby-version`
- PostgreSQL y sus librerías cliente (`libpq`)
- Node LTS (markdownlint, commitlint) y `yamllint`

## Primeros pasos

### Con Docker (recomendado)

```bash
git clone git@github.com:<org>/<repo>.git

cd ingenieria-en-computacion

docker compose up --build
```

| Servicio                                  | URL                     |
| ----------------------------------------- | ----------------------- |
| Aplicación                                | <http://localhost:3000> |
| Mailpit (emails capturados en desarrollo) | <http://localhost:8025> |

El contenedor `web` instala las gemas, prepara la base de datos
(`bin/rails db:prepare`) y ejecuta `bin/dev` (Puma + watcher de Tailwind).

Ejecutá cualquier comando dentro del contenedor con `bin/dc`:

```bash
bin/dc bin/rails console

bin/dc bin/rails db:migrate

bin/dc bundle exec rspec
```

### Sin Docker

```bash
mise install            # Ruby según mise.toml / .ruby-version

bundle install

bin/rails db:prepare

bin/dev
```

Anteponé `LOCAL=1` a los comandos de `bin/dc` para correrlos sin Docker.

## Configuración

| Variable       | Valor por defecto                  | Para qué sirve                          |
| -------------- | ---------------------------------- | --------------------------------------- |
| `DB_HOST`      | `localhost` (`db` en Compose)      | Host de PostgreSQL                      |
| `DB_USER`      | `postgres`                         | Usuario de PostgreSQL                   |
| `DB_PASSWORD`  | `postgres`                         | Contraseña de PostgreSQL                |
| `SMTP_HOST`    | `localhost` (`mailpit` en Compose) | Servidor SMTP (dev)                     |
| `COVERAGE_MIN` | `90`                               | Cobertura mínima (`bin/coverage-check`) |

Los secretos nunca van en git: usá las credenciales de Rails y los secrets de
GitHub.

## Base de datos

```bash
bin/dc bin/rails db:prepare   # crea, migra y siembra si hace falta

bin/dc bin/rails db:reset     # elimina y recrea (solo en desarrollo)
```

## Tests y chequeos de calidad

```bash
bin/dc bundle exec rspec      # specs unitarios / de request / componentes

bin/dc bundle exec cucumber   # escenarios de aceptación (features/)

bin/dc bin/ci                 # todo lo que corre el CI: linters, seguridad,
                              # specs, escenarios y cobertura (≥ 90 %)
```

Lefthook corre los linters (sobre todo el proyecto) al hacer commit, valida
el nombre del autor, completa el scope de la historia en el mensaje a partir
del nombre de la rama, valida el mensaje, y ejecuta los tests RSpec (`bin/ci-quick`) al hacer
push. Corré `bin/dc bin/ci` a mano antes del último push de una historia.
Los hooks corren en tu máquina, no en el contenedor. Instalalos una sola
vez con `bundle exec lefthook install`.

## Servicios

- **PostgreSQL**: base de datos principal.
- **Mailpit**: servidor SMTP de prueba para los emails de desarrollo.
- **Solid Queue / Cache / Cable**: jobs en segundo plano, caché y Action Cable
  sobre la base de datos (bases separadas en producción).

## Despliegue

Ramas: `main` (integración), `test` (staging) y `prod` (producción). Las tres
están protegidas: los cambios llegan solo mediante pull requests con el CI en
verde y una aprobación, integrados con merge commit. El hosting todavía está
por definirse; la decisión se registrará en `CLAUDE.md`.

## Documentación

- [Guía de contribución](CONTRIBUTING_ES.md)
- [Guía de armado del esqueleto](docs/skeleton.md)
- [Historias de usuario](user-stories/README.md)
- [Documentos de proceso](docs/process/definition-of-done.md)
- [CLAUDE.md](CLAUDE.md): convenciones para personas y asistentes de IA
