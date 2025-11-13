# Selenium WebDriver Integration Tests

## Descripción

Suite completa de tests de integración usando Selenium WebDriver que cubre todas las pantallas y flujos principales de usuario en PlebisHub.

## Estructura de Tests

### 1. User Journey Tests (`user_journey_test.rb`)
Tests del flujo completo del usuario:
- Registro de nuevos usuarios
- Login y autenticación
- Navegación por todas las secciones principales
- Acceso al dashboard

### 2. Microcredit Flow Tests (`microcredit_flow_test.rb`)
Tests de funcionalidad de microcréditos:
- Visualización de información de microcréditos
- Registro para microcréditos (usuario autenticado)
- Carga de provincias y municipios
- Navegación por campañas de microcréditos

### 3. Collaborations Flow Tests (`collaborations_flow_test.rb`)
Tests de colaboraciones/donaciones:
- Acceso a página de colaboraciones
- Visualización de colaboración existente
- Colaboración puntual/única
- Gestión de colaboraciones recurrentes

### 4. Impulsa Flow Tests (`impulsa_flow_test.rb`)
Tests de proyectos Impulsa:
- Acceso a página de Impulsa
- Creación de proyectos
- Navegación por pasos del proyecto
- Página de evaluación

### 5. Voting Flow Tests (`voting_flow_test.rb`)
Tests de votaciones y verificación:
- Verificación SMS
- Verificación de identidad
- Acceso a votaciones

### 6. User Profile Tests (`user_profile_test.rb`)
Tests de gestión de perfil:
- Visualización de perfil
- Actualización de datos
- Cambio de contraseña
- Código QR digital
- Logout

## Configuración

### Requisitos Previos

1. **PostgreSQL** debe estar ejecutándose
2. **Redis** debe estar ejecutándose (para tests de background jobs)
3. **ChromeDriver** o **GeckoDriver** (Firefox) instalado

### Variables de Entorno

```bash
# Modo headless (sin interfaz gráfica) - ideal para CI/CD
export HEADLESS=true

# Host y puerto de la aplicación
export APP_HOST=http://localhost:3000
export APP_PORT=3000

# Base de datos de test
export POSTGRES_TEST_DB=plebishub_test
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD=changeme
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432
```

## Ejecución de Tests

### Preparación

```bash
# 1. Asegurar que PostgreSQL y Redis están corriendo
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d db redis

# O si tienes servicios locales:
sudo service postgresql start
sudo service redis-server start

# 2. Configurar base de datos de test
RAILS_ENV=test bundle exec rails db:create db:migrate

# 3. Cargar variables de entorno
export $(cat .env.development | grep -v '^#' | xargs)
```

### Ejecutar Todos los Tests de Selenium

```bash
# Con interfaz gráfica (ver el navegador)
bundle exec rails test test/integration/

# En modo headless (sin interfaz gráfica)
HEADLESS=true bundle exec rails test test/integration/

# Test específico
bundle exec rails test test/integration/user_journey_test.rb

# Test específico con un solo test
bundle exec rails test test/integration/user_journey_test.rb::<nombre_del_test>
```

### Ejecutar Tests con Diferentes Navegadores

```bash
# Chrome (por defecto)
bundle exec rails test test/integration/

# Firefox (modificar en selenium_helper.rb)
# Cambiar: Capybara.default_driver = :selenium_firefox
```

## Características del Helper de Selenium

El archivo `test/support/selenium_helper.rb` proporciona:

### Configuración de Drivers
- **Chrome**: Headless y normal
- **Firefox**: Headless y normal
- Configuración automática según variables de entorno

### Métodos Útiles

```ruby
# Esperar por un elemento
wait_for_element('.mi-clase', timeout: 10)

# Esperar carga completa de página
wait_for_page_load

# Capturar screenshot en caso de error
take_screenshot('nombre_test')

# Aceptar alerta si existe
accept_alert_if_present

# Log de pasos del test
log_step('Descripción del paso')
```

## Screenshots

Los screenshots de errores se guardan automáticamente en:
```
tmp/screenshots/
```

Formato: `nombre_test_YYYYMMDD_HHMMSS.png`

## Debugging

### Ver el Test en Ejecución

```bash
# Quitar el modo headless
unset HEADLESS
bundle exec rails test test/integration/user_journey_test.rb
```

### Pausar Test para Inspeccionar

Agregar en el test:
```ruby
binding.pry  # Si usas pry
# o
debugger     # Debugger nativo de Ruby
```

### Aumentar Timeout

```ruby
# En el test
Capybara.default_max_wait_time = 30  # segundos
```

## Troubleshooting

### Error: Chrome/ChromeDriver no encontrado

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install chromium-browser chromium-chromedriver

# macOS
brew install --cask google-chrome
brew install chromedriver
```

### Error: PostgreSQL connection refused

```bash
# Verificar que PostgreSQL está corriendo
pg_isready -h localhost -p 5432

# Si no está corriendo
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d db
```

### Error: Database already exists

```bash
# Resetear base de datos de test
RAILS_ENV=test bundle exec rails db:drop db:create db:migrate
```

### Error: FactoryBot no encuentra factories

```bash
# Verificar que las factories existen
ls test/factories/

# Si no hay factory para User, crear una básica
# Ver: test/factories/users.rb
```

## Mejores Prácticas

1. **Siempre usar `wait_for_page_load`** después de navegación
2. **Usar `log_step`** para trackear progreso del test
3. **Capturar screenshots** en caso de fallo
4. **Tests independientes**: Cada test debe poder ejecutarse solo
5. **Limpieza**: Usar `teardown` para limpiar estado
6. **Datos únicos**: Usar timestamp en emails de test

## CI/CD Integration

Ejemplo para GitHub Actions:

```yaml
name: Selenium Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: changeme
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.3.6
          bundler-cache: true

      - name: Setup Chrome
        uses: browser-actions/setup-chrome@latest

      - name: Setup Database
        env:
          RAILS_ENV: test
          POSTGRES_HOST: localhost
          POSTGRES_PASSWORD: changeme
        run: |
          bundle exec rails db:create db:migrate

      - name: Run Selenium Tests
        env:
          HEADLESS: true
          RAILS_ENV: test
        run: |
          bundle exec rails test test/integration/

      - name: Upload Screenshots
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: test-screenshots
          path: tmp/screenshots/
```

## Mantenimiento

### Actualizar Selenium WebDriver

```bash
bundle update selenium-webdriver
```

### Actualizar ChromeDriver

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install --only-upgrade chromium-chromedriver

# macOS
brew upgrade chromedriver
```

## Contribuir

Para agregar nuevos tests:

1. Crear archivo en `test/integration/`
2. Heredar de `ActionDispatch::IntegrationTest`
3. Incluir `Capybara::DSL` y `SeleniumHelper`
4. Implementar `setup` y `teardown`
5. Usar `log_step` para documentar pasos
6. Capturar screenshots en errores

## Soporte

Para problemas o preguntas sobre los tests de Selenium, consultar:
- Documentación de Capybara: https://github.com/teamcapybara/capybara
- Documentación de Selenium: https://www.selenium.dev/documentation/
- Issues del proyecto: [GitHub Issues]
