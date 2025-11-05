# Guía para Actualizar Screenshots de PlebisHub

## 📸 Objetivo

Reemplazar las capturas de pantalla antiguas del sistema "Participa" con nuevas capturas que reflejen el branding de **PlebisHub** y **PlebisBrand**.

## 🎯 Estado Actual

Durante el proceso de rebranding de "Participa/Podemos" a "PlebisHub/PlebisBrand", se renombraron los archivos de imágenes:

- ~~`participa01.png`~~ → `plebishub01.png`
- ~~`participa02.png`~~ → `plebishub02.png`
- ~~`participa03.png`~~ → `plebishub03.png`

**Importante**: Estos archivos PNG contienen capturas del sistema ANTERIOR y aún muestran branding de "Podemos" y "Participa".

## ✅ Checklist de Actualización

### Antes de capturar las pantallas:

- [ ] Asegúrate de que la aplicación está ejecutándose con el rebranding completo
- [ ] Verifica que no hay referencias visuales a "Podemos" o "Participa"
- [ ] Confirma que el branding "PlebisHub" y "PlebisBrand" es visible
- [ ] Limpia datos de prueba que no deban ser públicos

### Screenshots requeridos:

#### 1. plebishub01.png - Pantalla Principal
- **Dimensiones recomendadas**: 986 x 687 px (o similar)
- **Debe mostrar**:
  - Header con logo/nombre "PlebisHub"
  - Navegación principal
  - Sección hero o página de inicio
  - Branding claro y visible

#### 2. plebishub02.png - Funcionalidad Clave #1
- **Dimensiones recomendadas**: 1172 x 671 px (o similar)
- **Opciones de contenido**:
  - Sistema de votaciones
  - Colaboraciones económicas
  - Microcréditos
  - Panel de usuario
- **Debe mostrar**: Funcionalidad representativa de la plataforma

#### 3. plebishub03.png - Funcionalidad Clave #2
- **Dimensiones recomendadas**: 1055 x 683 px (o similar)
- **Opciones de contenido**:
  - Iniciativas ciudadanas
  - Equipos de participación
  - Panel administrativo
  - Otra funcionalidad destacada

## 🛠️ Proceso de Captura

### 1. Preparar el Entorno

```bash
# Asegúrate de estar en un ambiente limpio
cd /path/to/PlebisHub
bundle install
rails db:seed  # Si hay seeds actualizadas

# Inicia el servidor
rails server
```

### 2. Capturar Screenshots

**Recomendaciones técnicas**:
- Usa resolución nativa (no zoom del navegador)
- Captura en un navegador moderno (Chrome, Firefox)
- Modo normal (no incógnito, para tener sesión activa si es necesario)
- Limpia la caché del navegador antes de capturar

**Herramientas sugeridas**:
- **Linux**: `gnome-screenshot`, `scrot`, `flameshot`
- **macOS**: `⌘ + Shift + 4`
- **Windows**: `Win + Shift + S`
- **Extensiones**: Full Page Screenshot (Chrome/Firefox)

### 3. Editar y Optimizar

```bash
# Opcional: Optimizar tamaño de las imágenes
# Usando ImageMagick (si está instalado)
convert plebishub01.png -quality 85 -strip plebishub01_optimized.png

# Usando pngcrush
pngcrush -brute plebishub01.png plebishub01_optimized.png
```

### 4. Reemplazar Archivos

```bash
# Navega al directorio de imágenes
cd doc/images/

# Haz backup de las imágenes antiguas (opcional)
mkdir -p old_screenshots
mv plebishub0*.png old_screenshots/

# Copia las nuevas capturas
cp /path/to/new/plebishub01.png .
cp /path/to/new/plebishub02.png .
cp /path/to/new/plebishub03.png .

# Verifica los tamaños
ls -lh plebishub*.png
```

### 5. Actualizar Referencias (si es necesario)

Si cambias las dimensiones significativamente, puede que necesites ajustar referencias en:
- `README.md`
- Documentación adicional
- `doc/images/README.md`

### 6. Commit y Push

```bash
# Añadir las nuevas imágenes
git add doc/images/plebishub*.png

# Eliminar placeholders SVG si ya no son necesarios
git rm doc/images/plebishub*_placeholder.svg

# Commit con mensaje descriptivo
git commit -m "Update screenshots with PlebisHub branding

- Replace old Participa screenshots with new PlebisHub captures
- Screenshots now show updated branding throughout
- Images reflect current state of the application"

# Push a tu branch
git push origin <tu-branch>
```

## 📋 Verificación Final

Antes de considerar la tarea completa, verifica:

- [ ] Los 3 archivos PNG están actualizados
- [ ] No hay referencias visuales al branding anterior
- [ ] Las imágenes se ven correctamente en el README
- [ ] El tamaño de los archivos es razonable (< 500KB cada uno)
- [ ] Las imágenes son claras y profesionales
- [ ] Los placeholders SVG han sido eliminados (opcional)

## 🎨 Sugerencias de Estilo

Para mantener consistencia visual:

1. **Usa el mismo navegador** para todas las capturas
2. **Misma resolución de pantalla** si es posible
3. **Similar nivel de zoom**
4. **Datos de ejemplo consistentes** (mismo usuario, fechas similares)
5. **Modo claro/oscuro consistente** (elige uno y úsalo en todas)

## 🆘 Solución de Problemas

### Las imágenes son muy grandes
```bash
# Redimensionar manteniendo proporción
convert input.png -resize 1200x800 output.png

# Reducir calidad
convert input.png -quality 80 output.png
```

### No puedo ejecutar la aplicación
- Verifica que completaste el rebranding
- Revisa `bundle install`
- Chequea configuración de base de datos
- Consulta `README.md` para instrucciones de instalación

### Aún veo referencias al branding antiguo
- Ejecuta `git pull` para obtener últimos cambios del rebranding
- Limpia caché del navegador
- Reinicia el servidor Rails

## 📞 Contacto

Si tienes dudas sobre qué capturas tomar o necesitas ayuda, contacta al equipo de desarrollo.

---

**Última actualización**: Durante el rebranding Podemos/Participa → PlebisBrand/PlebisHub
