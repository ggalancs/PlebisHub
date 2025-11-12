# 🎨 PlebisHub Brand Assets

Este directorio contiene todos los assets de marca de PlebisHub.

## 📁 Contenido

### Logos SVG

- **`logo-horizontal.svg`** - Logo completo horizontal (ícono + texto)
  - Uso: Headers, presentaciones, documentos
  - Dimensiones: 260×64px

- **`logo-vertical.svg`** - Logo vertical (ícono arriba, texto abajo)
  - Uso: Espacios estrechos, perfiles sociales
  - Dimensiones: 180×140px

- **`logo-mark.svg`** - Solo ícono
  - Uso: Favicon, app icon, avatares
  - Dimensiones: 64×64px

- **`logo-type.svg`** - Solo texto
  - Uso: Títulos, cuando el ícono ya está presente
  - Dimensiones: 180×48px

- **`logo-monochrome.svg`** - Versión monocromática
  - Uso: Impresión B&N, documentos oficiales
  - Color: #1a1a1a

- **`logo-inverted.svg`** - Versión para fondos oscuros
  - Uso: Dark mode, fondos oscuros
  - Colores claros: #c491cd, #5eead4

## 🎨 Colores de Marca

**Primary (Morado):**
- `#612d62` - Color principal

**Secondary (Verde/Teal):**
- `#269283` - Color secundario

Ver paleta completa en [BRAND_IDENTITY_GUIDE.md](../../../../../BRAND_IDENTITY_GUIDE.md)

## 📖 Documentación

Para directrices completas de uso, consultar:
- [Guía de Identidad Visual](../../../../../BRAND_IDENTITY_GUIDE.md)
- [Documento para Diseñador Principal](../../../../../DOCUMENTO_DISEÑADOR_PRINCIPAL_V2.md)

## 🔧 Uso en Vue

```vue
<script setup>
import Logo from '@/components/atoms/Logo.vue'
</script>

<template>
  <!-- Logo horizontal -->
  <Logo variant="horizontal" size="lg" />

  <!-- Logo vertical -->
  <Logo variant="vertical" size="md" />

  <!-- Solo ícono -->
  <Logo variant="mark" size="md" />

  <!-- Solo texto -->
  <Logo variant="type" size="md" />

  <!-- Monocromático -->
  <Logo variant="horizontal" theme="monochrome" />

  <!-- Invertido (fondo oscuro) -->
  <Logo variant="horizontal" theme="inverted" />

  <!-- Con colores personalizados -->
  <Logo
    variant="horizontal"
    :custom-colors="{
      primary: '#1e40af',
      secondary: '#0891b2'
    }"
  />
</template>
```

## 📦 Exportación

Los assets SVG pueden usarse directamente en web. Para otros formatos:

**PNG (para redes sociales, etc):**
- Usar herramientas como Inkscape, Figma, o servicios online
- Tamaños recomendados:
  - Favicon: 32×32px, 64×64px, 128×128px
  - App Icon iOS: 1024×1024px
  - App Icon Android: 512×512px
  - Twitter Avatar: 400×400px
  - Facebook Avatar: 180×180px

## ⚠️ Importante

- NO modificar estos archivos sin autorización del equipo de diseño
- Mantener proporciones originales (no distorsionar)
- Usar variante correcta según el fondo (claro/oscuro)
- Respetar espacios mínimos alrededor del logo

## 📞 Contacto

**Equipo de Diseño:**
- Email: design@plebishub.com
- Slack: #design-system

---

**Última actualización:** 12 de Noviembre de 2025
