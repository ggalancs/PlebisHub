# DOCUMENTO MAESTRO PARA DISEÑADOR PRINCIPAL
## Análisis Profundo y Plan de Rediseño del Front-End de PlebisHub

**Versión:** 1.0
**Fecha:** 11 de Noviembre de 2025
**Preparado para:** Diseñador Principal del Proyecto
**Preparado por:** Análisis Técnico Front-End Team

---

## ÍNDICE

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Identidad Visual Actual](#identidad-visual-actual)
3. [Análisis de Experiencia de Usuario (UX)](#análisis-ux)
4. [Sistema de Diseño Propuesto](#sistema-de-diseño)
5. [Paleta de Colores y Theming](#paleta-colores)
6. [Tipografía y Jerarquía Visual](#tipografía)
7. [Componentes y Patrones UI](#componentes-ui)
8. [Diseño Responsive y Mobile-First](#diseño-responsive)
9. [Personalización Extrema del Sistema](#personalización)
10. [Guía de Implementación Visual](#guía-implementación)
11. [Herramientas y Assets Recomendados](#herramientas)
12. [Plan de Trabajo y Timeline](#plan-trabajo)

---

## 1. RESUMEN EJECUTIVO {#resumen-ejecutivo}

### Contexto del Proyecto

PlebisHub es una plataforma de participación ciudadana con **8 módulos principales**:
- **Propuestas** - Iniciativas ciudadanas
- **Impulsa** - Crowdfunding de proyectos
- **Microcréditos** - Sistema de préstamos comunitarios
- **Votaciones** - Sistema electoral digital
- **Colaboraciones** - Donaciones recurrentes
- **Verificación** - Validación de identidad
- **CMS** - Gestión de contenidos
- **Participación** - Equipos de trabajo

### Estado Actual del Diseño

**Stack Tecnológico Visual:**
- Bootstrap 3.4.1 (obsoleto - versión de 2014)
- Sistema de grid personalizado
- Font Awesome 4.7 (iconografía)
- Montserrat como tipografía principal
- 4,849 líneas de CSS/SCSS custom
- Paleta corporativa: Morado (#612d62) + Verde (#269283)

**Problemas Identificados:**
1. ❌ Bootstrap 3 está desactualizado (11 años)
2. ❌ Diseño no mobile-first (responsive añadido después)
3. ❌ Inconsistencias visuales entre módulos
4. ❌ No existe un Design System formal
5. ❌ Paleta de colores hardcodeada (no personalizable)
6. ❌ Componentes no reutilizables
7. ❌ Iconografía mezclada (Font Awesome + imágenes PNG)
8. ❌ Falta de guías de estilo documentadas

### Objetivo del Rediseño

**Crear un sistema de diseño moderno, escalable y extremadamente personalizable que:**

✅ Permita cambiar toda la identidad visual desde un panel admin
✅ Sea 100% responsive y mobile-first
✅ Tenga componentes reutilizables y documentados
✅ Soporte múltiples temas (light/dark/custom)
✅ Sea accesible (WCAG 2.1 AA)
✅ Mejore la experiencia de usuario en un 300%
✅ Reduzca el tiempo de carga en un 50%

---

## 2. IDENTIDAD VISUAL ACTUAL {#identidad-visual-actual}

### 2.1 Análisis de la Marca

**Nombre de Marca:** PlebisBrand (customizable)
**Sector:** Tecnología cívica / Participación ciudadana
**Tono:** Democrático, transparente, moderno, accesible
**Target:** Ciudadanos de 18-65 años, diversos backgrounds

### 2.2 Paleta de Colores Actual

#### Colores Primarios (Morado)
```css
Purple Main:        #612d62   RGB(97, 45, 98)    - Fondos principales
Purple Intermediate: #954e99   RGB(149, 78, 153)  - Elementos interactivos
Purple Light:       #c3a6cf   RGB(195, 166, 207) - Fondos claros
Purple 60%:         #9c76a3   RGB(156, 118, 163) - Variante
```

**Uso actual:**
- Fondo del header
- Botones primarios
- Títulos y headings
- Enlaces hover
- Bordes de elementos activos

**Análisis:**
- ✅ Buena elección para sector institucional
- ✅ Contraste adecuado con blanco
- ❌ Puede resultar "pesado" en grandes áreas
- ❌ Poca diferenciación entre variantes

#### Colores Secundarios (Verde)
```css
Green Intermediate: #269283   RGB(38, 146, 131)  - Enlaces y acciones
Green Light:        #97c2b8   RGB(151, 194, 184) - Botones secundarios
```

**Uso actual:**
- Enlaces de texto
- Botones de acción secundaria
- Indicadores de éxito
- Progress bars

**Análisis:**
- ✅ Complementa bien al morado
- ✅ Transmite confianza y acción
- ❌ Solo dos variantes (poco flexible)

#### Colores de Sistema
```css
Alert Red:          #f5bfc9   RGB(245, 191, 201) - Errores
Alert Green:        #d0e0c9   RGB(208, 224, 201) - Éxito
Alert Highlight:    #DCF1DC   RGB(220, 241, 220) - Destacados
Secondary Grey:     #999999   RGB(153, 153, 153) - Texto secundario
Form Background:    #eaeaea   RGB(234, 234, 234) - Inputs
Text Color:         #333333   RGB(51, 51, 51)    - Texto principal
Border Light:       #d7cad8   RGB(215, 202, 216) - Bordes
```

**Problemas detectados:**
1. ❌ Rojo de error demasiado suave (baja urgencia visual)
2. ❌ Verde de éxito similar al secundario (confusión)
3. ❌ Gris secundario poco accesible (#999 sobre blanco = 2.8:1, necesita 4.5:1)
4. ❌ Falta de variantes dark/light para cada color

### 2.3 Tipografía Actual

#### Fuente Principal: Montserrat

```css
Font Family: 'Montserrat', Arial, sans-serif
Pesos usados: 400 (Regular), 700 (Bold)
Cargada desde: Google Fonts
```

**Uso:**
- Headings (h1-h6)
- Navegación
- Botones
- Énfasis (em.plebisbrand)

**Análisis:**
- ✅ Excelente legibilidad
- ✅ Moderna y limpia
- ✅ Buenas proporciones
- ❌ Solo 2 pesos (limitado para jerarquía)
- ❌ Falta de fuente para body text (usa fallback)

#### Fuente Secundaria: Helvetica Neue / Sistema

```css
Font Family: "Helvetica Neue", Helvetica, Arial, sans-serif
Uso: Textos de párrafo, formularios
```

**Análisis:**
- ✅ Segura (sistema)
- ❌ Inconsistente entre sistemas (no es web font)
- ❌ Puede verse diferente en Windows/Mac/Linux

#### Tamaños de Fuente

**Base:** 62.5% (equivalente a 10px) - después ajusta en em

**Escalas usadas:**
```css
Móvil:
  - Body: 1.2em (12px)
  - H1: 1.6em (16px)
  - H2: 1.4em (14px)
  - Buttons: 1.2em (12px)

Tablet (600-768px):
  - Body: 1.3-1.4em
  - H1: 1.8em
  - H2: 1.5em

Desktop (769px+):
  - Body: 1.4-1.6em
  - H1: 2.4em
  - H2: 2em

Desktop XL (978px+):
  - Body: 1.8em
  - H1: 3em
  - H2: 2.4em
```

**Problemas:**
1. ❌ No sigue una escala tipográfica estándar (no es modular)
2. ❌ Saltos inconsistentes entre breakpoints
3. ❌ Muchos overrides específicos (difícil de mantener)
4. ❌ No usa sistema de line-height consistente

### 2.4 Iconografía

**Sistema Actual:**

1. **Font Awesome 4.7.0**
   - Versión: 2017 (8 años desactualizada)
   - Iconos usados: ~30 diferentes
   - Implementación: `fa_icon` helper de Rails

2. **Imágenes PNG custom**
   - `ico.menu-*.png`
   - `ico.social*.png`
   - `ico.proposal-*.png`
   - `ico.ropes-purple.png` (decorativo recurrente)
   - `ico.alert-*.png`

**Problemas:**
1. ❌ Font Awesome 4 obsoleto (ahora va por v6.5)
2. ❌ Mix de iconos vectoriales + bitmap (inconsistente)
3. ❌ PNGs no escalables (problemas en retina)
4. ❌ Sin sistema unificado de iconografía
5. ❌ Iconos custom no son reutilizables

### 2.5 Componentes Visuales Actuales

#### Elementos Identificados

**1. Botones**
```css
Tipos:
  - .button (primario verde claro)
  - .button:hover (verde oscuro)
  - .button-danger (rojo)

Estilo:
  - Padding: 1em 3em
  - Border-radius: 3px
  - Text-transform: uppercase
  - Sin sombras
```

**Problemas:**
- ❌ Solo 2 variantes (primario + peligro)
- ❌ Falta botón secundario, ghost, outline
- ❌ Estados inconsistentes (active, disabled)
- ❌ No responsive (tamaño fijo)

**2. Cajas de Información**
```css
Tipos:
  - .box-info (morado claro, información)
  - .box-ko (rojo, error)
  - .box-ok (verde, éxito)
  - .box-notif (morado, notificación)

Características:
  - Padding: 1.5em 3em
  - Icon: Imagen PNG posicionada absolutamente
  - Decoración: "ico.ropes-purple.png" en esquina
```

**Problemas:**
- ❌ Iconos bitmap no escalables
- ❌ Cierre con imagen (debería ser SVG/icon)
- ❌ Decoración "ropes" no semántica
- ❌ No adaptativo al contenido

**3. Formularios**
```css
Campos:
  - Background: #eaeaea (gris)
  - Border: none
  - Padding: 0.85em 1.5%
  - Labels: Morado (#612d62)

Layout:
  - Móvil: 100% width (vertical)
  - Desktop: 32% label + 63% input (horizontal)
```

**Problemas:**
- ❌ Sin estados de foco claros
- ❌ No hay feedback visual de validación inline
- ❌ Formtastic genera markup pesado
- ❌ Select2 con estilos custom difícil de mantener

**4. Navegación**

**Header:**
```
Desktop: Logo (left) + Menú horizontal (right)
Mobile: Logo + Hamburger (Sidr panel)
```

**Problemas:**
- ❌ Menú hamburger con Sidr.js (librería obsoleta)
- ❌ No es sticky (desaparece al scroll)
- ❌ Items de menú pequeños en mobile
- ❌ Sin indicador de página activa claro

**5. Cards/Propuestas**
```css
Estructura:
  - Imagen (si existe)
  - Autor + fecha
  - Título (h2)
  - Descripción truncada
  - Botón de acción
  - Indicadores (tiempo, apoyos)
```

**Problemas:**
- ❌ No es un componente reusable
- ❌ Layout rígido (no adaptable)
- ❌ Imágenes sin lazy loading
- ❌ Truncado de texto con CSS puro (no accesible)

**6. Pasos (Wizard)**
```css
Diseño: 3 pasos horizontales con flechas
Estados: normal, active
Responsive: En mobile solo muestra números
```

**Problemas:**
- ❌ Hardcoded para 3 pasos
- ❌ Flechas con imágenes background
- ❌ Mobile UX pobre (pierde contexto)

**7. Tablas**
```css
.table-collaborations
  - Sin bordes externos
  - Header con border-bottom
  - Texto morado
  - No responsive (overflow horizontal)
```

**Problemas:**
- ❌ No stackeable en mobile
- ❌ Sin ordenamiento visual
- ❌ No paginación clara

### 2.6 Layouts y Grid System

**Sistema Actual:**

**Grid Personalizado (NO Bootstrap estándar):**
```css
Clases custom:
  .col-h-4a12      (horizontal 4 a 12)
  .col-bhome-1a6   (bootstrap home 1 a 6)
  .col-b-4a12      (bootstrap 4 a 12)
  .col-f-1a3       (footer 1 a 3)
  .col-xs-3/4/5    (extra small)
```

**Breakpoints:**
```css
0-459px:    Móvil pequeño
460-600px:  Móvil grande
600-768px:  Tablet
769-977px:  Desktop
978px+:     Desktop XL
```

**Problemas:**
1. ❌ Nombres de clase no semánticos ("col-h-4a12"?)
2. ❌ Breakpoints inconsistentes con estándares
3. ❌ Muchos overrides específicos por layout
4. ❌ No usa variables (hardcoded)
5. ❌ Difícil de extender o modificar

### 2.7 Assets Visuales

**Imágenes Encontradas:**

1. **Logos**
   - `logo.plebisbrand-220-p.png` (220px PNG)
   - `logo.podemos-220-p.png`
   - `admin_logo.png` (ActiveAdmin)

2. **Backgrounds**
   - `bg.*.png` (fondos de pasos, decorativos)
   - `img.gente.jpg` (foto hero home)

3. **Iconos**
   - ~20 archivos `ico.*.png`
   - Tamaños inconsistentes
   - No retina-ready (@2x)

4. **User Verification**
   - `nie-sample2.png`
   - `pasaporte-sample1.png`
   - Ejemplos para usuarios

5. **Defaults**
   - `author-default.png` (avatar placeholder)
   - `proposal-example.jpg`

**Problemas:**
1. ❌ Todos PNG (sin SVG)
2. ❌ No optimizados (sin WebP)
3. ❌ Sin CDN
4. ❌ Sin lazy loading
5. ❌ Tamaños fijos (no responsive images)

### 2.8 Animaciones y Microinteracciones

**Estado Actual: MÍNIMAS**

**Animaciones encontradas:**
```css
1. Bootstrap component-animations (modals, dropdowns)
2. Progress bar transitions (CSS)
3. Turbolinks page transitions (automático)
4. jQuery fadeOut/fadeIn en algunos elementos
```

**NO hay:**
- ❌ Transiciones en hover (botones, links)
- ❌ Loading states (spinners)
- ❌ Skeleton loaders
- ❌ Animaciones de entrada de elementos
- ❌ Feedback visual de acciones (clicks)
- ❌ Scroll animations

**Impacto UX:**
- Aplicación se siente "estática"
- No hay feedback inmediato de interacciones
- Cambios de estado abruptos

---

## 3. ANÁLISIS DE EXPERIENCIA DE USUARIO (UX) {#análisis-ux}

### 3.1 User Journey Mapping

#### Persona 1: Ciudadano Nuevo

**Objetivo:** Apoyar una propuesta

**Journey Actual:**
```
1. Landing page → Login/Registro
   PROBLEMA: Login en sidebar poco visible

2. Registro multistep (3 pasos)
   PROBLEMA: Muchos campos obligatorios, frustrante

3. Verificación email
   PROBLEMA: No hay feedback de email enviado

4. Página propuestas
   PROBLEMA: Muchas opciones, filtros no claros

5. Detalle propuesta
   PROBLEMA: Botón "Apoyar" poco prominente

6. Confirmación
   OK: Mensaje de éxito claro

FRICCIÓN TOTAL: 7/10 (ALTA)
TIEMPO PROMEDIO: 8-12 minutos
ABANDONO ESTIMADO: 60%
```

#### Persona 2: Usuario Recurrente

**Objetivo:** Crear un proyecto en Impulsa

**Journey Actual:**
```
1. Login
   OK: Rápido si recuerda credenciales

2. Navegación a Impulsa
   PROBLEMA: No está en menú principal, hay que buscar

3. Wizard multistep (5-7 pasos)
   PROBLEMA: No se puede guardar borrador
   PROBLEMA: Si hay error, pierdes datos

4. Upload de archivos
   PROBLEMA: Interfaz confusa, no drag-and-drop claro

5. Revisión
   PROBLEMA: No hay preview antes de enviar

6. Espera aprobación admin
   OK: Notificación clara

FRICCIÓN TOTAL: 6/10 (MEDIA-ALTA)
TIEMPO PROMEDIO: 20-30 minutos
ABANDONO ESTIMADO: 40%
```

#### Persona 3: Administrador

**Objetivo:** Revisar colaboraciones

**Journey Actual:**
```
1. Login admin
   OK: Panel ActiveAdmin funcional

2. Navegación a Collaborations
   OK: Menú claro

3. Filtrado y búsqueda
   PROBLEMA: Filtros limitados
   PROBLEMA: No hay export masivo fácil

4. Revisión individual
   OK: Vista detallada completa

5. Acción (aprobar/rechazar)
   PROBLEMA: No hay acciones masivas

6. Notificación a usuario
   OK: Automático

FRICCIÓN TOTAL: 4/10 (MEDIA)
TIEMPO PROMEDIO: 2-3 min/colaboración
```

### 3.2 Análisis de Pantallas Clave

#### Home Page (Logged Out)

**Layout:**
```
+----------------------------------+
| Header (logo + hamburger)        |
+----------------------------------+
| Hero con imagen de fondo         |
| + Texto intro                    |
| + Botón CTA                      |
+----------------------------------+
| Login sidebar (derecha)          |
+----------------------------------+
| Footer                           |
+----------------------------------+
```

**Problemas UX:**
1. ❌ Hero text difícil de leer sobre imagen
2. ❌ Login sidebar no es evidente en mobile
3. ❌ No hay propuesta de valor clara (¿qué puedo hacer aquí?)
4. ❌ CTA genérico ("Regístrate") sin contexto
5. ❌ No hay prueba social (números, testimonios)
6. ❌ Mucho scroll hasta contenido útil

**Mejoras Necesarias:**
- ✅ Hero con overlay para legibilidad
- ✅ Value proposition en 5 segundos
- ✅ CTA específicos por acción ("Apoya una propuesta", "Crea un proyecto")
- ✅ Sección de stats (X propuestas, Y usuarios, Z proyectos)
- ✅ Login modal en lugar de sidebar

#### Página de Propuestas

**Layout:**
```
+----------------------------------+
| Header + Nav                     |
+----------------------------------+
| Título + Filtros (tabs)          |
+----------------------------------+
| Lista de propuestas (grid 3 col) |
| [Card] [Card] [Card]             |
| [Card] [Card] [Card]             |
+----------------------------------+
| Sidebar: "Propuestas candentes"  |
+----------------------------------+
| Paginación                       |
+----------------------------------+
```

**Problemas UX:**
1. ❌ Filtros como tabs (poco escalable)
2. ❌ No hay búsqueda por texto
3. ❌ Cards muy simples (falta info clave)
4. ❌ Sidebar distractor (rompe foco)
5. ❌ No hay ordenamiento (más apoyadas, recientes)
6. ❌ Paginación clásica (no infinite scroll)

**Mejoras Necesarias:**
- ✅ Filtros avanzados (sidebar o panel)
- ✅ Búsqueda prominente
- ✅ Cards con más info visual (progreso, tiempo)
- ✅ Quitar sidebar o hacerlo colapsable
- ✅ Ordenamiento claro
- ✅ Infinite scroll + skeleton loaders

#### Detalle de Propuesta

**Layout:**
```
+----------------------------------+
| Header + Nav                     |
+----------------------------------+
| [Container 74%]    [Sidebar 24%] |
| - Autor                          |
| - Fecha                          |
| - Imagen                         |
| - Descripción          - Stats   |
| - Apoyos               - Tiempo  |
|                        - Botón   |
+----------------------------------+
```

**Problemas UX:**
1. ❌ Botón "Apoyar" solo en sidebar (no mobile-friendly)
2. ❌ Descripción no formateada (texto plano largo)
3. ❌ Sin sección de comentarios/discusión
4. ❌ No hay forma de compartir (social)
5. ❌ Stats poco visuales (solo números)
6. ❌ No hay related proposals

**Mejoras Necesarias:**
- ✅ Sticky CTA button (scroll)
- ✅ Rich text formatting para descripción
- ✅ Sección de comentarios/Q&A
- ✅ Share buttons prominentes
- ✅ Progress bar visual para apoyos
- ✅ "También te puede interesar" section

#### Wizard de Impulsa

**Layout:**
```
+----------------------------------+
| Header + Nav                     |
+----------------------------------+
| [Steps vertical]    [Form]       |
| 1. Datos básicos    [Campos]     |
| 2. Presupuesto      ...          |
| 3. Documentos                    |
| 4. etc.            [Siguiente]   |
+----------------------------------+
```

**Problemas UX:**
1. ❌ Steps verticales ocupan mucho espacio
2. ❌ No se puede volver atrás sin perder datos
3. ❌ Upload de archivos confuso (no preview)
4. ❌ No hay validación inline (solo al submit)
5. ❌ No se puede guardar borrador
6. ❌ Barra de progreso no es visual

**Mejoras Necesarias:**
- ✅ Steps horizontales compactos
- ✅ Navegación libre entre pasos (con guardado)
- ✅ Drag & drop con preview
- ✅ Validación en tiempo real
- ✅ Auto-save cada X segundos
- ✅ Progress bar visual con porcentaje

#### Panel de Usuario

**Layout:**
```
+----------------------------------+
| Header + Nav                     |
+----------------------------------+
| Submenu (tabs)                   |
| [Datos] [Email] [SMS] [Borrar]   |
+----------------------------------+
| Formulario activo                |
+----------------------------------+
```

**Problemas UX:**
1. ❌ Tabs horizontales en mobile (overflow)
2. ❌ Muchas secciones para cosas simples
3. ❌ "Borrar cuenta" al mismo nivel que otras opciones
4. ❌ No hay foto de perfil
5. ❌ No muestra actividad reciente

**Mejoras Necesarias:**
- ✅ Sidebar con secciones colapsables
- ✅ Agrupar configuraciones relacionadas
- ✅ "Borrar cuenta" en sección separada (danger zone)
- ✅ Avatar con upload
- ✅ Dashboard con actividad

#### ActiveAdmin Panel

**Estado:** Funcional pero genérico

**Problemas UX:**
1. ❌ UI muy densa (mucha información)
2. ❌ No personalizado a marca
3. ❌ Acciones no claras (iconos pequeños)
4. ❌ No hay dashboard visual (solo links)

**Mejoras Necesarias:**
- ✅ Theme customizado con colores de marca
- ✅ Dashboard con KPIs y gráficos
- ✅ Acciones con tooltips
- ✅ Bulk actions más accesibles

### 3.3 Problemas de Accesibilidad

**Evaluación WCAG 2.1:**

#### Nivel A (Mínimo)
- ⚠️ **Contraste:** Algunos textos grises (#999) no cumplen 4.5:1
- ⚠️ **Alt text:** Muchas imágenes decorativas sin alt vacío
- ⚠️ **Keyboard:** Algunos elementos no son tabulables
- ✅ **HTML semántico:** Uso correcto de headings

#### Nivel AA (Recomendado)
- ❌ **Contraste mejorado:** Falla en varios lugares
- ❌ **Resize text:** Algunas áreas rompen a 200%
- ❌ **Focus visible:** No hay outline claro en todos los inputs
- ❌ **Orientación:** No bloquea orientación (OK)

#### Nivel AAA (Óptimo)
- ❌ **Contraste extendido:** Solo cumple A
- ❌ **Espaciado:** No ajustable sin romper
- ❌ **Animaciones:** No hay prefers-reduced-motion

**Puntuación Global: 6/10 (MEJORABLE)**

### 3.4 Performance Percibida

**Métricas Estimadas (sin herramientas):**

```
First Contentful Paint:  ~1.5s (OK)
Largest Contentful Paint: ~2.5s (OK)
Time to Interactive:      ~3.5s (LENTO)
Cumulative Layout Shift:  ~0.2 (ALTA)

Lighthouse Score (estimado): 60-70/100
```

**Problemas:**
1. ❌ Sprockets carga todo JS en un solo archivo grande
2. ❌ No hay code splitting
3. ❌ CSS no crítico en head (bloquea render)
4. ❌ Imágenes sin lazy loading
5. ❌ No hay Service Worker (sin offline)
6. ❌ Font Awesome carga todos los iconos (solo usa ~30)

### 3.5 Responsive Design Issues

**Móvil (<460px):**
- ❌ Formularios con inputs muy juntos
- ❌ Botones difíciles de tocar (< 44x44px)
- ❌ Menú hamburger no intuitivo
- ❌ Tablas con scroll horizontal (UX mala)
- ❌ Steps wizard solo muestra números (pierde contexto)

**Tablet (600-768px):**
- ✅ Layout funcional (2 columnas)
- ❌ Algunos textos demasiado grandes
- ❌ Sidebar fuerza scroll vertical innecesario

**Desktop (>978px):**
- ✅ Layout claro y espacioso
- ❌ Mucho espacio en blanco en pantallas grandes (>1920px)
- ❌ No hay layout para ultra-wide (>2560px)

---

## 4. SISTEMA DE DISEÑO PROPUESTO {#sistema-de-diseño}

### 4.1 Filosofía del Nuevo Sistema

**Principios Rectores:**

1. **Atomic Design**
   - Átomos: Colores, tipografía, espaciado
   - Moléculas: Botones, inputs, iconos
   - Organismos: Forms, cards, navigation
   - Templates: Páginas completas
   - Pages: Instancias específicas

2. **Mobile-First**
   - Diseñar primero para el viewport más pequeño
   - Progressive enhancement para pantallas grandes
   - Touch-friendly (mínimo 44x44px)

3. **Accesibilidad por Defecto**
   - WCAG 2.1 AA como mínimo
   - Semántica HTML correcta
   - ARIA cuando sea necesario
   - Keyboard navigation completa

4. **Performance**
   - Critical CSS inline
   - Lazy loading de componentes
   - Optimización de assets
   - Lighthouse > 90/100

5. **Personalización Extrema**
   - Variables CSS para todo
   - Theming con CSS Custom Properties
   - Admin panel para cambios visuales
   - Sin hardcoding de valores

### 4.2 Tokens de Diseño

**¿Qué son los Design Tokens?**

Variables que representan decisiones visuales:
```
Color-Primary-500 = #612d62
Spacing-4 = 1rem
Font-Size-lg = 1.125rem
```

**Estructura Propuesta:**

#### Color Tokens
```css
/* Base Colors (personalizable) */
--color-brand-primary: #612d62;
--color-brand-secondary: #269283;
--color-brand-accent: #954e99;

/* Semantic Colors */
--color-text-primary: #1a1a1a;
--color-text-secondary: #666666;
--color-text-tertiary: #999999;
--color-text-inverse: #ffffff;

--color-bg-primary: #ffffff;
--color-bg-secondary: #f5f5f5;
--color-bg-tertiary: #eaeaea;

--color-border-primary: #d7cad8;
--color-border-secondary: #e0e0e0;

/* Feedback Colors */
--color-success-100: #f0fdf4;
--color-success-500: #22c55e;
--color-success-700: #15803d;

--color-error-100: #fef2f2;
--color-error-500: #ef4444;
--color-error-700: #b91c1c;

--color-warning-100: #fffbeb;
--color-warning-500: #f59e0b;
--color-warning-700: #b45309;

--color-info-100: #eff6ff;
--color-info-500: #3b82f6;
--color-info-700: #1d4ed8;
```

#### Spacing Tokens
```css
/* Scale: 4px base */
--spacing-0: 0;
--spacing-1: 0.25rem;  /* 4px */
--spacing-2: 0.5rem;   /* 8px */
--spacing-3: 0.75rem;  /* 12px */
--spacing-4: 1rem;     /* 16px */
--spacing-5: 1.25rem;  /* 20px */
--spacing-6: 1.5rem;   /* 24px */
--spacing-8: 2rem;     /* 32px */
--spacing-10: 2.5rem;  /* 40px */
--spacing-12: 3rem;    /* 48px */
--spacing-16: 4rem;    /* 64px */
--spacing-20: 5rem;    /* 80px */
--spacing-24: 6rem;    /* 96px */
```

#### Typography Tokens
```css
/* Font Families */
--font-primary: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
--font-secondary: 'Montserrat', sans-serif;
--font-mono: 'Fira Code', 'Courier New', monospace;

/* Font Sizes (Modular Scale: 1.250 - Major Third) */
--font-size-xs: 0.75rem;    /* 12px */
--font-size-sm: 0.875rem;   /* 14px */
--font-size-base: 1rem;     /* 16px */
--font-size-lg: 1.125rem;   /* 18px */
--font-size-xl: 1.25rem;    /* 20px */
--font-size-2xl: 1.563rem;  /* 25px */
--font-size-3xl: 1.953rem;  /* 31px */
--font-size-4xl: 2.441rem;  /* 39px */
--font-size-5xl: 3.052rem;  /* 49px */

/* Font Weights */
--font-weight-light: 300;
--font-weight-normal: 400;
--font-weight-medium: 500;
--font-weight-semibold: 600;
--font-weight-bold: 700;
--font-weight-extrabold: 800;

/* Line Heights */
--line-height-tight: 1.25;
--line-height-normal: 1.5;
--line-height-relaxed: 1.75;
--line-height-loose: 2;
```

#### Border Tokens
```css
--border-radius-none: 0;
--border-radius-sm: 0.125rem;  /* 2px */
--border-radius-base: 0.25rem; /* 4px */
--border-radius-md: 0.375rem;  /* 6px */
--border-radius-lg: 0.5rem;    /* 8px */
--border-radius-xl: 0.75rem;   /* 12px */
--border-radius-2xl: 1rem;     /* 16px */
--border-radius-full: 9999px;

--border-width-thin: 1px;
--border-width-base: 2px;
--border-width-thick: 4px;
```

#### Shadow Tokens
```css
--shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
--shadow-base: 0 1px 3px 0 rgba(0, 0, 0, 0.1),
               0 1px 2px -1px rgba(0, 0, 0, 0.1);
--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1),
             0 2px 4px -2px rgba(0, 0, 0, 0.1);
--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1),
             0 4px 6px -4px rgba(0, 0, 0, 0.1);
--shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1),
             0 8px 10px -6px rgba(0, 0, 0, 0.1);
--shadow-2xl: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
--shadow-inner: inset 0 2px 4px 0 rgba(0, 0, 0, 0.05);
```

#### Animation Tokens
```css
--duration-fast: 150ms;
--duration-base: 300ms;
--duration-slow: 500ms;

--easing-linear: cubic-bezier(0, 0, 1, 1);
--easing-ease-in: cubic-bezier(0.4, 0, 1, 1);
--easing-ease-out: cubic-bezier(0, 0, 0.2, 1);
--easing-ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
```

#### Breakpoint Tokens
```css
--breakpoint-xs: 0px;
--breakpoint-sm: 640px;
--breakpoint-md: 768px;
--breakpoint-lg: 1024px;
--breakpoint-xl: 1280px;
--breakpoint-2xl: 1536px;
```

### 4.3 Arquitectura CSS Propuesta

**Metodología: CUBE CSS + Utility Classes**

```
styles/
├── 01-settings/
│   ├── _tokens.css          (Design tokens)
│   ├── _colors.css          (Color system)
│   └── _typography.css      (Font system)
│
├── 02-tools/
│   ├── _mixins.css          (Reutilizables)
│   └── _functions.css       (Cálculos)
│
├── 03-generic/
│   ├── _reset.css           (CSS reset)
│   ├── _box-sizing.css      (Box model)
│   └── _normalize.css       (Cross-browser)
│
├── 04-elements/
│   ├── _headings.css        (h1-h6)
│   ├── _links.css           (a)
│   ├── _lists.css           (ul, ol)
│   └── _images.css          (img)
│
├── 05-objects/
│   ├── _container.css       (Layouts)
│   ├── _grid.css            (Grid system)
│   ├── _stack.css           (Vertical spacing)
│   └── _cluster.css         (Horizontal spacing)
│
├── 06-components/
│   ├── _button.css
│   ├── _card.css
│   ├── _form.css
│   ├── _modal.css
│   ├── _navigation.css
│   ├── _alert.css
│   └── ... (todos los componentes)
│
├── 07-utilities/
│   ├── _spacing.css         (m-*, p-*)
│   ├── _typography.css      (text-*)
│   ├── _colors.css          (bg-*, text-*)
│   ├── _display.css         (flex, grid)
│   └── _responsive.css      (hide-*, show-*)
│
└── main.css                 (Import all)
```

**Ejemplo de Componente:**

```css
/* 06-components/_button.css */

.button {
  /* Base styles */
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-2);

  padding: var(--spacing-3) var(--spacing-6);
  border: var(--border-width-base) solid transparent;
  border-radius: var(--border-radius-md);

  font-family: var(--font-primary);
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-medium);
  line-height: var(--line-height-tight);
  text-decoration: none;

  cursor: pointer;
  transition: all var(--duration-base) var(--easing-ease-in-out);

  /* Evita shrinking en flex */
  flex-shrink: 0;

  /* Touch-friendly */
  min-height: 44px;

  /* Focus visible para accesibilidad */
  &:focus-visible {
    outline: 2px solid var(--color-brand-primary);
    outline-offset: 2px;
  }
}

/* Variants */
.button--primary {
  background-color: var(--color-brand-primary);
  color: var(--color-text-inverse);

  &:hover {
    background-color: color-mix(in srgb, var(--color-brand-primary) 90%, black);
  }

  &:active {
    background-color: color-mix(in srgb, var(--color-brand-primary) 80%, black);
  }
}

.button--secondary {
  background-color: transparent;
  border-color: var(--color-border-primary);
  color: var(--color-text-primary);

  &:hover {
    background-color: var(--color-bg-secondary);
  }
}

.button--ghost {
  background-color: transparent;
  color: var(--color-brand-primary);

  &:hover {
    background-color: color-mix(in srgb, var(--color-brand-primary) 10%, transparent);
  }
}

.button--danger {
  background-color: var(--color-error-500);
  color: var(--color-text-inverse);

  &:hover {
    background-color: var(--color-error-700);
  }
}

/* Sizes */
.button--small {
  padding: var(--spacing-2) var(--spacing-4);
  font-size: var(--font-size-sm);
  min-height: 36px;
}

.button--large {
  padding: var(--spacing-4) var(--spacing-8);
  font-size: var(--font-size-lg);
  min-height: 52px;
}

/* States */
.button:disabled,
.button[aria-disabled="true"] {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}

.button--loading {
  position: relative;
  color: transparent;

  &::after {
    content: '';
    position: absolute;
    width: 16px;
    height: 16px;
    border: 2px solid currentColor;
    border-radius: 50%;
    border-top-color: transparent;
    animation: spin var(--duration-slow) linear infinite;
  }
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
```

---

## 5. PALETA DE COLORES Y THEMING {#paleta-colores}

### 5.1 Nueva Paleta Expandida

**Sistema de Colores: 9 tonos por color**

#### Morado (Primary) - Rediseñado
```css
--purple-50:  #faf5fb;  /* Muy claro - backgrounds */
--purple-100: #f3e8f5;  /* Claro - hover states */
--purple-200: #e4cfe8;  /* Claro medio */
--purple-300: #d0add6;  /* Medio claro */
--purple-400: #b687bd;  /* Medio */
--purple-500: #954e99;  /* Base ACTUAL (intermediate) */
--purple-600: #612d62;  /* Oscuro BASE ACTUAL (main) ⭐ */
--purple-700: #4a2249;  /* Muy oscuro */
--purple-800: #351933;  /* Casi negro */
--purple-900: #221020;  /* Negro */
```

**Uso:**
- 600: Primary buttons, links, headings
- 500: Hover states, secondary actions
- 400: Disabled states
- 200: Subtle backgrounds
- 50: Page backgrounds

#### Verde (Secondary) - Expandido
```css
--green-50:  #f0fdf7;
--green-100: #dcfce8;
--green-200: #bbf7d6;
--green-300: #97c2b8;  /* ACTUAL (light) */
--green-400: #5dc9af;
--green-500: #269283;  /* BASE ACTUAL ⭐ */
--green-600: #1a7366;
--green-700: #165a52;
--green-800: #134842;
--green-900: #0f3933;
```

**Uso:**
- 500: Success states, action buttons
- 400: Hover on success
- 300: Subtle success backgrounds
- 600: Success text on light

#### Gris (Neutral) - Sistema Completo
```css
--gray-50:  #fafafa;
--gray-100: #f5f5f5;
--gray-200: #eaeaea;  /* ACTUAL (form bg) */
--gray-300: #d7d7d7;
--gray-400: #b0b0b0;
--gray-500: #999999;  /* ACTUAL (secondary text) */
--gray-600: #666666;  /* Better contrast */
--gray-700: #4d4d4d;
--gray-800: #333333;  /* ACTUAL (text) */
--gray-900: #1a1a1a;  /* True black */
```

#### Rojo (Error/Danger)
```css
--red-50:  #fef2f2;
--red-100: #fee2e2;
--red-200: #fecaca;
--red-300: #fca5a5;
--red-400: #f87171;
--red-500: #ef4444;  /* Base - replacing #f5bfc9 */
--red-600: #dc2626;
--red-700: #b91c1c;
--red-800: #991b1b;
--red-900: #7f1d1d;
```

#### Amarillo (Warning)
```css
--yellow-50:  #fefce8;
--yellow-100: #fef9c3;
--yellow-200: #fef08a;
--yellow-300: #fde047;
--yellow-400: #facc15;
--yellow-500: #eab308;
--yellow-600: #ca8a04;
--yellow-700: #a16207;
--yellow-800: #854d0e;
--yellow-900: #713f12;
```

#### Azul (Info)
```css
--blue-50:  #eff6ff;
--blue-100: #dbeafe;
--blue-200: #bfdbfe;
--blue-300: #93c5fd;
--blue-400: #60a5fa;
--blue-500: #3b82f6;
--blue-600: #2563eb;
--blue-700: #1d4ed8;
--blue-800: #1e40af;
--blue-900: #1e3a8a;
```

### 5.2 Mapeo Semántico

**De colores raw a significado:**

```css
/* Primary Brand */
--color-primary-50: var(--purple-50);
--color-primary-100: var(--purple-100);
/* ... */
--color-primary-600: var(--purple-600);
/* ... */

/* Secondary Brand */
--color-secondary-500: var(--green-500);
/* ... */

/* Semantic Mappings */
--color-success: var(--green-500);
--color-success-light: var(--green-100);
--color-success-dark: var(--green-700);

--color-error: var(--red-500);
--color-error-light: var(--red-100);
--color-error-dark: var(--red-700);

--color-warning: var(--yellow-500);
--color-warning-light: var(--yellow-100);
--color-warning-dark: var(--yellow-700);

--color-info: var(--blue-500);
--color-info-light: var(--blue-100);
--color-info-dark: var(--blue-700);

/* Text */
--color-text-primary: var(--gray-900);
--color-text-secondary: var(--gray-600);
--color-text-tertiary: var(--gray-500);
--color-text-disabled: var(--gray-400);
--color-text-inverse: #ffffff;
--color-text-link: var(--primary-600);
--color-text-link-hover: var(--primary-700);

/* Backgrounds */
--color-bg-primary: #ffffff;
--color-bg-secondary: var(--gray-50);
--color-bg-tertiary: var(--gray-100);
--color-bg-elevated: #ffffff; /* cards, modals */
--color-bg-overlay: rgba(0, 0, 0, 0.5);

/* Borders */
--color-border-primary: var(--gray-300);
--color-border-secondary: var(--gray-200);
--color-border-focus: var(--primary-500);
--color-border-error: var(--error-500);
```

### 5.3 Dark Mode

**Sistema de Inversión:**

```css
/* Light Mode (default) - ya definido arriba */

/* Dark Mode */
@media (prefers-color-scheme: dark) {
  :root {
    /* Invertir backgrounds */
    --color-bg-primary: var(--gray-900);
    --color-bg-secondary: var(--gray-800);
    --color-bg-tertiary: var(--gray-700);
    --color-bg-elevated: var(--gray-800);

    /* Invertir text */
    --color-text-primary: var(--gray-50);
    --color-text-secondary: var(--gray-300);
    --color-text-tertiary: var(--gray-400);

    /* Borders más sutiles */
    --color-border-primary: var(--gray-700);
    --color-border-secondary: var(--gray-800);

    /* Colores de marca: mantener o ajustar levemente */
    --color-primary-600: var(--purple-500); /* Más claro en dark */
    --color-secondary-500: var(--green-400); /* Más claro */
  }
}

/* Override manual con clase */
[data-theme="dark"] {
  /* Mismo contenido que media query */
  /* Permite forzar dark mode independiente del sistema */
}

[data-theme="light"] {
  /* Forzar light mode */
}
```

**Toggle de Tema:**

El usuario podrá elegir:
- 🌞 Light (forzado)
- 🌙 Dark (forzado)
- 🔄 Auto (sigue sistema operativo)

### 5.4 Temas Personalizados

**Arquitectura de Multi-Theming:**

```css
/* Tema Base (PlebisHub Default) */
:root {
  --theme-primary: #612d62;
  --theme-secondary: #269283;
  /* ... resto de variables */
}

/* Tema Alternativo 1: Azul Corporativo */
[data-theme="corporate-blue"] {
  --theme-primary: #1e40af; /* Blue 800 */
  --theme-secondary: #0891b2; /* Cyan 600 */
  --theme-accent: #3b82f6;
}

/* Tema Alternativo 2: Rojo Activista */
[data-theme="activist-red"] {
  --theme-primary: #dc2626; /* Red 600 */
  --theme-secondary: #ea580c; /* Orange 600 */
  --theme-accent: #f97316;
}

/* Tema Alternativo 3: Verde Sostenible */
[data-theme="eco-green"] {
  --theme-primary: #15803d; /* Green 700 */
  --theme-secondary: #059669; /* Emerald 600 */
  --theme-accent: #10b981;
}

/* Aplicar theme variables a componentes */
.button--primary {
  background-color: var(--theme-primary);
}

header {
  background-color: var(--theme-primary);
}

a {
  color: var(--theme-secondary);
}
```

**Panel Admin para Theming:**

```
Settings > Appearance > Theme
┌─────────────────────────────────────┐
│ Primary Color:   [#612d62] 🎨       │
│ Secondary Color: [#269283] 🎨       │
│ Accent Color:    [#954e99] 🎨       │
├─────────────────────────────────────┤
│ Logo Upload:     [Browse...] 📁     │
│ Favicon Upload:  [Browse...] 📁     │
├─────────────────────────────────────┤
│ Typography:                         │
│ Heading Font:    [Montserrat ▼]     │
│ Body Font:       [Inter ▼]          │
├─────────────────────────────────────┤
│ Presets:                            │
│ [Default] [Blue] [Red] [Green]      │
│ [Custom]                            │
├─────────────────────────────────────┤
│ Preview:                            │
│ ┌─────────────────────────────────┐ │
│ │  [Preview de header]            │ │
│ │  [Preview de botones]           │ │
│ │  [Preview de cards]             │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ [Save Changes] [Reset to Default]   │
└─────────────────────────────────────┘
```

**Implementación Técnica:**

```ruby
# app/models/theme_configuration.rb
class ThemeConfiguration < ApplicationRecord
  validates :primary_color, format: { with: /\A#[0-9A-Fa-f]{6}\z/ }
  validates :secondary_color, format: { with: /\A#[0-9A-Fa-f]{6}\z/ }

  has_one_attached :logo
  has_one_attached :favicon

  PRESETS = {
    default: { primary: '#612d62', secondary: '#269283' },
    blue: { primary: '#1e40af', secondary: '#0891b2' },
    red: { primary: '#dc2626', secondary: '#ea580c' },
    green: { primary: '#15803d', secondary: '#059669' }
  }

  def to_css_variables
    <<~CSS
      :root {
        --theme-primary: #{primary_color};
        --theme-secondary: #{secondary_color};
        --theme-accent: #{accent_color};
      }
    CSS
  end
end
```

```erb
<!-- app/views/layouts/application.html.erb -->
<head>
  <style>
    <%= ThemeConfiguration.current.to_css_variables %>
  </style>
</head>
```

### 5.5 Generación de Paletas

**Herramienta: Color Palette Generator**

Dado un color primario elegido por el admin, generar automáticamente los 9 tonos:

```javascript
// utils/colorPalette.js
function generatePalette(baseHex) {
  const hsl = hexToHSL(baseHex);

  return {
    50: hslToHex({ h: hsl.h, s: hsl.s * 0.2, l: 96 }),
    100: hslToHex({ h: hsl.h, s: hsl.s * 0.3, l: 92 }),
    200: hslToHex({ h: hsl.h, s: hsl.s * 0.5, l: 84 }),
    300: hslToHex({ h: hsl.h, s: hsl.s * 0.7, l: 72 }),
    400: hslToHex({ h: hsl.h, s: hsl.s * 0.85, l: 60 }),
    500: baseHex, // Base color
    600: hslToHex({ h: hsl.h, s: hsl.s, l: hsl.l * 0.85 }),
    700: hslToHex({ h: hsl.h, s: hsl.s, l: hsl.l * 0.7 }),
    800: hslToHex({ h: hsl.h, s: hsl.s, l: hsl.l * 0.55 }),
    900: hslToHex({ h: hsl.h, s: hsl.s, l: hsl.l * 0.4 }),
  };
}

// Uso:
const customPalette = generatePalette('#612d62');
// {
//   50: '#faf5fb',
//   100: '#f3e8f5',
//   ...
// }
```

---

## 6. TIPOGRAFÍA Y JERARQUÍA VISUAL {#tipografía}

### 6.1 Sistema Tipográfico

**Fuentes Propuestas:**

#### Opción A: Inter + Montserrat (RECOMENDADA)

```css
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Montserrat:wght@600;700;800&display=swap');

--font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
--font-display: 'Montserrat', 'Inter', sans-serif;
```

**Uso:**
- **Inter:** Body text, UI components, forms
  - Legibilidad superior en pantallas
  - Designed for screens
  - Variable font option

- **Montserrat:** Headings, navigation, branding
  - Mantiene identidad actual
  - Fuerte presencia visual
  - Geometric sans

**Ventajas:**
- ✅ Inter mejora legibilidad en textos largos
- ✅ Mantiene Montserrat para reconocimiento de marca
- ✅ Contraste entre display y body
- ✅ Excelente rendering en todas las pantallas

#### Opción B: System Font Stack (Máximo Performance)

```css
--font-sans: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto',
             'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans',
             'Helvetica Neue', sans-serif;
```

**Ventajas:**
- ✅ Zero network requests
- ✅ Rendering instantáneo
- ✅ Nativo del OS (UX familiar)

**Desventajas:**
- ❌ Pierde identidad de marca
- ❌ Inconsistente entre OS

#### Opción C: Solo Montserrat (Conservador)

```css
@import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700;800&display=swap');

--font-sans: 'Montserrat', sans-serif;
```

**Ventajas:**
- ✅ Mantiene 100% identidad actual
- ✅ Una sola fuente (menos weight)

**Desventajas:**
- ❌ Montserrat no es óptima para body text
- ❌ Menos variedad visual

**RECOMENDACIÓN: Opción A (Inter + Montserrat)**

### 6.2 Escala Tipográfica

**Base: 16px (1rem)**

**Escala Modular: 1.250 (Major Third)**

```css
/* Font Sizes */
--text-xs: 0.75rem;     /* 12px */
--text-sm: 0.875rem;    /* 14px */
--text-base: 1rem;      /* 16px - base */
--text-lg: 1.125rem;    /* 18px */
--text-xl: 1.25rem;     /* 20px */
--text-2xl: 1.563rem;   /* 25px (1.25 × 1.25) */
--text-3xl: 1.953rem;   /* 31px */
--text-4xl: 2.441rem;   /* 39px */
--text-5xl: 3.052rem;   /* 49px */
--text-6xl: 3.815rem;   /* 61px */
--text-7xl: 4.768rem;   /* 76px */
```

**Responsive:**

```css
/* Mobile: Base scale */
h1 { font-size: var(--text-3xl); }  /* 31px */
h2 { font-size: var(--text-2xl); }  /* 25px */
h3 { font-size: var(--text-xl); }   /* 20px */

/* Tablet: +1 step */
@media (min-width: 768px) {
  h1 { font-size: var(--text-4xl); } /* 39px */
  h2 { font-size: var(--text-3xl); } /* 31px */
  h3 { font-size: var(--text-2xl); } /* 25px */
}

/* Desktop: +2 steps */
@media (min-width: 1024px) {
  h1 { font-size: var(--text-5xl); } /* 49px */
  h2 { font-size: var(--text-4xl); } /* 39px */
  h3 { font-size: var(--text-3xl); } /* 31px */
}
```

### 6.3 Pesos de Fuente (Font Weights)

**Mapeo Semántico:**

```css
--font-light: 300;       /* Uso: Subheadings, captions */
--font-normal: 400;      /* Uso: Body text */
--font-medium: 500;      /* Uso: Emphasized text, labels */
--font-semibold: 600;    /* Uso: Subheadings, buttons */
--font-bold: 700;        /* Uso: Headings, important */
--font-extrabold: 800;   /* Uso: Hero headings */
```

**Guía de Uso:**

| Elemento | Font | Weight | Size |
|----------|------|--------|------|
| H1 (Hero) | Montserrat | 800 | 5xl |
| H1 (Page) | Montserrat | 700 | 4xl |
| H2 | Montserrat | 700 | 3xl |
| H3 | Montserrat | 600 | 2xl |
| H4 | Montserrat | 600 | xl |
| H5 | Montserrat | 600 | lg |
| H6 | Montserrat | 600 | base |
| Body | Inter | 400 | base |
| Caption | Inter | 400 | sm |
| Overline | Inter | 600 | xs |
| Button | Inter | 500 | base |
| Label | Inter | 500 | sm |

### 6.4 Line Height (Interlineado)

```css
--leading-none: 1;
--leading-tight: 1.25;    /* Headings */
--leading-snug: 1.375;
--leading-normal: 1.5;    /* Body text - DEFAULT */
--leading-relaxed: 1.625; /* Legibilidad mejorada */
--leading-loose: 2;       /* Espaciado máximo */
```

**Aplicación:**

```css
h1, h2, h3, h4, h5, h6 {
  line-height: var(--leading-tight);  /* 1.25 */
}

p, li, td {
  line-height: var(--leading-normal); /* 1.5 */
}

.text-large,
.text-relaxed {
  line-height: var(--leading-relaxed); /* 1.625 */
}
```

### 6.5 Letter Spacing (Tracking)

```css
--tracking-tighter: -0.05em;
--tracking-tight: -0.025em;
--tracking-normal: 0;
--tracking-wide: 0.025em;
--tracking-wider: 0.05em;
--tracking-widest: 0.1em;
```

**Uso:**

```css
/* Headings grandes: Más apretado */
h1, h2 {
  letter-spacing: var(--tracking-tight);
}

/* Uppercase text: Más espaciado */
.uppercase,
button {
  letter-spacing: var(--tracking-wide);
}

/* Small text: Ligeramente más espaciado */
.text-xs,
.text-sm {
  letter-spacing: var(--tracking-wide);
}
```

### 6.6 Jerarquía Visual Completa

**Ejemplo de Página:**

```html
<!-- Hero -->
<h1 class="text-5xl font-extrabold tracking-tight">
  Participa en las decisiones
</h1>
<p class="text-xl text-secondary mt-4 leading-relaxed">
  Tu voz importa. Apoya propuestas, crea proyectos...
</p>

<!-- Section -->
<h2 class="text-4xl font-bold tracking-tight mt-16">
  Propuestas Activas
</h2>
<p class="text-base text-secondary mt-2">
  Estas propuestas están recibiendo apoyos ahora
</p>

<!-- Card -->
<h3 class="text-2xl font-semibold">
  Nombre de la propuesta
</h3>
<p class="text-sm text-tertiary mt-1">
  Por Usuario • Hace 2 días
</p>
<p class="text-base mt-4 leading-relaxed">
  Descripción de la propuesta con texto largo que necesita buena legibilidad...
</p>

<!-- Metadata -->
<span class="text-xs font-medium uppercase tracking-widest text-tertiary">
  Categoría: Educación
</span>
```

**CSS Aplicado:**

```css
.text-5xl { font-size: var(--text-5xl); }
.text-4xl { font-size: var(--text-4xl); }
.text-2xl { font-size: var(--text-2xl); }
.text-xl { font-size: var(--text-xl); }
.text-base { font-size: var(--text-base); }
.text-sm { font-size: var(--text-sm); }
.text-xs { font-size: var(--text-xs); }

.font-extrabold { font-weight: 800; }
.font-bold { font-weight: 700; }
.font-semibold { font-weight: 600; }
.font-medium { font-weight: 500; }

.tracking-tight { letter-spacing: -0.025em; }
.tracking-widest { letter-spacing: 0.1em; }

.leading-relaxed { line-height: 1.625; }

.text-secondary { color: var(--color-text-secondary); }
.text-tertiary { color: var(--color-text-tertiary); }
```

---

## 7. COMPONENTES Y PATRONES UI {#componentes-ui}

### 7.1 Biblioteca de Componentes

**Componentes a Diseñar (40 componentes base):**

#### Componentes Básicos (Atoms)

**1. Button (Botón)**
```
Variantes:
- Primary (relleno morado)
- Secondary (outline)
- Ghost (transparente)
- Danger (rojo)
- Success (verde)

Tamaños:
- Small (36px altura)
- Medium (44px altura - default)
- Large (52px altura)

Estados:
- Default
- Hover
- Active
- Disabled
- Loading (con spinner)

Extras:
- Icon left
- Icon right
- Icon only
- Full width
```

**Especificaciones de Diseño:**
```
Button Primary Medium:
- Padding: 12px 24px
- Height: 44px (touch-friendly)
- Border-radius: 6px
- Font: Inter Medium 16px
- Transition: 300ms ease-in-out
- Shadow: none (default), sm (hover)
- Min-width: 100px

Estados:
Default:  bg=#612d62, text=white
Hover:    bg=#4a2249, transform: translateY(-1px), shadow-md
Active:   bg=#351933, transform: translateY(0)
Disabled: opacity=0.5, cursor=not-allowed
```

**Mockup Visual:**
```
┌─────────────────────────┐
│   [↗] Apoyar Propuesta  │  ← Primary
└─────────────────────────┘

┌─────────────────────────┐
│   Cancelar              │  ← Secondary (outline)
└─────────────────────────┘

┌─────────────────────────┐
│   ⊗ Eliminar            │  ← Danger (rojo)
└─────────────────────────┘

┌──────────┐
│  [◌]     │  ← Loading (spinner girando)
└──────────┘
```

**2. Input (Campo de texto)**
```
Tipos:
- Text
- Email
- Password
- Number
- Search
- Textarea

Estados:
- Default
- Focus
- Error
- Success
- Disabled

Extras:
- Label
- Helper text
- Error message
- Icon prefix
- Icon suffix
- Character counter
```

**Especificaciones:**
```
Input Medium:
- Height: 44px
- Padding: 10px 16px
- Border: 2px solid #e0e0e0
- Border-radius: 6px
- Font: Inter Regular 16px
- Background: white

Focus:
- Border-color: #612d62
- Outline: 0
- Box-shadow: 0 0 0 3px rgba(97,45,98,0.1)

Error:
- Border-color: #ef4444
- Icon: ⚠️ (rojo)
- Message: "Este campo es obligatorio" (rojo)

Success:
- Border-color: #22c55e
- Icon: ✓ (verde)
```

**Mockup:**
```
Nombre completo *
┌──────────────────────────────────┐
│ Juan Pérez                  │
└──────────────────────────────────┘
Ejemplo: Juan García López

[FOCUS STATE]
┌══════════════════════════════════┐ ← Border morado
│ Juan Pérez                  │     + glow suave
└══════════════════════════════════┘

[ERROR STATE]
┌──────────────────────────────────┐
│ ⚠️                               │ ← Border rojo
└──────────────────────────────────┘
Este campo es obligatorio
```

**3. Checkbox & Radio**
```
Checkbox:
- 20x20px
- Border-radius: 4px
- Border: 2px solid
- Checkmark: ✓ icon

Radio:
- 20x20px círculo
- Dot interior cuando checked

Estados: unchecked, checked, indeterminate, disabled
```

**4. Badge (Etiqueta)**
```
Variantes:
- Default (gris)
- Primary (morado)
- Success (verde)
- Error (rojo)
- Warning (amarillo)

Tamaños:
- Small (texto 12px)
- Medium (texto 14px)
```

**Mockup:**
```
[Nueva]  [Activa]  [Cerrada]  [3]
 ↑ Primary  ↑ Success  ↑ Error   ↑ Contador
```

**5. Avatar (Foto de perfil)**
```
Tamaños:
- XS: 24px
- SM: 32px
- MD: 40px
- LG: 56px
- XL: 80px
- 2XL: 128px

Variantes:
- Image
- Initials (letras)
- Icon (user icon)
- Status indicator (dot verde/gris)
```

**6. Icon (Iconos)**
```
Sistema: Lucide Icons (moderno, open source)
Tamaños: 16px, 20px, 24px, 32px
Colores: currentColor (hereda del padre)
```

#### Componentes Compuestos (Molecules)

**7. Card (Tarjeta)**
```
Estructura:
┌─────────────────────────────────┐
│ [Imagen opcional]               │
├─────────────────────────────────┤
│ Header                          │
│ - Avatar + Nombre + Fecha       │
├─────────────────────────────────┤
│ Body                            │
│ - Título                        │
│ - Descripción                   │
│ - Tags/Badges                   │
├─────────────────────────────────┤
│ Footer                          │
│ - Acciones (botones/links)     │
│ - Stats (likes, views, etc)    │
└─────────────────────────────────┘

Variantes:
- Default (border)
- Elevated (shadow)
- Outlined (border grueso)
- Interactive (hover effect)
```

**Especificaciones:**
```
Card:
- Padding: 24px
- Border-radius: 12px
- Border: 1px solid #e0e0e0
- Background: white

Card Elevated:
- Shadow: 0 4px 6px rgba(0,0,0,0.1)
- Hover: shadow-lg, translateY(-2px)

Card Interactive:
- Cursor: pointer
- Transition: all 300ms
- Hover: border-color=#612d62
```

**8. Alert/Toast (Alerta)**
```
Tipos:
- Info (azul)
- Success (verde)
- Warning (amarillo)
- Error (rojo)

Elementos:
- Icon (automático según tipo)
- Title (opcional)
- Message
- Close button
- Action button (opcional)

Layout:
┌────────────────────────────────┐
│ [ℹ️] Título                    [×]│
│     Mensaje descriptivo         │
│     [Acción]                    │
└────────────────────────────────┘
```

**9. Progress Bar (Barra de progreso)**
```
Variantes:
- Linear (horizontal)
- Circular (pie chart)
- Stepped (wizard)

Estados:
- Determinate (porcentaje conocido)
- Indeterminate (loading)

Linear:
━━━━━━━━━━▒▒▒▒▒▒▒▒▒▒ 50%
 ↑ Completo  ↑ Falta

Circular:
    ◷
   75%
```

**10. Tabs (Pestañas)**
```
Variantes:
- Line (subrayado)
- Pills (relleno)
- Contained (fondo)

Layout:
[Datos personales] [Email] [Configuración]
 ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
 Contenido activo aquí...

Mobile: Scrollable horizontalmente
```

**11. Modal/Dialog**
```
Estructura:
[Overlay oscuro 50% opacidad]

    ┌────────────────────────────┐
    │ Título              [×]    │
    ├────────────────────────────┤
    │                            │
    │ Contenido del modal        │
    │                            │
    ├────────────────────────────┤
    │          [Cancelar] [Confirmar]│
    └────────────────────────────┘

Tamaños: SM, MD, LG, XL, Full
Animación: Fade in + scale
```

**12. Dropdown/Select**
```
Default:
┌──────────────────────┐
│ Selecciona opción ▼  │
└──────────────────────┘

Open:
┌──────────────────────┐
│ Selecciona opción ▲  │
└──────────────────────┘
┌──────────────────────┐
│ → Opción 1           │
│   Opción 2           │
│   Opción 3           │
│   Opción 4           │
└──────────────────────┘

Features:
- Búsqueda integrada
- Multi-select
- Grupos de opciones
- Custom rendering
```

#### Componentes Complejos (Organisms)

**13. Navigation (Navegación)**

**Desktop:**
```
┌────────────────────────────────────────────┐
│ [Logo]  Inicio Propuestas Impulsa  [User▼]│
└────────────────────────────────────────────┘

Sticky: Sí (se queda al hacer scroll)
Shadow al scroll: sí
```

**Mobile:**
```
┌─────────────────────────┐
│ [≡]  [Logo]       [🔔] │
└─────────────────────────┘

Hamburger abre slide-in menu:
┌───────────────┐
│ [×]           │
│               │
│ Inicio        │
│ Propuestas    │
│ Impulsa       │
│ Votos         │
│ Mi perfil     │
│               │
│ [Salir]       │
└───────────────┘
```

**14. Hero Section**
```
┌─────────────────────────────────────────┐
│ [Imagen de fondo con overlay]           │
│                                         │
│     Título Grande y Llamativo           │
│     Subtítulo explicativo               │
│                                         │
│     [CTA Principal]  [CTA Secundario]   │
│                                         │
└─────────────────────────────────────────┘

Altura: 60vh (desktop), 50vh (mobile)
Overlay: gradient de morado 80% opacity
```

**15. Proposal Card (Tarjeta propuesta)**
```
┌──────────────────────────────────────┐
│ [Imagen 16:9]                        │
├──────────────────────────────────────┤
│ [@avatar] Usuario • Hace 2 días      │
│                                      │
│ ## Título de la propuesta            │
│                                      │
│ Descripción breve que se trunca...   │
│                                      │
│ [Educación] [Cultura]                │
│                                      │
│ ━━━━━━━━▒▒▒▒ 650/1000 apoyos         │
│                                      │
│ ⏱️ 15 días restantes                 │
│                                      │
│ [Apoyar] [Ver más]                   │
└──────────────────────────────────────┘
```

**16. Stats Dashboard**
```
┌─────────────────────────────────────┐
│ Estadísticas del Proyecto           │
├─────────────────────────────────────┤
│                                     │
│  [Gráfico circular]    1,234        │
│                        Usuarios     │
│                                     │
│  [Gráfico líneas]     245           │
│                        Propuestas   │
│                                     │
│  [Gráfico barras]     €12,450       │
│                        Recaudado    │
└─────────────────────────────────────┘
```

**17. Form Multi-step (Wizard)**
```
Step indicator:
1 ━━━ 2 ━━━ 3 ━━━ 4
●     ○     ○     ○
Datos  Info  Docs  Revisar

┌─────────────────────────────────┐
│ Paso 1: Datos básicos           │
├─────────────────────────────────┤
│                                 │
│ [Campos del formulario]         │
│                                 │
├─────────────────────────────────┤
│ [Anterior] [Guardar]   [Siguiente]│
└─────────────────────────────────┘

Features:
- Auto-save cada 30 segundos
- Navegación libre entre pasos completados
- Validación inline
- Indicador de progreso (% completado)
```

**18. Data Table (Tabla de datos)**
```
Desktop:
┌───────────────────────────────────────┐
│ 🔍 Buscar...    [Filtros▼] [Export▼] │
├───────────────────────────────────────┤
│ Nombre ▲│ Email      │ Estado │ ⚙️   │
├─────────┼────────────┼────────┼─────┤
│ Juan P  │ juan@...   │ ●Activo│ ... │
│ María G │ maria@...  │ ○Inact │ ... │
│ Pedro L │ pedro@...  │ ●Activo│ ... │
├───────────────────────────────────────┤
│ ← 1 2 3 4 5 →        Mostrando 1-10  │
└───────────────────────────────────────┘

Mobile: Stack vertical en cards
```

**19. Pagination (Paginación)**
```
Variantes:

Classic:
[← Anterior]  1  2  3  4  5  [Siguiente →]

Simple:
[←] Página 3 de 10 [→]

Infinite scroll:
[Skeleton loaders aparecen al llegar al final]
```

**20. Breadcrumb (Migas de pan)**
```
Inicio / Propuestas / Educación / Detalle

Mobile (condensado):
... / Educación / Detalle
```

### 7.2 Patrones de Diseño

#### Empty States (Estados vacíos)
```
┌───────────────────────────────┐
│                               │
│        [📭 Icono grande]      │
│                               │
│    No hay propuestas aún      │
│                               │
│    Sé el primero en crear     │
│    una propuesta              │
│                               │
│    [+ Crear propuesta]        │
│                               │
└───────────────────────────────┘
```

#### Loading States (Estados de carga)

**Skeleton Loaders:**
```
┌───────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │
│ ▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░  │
│                               │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓          │
│ ▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░    │
└───────────────────────────────┘

Shimmer effect: Gradient animado que pasa
```

**Spinners:**
```
  ◜ ◝
  ◟ ◞   Cargando...
```

#### Error States (Estados de error)
```
┌───────────────────────────────┐
│                               │
│        [⚠️ Icono error]       │
│                               │
│    Algo salió mal             │
│                               │
│    No pudimos cargar las      │
│    propuestas. Por favor      │
│    intenta de nuevo.          │
│                               │
│    [🔄 Reintentar]            │
│                               │
└───────────────────────────────┘
```

#### Success States (Estados de éxito)
```
┌───────────────────────────────┐
│                               │
│        [✓ Icono éxito]        │
│                               │
│    ¡Propuesta creada!         │
│                               │
│    Tu propuesta ha sido       │
│    enviada y está pendiente   │
│    de aprobación.             │
│                               │
│    [Ver mis propuestas]       │
│                               │
└───────────────────────────────┘
```

### 7.3 Microinteracciones

**Hover en botones:**
```
Estado inicial → Hover:
- Background: lighten 10%
- Transform: translateY(-1px)
- Shadow: 0 4px 8px rgba(0,0,0,0.15)
- Duration: 200ms
- Easing: ease-out
```

**Click en botones:**
```
Active:
- Transform: translateY(0)
- Shadow: none
- Duration: 100ms

Ripple effect:
- Circle expande desde click point
- Opacity: 0.3 → 0
- Duration: 600ms
```

**Input focus:**
```
Default → Focus:
- Border-color: #612d62
- Border-width: 2px
- Box-shadow: 0 0 0 3px rgba(97,45,98,0.1)
- Duration: 200ms
```

**Card hover:**
```
Default → Hover:
- Transform: translateY(-4px)
- Shadow: elevation increase
- Border-color: primary
- Duration: 300ms
- Easing: ease-out
```

**Page transitions:**
```
Entrada:
- Opacity: 0 → 1
- Transform: translateY(20px) → translateY(0)
- Duration: 400ms
- Easing: ease-out
```

**Scroll animations:**
```
Elementos aparecen al hacer scroll:
- Opacity: 0 → 1
- Transform: translateY(40px) → translateY(0)
- Delay: stagger 100ms entre elementos
- Duration: 600ms
```

---

## 8. DISEÑO RESPONSIVE Y MOBILE-FIRST {#diseño-responsive}

### 8.1 Breakpoints del Sistema

**Sistema Propuesto (Tailwind-style):**

```css
/* Mobile First - Base sin media query */
/* 0-639px: Mobile */

@media (min-width: 640px) {  /* sm: Tablet portrait */

}

@media (min-width: 768px) {  /* md: Tablet landscape */

}

@media (min-width: 1024px) { /* lg: Desktop */

}

@media (min-width: 1280px) { /* xl: Desktop grande */

}

@media (min-width: 1536px) { /* 2xl: Desktop XL */

}
```

**Comparación con sistema actual:**

| Actual | Propuesto | Cambio |
|--------|-----------|--------|
| 0-459px | 0-639px | +180px rango mobile |
| 460-600px | 640-767px | Consolidado en sm |
| 600-768px | 768-1023px | Expandido md |
| 769-977px | 1024-1279px | Expandido lg |
| 978px+ | 1280px+ | Breakpoint más alto |

### 8.2 Layout Responsive

#### Container (Contenedor principal)

```css
.container {
  width: 100%;
  margin-left: auto;
  margin-right: auto;
  padding-left: 1rem;
  padding-right: 1rem;
}

@media (min-width: 640px) {
  .container {
    max-width: 640px;
  }
}

@media (min-width: 768px) {
  .container {
    max-width: 768px;
  }
}

@media (min-width: 1024px) {
  .container {
    max-width: 1024px;
    padding-left: 2rem;
    padding-right: 2rem;
  }
}

@media (min-width: 1280px) {
  .container {
    max-width: 1200px;  /* Max width óptimo */
  }
}
```

#### Grid System

```css
/* Mobile: 1 columna */
.grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: 1fr;
}

/* Tablet: 2 columnas */
@media (min-width: 768px) {
  .grid-cols-2 {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Desktop: 3 columnas */
@media (min-width: 1024px) {
  .grid-cols-3 {
    grid-template-columns: repeat(3, 1fr);
  }
}

/* Desktop XL: 4 columnas */
@media (min-width: 1280px) {
  .grid-cols-4 {
    grid-template-columns: repeat(4, 1fr);
  }
}
```

### 8.3 Componentes Responsive

#### Navigation

**Mobile (<768px):**
```
Header fijo arriba:
┌─────────────────────────┐
│ [☰] LOGO         [🔔]  │
└─────────────────────────┘
Altura: 60px

Menú slide-in desde izquierda
```

**Desktop (≥768px):**
```
┌──────────────────────────────────────┐
│ LOGO  Inicio Propuestas Impulsa [User]│
└──────────────────────────────────────┘
Altura: 72px

Sticky con shadow al scroll
```

#### Cards

**Mobile:**
```
┌─────────────────┐
│ Imagen          │
│ Contenido       │
│ Footer          │
└─────────────────┘
Stack vertical
Width: 100%
```

**Tablet (2 columnas):**
```
┌────────┐ ┌────────┐
│ Card 1 │ │ Card 2 │
└────────┘ └────────┘
Gap: 1rem
```

**Desktop (3 columnas):**
```
┌──────┐ ┌──────┐ ┌──────┐
│Card 1│ │Card 2│ │Card 3│
└──────┘ └──────┘ └──────┘
Gap: 1.5rem
```

#### Forms

**Mobile: Stack vertical completo**
```
Label
┌──────────────┐
│ Input        │
└──────────────┘

Label 2
┌──────────────┐
│ Input 2      │
└──────────────┘
```

**Desktop: Horizontal con labels 30% / inputs 70%**
```
Label              ┌─────────────────────┐
                   │ Input               │
                   └─────────────────────┘
```

#### Tables

**Mobile: Cards verticales**
```
┌────────────────────┐
│ Juan Pérez         │
│ juan@email.com     │
│ Estado: Activo     │
│ [Acciones]         │
└────────────────────┘

┌────────────────────┐
│ María García       │
│ ...                │
└────────────────────┘
```

**Desktop: Tabla tradicional**
```
┌──────────┬─────────────┬────────┐
│ Nombre   │ Email       │ Estado │
├──────────┼─────────────┼────────┤
│ Juan P   │ juan@...    │ Activo │
└──────────┴─────────────┴────────┘
```

### 8.4 Touch Targets

**Tamaños mínimos (WCAG 2.1):**
```
Mínimo recomendado: 44×44px
Óptimo: 48×48px

Botones móviles:
- Altura mínima: 44px
- Padding horizontal: 16px mínimo
- Spacing entre elementos tocables: 8px
```

**Áreas táctiles expandidas:**
```css
/* Aumentar área de click sin cambiar visual */
.button {
  position: relative;
}

.button::after {
  content: '';
  position: absolute;
  inset: -8px; /* Expande área 8px en todas direcciones */
}
```

### 8.5 Estrategia Mobile-First

**Proceso de Diseño:**

1. **Diseñar para móvil primero** (320px-640px)
   - Interfaz más simple y enfocada
   - Contenido prioritario visible
   - Navegación simplificada

2. **Expandir a tablet** (641px-1023px)
   - Agregar columnas
   - Mostrar más información
   - Navegación híbrida

3. **Optimizar para desktop** (1024px+)
   - Máximo aprovechamiento del espacio
   - Navegación completa
   - Funcionalidades avanzadas

**Ejemplo: Detalle de Propuesta**

**Mobile (320px):**
```
[Header sticky]
┌─────────────────┐
│ ← Volver        │
├─────────────────┤
│ Imagen          │
│                 │
│ Título          │
│                 │
│ @autor • fecha  │
│                 │
│ Descripción...  │
│                 │
│ [Badges]        │
│                 │
│ Progress bar    │
│ 650/1000        │
│                 │
│ ⏱️ 15 días      │
│                 │
│ [APOYAR]        │ ← Botón fijo abajo
└─────────────────┘
```

**Desktop (1024px):**
```
[Header]
┌─────────────────────────────────────────────┐
│ ← Propuestas                                │
└─────────────────────────────────────────────┘

┌───────────────────┬─────────────┐
│ [Imagen grande]   │ Sidebar:    │
│                   │             │
│ Título H1         │ Progress    │
│                   │ 650/1000    │
│ @autor • fecha    │ ━━━━━▒▒▒▒   │
│                   │             │
│ [Badges]          │ ⏱️ 15 días   │
│                   │             │
│ Descripción larga │ Stats       │
│ con formato rich  │ - Vistas    │
│ text...           │ - Shares    │
│                   │             │
│                   │ [APOYAR]    │
│                   │ [Compartir] │
│                   │             │
│ Sección comentarios│ Related:    │
│ ...               │ [Prop 1]    │
│                   │ [Prop 2]    │
└───────────────────┴─────────────┘
```

### 8.6 Imágenes Responsive

**Picture element con múltiples tamaños:**

```html
<picture>
  <!-- Mobile: 640px width -->
  <source
    media="(max-width: 640px)"
    srcset="proposal-mobile.webp 640w,
            proposal-mobile@2x.webp 1280w"
    type="image/webp"
  />

  <!-- Tablet: 1024px width -->
  <source
    media="(max-width: 1024px)"
    srcset="proposal-tablet.webp 1024w,
            proposal-tablet@2x.webp 2048w"
    type="image/webp"
  />

  <!-- Desktop: 1920px width -->
  <source
    srcset="proposal-desktop.webp 1920w,
            proposal-desktop@2x.webp 3840w"
    type="image/webp"
  />

  <!-- Fallback -->
  <img
    src="proposal-desktop.jpg"
    alt="Título de la propuesta"
    loading="lazy"
  />
</picture>
```

**Lazy loading:**
```html
<img
  src="placeholder.jpg"
  data-src="real-image.jpg"
  loading="lazy"
  alt="Descripción"
/>
```

### 8.7 Tipografía Responsive

**Fluid Typography con clamp:**

```css
/* H1: 32px mobile → 56px desktop */
h1 {
  font-size: clamp(2rem, 5vw, 3.5rem);
}

/* H2: 28px mobile → 40px desktop */
h2 {
  font-size: clamp(1.75rem, 4vw, 2.5rem);
}

/* Body: 16px mobile → 18px desktop */
body {
  font-size: clamp(1rem, 1.5vw, 1.125rem);
}
```

**Spacing responsive:**
```css
/* Padding sections: 32px mobile → 80px desktop */
.section {
  padding: clamp(2rem, 5vw, 5rem) 0;
}

/* Gap en grid: 16px mobile → 32px desktop */
.grid {
  gap: clamp(1rem, 2vw, 2rem);
}
```

---

## 9. PERSONALIZACIÓN EXTREMA DEL SISTEMA {#personalización}

### 9.1 Panel de Personalización Admin

**Ubicación:** ActiveAdmin > Settings > Appearance

#### Secciones del Panel

**A. Colores de Marca**
```
┌────────────────────────────────────────┐
│ COLORES DE MARCA                       │
├────────────────────────────────────────┤
│                                        │
│ Color Primario:                        │
│ ┌──────┐ #612d62  [Cambiar] [Reset]  │
│ │██████│                               │
│ └──────┘                               │
│ ℹ️ Usado en: Header, botones primarios,│
│   enlaces principales                  │
│                                        │
│ Color Secundario:                      │
│ ┌──────┐ #269283  [Cambiar] [Reset]  │
│ │██████│                               │
│ └──────┘                               │
│ ℹ️ Usado en: Botones secundarios,     │
│   estados de éxito                     │
│                                        │
│ Color Acento:                          │
│ ┌──────┐ #954e99  [Cambiar] [Reset]  │
│ │██████│                               │
│ └──────┘                               │
│                                        │
│ [🎨 Generar paleta completa]          │
│                                        │
│ ⚠️ Los cambios se aplicarán a toda    │
│   la plataforma instantáneamente       │
│                                        │
└────────────────────────────────────────┘
```

**B. Tipografía**
```
┌────────────────────────────────────────┐
│ TIPOGRAFÍA                             │
├────────────────────────────────────────┤
│                                        │
│ Fuente para Títulos:                   │
│ [Montserrat          ▼]               │
│                                        │
│ Previsualización:                      │
│ Título Grande                          │
│ Subtítulo mediano                      │
│                                        │
│ Fuente para Textos:                    │
│ [Inter               ▼]               │
│                                        │
│ Previsualización:                      │
│ Este es un párrafo de ejemplo con      │
│ la fuente seleccionada.                │
│                                        │
│ Fuentes disponibles:                   │
│ • Google Fonts (500+ fuentes)          │
│ • Adobe Fonts (con cuenta)             │
│ • Sistema (fuentes del navegador)      │
│ • Custom (subir fuente propia)         │
│                                        │
│ [+ Agregar fuente personalizada]       │
│                                        │
└────────────────────────────────────────┘
```

**C. Logos e Imágenes**
```
┌────────────────────────────────────────┐
│ LOGOS Y BRANDING                       │
├────────────────────────────────────────┤
│                                        │
│ Logo Principal (Header):               │
│ ┌──────────────┐                       │
│ │ [Logo Actual]│  [Cambiar] [Eliminar]│
│ └──────────────┘                       │
│ Formato: PNG, SVG (recomendado)        │
│ Tamaño: Max 200px altura               │
│                                        │
│ Logo Alternativo (Footer):             │
│ ┌──────────────┐                       │
│ │ [Logo Footer]│  [Cambiar]           │
│ └──────────────┘                       │
│                                        │
│ Favicon:                               │
│ [📁]  [Subir]  (32x32px, ICO/PNG)     │
│                                        │
│ Imagen Hero (Portada):                 │
│ ┌────────────────────────────┐         │
│ │ [Imagen actual]            │         │
│ │                            │         │
│ └────────────────────────────┘         │
│ [Cambiar]  [Galería] [Stock photos]   │
│ Dimensiones: 1920x1080px óptimo        │
│                                        │
└────────────────────────────────────────┘
```

**D. Temas Predefinidos**
```
┌────────────────────────────────────────┐
│ TEMAS PREDEFINIDOS                     │
├────────────────────────────────────────┤
│                                        │
│ Selecciona un tema base:               │
│                                        │
│ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐  │
│ │██████│ │██████│ │██████│ │██████│  │
│ │Morado│ │  Azul│ │  Rojo│ │ Verde│  │
│ │●    │ │  ○   │ │  ○   │ │  ○   │  │
│ └──────┘ └──────┘ └──────┘ └──────┘  │
│ Default Corporate Activista Ecológico │
│                                        │
│ ┌──────┐ ┌──────┐                     │
│ │██████│ │██████│                     │
│ │Naranj│ │Custom│                     │
│ │  ○   │ │  ○   │                     │
│ └──────┘ └──────┘                     │
│ Energía  Tu tema                       │
│                                        │
│ [Vista previa del tema seleccionado]   │
│                                        │
└────────────────────────────────────────┘
```

**E. Modo Claro/Oscuro**
```
┌────────────────────────────────────────┐
│ MODO CLARO / OSCURO                    │
├────────────────────────────────────────┤
│                                        │
│ Modo por defecto:                      │
│ ○ Claro                                │
│ ○ Oscuro                               │
│ ● Automático (según sistema)           │
│                                        │
│ Permitir cambio por usuario:           │
│ [✓] Sí  [ ] No                         │
│                                        │
│ Configuración Dark Mode:               │
│                                        │
│ Background oscuro:                     │
│ ┌──────┐ #1a1a1a  [Cambiar]          │
│ │██████│                               │
│ └──────┘                               │
│                                        │
│ Texto claro:                           │
│ ┌──────┐ #f5f5f5  [Cambiar]          │
│ │██████│                               │
│ └──────┘                               │
│                                        │
│ [Previsualizar en Dark Mode]          │
│                                        │
└────────────────────────────────────────┘
```

**F. Layout y Espaciado**
```
┌────────────────────────────────────────┐
│ LAYOUT Y ESPACIADO                     │
├────────────────────────────────────────┤
│                                        │
│ Ancho máximo del contenedor:           │
│ [1200] px  ├────●─────┤ 1920px        │
│                                        │
│ Espaciado entre secciones:             │
│ [ ] Compacto                           │
│ [●] Normal                             │
│ [ ] Amplio                             │
│                                        │
│ Border radius (esquinas redondeadas):  │
│ [6] px  ├─●───────┤ 20px              │
│                                        │
│ Sombras:                               │
│ [ ] Sin sombras                        │
│ [●] Sombras sutiles                    │
│ [ ] Sombras pronunciadas               │
│                                        │
│ Densidad de UI:                        │
│ [ ] Compacta (más info visible)        │
│ [●] Confortable (balanceada)           │
│ [ ] Espaciosa (max. breathing room)    │
│                                        │
└────────────────────────────────────────┘
```

**G. Componentes Personalizables**
```
┌────────────────────────────────────────┐
│ ESTILO DE COMPONENTES                  │
├────────────────────────────────────────┤
│                                        │
│ Botones:                               │
│ Estilo: [● Relleno  ○ Outline ○ Ghost]│
│ Forma:  [  Cuadrado  ●  Redondeado  ] │
│                                        │
│ Cards:                                 │
│ Bordes: [● Sí  ○ No]                  │
│ Sombra: [● Sí  ○ No]                  │
│ Hover:  [● Elevación  ○ Borde color]  │
│                                        │
│ Inputs:                                │
│ Estilo: [● Filled  ○ Outlined]        │
│ Tamaño: [  S  ● M  L  ]               │
│                                        │
│ Navegación:                            │
│ Sticky: [✓] Sí  [ ] No                │
│ Transparente inicial: [ ] Sí  [✓] No │
│                                        │
└────────────────────────────────────────┘
```

**H. Previsualización en Tiempo Real**
```
┌────────────────────────────────────────┐
│ PREVISUALIZACIÓN                       │
├────────────────────────────────────────┤
│                                        │
│ ┌────────────────────────────────────┐ │
│ │ ← → ⟳ [Vista previa en vivo]      │ │
│ ├────────────────────────────────────┤ │
│ │ [Header con cambios aplicados]     │ │
│ │                                    │ │
│ │ Contenido de ejemplo               │ │
│ │ [Botón] [Botón secundario]         │ │
│ │                                    │ │
│ │ [Card de ejemplo]                  │ │
│ │                                    │ │
│ └────────────────────────────────────┘ │
│                                        │
│ Dispositivo:  [📱 Móvil] [📱 Tablet] [🖥️ Desktop]│
│                                        │
│ [↗️ Abrir en nueva pestaña]           │
│                                        │
└────────────────────────────────────────┘
```

**I. Guardar y Publicar**
```
┌────────────────────────────────────────┐
│                                        │
│ [💾 Guardar borrador]                  │
│                                        │
│ [👁️ Previsualizar cambios]            │
│                                        │
│ [✓ Publicar cambios]                  │
│ ⚠️ Los cambios serán visibles para     │
│   todos los usuarios inmediatamente    │
│                                        │
│ [↶ Restaurar tema anterior]           │
│                                        │
│ [📤 Exportar tema] [📥 Importar tema]  │
│                                        │
└────────────────────────────────────────┘
```

### 9.2 Implementación Técnica de Personalización

#### Backend (Rails)

```ruby
# app/models/theme_setting.rb
class ThemeSetting < ApplicationRecord
  # Singleton pattern - solo 1 configuración activa
  def self.current
    first_or_create(
      primary_color: '#612d62',
      secondary_color: '#269283',
      accent_color: '#954e99'
    )
  end

  has_one_attached :logo
  has_one_attached :logo_footer
  has_one_attached :favicon
  has_one_attached :hero_image

  validates :primary_color, :secondary_color, :accent_color,
            format: { with: /\A#[0-9A-Fa-f]{6}\z/ }

  # Genera CSS variables
  def to_css
    <<~CSS
      :root {
        --color-primary: #{primary_color};
        --color-secondary: #{secondary_color};
        --color-accent: #{accent_color};

        /* Generar variantes automáticamente */
        #{generate_color_variants(:primary, primary_color)}
        #{generate_color_variants(:secondary, secondary_color)}

        /* Tipografía */
        --font-heading: #{heading_font || "'Montserrat', sans-serif"};
        --font-body: #{body_font || "'Inter', sans-serif"};

        /* Layout */
        --container-max-width: #{container_width || 1200}px;
        --border-radius: #{border_radius || 6}px;

        /* Espaciado */
        --spacing-multiplier: #{spacing_density || 1};
      }
    CSS
  end

  private

  def generate_color_variants(name, hex)
    # Usa biblioteca de colores para generar tonos
    color = Color::RGB.from_html(hex)

    variants = []
    [50, 100, 200, 300, 400, 500, 600, 700, 800, 900].each do |shade|
      lightness = calculate_lightness(shade)
      variant_color = color.adjust_lightness(lightness)
      variants << "--color-#{name}-#{shade}: #{variant_color.to_hex};"
    end

    variants.join("\n        ")
  end

  def calculate_lightness(shade)
    # Mapeo de shade a lightness adjustment
    {
      50 => 0.4, 100 => 0.3, 200 => 0.2, 300 => 0.1,
      400 => 0.05, 500 => 0, 600 => -0.1, 700 => -0.2,
      800 => -0.3, 900 => -0.4
    }[shade] || 0
  end
end
```

```ruby
# app/controllers/admin/theme_settings_controller.rb
module Admin
  class ThemeSettingsController < ApplicationController
    def edit
      @theme_setting = ThemeSetting.current
    end

    def update
      @theme_setting = ThemeSetting.current

      if @theme_setting.update(theme_params)
        # Invalida cache de CSS
        Rails.cache.delete('theme_css')

        # Regenera archivo CSS estático
        generate_theme_css

        redirect_to edit_admin_theme_setting_path,
                    notice: 'Tema actualizado correctamente'
      else
        render :edit
      end
    end

    private

    def theme_params
      params.require(:theme_setting).permit(
        :primary_color, :secondary_color, :accent_color,
        :heading_font, :body_font,
        :container_width, :border_radius, :spacing_density,
        :logo, :logo_footer, :favicon, :hero_image,
        :enable_dark_mode, :default_mode
      )
    end

    def generate_theme_css
      css_content = ThemeSetting.current.to_css

      File.write(
        Rails.root.join('app/assets/stylesheets/theme_generated.css'),
        css_content
      )
    end
  end
end
```

#### Frontend (CSS/JavaScript)

```css
/* app/assets/stylesheets/theme.css */

/* Este archivo usa las variables generadas dinámicamente */

.button--primary {
  background-color: var(--color-primary-600);
  color: white;
}

.button--primary:hover {
  background-color: var(--color-primary-700);
}

h1, h2, h3, h4, h5, h6 {
  font-family: var(--font-heading);
}

body {
  font-family: var(--font-body);
}

.container {
  max-width: var(--container-max-width);
}

.card {
  border-radius: var(--border-radius);
}

/* Espaciado dinámico */
.section {
  padding: calc(4rem * var(--spacing-multiplier)) 0;
}
```

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
<head>
  <!-- CSS generado dinámicamente -->
  <style id="theme-css">
    <%= ThemeSetting.current.to_css.html_safe %>
  </style>

  <!-- CSS estático del diseño -->
  <%= stylesheet_link_tag 'application' %>

  <!-- Logo dinámico -->
  <% if ThemeSetting.current.favicon.attached? %>
    <%= favicon_link_tag url_for(ThemeSetting.current.favicon) %>
  <% end %>
</head>
<body>
  <header>
    <% if ThemeSetting.current.logo.attached? %>
      <%= image_tag ThemeSetting.current.logo, alt: 'Logo', class: 'logo' %>
    <% else %>
      <%= image_tag 'logo-default.svg', alt: 'Logo', class: 'logo' %>
    <% end %>
  </header>

  <%= yield %>
</body>
</html>
```

### 9.3 Live Preview con JavaScript

```javascript
// app/assets/javascripts/admin/theme_preview.js

class ThemePreview {
  constructor() {
    this.iframe = document.getElementById('theme-preview-iframe');
    this.initColorPickers();
    this.initLiveUpdate();
  }

  initColorPickers() {
    // Color pickers con actualización en tiempo real
    document.querySelectorAll('input[type="color"]').forEach(picker => {
      picker.addEventListener('input', (e) => {
        this.updatePreview();
      });
    });
  }

  initLiveUpdate() {
    // Detecta cambios en cualquier input del formulario
    document.querySelector('#theme-form').addEventListener('input',
      this.debounce(() => this.updatePreview(), 300)
    );
  }

  updatePreview() {
    const formData = this.getFormData();
    const cssVars = this.generateCSSVars(formData);

    // Actualiza variables CSS en el iframe
    if (this.iframe && this.iframe.contentWindow) {
      const doc = this.iframe.contentDocument;
      const style = doc.getElementById('theme-css') || doc.createElement('style');
      style.id = 'theme-css';
      style.textContent = cssVars;

      if (!doc.getElementById('theme-css')) {
        doc.head.appendChild(style);
      }
    }
  }

  getFormData() {
    return {
      primaryColor: document.getElementById('theme_primary_color').value,
      secondaryColor: document.getElementById('theme_secondary_color').value,
      accentColor: document.getElementById('theme_accent_color').value,
      borderRadius: document.getElementById('theme_border_radius').value,
      // ... más campos
    };
  }

  generateCSSVars(data) {
    return `
      :root {
        --color-primary-600: ${data.primaryColor};
        --color-secondary-500: ${data.secondaryColor};
        --color-accent-500: ${data.accentColor};
        --border-radius: ${data.borderRadius}px;
      }
    `;
  }

  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }
}

// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('theme-form')) {
    new ThemePreview();
  }
});
```

### 9.4 Exportar/Importar Temas

```ruby
# app/services/theme_exporter.rb
class ThemeExporter
  def self.export(theme_setting)
    {
      version: '1.0',
      name: theme_setting.name || 'Custom Theme',
      colors: {
        primary: theme_setting.primary_color,
        secondary: theme_setting.secondary_color,
        accent: theme_setting.accent_color
      },
      typography: {
        heading: theme_setting.heading_font,
        body: theme_setting.body_font
      },
      layout: {
        container_width: theme_setting.container_width,
        border_radius: theme_setting.border_radius,
        spacing_density: theme_setting.spacing_density
      },
      components: {
        button_style: theme_setting.button_style,
        card_style: theme_setting.card_style
      },
      exported_at: Time.current.iso8601
    }.to_json
  end

  def self.import(json_data)
    data = JSON.parse(json_data)

    ThemeSetting.current.update!(
      primary_color: data.dig('colors', 'primary'),
      secondary_color: data.dig('colors', 'secondary'),
      # ... resto de campos
    )
  end
end
```

**Uso:**
```ruby
# Exportar
theme_json = ThemeExporter.export(ThemeSetting.current)
File.write('my-theme.json', theme_json)

# Importar
theme_json = File.read('downloaded-theme.json')
ThemeExporter.import(theme_json)
```

---

## 10. GUÍA DE IMPLEMENTACIÓN VISUAL {#guía-implementación}

### 10.1 Workflow Diseñador → Desarrollador

#### Fase 1: Diseño en Figma (4 semanas)

**Semana 1: Fundamentos**
- [ ] Crear archivo Figma del proyecto
- [ ] Definir Design Tokens (Auto Layout variables)
- [ ] Crear paleta de colores (9 tonos por color)
- [ ] Definir escala tipográfica
- [ ] Crear biblioteca de iconos

**Semana 2: Componentes**
- [ ] Diseñar atoms (30 componentes)
- [ ] Diseñar molecules (15 componentes)
- [ ] Crear variantes para cada componente
- [ ] Diseñar estados (hover, active, disabled)
- [ ] Documentar uso de cada componente

**Semana 3: Templates**
- [ ] Diseñar 15 páginas principales
  - Home (logged out / logged in)
  - Propuestas (listado / detalle)
  - Impulsa (landing / wizard / proyecto)
  - Microcréditos
  - Votaciones
  - Perfil de usuario
  - Panel admin
- [ ] Variantes mobile/tablet/desktop

**Semana 4: Prototipos e Interacciones**
- [ ] Crear prototipos navegables
- [ ] Definir microinteracciones
- [ ] Documentar animaciones (Lottie)
- [ ] Crear style guide completo
- [ ] Presentación a stakeholders

#### Fase 2: Handoff y Documentación (1 semana)

**Entregables para Desarrolladores:**

1. **Archivo Figma organizado**
   ```
   📁 PlebisHub Design System
   ├── 📄 Cover (portada con info)
   ├── 📑 Design Tokens
   ├── 🎨 Colors
   ├── 📝 Typography
   ├── 🔤 Icons
   ├── 🧩 Components
   │   ├── Atoms
   │   ├── Molecules
   │   └── Organisms
   ├── 📱 Mobile Designs
   ├── 💻 Desktop Designs
   └── 📖 Documentation
   ```

2. **Figma Dev Mode habilitado**
   - CSS variables exportables
   - Medidas automáticas
   - Assets descargables

3. **Zeplin/Figma Inspect**
   - Especificaciones exactas
   - Assets exportados (SVG, PNG @2x, WebP)
   - Código CSS sugerido

4. **Storybook mockups** (opcional pero recomendado)
   - Diseños de cada componente en Storybook
   - Props y variantes documentadas

5. **Guía de estilo PDF**
   - Paleta de colores con hex codes
   - Tipografía (fuentes, tamaños, weights)
   - Espaciado (grids, padding, margins)
   - Componentes (anatomía visual)
   - Iconografía (naming, uso)

#### Fase 3: Implementación Desarrollo (8 semanas)

**Semana 1-2: Setup y Tokens**
- [ ] Configurar CSS custom properties
- [ ] Implementar design tokens
- [ ] Setup de tipografías
- [ ] Crear utilidades CSS

**Semana 3-4: Componentes Atoms**
- [ ] Buttons
- [ ] Inputs
- [ ] Checkboxes/Radios
- [ ] Badges
- [ ] Icons
- Testing de componentes

**Semana 5-6: Componentes Molecules y Organisms**
- [ ] Cards
- [ ] Forms
- [ ] Modals
- [ ] Navigation
- [ ] Tables
- Testing e integración

**Semana 7-8: Páginas y QA**
- [ ] Implementar todas las páginas
- [ ] Responsive testing
- [ ] Cross-browser testing
- [ ] Accessibility audit
- [ ] Performance optimization

### 10.2 Checklist de Calidad de Diseño

#### Antes de entregar a desarrollo:

**Consistencia:**
- [ ] Todos los componentes usan tokens definidos
- [ ] Espaciado coherente (múltiplos de 4px o 8px)
- [ ] Colores de la paleta (no colores custom)
- [ ] Tipografía de la escala definida
- [ ] Iconos del mismo sistema
- [ ] Border radius consistente

**Completitud:**
- [ ] Todas las páginas clave diseñadas
- [ ] Variantes mobile/tablet/desktop
- [ ] Estados hover, active, disabled
- [ ] Estados empty, loading, error
- [ ] Flujos completos (happy path + errores)

**Accesibilidad:**
- [ ] Contraste mínimo 4.5:1 para texto normal
- [ ] Contraste mínimo 3:1 para texto grande
- [ ] Touch targets mínimo 44x44px
- [ ] Estados de foco visibles
- [ ] Alt text definido para imágenes
- [ ] Jerarquía de headings correcta

**Responsive:**
- [ ] Breakpoints definidos
- [ ] Comportamiento en cada breakpoint
- [ ] Imágenes responsive
- [ ] Tipografía responsive
- [ ] Navegación mobile

**Documentación:**
- [ ] Nombre de componentes claro
- [ ] Descripción de uso
- [ ] Variantes explicadas
- [ ] Do's y Don'ts
- [ ] Ejemplos de uso real

### 10.3 Herramientas de Colaboración

#### Figma Plugins Recomendados:

1. **Design Tokens**
   - Figma Tokens
   - Design System Manager

2. **Accesibilidad**
   - Stark (contrast checker)
   - A11y - Color Contrast Checker

3. **Handoff**
   - Anima (Figma to Code)
   - Figma to HTML/CSS

4. **Assets**
   - Iconify
   - Unsplash (para placeholders)
   - Content Reel (para contenido fake)

5. **Productividad**
   - Auto Layout
   - Component Master
   - Find and Replace

#### Comunicación Diseño ↔ Desarrollo:

**Daily sync (15 min):**
- Componentes listos para implementar hoy
- Dudas del dev sobre specs
- Feedback de componentes ya implementados

**Weekly review (1 hora):**
- Demo de componentes implementados
- Ajustes necesarios
- Planificación próxima semana

**Herramientas:**
- Slack channel #design-dev
- Figma comments para dudas específicas
- Loom videos para explicar interacciones complejas

---

## 11. HERRAMIENTAS Y ASSETS RECOMENDADOS {#herramientas}

### 11.1 Software de Diseño

**Figma** (RECOMENDADO) ⭐
- **Precio:** Gratis para 1 proyecto, $12/mes profesional
- **Pros:**
  - Colaboración en tiempo real
  - Dev Mode para handoff
  - Plugins ecosystem
  - Versionado automático
  - Prototipado avanzado
- **Contras:**
  - Requiere internet
  - Curva de aprendizaje media

**Adobe XD**
- **Precio:** $9.99/mes
- **Pros:**
  - Integración con Adobe Suite
  - Performance en archivos grandes
- **Contras:**
  - Menos plugins que Figma
  - Colaboración limitada

**Sketch** (Solo Mac)
- **Precio:** $99/año
- **Pros:**
  - Potente para diseño UI
  - Muchos plugins
- **Contras:**
  - Solo macOS
  - Colaboración menos fluida

**Penpot** (Open Source)
- **Precio:** Gratis
- **Pros:**
  - Open source
  - Web-based
  - SVG native
- **Contras:**
  - Menos maduro
  - Menos recursos/comunidad

**RECOMENDACIÓN: Figma**
- Mejor balance features/precio/colaboración

### 11.2 Prototipado e Interacciones

**Figma Prototyping** ⭐
- Integrado en Figma
- Smart animate
- Suficiente para 90% de casos

**ProtoPie**
- Interacciones complejas
- Sensores (giroscopio, voz)
- $25/mes

**Principle**
- Animaciones timeline-based
- Solo Mac
- $129 one-time

**Framer**
- Código + diseño
- React-based
- $20/mes

### 11.3 Iconografía

**Lucide Icons** (RECOMENDADO) ⭐
- **URL:** https://lucide.dev
- **Cantidad:** 1000+ iconos
- **Estilo:** Outline, consistente
- **Formato:** SVG, React, Vue components
- **Licencia:** MIT (gratis)
- **Pros:**
  - Moderno y limpio
  - Open source
  - Fácil integración
  - Customizable

**Heroicons**
- **URL:** https://heroicons.com
- **Cantidad:** 292 iconos
- **Estilo:** Outline y Solid
- **Por:** Tailwind Labs
- **Licencia:** MIT

**Phosphor Icons**
- **URL:** https://phosphoricons.com
- **Cantidad:** 7,000+ iconos
- **Estilo:** 6 pesos diferentes
- **Licencia:** MIT

**Font Awesome 6**
- **URL:** https://fontawesome.com
- **Cantidad:** 2,000+ gratuitos
- **Estilo:** Solid, Regular, Brands
- **Licencia:** Gratis + Pro ($99/año)
- **Pros:** Muy conocido, mucha variedad
- **Contras:** Iconos gratuitos limitados, webfont pesado

**Material Icons**
- **URL:** https://fonts.google.com/icons
- **Cantidad:** 2,000+
- **Por:** Google
- **Licencia:** Apache 2.0

**RECOMENDACIÓN: Lucide Icons**
- Estilo más moderno
- Mejor integración con frameworks
- Completamente gratis
- Consistencia visual superior

### 11.4 Tipografías

#### Google Fonts (Gratis) ⭐

**Para Headings:**
- **Montserrat** (actual, mantener) - Geometric sans
- **Poppins** - Circular, friendly
- **Space Grotesk** - Moderno, tech
- **Plus Jakarta Sans** - Elegante, profesional

**Para Body:**
- **Inter** (RECOMENDADO) ⭐ - Diseñado para screens
- **Public Sans** - Similar a Inter, gobierno
- **Work Sans** - Versátil, legible
- **IBM Plex Sans** - Corporativo

**Para Display:**
- **Unbounded** - Curvas, moderno
- **Cabinet Grotesk** - Editorial
- **Syne** - Geométrico futurista

#### Adobe Fonts (Con Creative Cloud)

- **Acumin Pro** - Versatil sans
- **Source Sans 3** - Open source, Adobe
- **Proxima Nova** - Clásico moderno

#### Fuentes Premium

**MyFonts / Fonts.com**
- **Avenir Next** - $35-200
- **Gotham** - $199
- **Circular** (Spotify) - $199

**RECOMENDACIÓN:**
- **Primary:** Inter (Google Fonts - Gratis)
- **Display:** Montserrat (mantener identidad actual)
- **Fallback:** System fonts

### 11.5 Fotografía e Imágenes

**Stock Photos Gratuitas:**

**Unsplash** ⭐
- **URL:** https://unsplash.com
- **Calidad:** Alta resolución
- **Licencia:** Unsplash License (uso libre)
- **Temas:** Muy variado, comunidad grande

**Pexels**
- **URL:** https://www.pexels.com
- **Calidad:** Alta
- **Licencia:** Pexels License (libre)
- **Videos:** También incluye videos stock

**Pixabay**
- **URL:** https://pixabay.com
- **Calidad:** Variable
- **Licencia:** Pixabay License
- **Variedad:** Fotos, vectores, ilustraciones

**Stock Photos Premium:**

**Getty Images**
- Calidad profesional máxima
- Desde $175/imagen

**Shutterstock**
- Plan mensual desde $49/mes (10 imágenes)
- Gran variedad

**RECOMENDACIÓN: Unsplash**
- Gratis
- Alta calidad
- Suficiente para la mayoría de necesidades

### 11.6 Ilustraciones

**unDraw** (RECOMENDADO) ⭐
- **URL:** https://undraw.co
- **Estilo:** Flat, minimalista
- **Customización:** Color personalizable
- **Licencia:** Open source, gratis
- **Formato:** SVG

**Storyset**
- **URL:** https://storyset.com
- **Estilo:** Animated illustrations
- **Licencia:** Gratis con atribución
- **Formato:** SVG animado, After Effects

**Open Doodles**
- **URL:** https://opendoodles.com
- **Estilo:** Hand-drawn
- **Licencia:** CC0 (dominio público)

**Humaaans**
- **URL:** https://humaaans.com
- **Estilo:** Personajes modulares
- **Customización:** Mix & match
- **Licencia:** Gratis

### 11.7 Herramientas de Color

**Coolors** ⭐
- **URL:** https://coolors.co
- **Función:** Generador de paletas
- **Features:**
  - Generación random
  - Ajuste HSL individual
  - Exportar en múltiples formatos
  - Explorar paletas populares

**Adobe Color**
- **URL:** https://color.adobe.com
- **Función:** Rueda de color, armonías
- **Features:**
  - Reglas de armonía (complementarios, tríada, etc)
  - Extractor de paletas de imágenes
  - Accesibilidad (contraste)

**Paletton**
- **URL:** https://paletton.com
- **Función:** Diseño de esquemas de color
- **Features:**
  - Simulación daltonismo
  - Previsualización en diseño
  - Esquemas monocromáticos, complementarios, etc

**Contrast Checker**
- **URL:** https://webaim.org/resources/contrastchecker/
- **Función:** Verificar contraste WCAG
- **Features:**
  - Ratios AA y AAA
  - Sugerencias de ajuste

### 11.8 Optimización de Assets

**TinyPNG** ⭐
- **URL:** https://tinypng.com
- **Función:** Compresión PNG/JPEG
- **Reducción:** 70% típico sin pérdida visual
- **Batch:** 20 imágenes gratis

**Squoosh**
- **URL:** https://squoosh.app
- **Por:** Google
- **Función:** Compresión avanzada
- **Formatos:** WebP, AVIF, MozJPEG
- **Features:** Comparación before/after

**SVGOMG**
- **URL:** https://jakearchibald.github.io/svgomg/
- **Función:** Optimización SVG
- **Reducción:** 30-50% típico
- **Features:** Control granular de optimizaciones

**ImageOptim** (Mac)
- **App nativa:** Arrastra y suelta
- **Batch processing**
- **Lossless y lossy**

### 11.9 Accesibilidad

**WAVE** (Web Accessibility Evaluation Tool)
- **URL:** https://wave.webaim.org
- **Función:** Audit automático
- **Browser extension:** Chrome, Firefox

**axe DevTools**
- **Browser extension**
- **Función:** Testing WCAG en dev
- **Features:** Audit automático + guided tests

**Lighthouse**
- **Integrado en Chrome DevTools**
- **Función:** Audit performance + a11y
- **Score:** /100

**Color Oracle**
- **App:** Simulación daltonismo
- **Plataformas:** Windows, Mac, Linux
- **Gratis**

### 11.10 Prototipado y Wireframing

**Figma** (ya mencionado)
- Todo en uno

**Whimsical**
- **URL:** https://whimsical.com
- **Función:** Wireframes rápidos, flowcharts
- **Pros:** Muy rápido, colaborativo
- **Precio:** $10/mes

**Balsamiq**
- **URL:** https://balsamiq.com
- **Función:** Wireframes low-fidelity
- **Estilo:** Sketch look
- **Precio:** $90/year

**Excalidraw**
- **URL:** https://excalidraw.com
- **Función:** Diagramas hand-drawn
- **Licencia:** Open source, gratis
- **Features:** Colaborativo, no login

---

## 12. PLAN DE TRABAJO Y TIMELINE {#plan-trabajo}

### 12.1 Roadmap Completo del Rediseño

#### Fase 0: Descubrimiento y Planificación (2 semanas)

**Semana 1: Research**
- [ ] Audit del diseño actual (completado ✓)
- [ ] Análisis de competencia
- [ ] User interviews (5-10 usuarios)
- [ ] Análisis de analytics
- [ ] Definir KPIs de éxito

**Deliverables:**
- Documento de research
- User personas actualizadas
- Problemas priorizados

**Semana 2: Estrategia**
- [ ] Workshop con stakeholders
- [ ] Definir objetivos del rediseño
- [ ] Crear project brief
- [ ] Definir scope y prioridades
- [ ] Asignar equipo y roles

**Deliverables:**
- Design brief
- Roadmap visual
- Matriz de prioridades

#### Fase 1: Fundamentos del Design System (3 semanas)

**Semana 3: Design Tokens**
- [ ] Definir paleta de colores expandida (9 tonos × 6 colores)
- [ ] Escala tipográfica modular
- [ ] Sistema de espaciado
- [ ] Tokens de bordes, sombras, animaciones
- [ ] Documentar decisiones

**Deliverables:**
- Figma: Página de tokens
- CSV/JSON exportable de tokens

**Semana 4: Tipografía e Iconografía**
- [ ] Seleccionar fuentes finales
- [ ] Crear escala tipográfica responsive
- [ ] Definir line-heights, letter-spacing
- [ ] Seleccionar sistema de iconos
- [ ] Crear biblioteca de iconos en Figma

**Deliverables:**
- Typography style guide
- Icon library (Figma + SVG)

**Semana 5: Componentes Base (Atoms)**
- [ ] Diseñar 30 componentes atoms
- [ ] Crear variantes (sizes, states)
- [ ] Documentar cada componente
- [ ] Crear componentes en Figma con Auto Layout

**Deliverables:**
- Figma: 30 componentes atoms
- Documento de especificaciones

#### Fase 2: Componentes y Patrones (4 semanas)

**Semana 6-7: Molecules**
- [ ] Cards (5 variantes)
- [ ] Forms (inputs, selects, textareas)
- [ ] Alerts y Toasts
- [ ] Modals
- [ ] Dropdowns
- [ ] Tabs
- [ ] Tooltips
- [ ] Progress bars

**Deliverables:**
- 15 componentes molecules
- Estados y variantes
- Uso documentado

**Semana 8-9: Organisms**
- [ ] Navigation (desktop + mobile)
- [ ] Header + Footer
- [ ] Hero sections
- [ ] Proposal cards
- [ ] Data tables
- [ ] Wizards multi-step
- [ ] User dashboard widgets
- [ ] Stats dashboards

**Deliverables:**
- 10 organismos complejos
- Responsive behaviors
- Interacciones definidas

#### Fase 3: Páginas y Flujos (5 semanas)

**Semana 10: Páginas Públicas**
- [ ] Home (logged out)
- [ ] Login / Registro
- [ ] Propuestas (listado)
- [ ] Propuesta (detalle)
- [ ] Info pages
- [ ] Footer pages

**Deliverables:**
- 6 páginas desktop
- 6 páginas mobile
- Prototipos navegables

**Semana 11-12: Páginas de Usuario**
- [ ] Home (logged in)
- [ ] Mi perfil
- [ ] Mis propuestas
- [ ] Mis proyectos Impulsa
- [ ] Mis colaboraciones
- [ ] Notificaciones
- [ ] Configuración

**Deliverables:**
- 7 páginas con estados (empty, loading, error)
- Flows de navegación

**Semana 13: Impulsa y Microcréditos**
- [ ] Impulsa landing
- [ ] Wizard crear proyecto (5 pasos)
- [ ] Proyecto detail
- [ ] Microcréditos landing
- [ ] Solicitud préstamo
- [ ] Dashboard microcréditos

**Deliverables:**
- 2 módulos completos
- Wizards interactivos

**Semana 14: Votaciones y Admin**
- [ ] Portal votaciones
- [ ] Booth de votación
- [ ] Resultados
- [ ] Panel admin (reskin ActiveAdmin)
- [ ] Dashboard admin

**Deliverables:**
- Módulo votaciones completo
- Tema custom ActiveAdmin

#### Fase 4: Documentación y Handoff (2 semanas)

**Semana 15: Style Guide**
- [ ] Compilar style guide completo
- [ ] Sección de colores
- [ ] Sección de tipografía
- [ ] Todos los componentes
- [ ] Do's and Don'ts
- [ ] Ejemplos de uso

**Deliverables:**
- PDF style guide (50-80 páginas)
- Figma organizado y limpio

**Semana 16: Dev Handoff**
- [ ] Preparar Figma para Dev Mode
- [ ] Exportar assets (SVG, PNG @2x, WebP)
- [ ] Crear Zeplin/Figma Inspect
- [ ] Video walkthrough del diseño
- [ ] Reunión de handoff con devs

**Deliverables:**
- Assets organizados (zip)
- Specs de componentes
- Video explicativo

#### Fase 5: Desarrollo Frontend (12 semanas)

**Semana 17-18: Setup**
- [ ] Configurar entorno (Vite/importmap)
- [ ] Instalar dependencias
- [ ] Setup CSS custom properties
- [ ] Crear tokens CSS
- [ ] Setup de fuentes

**Deliverables:**
- Proyecto configurado
- Tokens implementados

**Semana 19-22: Componentes (4 semanas)**
- [ ] Atoms (2 semanas)
  - Buttons, inputs, badges, avatars, icons
  - Testing unitario
- [ ] Molecules (2 semanas)
  - Cards, forms, alerts, modals, tabs
  - Testing de integración

**Deliverables:**
- 45 componentes funcionales
- Tests > 80% coverage
- Storybook con todos los componentes

**Semana 23-26: Páginas (4 semanas)**
- [ ] Páginas públicas (1 semana)
- [ ] Páginas de usuario (1.5 semanas)
- [ ] Impulsa + Microcréditos (1 semana)
- [ ] Votaciones + Admin (0.5 semana)

**Deliverables:**
- 20+ páginas implementadas
- Responsive en 3 breakpoints
- Cross-browser tested

**Semana 27-28: QA y Optimización (2 semanas)**
- [ ] Lighthouse audit (score > 90)
- [ ] WCAG audit (nivel AA)
- [ ] Cross-browser testing (Chrome, Firefox, Safari, Edge)
- [ ] Mobile testing (iOS, Android)
- [ ] Performance optimization
- [ ] Fix de bugs encontrados

**Deliverables:**
- Aplicación production-ready
- Reporte de QA
- Mejoras de performance aplicadas

#### Fase 6: Sistema de Personalización (3 semanas)

**Semana 29-30: Panel Admin**
- [ ] Implementar ThemeSetting model
- [ ] CRUD de configuración
- [ ] Panel de personalización (UI)
- [ ] Live preview
- [ ] Generador de CSS dinámico

**Deliverables:**
- Panel funcional en ActiveAdmin
- Preview en tiempo real

**Semana 31: Exportar/Importar + Testing**
- [ ] Exportar tema a JSON
- [ ] Importar tema desde JSON
- [ ] Galería de temas predefinidos
- [ ] Testing de personalización
- [ ] Documentación para admins

**Deliverables:**
- Sistema de theming completo
- 5 temas predefinidos
- Guía de uso

#### Fase 7: Launch (2 semanas)

**Semana 32: Pre-launch**
- [ ] Testing final en staging
- [ ] Load testing
- [ ] Preparar plan de rollback
- [ ] Comunicación a usuarios
- [ ] Entrenamiento a admins

**Semana 33: Launch + Monitoreo**
- [ ] Deploy a producción (gradual)
- [ ] Monitoreo 24/7 primera semana
- [ ] Hotfixes si necesario
- [ ] Recolección de feedback
- [ ] Ajustes post-launch

**Deliverables:**
- Aplicación en producción
- Usuarios migrados
- Feedback recolectado

### 12.2 Timeline Visual

```
FASE 0: Descubrimiento        ██ (2 semanas)
FASE 1: Fundamentos           ███ (3 semanas)
FASE 2: Componentes           ████ (4 semanas)
FASE 3: Páginas y Flujos      █████ (5 semanas)
FASE 4: Documentación         ██ (2 semanas)
FASE 5: Desarrollo            ████████████ (12 semanas)
FASE 6: Personalización       ███ (3 semanas)
FASE 7: Launch                ██ (2 semanas)
─────────────────────────────────────────────
TOTAL:                        33 semanas (7.5 meses)
```

### 12.3 Equipo y Roles

**Equipo Mínimo:**

| Rol | Dedicación | Fases |
|-----|-----------|-------|
| **Diseñador UX/UI Senior** | Full-time | 0-4 (16 semanas) |
| **Desarrollador Frontend Senior** | Full-time | 5-7 (17 semanas) |
| **Desarrollador Frontend Junior** | Full-time | 5-7 (apoyo) |
| **QA Engineer** | Part-time | 5-7 (testing) |
| **Product Manager** | Part-time | Todo el proyecto |

**Equipo Óptimo:**

| Rol | Dedicación |
|-----|-----------|
| **UX Researcher** | Part-time (Fase 0) |
| **Diseñador UX/UI Senior** | Full-time |
| **Diseñador UI Junior** | Full-time (apoyo componentes) |
| **Desarrollador Frontend Senior** | Full-time |
| **Desarrollador Frontend Mid** | Full-time |
| **Desarrollador Backend** | Part-time (API, theming) |
| **QA Engineer** | Full-time (últimas 6 semanas) |
| **Product Manager** | Full-time |

### 12.4 Presupuesto Estimado

**Opción 1: Equipo In-House (España)**

| Rol | Salario Mensual | Meses | Total |
|-----|-----------------|-------|-------|
| Diseñador Senior | €4,000 | 4 | €16,000 |
| Dev Frontend Senior | €5,000 | 4.5 | €22,500 |
| Dev Frontend Junior | €3,000 | 4.5 | €13,500 |
| QA Engineer | €3,500 | 1.5 | €5,250 |
| Product Manager | €4,500 | 8 (50%) | €18,000 |
| **Subtotal Equipo** | | | **€75,250** |
| Software/Tools | | | €2,000 |
| Buffer (15%) | | | €11,587 |
| **TOTAL** | | | **€88,837** |

**Opción 2: Equipo Remoto (Internacional)**

| Rol | Salario Mensual | Meses | Total |
|-----|-----------------|-------|-------|
| Diseñador Senior | €3,000 | 4 | €12,000 |
| Dev Frontend Senior | €4,000 | 4.5 | €18,000 |
| Dev Frontend Mid | €2,500 | 4.5 | €11,250 |
| QA Engineer | €2,000 | 1.5 | €3,000 |
| Product Manager | €3,000 | 8 (50%) | €12,000 |
| **Subtotal Equipo** | | | **€56,250** |
| Software/Tools | | | €1,500 |
| Buffer (15%) | | | €8,662 |
| **TOTAL** | | | **€66,412** |

**Opción 3: Agencia Especializada**

- **Rango:** €80,000 - €150,000
- **Incluye:** Todo el diseño + desarrollo
- **Pros:** Experiencia, portfolio, garantías
- **Contras:** Menos control, handoff al final

### 12.5 Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| **Scope creep** | Alta | Alto | Definir scope cerrado, change requests formales |
| **Retrasos en diseño** | Media | Medio | Buffer 15%, checkpoints semanales |
| **Incompatibilidad navegadores** | Media | Alto | Testing early, polyfills preparados |
| **Performance issues** | Media | Alto | Lighthouse desde día 1, lazy loading |
| **Resistencia al cambio** | Media | Medio | Involucrar usuarios en beta, comunicación clara |
| **Bugs en producción** | Alta | Alto | QA exhaustivo, rollback plan, gradual rollout |
| **Personalización rompe diseño** | Media | Alto | Validaciones, preview obligatorio, límites razonables |

### 12.6 KPIs de Éxito

**Métricas de Negocio:**
- ↑ Conversión registro: +30% (objetivo)
- ↑ Propuestas creadas: +40%
- ↑ Proyectos Impulsa: +50%
- ↓ Tasa de abandono: -40%
- ↑ Tiempo en plataforma: +25%

**Métricas Técnicas:**
- Lighthouse Score: > 90/100
- First Contentful Paint: < 1.5s
- Time to Interactive: < 3s
- Cumulative Layout Shift: < 0.1
- WCAG Level: AA (100%)

**Métricas de Usuario:**
- NPS (Net Promoter Score): > 50
- Satisfacción diseño: > 4.5/5
- Facilidad de uso: > 4.3/5
- Comentarios positivos: > 80%

### 12.7 Plan de Comunicación

**Interna (Equipo):**
- Daily standup (15min)
- Weekly review (1h)
- Sprint planning (2h cada 2 semanas)
- Retrospectivas (1h cada mes)

**Con Stakeholders:**
- Demo quincenal (30min)
- Reporte mensual (documento)
- Presentación final (2h)

**Con Usuarios:**
- Anuncio previo (1 mes antes)
- Beta testing (2 semanas antes)
- Tutorial de cambios (video + docs)
- Soporte durante transición (2 semanas)

---

## CONCLUSIÓN

Este documento proporciona una visión completa y detallada del rediseño del front-end de PlebisHub. Con un enfoque en:

✅ **Modernización** - Tecnologías actuales y mejores prácticas
✅ **Personalización** - Sistema extremadamente flexible desde admin
✅ **Accesibilidad** - WCAG AA como estándar
✅ **Performance** - Lighthouse > 90
✅ **Escalabilidad** - Design System para futuro crecimiento

**Próximos Pasos:**

1. **Revisión de este documento** con stakeholders
2. **Aprobación de presupuesto** y timeline
3. **Contratación/asignación** de equipo
4. **Kick-off** del proyecto
5. **Fase 0: Descubrimiento** (inicio inmediato)

---

**Contacto para dudas:**
- Diseñador Principal: [email]
- Project Manager: [email]
- Tech Lead: [email]

**Documentos relacionados:**
- [ ] Documento Técnico para Desarrollador Front-End (próximo)
- [ ] Especificación de API REST
- [ ] Plan de Testing y QA
- [ ] Guía de Migración y Rollback

---

*Versión 1.0 - Noviembre 2025*
*PlebisHub Front-End Redesign Project*
