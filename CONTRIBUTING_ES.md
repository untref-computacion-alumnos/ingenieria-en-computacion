# Cómo contribuir

Español · [English](CONTRIBUTING.md)

Gracias por colaborar. Esta guía describe cómo viaja el trabajo desde una
historia de usuario hasta `main`. Las instrucciones de instalación están en el
[README](README_ES.md).

## El flujo en resumen

1. Tomá una historia del tablero (columna `Ready`) y pasala a `In progress`.
   Mantené una sola historia en progreso a la vez.
2. Creá tu rama desde un `main` actualizado.
3. Escribí los escenarios `.feature`, después los specs y por último el código.
4. Ejecutá `bin/dc bin/ci` hasta que pase.
5. Abrí un pull request y completá la plantilla.
6. Resolvé los comentarios de la revisión, conseguí una aprobación e integrá.

## Ramas

| Rama   | Propósito                             |
| ------ | ------------------------------------- |
| `main` | Integración; todos los PR apuntan acá |
| `test` | Staging; se promueve desde `main`     |
| `prod` | Producción; se promueve desde `test`  |

`main`, `test` y `prod` están protegidas: sin push directo, sin force push y
sin borrado. Nombrá tus ramas de trabajo según la historia, por ejemplo
`us-012-registro-de-estudiantes`, en minúsculas.

## Proceso de desarrollo

Seguimos BDD con TDD adentro:

1. **Aceptación**: escribí o actualizá los escenarios Gherkin en `features/`.
   Tienen que ser legibles para quien no programa y pasar `cuke_linter`.
2. **Rojo**: escribí un ejemplo de RSpec que falle para el próximo
   comportamiento pequeño.
3. **Verde**: escribí el código más simple que lo haga pasar.
4. **Refactor**: limpiá con los tests en verde.
5. Repetí hasta que los escenarios pasen.

Convenciones:

- Sin texto de interfaz escrito a mano: usá I18n (`config/locales/`).
  `i18n-tasks health` debe pasar y el locale por defecto es `es-AR`.
- La autorización va en políticas de Pundit; testealas con `pundit-matchers`.
- Preferí ViewComponents chicos antes que parciales grandes.
- Mantené las migraciones reversibles y no edites una que ya fue integrada.
- Los secretos nunca van en git; usá las credenciales de Rails y los secrets
  de GitHub.

## Commits

Cada mensaje de commit sigue el formato `tipo(us-NN): descripción`:

```text
feat(us-012): add student signup form
fix(us-015): handle empty course list
docs(us-020): explain how to run Cucumber
```

Tipos aceptados: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`,
`build`, `perf`, `style` y `revert`. `us-NN` es el número de la historia, en
minúsculas. También se aceptan los mensajes que genera git para merges
(`Merge ...`) y reverts (`Revert "..."`). commitlint rechaza cualquier otro, en local a través de Lefthook y en CI sobre
los pull requests (reglas en `.commitlintrc.yml`; instalalo una vez con
`npm install -g @commitlint/cli`).
Hacé commits enfocados y escribí la descripción en imperativo (en inglés, como
el resto del historial).

Si tu rama empieza con el id de una historia (`us-012-registro`), Lefthook
completa el mensaje con `(us-012):`. Escribí el tipo antes del paréntesis y la
descripción después. No hace nada con `-m`, merges ni amends.

### Identidad del autor

Los commits tienen que mostrar tu nombre y apellido reales, no un usuario.
Configuralo una sola vez:

```bash
git config user.name "Nombre Apellido"
git config user.email "vos@ejemplo.com"
```

Lefthook rechaza el commit si `user.name` es una sola palabra. Si alguien ya
commiteó con otro nombre o email, agregá una línea a `.mailmap` para que las
herramientas del historial muestren a una sola persona:

```text
Nombre Apellido <vos@ejemplo.com> usuario-viejo <email.viejo@ejemplo.com>
```

Verificalo con `git shortlog -sne`. GitHub ignora `.mailmap`: agrupa a los
autores por email, así que agregá a tu cuenta de GitHub todos los emails con
los que commiteás.

## Chequeos de calidad

```bash
bin/dc bin/ci
```

`bin/ci` ejecuta `bin/lint`, `bin/security`, `bin/advisory` y `bin/test`; cada
uno se puede correr por separado.

Son los mismos comandos que corre el CI: RuboCop, ERB Lint, markdownlint,
yamllint, cuke_linter, i18n-tasks, Brakeman, bundler-audit, RSpec, Cucumber y
el umbral de cobertura. Reek y Rails Best Practices son solo informativos.
Instalá los hooks de Git una vez con `bundle exec lefthook install`.

## Pull requests

- Título: `tipo(us-NN): resumen corto`, como un commit.
- Enlazá la historia y completá todos los ítems del checklist de la plantilla.
- Mantené los PR chicos y enfocados; separá los cambios no relacionados.
- Los jobs de CI `lint`, `security` y `test` deben pasar.
- Se requiere una aprobación, las aprobaciones viejas se descartan con commits
  nuevos y todas las conversaciones deben quedar resueltas.
- Integrá con **merge commit** (squash y rebase están deshabilitados). La rama
  se borra después del merge.

### Revisión

- Verificá el comportamiento contra los criterios de aceptación de la historia.
- Buscá tests faltantes, texto escrito a mano, consultas N+1 y huecos de
  autorización.
- Sé específico y amable; proponé cambios en lugar de solo marcar problemas.

## Definición de terminado

Una historia está terminada cuando:

- [ ] Los escenarios `.feature` pasan
- [ ] Se agregaron ejemplos de RSpec (rojo → verde → refactor)
- [ ] Los linters están limpios (`bin/dc bin/ci`)
- [ ] La cobertura es al menos 90 % y Brakeman y bundler-audit están limpios
- [ ] No hay texto de interfaz escrito a mano (I18n)
- [ ] La documentación está actualizada

Más detalle en [definition-of-done.md](docs/process/definition-of-done.md).

## Reportar problemas

Abrí un issue en GitHub con lo que esperabas, lo que pasó y los pasos para
reproducirlo. Si es un problema de seguridad, no abras un issue público:
contactá directamente a quienes mantienen el proyecto.
