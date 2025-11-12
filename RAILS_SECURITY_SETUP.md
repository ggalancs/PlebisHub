# Rails Security & Performance Setup Guide

## Overview

Este documento describe cómo activar las mejoras de seguridad y rendimiento implementadas en el backend de Rails para PlebisHub.

**Fecha de implementación**: Noviembre 2025
**Gems añadidas**: `rack-attack` (~> 6.7), `redis` (~> 5.0)
**Configuración existente mejorada**: `secure_headers`

---

## Tabla de Contenidos

1. [Cambios Implementados](#cambios-implementados)
2. [Requisitos Previos](#requisitos-previos)
3. [Configuración de Desarrollo](#configuración-de-desarrollo)
4. [Configuración de Producción](#configuración-de-producción)
5. [Verificación](#verificación)
6. [Monitoreo](#monitoreo)
7. [Troubleshooting](#troubleshooting)

---

## Cambios Implementados

### 1. Rate Limiting (Rack::Attack)

**Archivo**: `config/initializers/rack_attack.rb`

Límites configurados:
- **Login por email**: 5 intentos/minuto
- **Login por IP**: 10 intentos/minuto
- **Registro por IP**: 3 intentos/hora
- **SMS validation por IP**: 5 solicitudes/hora
- **Password reset por IP**: 3 intentos/hora
- **Votos por usuario**: 30 votos/minuto
- **Comentarios por usuario**: 10 comentarios/minuto
- **Propuestas por usuario**: 5 propuestas/hora
- **Microcréditos por usuario**: 3 solicitudes/hora
- **Colaboraciones por usuario**: 5 solicitudes/hora
- **API general por IP**: 100 requests/minuto
- **Requests no autenticados por IP**: 20 requests/minuto

### 2. Security Headers (SecureHeaders)

**Archivo**: `config/initializers/secure_headers.rb`

Headers configurados:
- **Content Security Policy (CSP)**: Previene XSS, code injection
- **HSTS**: Fuerza HTTPS en producción
- **X-Frame-Options**: Previene clickjacking
- **X-Content-Type-Options**: Previene MIME sniffing
- **Referrer-Policy**: Controla información de referrer
- **Expect-CT**: Certificate Transparency
- **Cookies seguros**: HttpOnly, Secure, SameSite

### 3. Middleware Configuration

**Archivo**: `config/application.rb`

- Rack::Attack middleware añadido
- SecureHeaders configurado automáticamente

---

## Requisitos Previos

### Desarrollo

- Ruby >= 3.3.6
- Rails ~> 7.2.3
- Bundler

### Producción

- Ruby >= 3.3.6
- Rails ~> 7.2.3
- **Redis** >= 5.0 (para rate limiting distribuido)
- Servidor web con soporte HTTPS (Nginx, Apache, etc.)

---

## Configuración de Desarrollo

### 1. Instalar Dependencias

```bash
bundle install
```

### 2. Verificar Configuración

El entorno de desarrollo usa **memory store** para rate limiting (no requiere Redis).

### 3. Iniciar Servidor

```bash
rails server
# o
bin/dev # si usas Procfile
```

### 4. Verificar Headers

```bash
curl -I http://localhost:3000
```

Deberías ver headers como:
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`
- `X-Frame-Options: SAMEORIGIN`
- `Content-Security-Policy-Report-Only: ...` (modo report-only en desarrollo)

---

## Configuración de Producción

### 1. Instalar y Configurar Redis

#### Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install redis-server

# Iniciar Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Verificar
redis-cli ping
# Respuesta: PONG
```

#### Docker:

```yaml
# docker-compose.yml
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    command: redis-server --appendonly yes

volumes:
  redis-data:
```

#### Redis Cloud / Heroku:

Usar la URL de conexión proporcionada por el servicio.

### 2. Configurar Variable de Entorno

Añadir a `.env` o configuración del servidor:

```bash
# Redis URL para Rack::Attack
REDIS_URL=redis://localhost:6379/0

# Para servicios cloud:
# REDIS_URL=redis://:[password]@[hostname]:[port]/[db]
```

#### En Heroku:

```bash
# Si usas Heroku Redis addon, la variable REDIS_URL se configura automáticamente
heroku addons:create heroku-redis:mini
```

#### En Capistrano:

Añadir a `config/deploy/production.rb`:

```ruby
set :default_env, {
  'REDIS_URL' => 'redis://your-redis-server:6379/0'
}
```

### 3. Configurar HTTPS

Rack::Attack y SecureHeaders funcionan mejor con HTTPS. Asegúrate de que tu servidor web está configurado con SSL/TLS.

#### Nginx ejemplo:

```nginx
server {
    listen 443 ssl http2;
    server_name tudominio.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # Headers adicionales (opcional, Rails ya los envía)
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 4. Desplegar

```bash
# Con Capistrano
cap production deploy

# Manual
bundle install --deployment --without development test
RAILS_ENV=production bundle exec rails assets:precompile
RAILS_ENV=production bundle exec rails server -e production
```

### 5. Verificar en Producción

```bash
# Verificar headers de seguridad
curl -I https://tudominio.com

# Verificar rate limiting
for i in {1..10}; do curl -X POST https://tudominio.com/login -d "email=test@test.com" -d "password=test"; done

# Deberías ver un 429 después de 5 intentos
```

---

## Verificación

### Verificar Rate Limiting

```ruby
# Rails console
Rack::Attack.cache.store.class
# => ActiveSupport::Cache::RedisCacheStore (en producción)
# => ActiveSupport::Cache::MemoryStore (en desarrollo)

# Verificar conexión Redis
Rack::Attack.cache.store.redis.ping
# => "PONG"
```

### Verificar Security Headers

```bash
# Instalar httpie (opcional)
brew install httpie

# Verificar headers
http https://tudominio.com

# O con curl
curl -I https://tudominio.com | grep -E "(Content-Security-Policy|X-Frame-Options|Strict-Transport-Security)"
```

### Test de Rate Limiting

```bash
# Script de prueba
#!/bin/bash
for i in {1..15}; do
  echo "Request $i:"
  curl -X POST http://localhost:3000/login \
    -d "email=test@test.com" \
    -d "password=wrongpassword" \
    -w "\nStatus: %{http_code}\n\n"
  sleep 0.5
done
```

Deberías ver:
- Primeros 5 requests: `200` o `422` (credenciales incorrectas)
- Requests 6-15: `429` (Too Many Requests)

---

## Monitoreo

### Logs de Rate Limiting

Los requests bloqueados se registran en `log/production.log`:

```
[Rack::Attack] throttle 192.168.1.100 /login
[Rack::Attack] throttle 192.168.1.100 /api/proposals
```

### Monitorear con Rails Console

```ruby
# Ver requests rastreados
Rails.cache.redis.keys('rack::attack:*')

# Ver contador de un IP específico
Rack::Attack.cache.read('rack::attack:logins/ip:192.168.1.100')
```

### Integración con Servicios de Monitoreo

#### Airbrake (ya instalado):

Los errores de Rack::Attack se reportan automáticamente a Airbrake.

#### Custom Monitoring:

```ruby
# config/initializers/rack_attack.rb

# Añadir notificaciones personalizadas
ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, payload|
  req = payload[:request]

  if req.env['rack.attack.matched'] == 'logins/ip'
    # Enviar alerta a Slack, Discord, etc.
    # SlackNotifier.send("Rate limit excedido: #{req.ip}")
  end
end
```

---

## Troubleshooting

### Problema: Redis no conecta

**Error**:
```
[Rack::Attack] Failed to connect to Redis: Connection refused
```

**Solución**:
1. Verificar que Redis está corriendo: `redis-cli ping`
2. Verificar REDIS_URL: `echo $REDIS_URL`
3. Verificar firewall/puertos
4. Rack::Attack automáticamente hace fallback a memory store

### Problema: Rate limit muy estricto

**Síntoma**: Usuarios legítimos siendo bloqueados

**Solución**:

Ajustar límites en `config/initializers/rack_attack.rb`:

```ruby
# De:
throttle('logins/email', limit: 5, period: 1.minute)

# A:
throttle('logins/email', limit: 10, period: 1.minute)
```

### Problema: CSP bloqueando recursos

**Síntoma**: Contenido no carga, errores de CSP en consola del navegador

**Solución**:

1. Verificar en modo report-only (desarrollo)
2. Añadir dominio a trusted_src en `config/initializers/secure_headers.rb`:

```ruby
# En config/secrets.yml
production:
  secure_sites:
    - 'https://cdn.example.com'
```

### Problema: HSTS demasiado agresivo

**Síntoma**: No puedes acceder a la app sin HTTPS

**Solución temporal**:

Limpiar HSTS en navegador:
- Chrome: `chrome://net-internals/#hsts` → Delete domain
- Firefox: Limpiar historial de seguridad

**Solución permanente**:

Configurar SSL/TLS correctamente antes de habilitar HSTS.

---

## Configuraciones Adicionales

### Whitelist de IPs

Para permitir ciertos IPs sin rate limiting:

```ruby
# config/initializers/rack_attack.rb

# Whitelist de IPs
safelist('allow_admin_ips') do |req|
  admin_ips = ['123.456.789.0', '98.76.54.32']
  admin_ips.include?(req.ip)
end
```

### Custom Throttles

Para añadir nuevos límites:

```ruby
# Limitar creación de tickets de soporte
throttle('support/user', limit: 5, period: 1.day) do |req|
  if req.path == '/support/tickets' && req.post?
    req.env['warden']&.user&.id
  end
end
```

### Desactivar Temporalmente

```ruby
# config/environments/production.rb

# Desactivar Rack::Attack completamente
config.middleware.delete Rack::Attack

# O desactivar solo throttling
# En config/initializers/rack_attack.rb
Rack::Attack.enabled = false
```

---

## Comandos Útiles

```bash
# Ver todas las gemas de seguridad instaladas
bundle list | grep -E "(rack-attack|secure_headers|redis)"

# Limpiar cache de rate limiting (desarrollo)
rails runner "Rack::Attack.cache.store.clear"

# Ver configuración actual de Rack::Attack
rails runner "puts Rack::Attack.cache.store.inspect"

# Reiniciar Redis
sudo systemctl restart redis-server

# Ver logs de Redis
sudo journalctl -u redis-server -f
```

---

## Referencias

- [Rack::Attack Documentation](https://github.com/rack/rack-attack)
- [SecureHeaders Documentation](https://github.com/github/secure_headers)
- [Redis Documentation](https://redis.io/documentation)
- [OWASP Security Headers](https://owasp.org/www-project-secure-headers/)
- [Content Security Policy Guide](https://content-security-policy.com/)

---

## Notas Finales

- ✅ Rate limiting activo en todos los entornos
- ✅ Security headers configurados con mejores prácticas
- ✅ Redis opcional (fallback a memory store)
- ✅ Compatible con arquitectura distribuida (múltiples servidores)
- ✅ Logs detallados para debugging
- ✅ Integración con frontend (CSP headers coherentes)

**Próximos pasos sugeridos**:

1. Monitorear logs durante 1 semana
2. Ajustar límites según patrones reales de uso
3. Implementar endpoint de reportes CSP: `/api/csp-violations`
4. Considerar añadir Rack::Throttle para límites más granulares
5. Implementar fail2ban para bloqueos a nivel de firewall

---

**Documento actualizado**: Noviembre 12, 2025
**Autor**: Claude Code Review System
**Versión**: 1.0
