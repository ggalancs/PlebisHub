# PlebisHub - Configuración para Desarrollo Local

## Cambios Realizados para Desarrollo Local

Este documento describe los cambios realizados para facilitar el desarrollo local de PlebisHub con PostgreSQL.

### ✅ Problemas Resueltos

1. **Base de datos en desarrollo**: Cambiada de SQLite a PostgreSQL para mantener consistencia entre todos los entornos
2. **Configuración faltante**: Creado `config/database.yml` con configuración completa
3. **Variables de entorno**: Creado `.env.development` con todas las variables necesarias
4. **Tests de integración**: Suite completa de tests con Selenium WebDriver

## Configuración de Base de Datos

### Cambios en `config/database.yml`

Se ha creado el archivo `config/database.yml` configurado para usar **PostgreSQL en todos los entornos**:

- **Development**: `plebishub_development`
- **Test**: `plebishub_test`
- **Production**: Usa `DATABASE_URL` desde variables de entorno

La configuración soporta variables de entorno para facilitar el uso con Docker o servicios locales.

### Cambios en `Gemfile`

Se ha comentado la dependencia de `sqlite3` para evitar conflictos:

```ruby
# gem 'sqlite3', '~> 1.4' # REMOVED: Always use PostgreSQL for consistency
```

## Configuración de Desarrollo

### Opción 1: Usando Docker (Recomendado)

```bash
# 1. Iniciar servicios (PostgreSQL + Redis)
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d db redis

# 2. Verificar que los servicios están corriendo
docker compose ps

# 3. Cargar variables de entorno
export $(cat .env.development | grep -v '^#' | xargs)

# 4. Instalar dependencias
bundle install

# 5. Crear y migrar base de datos
bundle exec rails db:create db:migrate

# 6. (Opcional) Cargar datos de semilla
bundle exec rails db:seed

# 7. Iniciar servidor
bundle exec rails server
```

La aplicación estará disponible en: http://localhost:3000

### Opción 2: Servicios Locales

Si prefieres usar PostgreSQL y Redis instalados localmente:

```bash
# 1. Asegurar que PostgreSQL está corriendo
sudo service postgresql start
pg_isready -h localhost -p 5432

# 2. Asegurar que Redis está corriendo
sudo service redis-server start
redis-cli ping

# 3. Cargar variables de entorno
export $(cat .env.development | grep -v '^#' | xargs)

# 4. Ejecutar script de setup
./bin/setup-dev

# 5. Iniciar servidor
bundle exec rails server
```

### Script de Setup Automatizado

Se ha creado `bin/setup-dev` que automatiza:
- Verificación de PostgreSQL y Redis
- Instalación de dependencias
- Creación y migración de base de datos
- Carga opcional de datos de semilla

```bash
./bin/setup-dev
```

## Tests con Selenium WebDriver

### Suite de Tests Creada

Se ha creado una suite completa de tests de integración usando Selenium WebDriver que cubre:

1. **User Journey** (`test/integration/user_journey_test.rb`)
   - Registro de usuarios
   - Login
   - Navegación completa

2. **Microcredit Flow** (`test/integration/microcredit_flow_test.rb`)
   - Información de microcréditos
   - Registro para microcréditos
   - Provincias y municipios

3. **Collaborations Flow** (`test/integration/collaborations_flow_test.rb`)
   - Creación de colaboraciones
   - Colaboraciones recurrentes y puntuales

4. **Impulsa Flow** (`test/integration/impulsa_flow_test.rb`)
   - Creación de proyectos
   - Navegación por pasos
   - Evaluación

5. **Voting Flow** (`test/integration/voting_flow_test.rb`)
   - Verificación SMS
   - Verificación de identidad

6. **User Profile** (`test/integration/user_profile_test.rb`)
   - Gestión de perfil
   - Cambio de contraseña
   - QR digital
   - Logout

### Ejecutar Tests

```bash
# Preparar base de datos de test
RAILS_ENV=test bundle exec rails db:create db:migrate

# Ejecutar todos los tests de Selenium
bundle exec rails test test/integration/

# Ejecutar tests en modo headless (sin interfaz gráfica)
HEADLESS=true bundle exec rails test test/integration/

# Ejecutar un test específico
bundle exec rails test test/integration/user_journey_test.rb
```

### Requisitos para Tests

1. **ChromeDriver** o **GeckoDriver** instalado:

```bash
# Ubuntu/Debian
sudo apt-get install chromium-browser chromium-chromedriver

# macOS
brew install --cask google-chrome
brew install chromedriver
```

2. **PostgreSQL y Redis** corriendo

Ver documentación completa en: `test/integration/README_SELENIUM_TESTS.md`

## Estructura de Archivos Creados/Modificados

```
PlebisHub/
├── config/
│   └── database.yml                    # ✅ CREADO - Configuración de PostgreSQL
├── .env.development                     # ✅ CREADO - Variables de entorno
├── bin/
│   └── setup-dev                       # ✅ CREADO - Script de setup automatizado
├── test/
│   ├── support/
│   │   └── selenium_helper.rb          # ✅ CREADO - Helper para Selenium
│   └── integration/
│       ├── README_SELENIUM_TESTS.md    # ✅ CREADO - Documentación de tests
│       ├── user_journey_test.rb        # ✅ CREADO - Tests de journey completo
│       ├── microcredit_flow_test.rb    # ✅ CREADO - Tests de microcréditos
│       ├── collaborations_flow_test.rb # ✅ CREADO - Tests de colaboraciones
│       ├── impulsa_flow_test.rb        # ✅ CREADO - Tests de Impulsa
│       ├── voting_flow_test.rb         # ✅ CREADO - Tests de votaciones
│       └── user_profile_test.rb        # ✅ CREADO - Tests de perfil
├── Gemfile                             # ✅ MODIFICADO - Eliminado sqlite3
└── DEVELOPMENT_SETUP.md                # ✅ CREADO - Este documento

```

## Variables de Entorno

El archivo `.env.development` incluye:

```bash
# PostgreSQL
POSTGRES_DB=plebishub_development
POSTGRES_TEST_DB=plebishub_test
POSTGRES_USER=postgres
POSTGRES_PASSWORD=changeme
POSTGRES_HOST=localhost
POSTGRES_PORT=5432

# Redis
REDIS_URL=redis://:changeme@localhost:6379/0

# Rails
SECRET_KEY_BASE=development_secret_key_base_please_change_in_production
RAILS_ENV=development

# Application
APP_PORT=3000
```

## Comandos Útiles

### Base de Datos

```bash
# Crear base de datos
bundle exec rails db:create

# Ejecutar migraciones
bundle exec rails db:migrate

# Rollback última migración
bundle exec rails db:rollback

# Resetear base de datos
bundle exec rails db:drop db:create db:migrate db:seed

# Consola de Rails con acceso a BD
bundle exec rails console

# Consola de PostgreSQL
psql -h localhost -U postgres -d plebishub_development
```

### Servidor

```bash
# Servidor de desarrollo (Rails default)
bundle exec rails server

# Con Puma (configurado)
bundle exec puma -C config/puma.rb

# Con Unicorn (configurado para staging/production)
bundle exec unicorn -c config/unicorn.rb
```

### Tests

```bash
# Todos los tests
bundle exec rails test

# Solo tests de integración
bundle exec rails test test/integration/

# Test específico
bundle exec rails test test/integration/user_journey_test.rb

# Con cobertura (SimpleCov)
COVERAGE=true bundle exec rails test
```

### Docker

```bash
# Iniciar todos los servicios
docker compose -f docker-compose.yml -f docker-compose.dev.yml up

# Solo base de datos y Redis
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d db redis

# Ver logs
docker compose logs -f app

# Parar servicios
docker compose down

# Limpiar volúmenes
docker compose down -v
```

## Troubleshooting

### Error: Database does not exist

```bash
bundle exec rails db:create
```

### Error: Pending migrations

```bash
bundle exec rails db:migrate
```

### Error: Connection refused to PostgreSQL

Verificar que PostgreSQL está corriendo:

```bash
# Con Docker
docker compose ps

# Servicio local
sudo service postgresql status
pg_isready -h localhost -p 5432
```

### Error: Redis connection error

Verificar que Redis está corriendo:

```bash
# Con Docker
docker compose ps

# Servicio local
redis-cli ping
```

### Error: Bundle install fails

```bash
# Limpiar cache de bundler
rm -rf .bundle vendor/bundle
bundle install

# Si persiste, verificar versión de Ruby
ruby -v  # Debe ser >= 3.3.6
```

## Próximos Pasos

1. ✅ Configuración de PostgreSQL completada
2. ✅ Tests de Selenium creados
3. ✅ Documentación actualizada
4. 🔄 Ejecutar aplicación y verificar errores
5. 🔄 Ejecutar suite de tests completa
6. 🔄 Configurar CI/CD con tests automatizados

## Contacto y Soporte

Para problemas o preguntas sobre el setup de desarrollo:
- Ver issues en GitHub
- Consultar documentación de Rails 7.2
- Revisar logs en `log/development.log`

---

**Última actualización**: 2025-11-13
**Versión de Rails**: 7.2.3
**Versión de Ruby**: 3.3.6+
