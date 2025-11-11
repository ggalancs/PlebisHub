# DOCUMENTO TÉCNICO PARA DESARROLLADOR FRONT-END
# Refactorización y Modernización del Front-End de PlebisHub

**Versión:** 1.0
**Fecha:** 11 de Noviembre de 2025
**Autor:** Análisis Técnico Front-End
**Proyecto:** PlebisHub - Plataforma de Participación Ciudadana

---

## TABLA DE CONTENIDOS

1. [Resumen Ejecutivo Técnico](#1-resumen-ejecutivo-técnico)
2. [Arquitectura Actual - Análisis Profundo](#2-arquitectura-actual---análisis-profundo)
3. [Stack Tecnológico Propuesto](#3-stack-tecnológico-propuesto)
4. [Estrategia de Migración](#4-estrategia-de-migración)
5. [Sistema de Diseño - Implementación Técnica](#5-sistema-de-diseño---implementación-técnica)
6. [Componentes - Código y Patrones](#6-componentes---código-y-patrones)
7. [Personalización Extrema - Arquitectura](#7-personalización-extrema---arquitectura)
8. [Testing y Calidad](#8-testing-y-calidad)
9. [Performance y Optimización](#9-performance-y-optimización)
10. [Build Tools y Deployment](#10-build-tools-y-deployment)
11. [Integración con Rails Engines](#11-integración-con-rails-engines)
12. [Plan de Implementación Técnico](#12-plan-de-implementación-técnico)

---

## 1. RESUMEN EJECUTIVO TÉCNICO

### 1.1 Estado Actual del Front-End

**Stack Tecnológico Detectado:**
- Rails 7.2.3 con Asset Pipeline (Sprockets)
- Bootstrap 3.4.1 (lanzado en 2014, 11 años obsoleto)
- jQuery 3.x + jquery_ujs
- CoffeeScript mezclado con JavaScript ES5
- Turbolinks para navegación
- Font Awesome 4.7 (obsoleto)
- Sin bundler moderno (sin Webpack/Vite)
- Sin framework reactivo (sin Vue/React/Svelte)

**Problemas Críticos Identificados:**

1. **Deuda Técnica Severa:**
   - Bootstrap 3.4.1 no recibe actualizaciones de seguridad desde 2019
   - CoffeeScript es un lenguaje en desuso desde 2017
   - Asset Pipeline es más lento que bundlers modernos

2. **Mantenibilidad:**
   - 194 archivos ERB con lógica mezclada
   - Estilos no modularizados (2,467 líneas en general.css.scss)
   - Sin componentes reutilizables
   - Selectores CSS profundamente anidados (>5 niveles)

3. **Performance:**
   - Sin tree-shaking (código muerto en producción)
   - Sin code-splitting (bundle monolítico)
   - Sin lazy-loading de imágenes
   - Sin optimización de Critical CSS

4. **Personalización:**
   - Colores hardcodeados en 50+ lugares
   - Sin sistema de theming
   - Imposible personalizar sin modificar código

**Métricas Actuales:**

```
Total CSS/SCSS:        4,849 líneas
Total JavaScript/CS:     652 líneas
Archivos ERB:            194 archivos
Engines Rails:           8 módulos
Tamaño bundle (est.):    ~450 KB (no optimizado)
Lighthouse Score:        ~65-70/100 (estimado)
```

### 1.2 Objetivos de la Refactorización

**Objetivos Técnicos:**

1. **Modernización del Stack:**
   - Migrar a bundler moderno (Vite 5.x)
   - Actualizar a Bootstrap 5.3+ o Tailwind CSS
   - Eliminar CoffeeScript → JavaScript ES2023+
   - Implementar framework reactivo (Vue 3 recomendado)

2. **Arquitectura de Componentes:**
   - Sistema de Design Tokens
   - Componentes Web (Web Components o SFC)
   - Atomic Design Pattern
   - Storybook para documentación

3. **Personalización Extrema:**
   - ThemingEngine con CSS Custom Properties
   - Panel de administración para customización
   - Preview en tiempo real
   - Export/Import de temas

4. **Performance:**
   - Reducir bundle a <150 KB (gzip)
   - Lighthouse Score >90/100
   - Core Web Vitals: LCP <2.5s, FID <100ms, CLS <0.1
   - Tree-shaking automático

5. **Developer Experience:**
   - Hot Module Replacement (HMR)
   - TypeScript para type-safety
   - ESLint + Prettier
   - Husky + lint-staged

**Métricas Objetivo:**

```
Bundle Size:           <150 KB (gzip)
Lighthouse Score:      >90/100
Time to Interactive:   <3 segundos
Test Coverage:         >80%
Build Time:            <30 segundos
```

### 1.3 ROI Técnico

**Beneficios Cuantificables:**

- **Performance:** 40-60% reducción en tiempo de carga
- **Mantenimiento:** 70% menos tiempo para cambios CSS
- **Bugs:** 50% reducción en bugs de UI (con TypeScript)
- **Onboarding:** 80% más rápido para nuevos devs (componentes documentados)

---

## 2. ARQUITECTURA ACTUAL - ANÁLISIS PROFUNDO

### 2.1 Estructura de Archivos Actual

**Análisis del árbol de archivos:**

```
app/
├── assets/
│   ├── stylesheets/
│   │   ├── application.css
│   │   ├── general.css.scss          # 2,467 líneas (PROBLEMA: monolítico)
│   │   ├── bootstrap_custom.css.sass # Bootstrap 3 overrides
│   │   ├── forms.css.scss            # Formtastic styles
│   │   ├── admin.css.scss            # ActiveAdmin styles
│   │   └── [otros 12 archivos]
│   ├── javascripts/
│   │   ├── application.js            # Manifest Sprockets
│   │   ├── general.js                # jQuery DOM manipulation
│   │   ├── general.js.coffee         # CoffeeScript mezclado
│   │   └── [otros 8 archivos]
│   └── images/
│       └── [assets estáticos]
├── views/
│   ├── layouts/
│   │   ├── application.html.erb     # Layout principal
│   │   └── admin.html.erb
│   └── [194 archivos ERB total]
└── helpers/
    └── application_helper.rb

engines/
├── plebis_cms/
├── plebis_participation/
├── plebis_proposals/
├── plebis_impulsa/
├── plebis_verification/
├── plebis_microcredit/
├── plebis_votes/
└── plebis_collaborations/
```

**Problemas de Arquitectura:**

```ruby
# PROBLEMA 1: Manifest Sprockets obsoleto
# app/assets/javascripts/application.js
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require_tree .  # ❌ Carga TODO sin tree-shaking
```

```scss
// PROBLEMA 2: CSS monolítico sin modularización
// app/assets/stylesheets/general.css.scss (2,467 líneas)

// Colores hardcodeados en múltiples lugares
$brand-primary: #612d62;  // Repetido 47 veces
$brand-secondary: #269283; // Repetido 34 veces

// Selectores profundamente anidados (>7 niveles)
.main-content {
  .container {
    .row {
      .col-md-8 {
        .card {
          .card-body {
            .title {
              .icon { } // ❌ 7 niveles de anidación
            }
          }
        }
      }
    }
  }
}

// Media queries no mobile-first
@media (max-width: 768px) { } // ❌ Debería ser min-width
```

```coffeescript
# PROBLEMA 3: CoffeeScript obsoleto
# app/assets/javascripts/general.js.coffee

$ ->
  # Código sin modularizar
  $('.btn').click ->
    $(this).toggleClass('active')  # ❌ jQuery soup
```

### 2.2 Análisis de Dependencias

**Archivo Gemfile - Dependencias Front-End:**

```ruby
# Gemfile (extracto front-end)
gem 'bootstrap-sass', '~> 3.4.1'      # ⚠️ CRÍTICO: 11 años obsoleto
gem 'sass-rails'                       # Asset Pipeline
gem 'uglifier'                         # ⚠️ Minificador obsoleto (usar Terser)
gem 'coffee-rails'                     # ⚠️ CoffeeScript deprecado
gem 'jquery-rails'                     # jQuery (OK para Rails UJS)
gem 'turbolinks', '~> 5'              # OK, pero Turbo mejor
gem 'font-awesome-sass', '~> 4.7'     # ⚠️ Versión obsoleta (actual: 6.x)
gem 'formtastic'                       # Form builder (OK)
```

**Dependencias JavaScript Detectadas:**

```javascript
// Sprockets manifest actual
//= require jquery               // 87 KB
//= require jquery_ujs           // 8 KB
//= require turbolinks           // 15 KB
//= require bootstrap            // 141 KB (Bootstrap 3 completo)
//= require_tree .               // ~50 KB (todo el directorio)
// TOTAL: ~300 KB sin minificar, ~150 KB minificado (sin gzip)
```

**Análisis de Seguridad:**

```bash
# Vulnerabilidades conocidas en Bootstrap 3.4.1:
# - CVE-2019-8331: XSS en tooltip/popover
# - CVE-2018-14041: XSS en collapse
# - CVE-2018-14042: XSS en dropdown

# jQuery 3.x: Relativamente seguro, pero versiones <3.5 tienen vulnerabilidades
```

### 2.3 Análisis de Performance Actual

**Métricas Estimadas (sin acceso a producción):**

```
Primera Carga:
├── HTML:                ~15 KB
├── CSS:                 ~180 KB (sin gzip)
├── JavaScript:          ~150 KB (minificado)
├── Imágenes:            ~200 KB (promedio)
└── TOTAL:               ~545 KB

Lighthouse Score Estimado:
├── Performance:         65-70/100
├── Accessibility:       75-80/100
├── Best Practices:      70-75/100
└── SEO:                 80-85/100

Core Web Vitals Estimados:
├── LCP:                 3.5-4.5 segundos  (❌ Objetivo: <2.5s)
├── FID:                 150-250 ms        (❌ Objetivo: <100ms)
└── CLS:                 0.15-0.25         (❌ Objetivo: <0.1)
```

**Bottlenecks Identificados:**

1. **Render-Blocking Resources:**
   ```html
   <!-- application.html.erb -->
   <%= stylesheet_link_tag 'application' %>  <!-- ❌ Bloquea render -->
   <%= javascript_include_tag 'application' %> <!-- ❌ Sin defer/async -->
   ```

2. **Sin Lazy Loading:**
   ```erb
   <!-- Imágenes cargadas eagerly -->
   <%= image_tag 'hero.jpg', class: 'img-responsive' %> <!-- ❌ Sin loading="lazy" -->
   ```

3. **Sin Code Splitting:**
   - Todo el JavaScript se carga en primera carga
   - No hay chunks por ruta/engine

---

## 3. STACK TECNOLÓGICO PROPUESTO

### 3.1 Opciones de Stack (3 Alternativas)

#### OPCIÓN A: Modernización Conservadora (Recomendado para PlebisHub)

**Stack:**
```
Frontend Framework:    Vue 3 + Composition API
Build Tool:            Vite 5.x
CSS Framework:         Tailwind CSS 3.4+
Type System:          TypeScript 5.x
Testing:              Vitest + Testing Library
Package Manager:       pnpm
Rails Integration:     vite_rails gem
```

**Pros:**
- ✅ Curva de aprendizaje moderada
- ✅ Integración nativa con Rails (vite_rails)
- ✅ Vue 3 es reactivo pero menos complejo que React
- ✅ Tailwind permite customización extrema fácilmente
- ✅ Vite es el bundler más rápido (10-100x vs Webpack)

**Cons:**
- ⚠️ Requiere aprender Vue si el equipo no lo conoce
- ⚠️ Tailwind requiere cambio de mentalidad CSS

**Justificación para PlebisHub:**
- Rails Engines se integran perfectamente con Vue SFC
- Tailwind facilita el theming dinámico con CSS variables
- TypeScript previene bugs en formularios complejos

#### OPCIÓN B: Full JavaScript SPA

**Stack:**
```
Frontend:          Next.js 14 (React) o Nuxt 3 (Vue)
Backend:           Rails API-only mode
Comunicación:      REST o GraphQL (Apollo)
Deployment:        Frontend separado (Vercel/Netlify)
```

**Pros:**
- ✅ Separación total front/back
- ✅ Ecosistema JavaScript más grande
- ✅ SSR/SSG para mejor SEO

**Cons:**
- ❌ Requiere reescribir TODAS las vistas (194 archivos ERB)
- ❌ Pérdida de funcionalidades Rails (helpers, i18n, asset pipeline)
- ❌ Complejidad de deployment aumenta significativamente
- ❌ Turbo/Stimulus no funcionan

**Justificación contra:**
No recomendado para PlebisHub porque los 8 Rails Engines están fuertemente acoplados a vistas ERB.

#### OPCIÓN C: Rails Moderno con Hotwire

**Stack:**
```
Frontend:          Hotwire (Turbo + Stimulus)
CSS:               Tailwind CSS
Build:             Importmaps o esbuild
JS Sprinkles:      Stimulus Controllers
```

**Pros:**
- ✅ Mínima refactorización de ERB
- ✅ Filosofía "HTML-over-the-wire" de Rails 7
- ✅ No requiere framework JavaScript pesado

**Cons:**
- ❌ Stimulus es limitado para componentes complejos
- ❌ Dificulta personalización extrema del UI
- ❌ No hay componentes reutilizables reales

**Justificación contra:**
No cumple el requisito de "personalización extrema" porque Stimulus no permite theming dinámico fácilmente.

### 3.2 Stack Recomendado: OPCIÓN A (Detallado)

**Arquitectura Propuesta:**

```
┌─────────────────────────────────────────────────────┐
│                   NAVEGADOR                          │
│  ┌────────────────────────────────────────────┐    │
│  │         Vue 3 App (Islands)                │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐│    │
│  │  │ Island 1 │  │ Island 2 │  │ Island 3 ││    │
│  │  │ (Header) │  │ (Sidebar)│  │ (Voting) ││    │
│  │  └──────────┘  └──────────┘  └──────────┘│    │
│  │         ↓              ↓             ↓     │    │
│  │         Shared State (Pinia Store)        │    │
│  └────────────────────────────────────────────┘    │
│                      ↕ HTTP/Turbo                   │
│  ┌────────────────────────────────────────────┐    │
│  │         ERB Templates (Rails)              │    │
│  │  <%= vite_vue_component 'VoteButton' %>    │    │
│  └────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
                        ↕
┌─────────────────────────────────────────────────────┐
│                 RAILS SERVER                         │
│  ┌────────────────────────────────────────────┐    │
│  │         Controllers + Engines              │    │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐│    │
│  │  │ Proposals│  │ Votes    │  │ CMS      ││    │
│  │  │ Engine   │  │ Engine   │  │ Engine   ││    │
│  │  └──────────┘  └──────────┘  └──────────┘│    │
│  └────────────────────────────────────────────┘    │
│  ┌────────────────────────────────────────────┐    │
│  │         Models + Database                  │    │
│  │  ┌──────────┐  ┌──────────┐               │    │
│  │  │PostgreSQL│  │ Redis    │               │    │
│  │  └──────────┘  └──────────┘               │    │
│  └────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

**Tecnologías Específicas:**

```json
{
  "packageManager": "pnpm@8.15.0",
  "dependencies": {
    "vue": "^3.4.0",
    "pinia": "^2.1.7",
    "@vueuse/core": "^10.7.0",
    "tailwindcss": "^3.4.0",
    "@headlessui/vue": "^1.7.16",
    "vee-validate": "^4.12.0",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^5.0.0",
    "vite": "^5.0.0",
    "typescript": "^5.3.0",
    "vitest": "^1.2.0",
    "@vue/test-utils": "^2.4.0",
    "tailwindcss": "^3.4.0",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.56.0",
    "prettier": "^3.1.1"
  }
}
```

**Gems Rails:**

```ruby
# Gemfile additions
gem 'vite_rails', '~> 3.0'      # Vite integration
gem 'vite_vue_plugin'            # Vue SFC support
gem 'tailwindcss-rails'          # Tailwind integration

# Remove obsolete gems
# gem 'bootstrap-sass'           # ❌ Eliminar
# gem 'coffee-rails'             # ❌ Eliminar
# gem 'uglifier'                 # ❌ Eliminar (Vite minifica)
```

### 3.3 Configuración Vite

**vite.config.ts:**

```typescript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import RubyPlugin from 'vite-plugin-ruby'
import path from 'path'

export default defineConfig({
  plugins: [
    vue(),
    RubyPlugin(),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './app/frontend'),
      '@components': path.resolve(__dirname, './app/frontend/components'),
      '@composables': path.resolve(__dirname, './app/frontend/composables'),
      '@stores': path.resolve(__dirname, './app/frontend/stores'),
    },
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vue-vendor': ['vue', 'pinia'],
          'ui-vendor': ['@headlessui/vue'],
          'utils': ['@vueuse/core'],
        },
      },
    },
    target: 'es2020',
    cssCodeSplit: true,
    sourcemap: process.env.NODE_ENV === 'development',
  },
  server: {
    hmr: {
      host: 'localhost',
      protocol: 'ws',
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './app/frontend/test/setup.ts',
    coverage: {
      provider: 'istanbul',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'app/frontend/test/'],
    },
  },
})
```

**tailwind.config.js:**

```javascript
const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/frontend/**/*.{vue,js,ts}',
    './app/views/**/*.{erb,haml,html}',
    './app/helpers/**/*.rb',
    './engines/*/app/views/**/*.{erb,haml,html}',
  ],
  darkMode: 'class', // Soporte dark mode
  theme: {
    extend: {
      colors: {
        primary: {
          50: 'rgb(var(--color-primary-50) / <alpha-value>)',
          100: 'rgb(var(--color-primary-100) / <alpha-value>)',
          200: 'rgb(var(--color-primary-200) / <alpha-value>)',
          300: 'rgb(var(--color-primary-300) / <alpha-value>)',
          400: 'rgb(var(--color-primary-400) / <alpha-value>)',
          500: 'rgb(var(--color-primary-500) / <alpha-value>)',
          600: 'rgb(var(--color-primary-600) / <alpha-value>)',
          700: 'rgb(var(--color-primary-700) / <alpha-value>)',
          800: 'rgb(var(--color-primary-800) / <alpha-value>)',
          900: 'rgb(var(--color-primary-900) / <alpha-value>)',
          950: 'rgb(var(--color-primary-950) / <alpha-value>)',
        },
        secondary: {
          // Same pattern...
        },
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
        display: ['Montserrat', ...defaultTheme.fontFamily.sans],
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        '112': '28rem',
        '128': '32rem',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'slide-down': 'slideDown 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        slideDown: {
          '0%': { transform: 'translateY(-10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
  ],
}
```

---

## 4. ESTRATEGIA DE MIGRACIÓN

### 4.1 Enfoque: Migración Incremental (Strangler Fig Pattern)

**Filosofía:** No hacer "big bang rewrite". Migrar componente por componente mientras la app sigue funcionando.

```
Fase 1: Setup (Semanas 1-2)
├── Instalar Vite + Vue 3
├── Configurar Tailwind
├── Crear primer componente de prueba
└── Verificar pipeline CI/CD

Fase 2: Fundamentos (Semanas 3-5)
├── Sistema de Design Tokens
├── Componentes básicos (Button, Input, Card)
├── Mirar ERB → Vue
└── Documentar en Storybook

Fase 3: Migración Por Engine (Semanas 6-14)
├── Engine 1: plebis_cms (2 semanas)
├── Engine 2: plebis_proposals (3 semanas)
├── Engine 3: plebis_participation (2 semanas)
├── Engine 4: plebis_votes (2 semanas)
├── Engines restantes (5 semanas)
└── Cada engine mantiene funcionalidad durante migración

Fase 4: Customization System (Semanas 15-17)
├── ThemeSetting model + admin panel
├── Live preview system
└── Theme export/import

Fase 5: Testing + Optimization (Semanas 18-20)
├── Test coverage >80%
├── Performance audit
└── Accessibility audit
```

### 4.2 Instalación del Nuevo Stack

**Paso 1: Instalar Vite Rails**

```bash
# Gemfile
gem 'vite_rails', '~> 3.0'

# Instalar gem
bundle install

# Instalar Vite
bundle exec vite install

# Resultado: Crea estructura
# app/frontend/
#   ├── entrypoints/
#   │   └── application.js
#   └── components/
```

**Paso 2: Configurar pnpm + Vue 3**

```bash
# Instalar pnpm globalmente
npm install -g pnpm

# Inicializar proyecto frontend
pnpm init

# Instalar dependencias core
pnpm add vue@^3.4.0 pinia@^2.1.7

# Instalar devDependencies
pnpm add -D @vitejs/plugin-vue@^5.0.0 \
            vite@^5.0.0 \
            typescript@^5.3.0 \
            @vue/tsconfig@^0.5.1
```

**package.json resultante:**

```json
{
  "name": "plebis-hub-frontend",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "lint": "eslint . --ext .vue,.js,.jsx,.cjs,.mjs,.ts,.tsx,.cts,.mts --fix",
    "format": "prettier --write 'app/frontend/**/*.{js,ts,vue,css}'"
  },
  "dependencies": {
    "vue": "^3.4.0",
    "pinia": "^2.1.7",
    "@vueuse/core": "^10.7.0",
    "@headlessui/vue": "^1.7.16",
    "@heroicons/vue": "^2.1.1",
    "vee-validate": "^4.12.0",
    "yup": "^1.3.3",
    "axios": "^1.6.5"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^5.0.0",
    "@vue/test-utils": "^2.4.0",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.56.0",
    "eslint-plugin-vue": "^9.19.2",
    "jsdom": "^24.0.0",
    "postcss": "^8.4.33",
    "prettier": "^3.1.1",
    "tailwindcss": "^3.4.0",
    "typescript": "^5.3.0",
    "vite": "^5.0.0",
    "vite-plugin-ruby": "^5.0.0",
    "vitest": "^1.2.0"
  }
}
```

**Paso 3: Configurar TypeScript**

```typescript
// tsconfig.json
{
  "extends": "@vue/tsconfig/tsconfig.dom.json",
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "strict": true,
    "jsx": "preserve",
    "sourceMap": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./app/frontend/*"],
      "@components/*": ["./app/frontend/components/*"],
      "@composables/*": ["./app/frontend/composables/*"],
      "@stores/*": ["./app/frontend/stores/*"],
      "@types/*": ["./app/frontend/types/*"]
    }
  },
  "include": [
    "app/frontend/**/*.ts",
    "app/frontend/**/*.d.ts",
    "app/frontend/**/*.tsx",
    "app/frontend/**/*.vue"
  ],
  "exclude": ["node_modules"]
}
```

**Paso 4: Instalar Tailwind CSS**

```bash
# Instalar Tailwind
pnpm add -D tailwindcss@^3.4.0 postcss autoprefixer

# Generar config
npx tailwindcss init -p
```

```javascript
// postcss.config.js
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
```

```css
/* app/frontend/stylesheets/application.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Custom base styles */
@layer base {
  :root {
    /* Design tokens - populated dynamically */
    --color-primary-50: 248 247 248;
    --color-primary-600: 97 45 98;
    --color-primary-700: 74 34 75;
    /* ...more tokens... */
  }

  body {
    @apply font-sans text-gray-900 antialiased;
  }
}

@layer components {
  /* Component classes if needed */
  .btn-primary {
    @apply px-6 py-3 bg-primary-600 text-white rounded-lg;
    @apply hover:bg-primary-700 focus:ring-4 focus:ring-primary-200;
    @apply transition-all duration-300;
  }
}
```

**Paso 5: Configurar Layout Rails**

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="csrf-token" content="<%= form_authenticity_token %>">

  <title><%= content_for?(:title) ? yield(:title) : "PlebisHub" %></title>

  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <%# Vite CSS %>
  <%= vite_client_tag %>
  <%= vite_stylesheet_tag 'application' %>

  <%# Custom theme CSS variables %>
  <%= content_for :custom_theme_css %>

  <%# Preload critical fonts %>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Montserrat:wght@600;700;800&display=swap" rel="stylesheet">
</head>
<body class="<%= body_classes %>" data-controller="theme">
  <%# Vue mount point para header %>
  <div id="app-header"
       data-user="<%= current_user.to_json if current_user %>">
  </div>

  <%= yield %>

  <%# Vue mount point para footer %>
  <div id="app-footer"></div>

  <%# Vite JavaScript %>
  <%= vite_javascript_tag 'application' %>

  <%# Pass Rails data to Vue %>
  <script>
    window.PlebisHub = {
      csrfToken: '<%= form_authenticity_token %>',
      currentUser: <%= raw current_user.to_json if current_user else 'null' %>,
      locale: '<%= I18n.locale %>',
      environment: '<%= Rails.env %>',
    };
  </script>
</body>
</html>
```

### 4.3 Estrategia de Convivencia ERB + Vue

**Patrón "Islands Architecture":** Vue components viven como "islas" dentro de páginas ERB.

```erb
<!-- app/views/proposals/show.html.erb -->
<div class="container">
  <h1><%= @proposal.title %></h1>

  <%# ERB tradicional para contenido estático %>
  <div class="proposal-content">
    <%= simple_format @proposal.description %>
  </div>

  <%# Vue component para funcionalidad interactiva %>
  <div id="vote-widget"
       data-proposal-id="<%= @proposal.id %>"
       data-votes-count="<%= @proposal.votes_count %>"
       data-user-voted="<%= @proposal.voted_by?(current_user) %>">
  </div>

  <%# Vue component para comentarios %>
  <div id="comments-section"
       data-proposal-id="<%= @proposal.id %>">
  </div>
</div>

<script type="module">
  import { createApp } from 'vue'
  import VoteWidget from '@components/VoteWidget.vue'
  import CommentsSection from '@components/CommentsSection.vue'

  // Mount VoteWidget
  createApp(VoteWidget, {
    proposalId: <%= @proposal.id %>,
    initialVotesCount: <%= @proposal.votes_count %>,
    userVoted: <%= @proposal.voted_by?(current_user).to_json %>,
  }).mount('#vote-widget')

  // Mount CommentsSection
  createApp(CommentsSection, {
    proposalId: <%= @proposal.id %>,
  }).mount('#comments-section')
</script>
```

**Helper para simplificar:**

```ruby
# app/helpers/vue_helper.rb
module VueHelper
  def vue_component(component_name, props = {})
    element_id = "vue-#{component_name.parameterize}-#{SecureRandom.hex(4)}"

    content_tag(:div, '', id: element_id, data: { vue_component: component_name, vue_props: props.to_json }) +
    javascript_tag(<<~JS, type: 'module')
      import { createApp } from 'vue'
      import #{component_name} from '@components/#{component_name}.vue'

      const props = JSON.parse(document.querySelector('##{element_id}').dataset.vueProps)
      createApp(#{component_name}, props).mount('##{element_id}')
    JS
  end
end
```

Uso simplificado:

```erb
<%= vue_component('VoteWidget', {
  proposalId: @proposal.id,
  initialVotesCount: @proposal.votes_count
}) %>
```

### 4.4 Migración de Estilos: Bootstrap 3 → Tailwind

**Mapeo de clases comunes:**

```javascript
// migration-map.js - Referencia para migración
export const bootstrapToTailwind = {
  // Layout
  'container': 'container mx-auto px-4',
  'container-fluid': 'w-full px-4',
  'row': 'flex flex-wrap -mx-4',
  'col-md-6': 'w-full md:w-1/2 px-4',
  'col-md-4': 'w-full md:w-1/3 px-4',
  'col-md-8': 'w-full md:w-2/3 px-4',

  // Buttons
  'btn': 'inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2',
  'btn-primary': 'bg-primary-600 text-white hover:bg-primary-700 focus:ring-primary-500',
  'btn-secondary': 'bg-gray-600 text-white hover:bg-gray-700 focus:ring-gray-500',
  'btn-success': 'bg-green-600 text-white hover:bg-green-700 focus:ring-green-500',
  'btn-lg': 'px-6 py-3 text-base',
  'btn-sm': 'px-3 py-1.5 text-xs',

  // Typography
  'text-center': 'text-center',
  'text-right': 'text-right',
  'text-muted': 'text-gray-600',
  'lead': 'text-xl font-light',

  // Spacing
  'mt-3': 'mt-4',
  'mb-3': 'mb-4',
  'pt-3': 'pt-4',
  'pb-3': 'pb-4',

  // Alerts
  'alert': 'p-4 rounded-lg',
  'alert-success': 'bg-green-50 text-green-800 border border-green-200',
  'alert-danger': 'bg-red-50 text-red-800 border border-red-200',
  'alert-warning': 'bg-yellow-50 text-yellow-800 border border-yellow-200',
  'alert-info': 'bg-blue-50 text-blue-800 border border-blue-200',

  // Forms
  'form-control': 'block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500',
  'form-group': 'mb-4',
  'label': 'block text-sm font-medium text-gray-700 mb-1',

  // Cards
  'panel': 'bg-white rounded-lg shadow',
  'panel-heading': 'px-6 py-4 border-b border-gray-200',
  'panel-body': 'px-6 py-4',
  'panel-footer': 'px-6 py-4 border-t border-gray-200 bg-gray-50',

  // Visibility
  'hidden-xs': 'hidden sm:block',
  'visible-xs': 'block sm:hidden',
}
```

**Script de migración automática:**

```ruby
# lib/tasks/migrate_bootstrap_to_tailwind.rake
namespace :frontend do
  desc "Migrate Bootstrap classes to Tailwind in ERB files"
  task :migrate_styles => :environment do
    mapping = {
      'btn btn-primary' => 'btn-primary',
      'btn btn-secondary' => 'btn-secondary',
      'container' => 'container mx-auto px-4',
      # ...rest of mapping
    }

    Dir.glob('app/views/**/*.html.erb').each do |file|
      content = File.read(file)
      original = content.dup

      mapping.each do |bootstrap_class, tailwind_class|
        content.gsub!(/class=["']([^"']*)\b#{Regexp.escape(bootstrap_class)}\b([^"']*)["']/) do |match|
          other_classes = $1 + $2
          %{class="#{tailwind_class} #{other_classes}".strip}
        end
      end

      if content != original
        File.write(file, content)
        puts "✓ Updated #{file}"
      end
    end
  end
end
```

### 4.5 Migración de JavaScript: jQuery → Vue

**Patrón común jQuery → Vue:**

```javascript
// ANTES (jQuery)
$(document).ready(function() {
  $('.vote-button').click(function() {
    const proposalId = $(this).data('proposal-id')
    const button = $(this)

    $.ajax({
      url: `/proposals/${proposalId}/vote`,
      method: 'POST',
      headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') },
      success: function(data) {
        button.addClass('voted')
        button.find('.count').text(data.votes_count)
      },
      error: function() {
        alert('Error al votar')
      }
    })
  })
})
```

```vue
<!-- DESPUÉS (Vue 3) -->
<script setup lang="ts">
import { ref } from 'vue'
import axios from 'axios'

interface Props {
  proposalId: number
  initialVotesCount: number
  userVoted: boolean
}

const props = defineProps<Props>()

const votesCount = ref(props.initialVotesCount)
const isVoted = ref(props.userVoted)
const isLoading = ref(false)

const vote = async () => {
  if (isLoading.value) return

  isLoading.value = true

  try {
    const { data } = await axios.post(
      `/proposals/${props.proposalId}/vote`,
      {},
      {
        headers: {
          'X-CSRF-Token': window.PlebisHub.csrfToken,
        },
      }
    )

    votesCount.value = data.votes_count
    isVoted.value = true
  } catch (error) {
    console.error('Error voting:', error)
    alert('Error al votar')
  } finally {
    isLoading.value = false
  }
}
</script>

<template>
  <button
    @click="vote"
    :disabled="isLoading || isVoted"
    class="btn-primary"
    :class="{ 'opacity-50 cursor-not-allowed': isVoted }"
  >
    <span v-if="isLoading">Votando...</span>
    <span v-else-if="isVoted">✓ Votado</span>
    <span v-else>Votar</span>
    <span class="ml-2 count">{{ votesCount }}</span>
  </button>
</template>
```

**Ventajas del enfoque Vue:**
- ✅ Type-safety con TypeScript
- ✅ Reactivity automática (no más manual DOM updates)
- ✅ Testeable con Vue Test Utils
- ✅ Composable y reutilizable
- ✅ Mejor manejo de errores

### 4.6 Estrategia de Testing Durante Migración

**Test Pyramid:**

```
         /\
        /  \  E2E Tests (10%)
       /────\  Playwright/Cypress
      /      \
     /────────\  Integration Tests (30%)
    /          \ Vitest + Testing Library
   /────────────\
  /              \ Unit Tests (60%)
 /────────────────\ Vitest
```

**Setup de Vitest:**

```typescript
// app/frontend/test/setup.ts
import { expect, afterEach } from 'vitest'
import { cleanup } from '@testing-library/vue'
import matchers from '@testing-library/jest-dom/matchers'

expect.extend(matchers)

afterEach(() => {
  cleanup()
})

// Mock window.PlebisHub
global.window.PlebisHub = {
  csrfToken: 'test-token',
  currentUser: null,
  locale: 'es',
  environment: 'test',
}
```

**Ejemplo de test:**

```typescript
// app/frontend/components/__tests__/VoteWidget.spec.ts
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import VoteWidget from '../VoteWidget.vue'
import axios from 'axios'

vi.mock('axios')

describe('VoteWidget', () => {
  it('renders initial votes count', () => {
    const wrapper = mount(VoteWidget, {
      props: {
        proposalId: 1,
        initialVotesCount: 42,
        userVoted: false,
      },
    })

    expect(wrapper.text()).toContain('42')
  })

  it('calls API when vote button clicked', async () => {
    const mockPost = vi.mocked(axios.post)
    mockPost.mockResolvedValue({ data: { votes_count: 43 } })

    const wrapper = mount(VoteWidget, {
      props: {
        proposalId: 1,
        initialVotesCount: 42,
        userVoted: false,
      },
    })

    await wrapper.find('button').trigger('click')

    expect(mockPost).toHaveBeenCalledWith(
      '/proposals/1/vote',
      {},
      expect.objectContaining({
        headers: { 'X-CSRF-Token': 'test-token' },
      })
    )

    await wrapper.vm.$nextTick()
    expect(wrapper.text()).toContain('43')
  })

  it('disables button when already voted', () => {
    const wrapper = mount(VoteWidget, {
      props: {
        proposalId: 1,
        initialVotesCount: 42,
        userVoted: true,
      },
    })

    expect(wrapper.find('button').attributes('disabled')).toBeDefined()
  })
})
```

**Test de regresión visual con Storybook:**

```typescript
// app/frontend/components/VoteWidget.stories.ts
import type { Meta, StoryObj } from '@storybook/vue3'
import VoteWidget from './VoteWidget.vue'

const meta: Meta<typeof VoteWidget> = {
  title: 'Components/VoteWidget',
  component: VoteWidget,
  tags: ['autodocs'],
  argTypes: {
    initialVotesCount: { control: 'number' },
    userVoted: { control: 'boolean' },
  },
}

export default meta
type Story = StoryObj<typeof VoteWidget>

export const Default: Story = {
  args: {
    proposalId: 1,
    initialVotesCount: 42,
    userVoted: false,
  },
}

export const AlreadyVoted: Story = {
  args: {
    proposalId: 1,
    initialVotesCount: 42,
    userVoted: true,
  },
}

export const HighVoteCount: Story = {
  args: {
    proposalId: 1,
    initialVotesCount: 9999,
    userVoted: false,
  },
}
```

---

## 5. SISTEMA DE DISEÑO - IMPLEMENTACIÓN TÉCNICA

### 5.1 Design Tokens - Arquitectura

**Concepto:** Design tokens son las decisiones de diseño atomizadas y almacenadas como variables reutilizables.

**Estructura de Tokens:**

```
Design Tokens
├── Core Tokens (primitivos, inmutables)
│   ├── colors-core.json
│   ├── spacing-core.json
│   ├── typography-core.json
│   └── effects-core.json
├── Semantic Tokens (contextuales, derivan de core)
│   ├── colors-semantic.json
│   ├── components-semantic.json
│   └── layout-semantic.json
└── Theme Tokens (variantes de marca, dinámicos)
    ├── theme-default.json
    ├── theme-dark.json
    └── theme-custom.json (generado por admin)
```

**Implementación con Style Dictionary:**

```bash
pnpm add -D style-dictionary
```

```javascript
// style-dictionary.config.js
import StyleDictionary from 'style-dictionary'

const sd = StyleDictionary.extend({
  source: ['app/frontend/design-tokens/**/*.json'],
  platforms: {
    css: {
      transformGroup: 'css',
      buildPath: 'app/frontend/stylesheets/tokens/',
      files: [
        {
          destination: '_variables.css',
          format: 'css/variables',
          options: {
            outputReferences: true,
          },
        },
      ],
    },
    js: {
      transformGroup: 'js',
      buildPath: 'app/frontend/design-tokens/dist/',
      files: [
        {
          destination: 'tokens.js',
          format: 'javascript/es6',
        },
        {
          destination: 'tokens.d.ts',
          format: 'typescript/es6-declarations',
        },
      ],
    },
  },
})

sd.buildAllPlatforms()
```

**Tokens de Color (Ejemplo):**

```json
// app/frontend/design-tokens/colors-core.json
{
  "color": {
    "purple": {
      "50": { "value": "#f8f7f8" },
      "100": { "value": "#ede7ee" },
      "200": { "value": "#d6c9d7" },
      "300": { "value": "#bda2bf" },
      "400": { "value": "#a06ea2" },
      "500": { "value": "#884a8a" },
      "600": { "value": "#612d62" },
      "700": { "value": "#4a2249" },
      "800": { "value": "#351933" },
      "900": { "value": "#1f0e1f" },
      "950": { "value": "#0f070f" }
    },
    "green": {
      "50": { "value": "#f0faf8" },
      "100": { "value": "#d8f3ed" },
      "200": { "value": "#b0e7db" },
      "300": { "value": "#7fd6c5" },
      "400": { "value": "#4ec0aa" },
      "500": { "value": "#269283" },
      "600": { "value": "#1e7269" },
      "700": { "value": "#185a54" },
      "800": { "value": "#134643" },
      "900": { "value": "#0f3a38" },
      "950": { "value": "#06201f" }
    },
    "gray": {
      "50": { "value": "#f9fafb" },
      "100": { "value": "#f3f4f6" },
      "200": { "value": "#e5e7eb" },
      "300": { "value": "#d1d5db" },
      "400": { "value": "#9ca3af" },
      "500": { "value": "#6b7280" },
      "600": { "value": "#4b5563" },
      "700": { "value": "#374151" },
      "800": { "value": "#1f2937" },
      "900": { "value": "#111827" },
      "950": { "value": "#030712" }
    }
  }
}
```

```json
// app/frontend/design-tokens/colors-semantic.json
{
  "color": {
    "brand": {
      "primary": { "value": "{color.purple.600}" },
      "secondary": { "value": "{color.green.500}" },
      "accent": { "value": "{color.purple.400}" }
    },
    "text": {
      "primary": { "value": "{color.gray.900}" },
      "secondary": { "value": "{color.gray.600}" },
      "tertiary": { "value": "{color.gray.500}" },
      "inverse": { "value": "#ffffff" },
      "link": { "value": "{color.brand.primary}" }
    },
    "background": {
      "primary": { "value": "#ffffff" },
      "secondary": { "value": "{color.gray.50}" },
      "tertiary": { "value": "{color.gray.100}" }
    },
    "border": {
      "default": { "value": "{color.gray.200}" },
      "hover": { "value": "{color.gray.300}" },
      "focus": { "value": "{color.brand.primary}" }
    },
    "status": {
      "success": { "value": "{color.green.500}" },
      "error": { "value": "#ef4444" },
      "warning": { "value": "#f59e0b" },
      "info": { "value": "#3b82f6" }
    }
  }
}
```

**Output CSS Generado:**

```css
/* app/frontend/stylesheets/tokens/_variables.css */
:root {
  /* Core Colors */
  --color-purple-50: #f8f7f8;
  --color-purple-600: #612d62;
  --color-purple-700: #4a2249;
  --color-green-500: #269283;
  --color-green-600: #1e7269;

  /* Semantic Colors */
  --color-brand-primary: var(--color-purple-600);
  --color-brand-secondary: var(--color-green-500);
  --color-text-primary: var(--color-gray-900);
  --color-text-secondary: var(--color-gray-600);
  --color-background-primary: #ffffff;
  --color-border-default: var(--color-gray-200);
  --color-status-success: var(--color-green-500);

  /* Typography */
  --font-family-sans: 'Inter var', -apple-system, BlinkMacSystemFont, sans-serif;
  --font-family-display: 'Montserrat', var(--font-family-sans);

  --font-size-xs: 0.75rem;      /* 12px */
  --font-size-sm: 0.875rem;     /* 14px */
  --font-size-base: 1rem;       /* 16px */
  --font-size-lg: 1.125rem;     /* 18px */
  --font-size-xl: 1.25rem;      /* 20px */
  --font-size-2xl: 1.5rem;      /* 24px */
  --font-size-3xl: 1.875rem;    /* 30px */
  --font-size-4xl: 2.25rem;     /* 36px */
  --font-size-5xl: 3rem;        /* 48px */

  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;

  --line-height-tight: 1.25;
  --line-height-normal: 1.5;
  --line-height-relaxed: 1.75;

  /* Spacing (8px grid) */
  --spacing-0: 0;
  --spacing-1: 0.25rem;   /* 4px */
  --spacing-2: 0.5rem;    /* 8px */
  --spacing-3: 0.75rem;   /* 12px */
  --spacing-4: 1rem;      /* 16px */
  --spacing-5: 1.25rem;   /* 20px */
  --spacing-6: 1.5rem;    /* 24px */
  --spacing-8: 2rem;      /* 32px */
  --spacing-10: 2.5rem;   /* 40px */
  --spacing-12: 3rem;     /* 48px */
  --spacing-16: 4rem;     /* 64px */
  --spacing-20: 5rem;     /* 80px */
  --spacing-24: 6rem;     /* 96px */

  /* Border Radius */
  --radius-none: 0;
  --radius-sm: 0.125rem;  /* 2px */
  --radius-base: 0.25rem; /* 4px */
  --radius-md: 0.375rem;  /* 6px */
  --radius-lg: 0.5rem;    /* 8px */
  --radius-xl: 0.75rem;   /* 12px */
  --radius-2xl: 1rem;     /* 16px */
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-base: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);

  /* Transitions */
  --transition-fast: 150ms cubic-bezier(0.4, 0, 0.2, 1);
  --transition-base: 300ms cubic-bezier(0.4, 0, 0.2, 1);
  --transition-slow: 500ms cubic-bezier(0.4, 0, 0.2, 1);

  /* Z-Index Scale */
  --z-index-dropdown: 1000;
  --z-index-sticky: 1020;
  --z-index-fixed: 1030;
  --z-index-modal-backdrop: 1040;
  --z-index-modal: 1050;
  --z-index-popover: 1060;
  --z-index-tooltip: 1070;
}

/* Dark Mode Overrides */
[data-theme="dark"] {
  --color-text-primary: #f9fafb;
  --color-text-secondary: #d1d5db;
  --color-background-primary: #111827;
  --color-background-secondary: #1f2937;
  --color-background-tertiary: #374151;
  --color-border-default: #374151;
}
```

### 5.2 ThemeEngine - Personalización Dinámica

**Model Rails para Theme Settings:**

```ruby
# app/models/theme_setting.rb
class ThemeSetting < ApplicationRecord
  # == Schema Information
  # Table name: theme_settings
  #  id                 :bigint
  #  name               :string
  #  primary_color      :string
  #  secondary_color    :string
  #  accent_color       :string
  #  font_primary       :string
  #  font_display       :string
  #  logo_url           :string
  #  favicon_url        :string
  #  custom_css         :text
  #  is_active          :boolean default(FALSE)
  #  created_at         :datetime
  #  updated_at         :datetime

  validates :name, presence: true
  validates :primary_color, :secondary_color, format: { with: /\A#[0-9A-F]{6}\z/i }

  # Generar todas las variantes de color (50-950)
  def color_variants(hex_color)
    # Convertir hex a HSL
    hsl = hex_to_hsl(hex_color)

    # Generar 11 tonos
    {
      50 => adjust_lightness(hsl, 95),
      100 => adjust_lightness(hsl, 90),
      200 => adjust_lightness(hsl, 80),
      300 => adjust_lightness(hsl, 70),
      400 => adjust_lightness(hsl, 60),
      500 => hex_color, # Original
      600 => adjust_lightness(hsl, 40),
      700 => adjust_lightness(hsl, 30),
      800 => adjust_lightness(hsl, 20),
      900 => adjust_lightness(hsl, 10),
      950 => adjust_lightness(hsl, 5),
    }
  end

  # Generar CSS custom properties
  def to_css
    primary_variants = color_variants(primary_color)
    secondary_variants = color_variants(secondary_color)

    css = <<~CSS
      :root[data-theme="custom-#{id}"] {
        /* Primary Color Scale */
        #{generate_css_vars('color-primary', primary_variants)}

        /* Secondary Color Scale */
        #{generate_css_vars('color-secondary', secondary_variants)}

        /* Accent Color */
        --color-accent: #{accent_color};

        /* Typography */
        --font-family-primary: #{font_primary || 'Inter, sans-serif'};
        --font-family-display: #{font_display || 'Montserrat, sans-serif'};
      }
    CSS

    css += custom_css if custom_css.present?
    css
  end

  # Export theme como JSON
  def to_theme_json
    {
      name: name,
      colors: {
        primary: primary_color,
        secondary: secondary_color,
        accent: accent_color,
      },
      typography: {
        fontPrimary: font_primary,
        fontDisplay: font_display,
      },
      assets: {
        logo: logo_url,
        favicon: favicon_url,
      },
      customCSS: custom_css,
    }
  end

  # Import theme desde JSON
  def self.from_theme_json(json_data)
    create!(
      name: json_data[:name],
      primary_color: json_data.dig(:colors, :primary),
      secondary_color: json_data.dig(:colors, :secondary),
      accent_color: json_data.dig(:colors, :accent),
      font_primary: json_data.dig(:typography, :fontPrimary),
      font_display: json_data.dig(:typography, :fontDisplay),
      logo_url: json_data.dig(:assets, :logo),
      favicon_url: json_data.dig(:assets, :favicon),
      custom_css: json_data[:customCSS],
    )
  end

  private

  def hex_to_hsl(hex)
    # Implementación de conversión hex → HSL
    # (código omitido por brevedad, usar gem 'color' o implementar)
    Color::RGB.by_hex(hex).to_hsl
  end

  def adjust_lightness(hsl, lightness)
    # Retornar nuevo color con lightness ajustada
    Color::HSL.new(hsl.hue, hsl.saturation, lightness).to_rgb.hex
  end

  def generate_css_vars(prefix, variants)
    variants.map do |tone, hex|
      "  --#{prefix}-#{tone}: #{hex};"
    end.join("\n")
  end
end
```

**Migration:**

```ruby
# db/migrate/20250111000001_create_theme_settings.rb
class CreateThemeSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :theme_settings do |t|
      t.string :name, null: false
      t.string :primary_color, default: '#612d62'
      t.string :secondary_color, default: '#269283'
      t.string :accent_color, default: '#954e99'
      t.string :font_primary, default: 'Inter'
      t.string :font_display, default: 'Montserrat'
      t.string :logo_url
      t.string :favicon_url
      t.text :custom_css
      t.boolean :is_active, default: false

      t.timestamps
    end

    add_index :theme_settings, :is_active
  end
end
```

**Helper para inyectar CSS dinámico:**

```ruby
# app/helpers/theme_helper.rb
module ThemeHelper
  def current_theme
    @current_theme ||= ThemeSetting.find_by(is_active: true) || default_theme
  end

  def theme_css_variables
    content_tag(:style, current_theme.to_css.html_safe, id: 'custom-theme-styles')
  end

  def theme_data_attribute
    current_theme.present? ? "custom-#{current_theme.id}" : "default"
  end

  private

  def default_theme
    ThemeSetting.new(
      name: 'Default',
      primary_color: '#612d62',
      secondary_color: '#269283',
      accent_color: '#954e99',
    )
  end
end
```

**Uso en Layout:**

```erb
<!-- app/views/layouts/application.html.erb -->
<html data-theme="<%= theme_data_attribute %>">
<head>
  <%= theme_css_variables %>
  <%= favicon_link_tag current_theme.favicon_url || 'favicon.ico' %>
</head>
<body>
  <% if current_theme.logo_url.present? %>
    <%= image_tag current_theme.logo_url, alt: 'Logo', class: 'site-logo' %>
  <% end %>

  <%= yield %>
</body>
</html>
```

### 5.3 Vue Composable para Theming

**Composable useTheme:**

```typescript
// app/frontend/composables/useTheme.ts
import { ref, computed, watch } from 'vue'

export interface Theme {
  id: number | null
  name: string
  colors: {
    primary: string
    secondary: string
    accent: string
  }
  typography: {
    fontPrimary: string
    fontDisplay: string
  }
}

const currentTheme = ref<Theme | null>(null)
const isDarkMode = ref(false)

export function useTheme() {
  // Load theme from DOM
  const loadThemeFromDOM = () => {
    const themeAttr = document.documentElement.dataset.theme
    if (themeAttr && themeAttr.startsWith('custom-')) {
      const themeId = parseInt(themeAttr.replace('custom-', ''))
      fetchTheme(themeId)
    }
  }

  // Fetch theme from API
  const fetchTheme = async (themeId: number) => {
    try {
      const response = await fetch(`/api/themes/${themeId}`)
      const data = await response.json()
      currentTheme.value = data
    } catch (error) {
      console.error('Error loading theme:', error)
    }
  }

  // Apply theme programmatically
  const applyTheme = (theme: Theme) => {
    const root = document.documentElement

    // Apply colors
    Object.entries(theme.colors).forEach(([key, value]) => {
      root.style.setProperty(`--color-${key}`, value)
    })

    // Apply fonts
    root.style.setProperty('--font-family-primary', theme.typography.fontPrimary)
    root.style.setProperty('--font-family-display', theme.typography.fontDisplay)

    currentTheme.value = theme
  }

  // Toggle dark mode
  const toggleDarkMode = () => {
    isDarkMode.value = !isDarkMode.value
    document.documentElement.classList.toggle('dark', isDarkMode.value)
    localStorage.setItem('darkMode', isDarkMode.value.toString())
  }

  // Initialize dark mode from localStorage
  const initDarkMode = () => {
    const savedDarkMode = localStorage.getItem('darkMode') === 'true'
    isDarkMode.value = savedDarkMode
    document.documentElement.classList.toggle('dark', savedDarkMode)
  }

  // Get color value from CSS variable
  const getColorValue = (colorName: string): string => {
    return getComputedStyle(document.documentElement)
      .getPropertyValue(`--color-${colorName}`)
      .trim()
  }

  // Computed: current primary color
  const primaryColor = computed(() => {
    return currentTheme.value?.colors.primary || getColorValue('brand-primary')
  })

  // Computed: current secondary color
  const secondaryColor = computed(() => {
    return currentTheme.value?.colors.secondary || getColorValue('brand-secondary')
  })

  return {
    currentTheme,
    isDarkMode,
    primaryColor,
    secondaryColor,
    loadThemeFromDOM,
    applyTheme,
    toggleDarkMode,
    initDarkMode,
    getColorValue,
  }
}
```

**Uso en componentes:**

```vue
<script setup lang="ts">
import { onMounted } from 'vue'
import { useTheme } from '@/composables/useTheme'

const { primaryColor, secondaryColor, isDarkMode, toggleDarkMode } = useTheme()

onMounted(() => {
  console.log('Primary color:', primaryColor.value)
})
</script>

<template>
  <div>
    <button
      @click="toggleDarkMode"
      class="p-2 rounded"
      :style="{ backgroundColor: primaryColor }"
    >
      {{ isDarkMode ? '☀️' : '🌙' }} Toggle Dark Mode
    </button>
  </div>
</template>
```

### 5.4 ActiveAdmin Panel para Theme Management

**Admin Resource:**

```ruby
# app/admin/theme_settings.rb
ActiveAdmin.register ThemeSetting do
  menu priority: 10, label: 'Temas'

  permit_params :name, :primary_color, :secondary_color, :accent_color,
                :font_primary, :font_display, :logo_url, :favicon_url,
                :custom_css, :is_active

  index do
    selectable_column
    id_column
    column :name
    column :primary_color do |theme|
      span style: "background-color: #{theme.primary_color}; padding: 5px 15px; color: white; border-radius: 4px;" do
        theme.primary_color
      end
    end
    column :secondary_color do |theme|
      span style: "background-color: #{theme.secondary_color}; padding: 5px 15px; color: white; border-radius: 4px;" do
        theme.secondary_color
      end
    end
    column :is_active
    column :created_at
    actions defaults: true do |theme|
      link_to 'Preview', preview_admin_theme_setting_path(theme), class: 'member_link', target: '_blank'
      link_to 'Export JSON', export_admin_theme_setting_path(theme, format: :json), class: 'member_link'
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Información Básica' do
      f.input :name
      f.input :is_active, label: 'Activar este tema'
    end

    f.inputs 'Colores de Marca' do
      f.input :primary_color, as: :color, hint: 'Color primario (púrpura)'
      f.input :secondary_color, as: :color, hint: 'Color secundario (verde)'
      f.input :accent_color, as: :color, hint: 'Color de acento'

      # Preview de colores
      li class: 'color-preview' do
        div id: 'color-preview-container', style: 'margin-top: 20px;' do
          h4 'Vista Previa de Colores:'
          div style: 'display: flex; gap: 20px; margin-top: 10px;' do
            div style: 'text-align: center;' do
              div id: 'primary-preview', style: 'width: 100px; height: 100px; border-radius: 8px; border: 2px solid #ccc;'
              p 'Primario'
            end
            div style: 'text-align: center;' do
              div id: 'secondary-preview', style: 'width: 100px; height: 100px; border-radius: 8px; border: 2px solid #ccc;'
              p 'Secundario'
            end
            div style: 'text-align: center;' do
              div id: 'accent-preview', style: 'width: 100px; height: 100px; border-radius: 8px; border: 2px solid #ccc;'
              p 'Acento'
            end
          end
        end
      end
    end

    f.inputs 'Tipografía' do
      f.input :font_primary, as: :select,
              collection: ['Inter', 'Roboto', 'Open Sans', 'Lato', 'Poppins', 'Montserrat'],
              hint: 'Fuente para texto general'
      f.input :font_display, as: :select,
              collection: ['Montserrat', 'Playfair Display', 'Raleway', 'Oswald', 'Bebas Neue'],
              hint: 'Fuente para títulos y encabezados'
    end

    f.inputs 'Assets' do
      f.input :logo_url, hint: 'URL del logo principal'
      f.input :favicon_url, hint: 'URL del favicon'
    end

    f.inputs 'CSS Personalizado' do
      f.input :custom_css, as: :text, input_html: { rows: 15 },
              hint: 'CSS adicional para personalizaciones avanzadas'
    end

    f.actions do
      f.action :submit
      f.action :cancel, wrapper_html: { class: 'cancel' }
      li do
        link_to 'Vista Previa', preview_admin_theme_setting_path(f.object),
                class: 'button', target: '_blank' if f.object.persisted?
      end
    end
  end

  # Custom member actions
  member_action :preview, method: :get do
    @theme = resource
    render 'admin/theme_settings/preview', layout: 'preview'
  end

  member_action :export, method: :get do
    @theme = resource
    respond_to do |format|
      format.json do
        render json: @theme.to_theme_json
      end
    end
  end

  collection_action :import, method: [:get, :post] do
    if request.post?
      file = params[:theme_file]
      json_data = JSON.parse(file.read, symbolize_names: true)
      @theme = ThemeSetting.from_theme_json(json_data)

      if @theme.persisted?
        redirect_to admin_theme_settings_path, notice: 'Tema importado exitosamente'
      else
        flash.now[:error] = 'Error al importar tema'
        render :import
      end
    end
  end

  # JavaScript para preview en tiempo real
  controller do
    def edit
      super
      @page_title = "Editar Tema: #{resource.name}"
    end
  end
end
```

**JavaScript para Live Preview:**

```javascript
// app/assets/javascripts/admin/theme_preview.js
document.addEventListener('DOMContentLoaded', () => {
  const primaryInput = document.getElementById('theme_setting_primary_color')
  const secondaryInput = document.getElementById('theme_setting_secondary_color')
  const accentInput = document.getElementById('theme_setting_accent_color')

  const primaryPreview = document.getElementById('primary-preview')
  const secondaryPreview = document.getElementById('secondary-preview')
  const accentPreview = document.getElementById('accent-preview')

  if (primaryInput && primaryPreview) {
    primaryInput.addEventListener('input', (e) => {
      primaryPreview.style.backgroundColor = e.target.value
    })
    // Set initial value
    primaryPreview.style.backgroundColor = primaryInput.value
  }

  if (secondaryInput && secondaryPreview) {
    secondaryInput.addEventListener('input', (e) => {
      secondaryPreview.style.backgroundColor = e.target.value
    })
    secondaryPreview.style.backgroundColor = secondaryInput.value
  }

  if (accentInput && accentPreview) {
    accentInput.addEventListener('input', (e) => {
      accentPreview.style.backgroundColor = e.target.value
    })
    accentPreview.style.backgroundColor = accentInput.value
  }
})
```

**Vista de Preview:**

```erb
<!-- app/views/admin/theme_settings/preview.html.erb -->
<!DOCTYPE html>
<html data-theme="custom-<%= @theme.id %>">
<head>
  <title>Preview: <%= @theme.name %></title>
  <%= csrf_meta_tags %>
  <%= vite_stylesheet_tag 'application' %>

  <style>
    <%= @theme.to_css.html_safe %>
  </style>
</head>
<body>
  <div class="preview-container" style="padding: 2rem;">
    <div style="max-width: 1200px; margin: 0 auto;">
      <h1 style="font-family: var(--font-family-display); color: var(--color-brand-primary);">
        Vista Previa: <%= @theme.name %>
      </h1>

      <div style="margin-top: 2rem; display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem;">
        <!-- Button Examples -->
        <div>
          <h3>Botones</h3>
          <button class="btn-primary">Primario</button>
          <button class="btn-secondary">Secundario</button>
        </div>

        <!-- Card Example -->
        <div class="bg-white rounded-lg shadow p-6">
          <h3 class="text-xl font-bold mb-2" style="color: var(--color-brand-primary);">Card Title</h3>
          <p class="text-gray-600">Este es un ejemplo de card con el tema personalizado.</p>
        </div>

        <!-- Form Example -->
        <div>
          <h3>Formulario</h3>
          <label class="block text-sm font-medium mb-1">Email</label>
          <input type="email" class="form-control" placeholder="email@example.com">
        </div>
      </div>

      <!-- Color Palette -->
      <div style="margin-top: 3rem;">
        <h2>Paleta de Colores</h2>
        <div style="display: flex; gap: 1rem; margin-top: 1rem;">
          <div style="width: 100px; height: 100px; background-color: var(--color-brand-primary); border-radius: 8px;"></div>
          <div style="width: 100px; height: 100px; background-color: var(--color-brand-secondary); border-radius: 8px;"></div>
          <div style="width: 100px; height: 100px; background-color: var(--color-accent); border-radius: 8px;"></div>
        </div>
      </div>
    </div>
  </div>

  <%= vite_javascript_tag 'application' %>
</body>
</html>
```

---

## 6. COMPONENTES - CÓDIGO Y PATRONES

### 6.1 Arquitectura de Componentes (Atomic Design)

**Estructura de carpetas:**

```
app/frontend/components/
├── atoms/               # Elementos atómicos indivisibles
│   ├── Button.vue
│   ├── Input.vue
│   ├── Badge.vue
│   ├── Icon.vue
│   ├── Avatar.vue
│   └── Spinner.vue
├── molecules/           # Combinación simple de atoms
│   ├── FormField.vue     # Label + Input + Error
│   ├── SearchBar.vue     # Input + Button + Icon
│   ├── UserCard.vue      # Avatar + Text + Badge
│   └── AlertBanner.vue   # Icon + Text + Close Button
├── organisms/           # Componentes complejos
│   ├── Header.vue
│   ├── Footer.vue
│   ├── ProposalCard.vue
│   ├── CommentsList.vue
│   ├── VotingWidget.vue
│   └── NavigationMenu.vue
├── templates/           # Layouts de página
│   ├── MainLayout.vue
│   ├── AuthLayout.vue
│   └── DashboardLayout.vue
└── pages/              # Páginas completas (si SPA)
    ├── HomePage.vue
    ├── ProposalDetailPage.vue
    └── ProfilePage.vue
```

### 6.2 Atoms - Componentes Básicos

#### Button Component

```vue
<!-- app/frontend/components/atoms/Button.vue -->
<script setup lang="ts">
import { computed } from 'vue'

export interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'tertiary' | 'danger' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
  loading?: boolean
  fullWidth?: boolean
  type?: 'button' | 'submit' | 'reset'
  as?: 'button' | 'a'
  href?: string
}

const props = withDefaults(defineProps<ButtonProps>(), {
  variant: 'primary',
  size: 'md',
  disabled: false,
  loading: false,
  fullWidth: false,
  type: 'button',
  as: 'button',
})

const emit = defineEmits<{
  click: [event: MouseEvent]
}>()

const classes = computed(() => {
  const base = [
    'inline-flex items-center justify-center',
    'font-medium rounded-lg',
    'transition-all duration-300',
    'focus:outline-none focus:ring-4 focus:ring-offset-2',
    'disabled:opacity-50 disabled:cursor-not-allowed',
  ]

  // Size variants
  const sizes = {
    sm: 'px-3 py-1.5 text-xs',
    md: 'px-6 py-3 text-sm',
    lg: 'px-8 py-4 text-base',
  }

  // Color variants
  const variants = {
    primary: 'bg-primary-600 text-white hover:bg-primary-700 focus:ring-primary-200',
    secondary: 'bg-secondary-500 text-white hover:bg-secondary-600 focus:ring-secondary-200',
    tertiary: 'bg-gray-200 text-gray-800 hover:bg-gray-300 focus:ring-gray-100',
    danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-200',
    ghost: 'bg-transparent text-primary-600 hover:bg-primary-50 focus:ring-primary-100',
  }

  const fullWidthClass = props.fullWidth ? 'w-full' : ''

  return [
    ...base,
    sizes[props.size],
    variants[props.variant],
    fullWidthClass,
  ].join(' ')
})

const handleClick = (event: MouseEvent) => {
  if (!props.disabled && !props.loading) {
    emit('click', event)
  }
}
</script>

<template>
  <component
    :is="as"
    :type="as === 'button' ? type : undefined"
    :href="as === 'a' ? href : undefined"
    :class="classes"
    :disabled="disabled || loading"
    @click="handleClick"
  >
    <svg
      v-if="loading"
      class="animate-spin -ml-1 mr-3 h-5 w-5"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
      <path
        class="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      ></path>
    </svg>

    <slot></slot>
  </component>
</template>
```

**Test del Button:**

```typescript
// app/frontend/components/atoms/__tests__/Button.spec.ts
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import Button from '../Button.vue'

describe('Button', () => {
  it('renders slot content', () => {
    const wrapper = mount(Button, {
      slots: {
        default: 'Click me',
      },
    })

    expect(wrapper.text()).toBe('Click me')
  })

  it('applies primary variant classes by default', () => {
    const wrapper = mount(Button)

    expect(wrapper.classes()).toContain('bg-primary-600')
  })

  it('emits click event when clicked', async () => {
    const wrapper = mount(Button)

    await wrapper.trigger('click')

    expect(wrapper.emitted('click')).toHaveLength(1)
  })

  it('does not emit click when disabled', async () => {
    const wrapper = mount(Button, {
      props: { disabled: true },
    })

    await wrapper.trigger('click')

    expect(wrapper.emitted('click')).toBeUndefined()
  })

  it('shows loading spinner when loading', () => {
    const wrapper = mount(Button, {
      props: { loading: true },
    })

    expect(wrapper.find('svg').exists()).toBe(true)
  })

  it('renders as anchor tag when as="a"', () => {
    const wrapper = mount(Button, {
      props: {
        as: 'a',
        href: '/test',
      },
    })

    expect(wrapper.element.tagName).toBe('A')
    expect(wrapper.attributes('href')).toBe('/test')
  })
})
```

#### Input Component

```vue
<!-- app/frontend/components/atoms/Input.vue -->
<script setup lang="ts">
import { computed, useAttrs } from 'vue'

export interface InputProps {
  modelValue?: string | number
  type?: 'text' | 'email' | 'password' | 'number' | 'tel' | 'url'
  placeholder?: string
  disabled?: boolean
  readonly?: boolean
  error?: string
  size?: 'sm' | 'md' | 'lg'
  fullWidth?: boolean
}

const props = withDefaults(defineProps<InputProps>(), {
  type: 'text',
  size: 'md',
  fullWidth: true,
})

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
  blur: [event: FocusEvent]
  focus: [event: FocusEvent]
}>()

const attrs = useAttrs()

const classes = computed(() => {
  const base = [
    'block rounded-lg border',
    'transition-all duration-300',
    'focus:outline-none focus:ring-4',
    'disabled:bg-gray-100 disabled:cursor-not-allowed',
  ]

  const sizes = {
    sm: 'px-3 py-2 text-sm',
    md: 'px-4 py-3 text-base',
    lg: 'px-5 py-4 text-lg',
  }

  const stateClasses = props.error
    ? 'border-red-300 focus:border-red-500 focus:ring-red-100'
    : 'border-gray-300 focus:border-primary-500 focus:ring-primary-100'

  const widthClass = props.fullWidth ? 'w-full' : ''

  return [
    ...base,
    sizes[props.size],
    stateClasses,
    widthClass,
  ].join(' ')
})

const handleInput = (event: Event) => {
  const target = event.target as HTMLInputElement
  emit('update:modelValue', target.value)
}
</script>

<template>
  <input
    :type="type"
    :value="modelValue"
    :placeholder="placeholder"
    :disabled="disabled"
    :readonly="readonly"
    :class="classes"
    v-bind="attrs"
    @input="handleInput"
    @blur="emit('blur', $event as FocusEvent)"
    @focus="emit('focus', $event as FocusEvent)"
  />
</template>
```

#### Badge Component

```vue
<!-- app/frontend/components/atoms/Badge.vue -->
<script setup lang="ts">
import { computed } from 'vue'

export interface BadgeProps {
  variant?: 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info'
  size?: 'sm' | 'md' | 'lg'
  rounded?: boolean
  dot?: boolean
}

const props = withDefaults(defineProps<BadgeProps>(), {
  variant: 'primary',
  size: 'md',
  rounded: false,
  dot: false,
})

const classes = computed(() => {
  const base = [
    'inline-flex items-center font-medium',
    'transition-all duration-300',
  ]

  const sizes = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-3 py-1 text-sm',
    lg: 'px-4 py-1.5 text-base',
  }

  const variants = {
    primary: 'bg-primary-100 text-primary-800',
    secondary: 'bg-secondary-100 text-secondary-800',
    success: 'bg-green-100 text-green-800',
    warning: 'bg-yellow-100 text-yellow-800',
    danger: 'bg-red-100 text-red-800',
    info: 'bg-blue-100 text-blue-800',
  }

  const roundedClass = props.rounded ? 'rounded-full' : 'rounded-md'

  return [
    ...base,
    sizes[props.size],
    variants[props.variant],
    roundedClass,
  ].join(' ')
})

const dotColor = computed(() => {
  const colors = {
    primary: 'bg-primary-600',
    secondary: 'bg-secondary-500',
    success: 'bg-green-600',
    warning: 'bg-yellow-500',
    danger: 'bg-red-600',
    info: 'bg-blue-600',
  }

  return colors[props.variant]
})
</script>

<template>
  <span :class="classes">
    <span
      v-if="dot"
      :class="[dotColor, 'w-2 h-2 rounded-full mr-2']"
    ></span>
    <slot></slot>
  </span>
</template>
```

### 6.3 Molecules - Componentes Compuestos

#### FormField Component

```vue
<!-- app/frontend/components/molecules/FormField.vue -->
<script setup lang="ts">
import { computed } from 'vue'
import Input from '@/components/atoms/Input.vue'

export interface FormFieldProps {
  modelValue?: string | number
  label?: string
  error?: string
  hint?: string
  required?: boolean
  type?: 'text' | 'email' | 'password' | 'number' | 'tel' | 'url'
  placeholder?: string
  disabled?: boolean
}

const props = defineProps<FormFieldProps>()

const emit = defineEmits<{
  'update:modelValue': [value: string | number]
}>()

const inputId = computed(() => {
  return `field-${Math.random().toString(36).substr(2, 9)}`
})
</script>

<template>
  <div class="form-field">
    <label
      v-if="label"
      :for="inputId"
      class="block text-sm font-medium text-gray-700 mb-1"
    >
      {{ label }}
      <span v-if="required" class="text-red-500">*</span>
    </label>

    <Input
      :id="inputId"
      :model-value="modelValue"
      :type="type"
      :placeholder="placeholder"
      :disabled="disabled"
      :error="error"
      @update:model-value="emit('update:modelValue', $event)"
    />

    <p
      v-if="hint && !error"
      class="mt-1 text-xs text-gray-500"
    >
      {{ hint }}
    </p>

    <p
      v-if="error"
      class="mt-1 text-xs text-red-600 flex items-center"
    >
      <svg
        class="w-4 h-4 mr-1"
        fill="currentColor"
        viewBox="0 0 20 20"
      >
        <path
          fill-rule="evenodd"
          d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"
          clip-rule="evenodd"
        />
      </svg>
      {{ error }}
    </p>
  </div>
</template>
```

#### SearchBar Component

```vue
<!-- app/frontend/components/molecules/SearchBar.vue -->
<script setup lang="ts">
import { ref } from 'vue'
import Input from '@/components/atoms/Input.vue'
import Button from '@/components/atoms/Button.vue'

export interface SearchBarProps {
  modelValue?: string
  placeholder?: string
  loading?: boolean
}

const props = withDefaults(defineProps<SearchBarProps>(), {
  placeholder: 'Buscar...',
  loading: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
  search: [query: string]
  clear: []
}>()

const localValue = ref(props.modelValue || '')

const handleInput = (value: string | number) => {
  localValue.value = value.toString()
  emit('update:modelValue', localValue.value)
}

const handleSearch = () => {
  emit('search', localValue.value)
}

const handleClear = () => {
  localValue.value = ''
  emit('update:modelValue', '')
  emit('clear')
}

const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Enter') {
    handleSearch()
  }
}
</script>

<template>
  <div class="search-bar flex gap-2">
    <div class="relative flex-1">
      <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
        <svg
          class="h-5 w-5 text-gray-400"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
          />
        </svg>
      </div>

      <Input
        :model-value="localValue"
        :placeholder="placeholder"
        class="pl-10 pr-10"
        @update:model-value="handleInput"
        @keydown="handleKeydown"
      />

      <button
        v-if="localValue"
        type="button"
        class="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-gray-600"
        @click="handleClear"
      >
        <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
          <path
            fill-rule="evenodd"
            d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
            clip-rule="evenodd"
          />
        </svg>
      </button>
    </div>

    <Button
      variant="primary"
      :loading="loading"
      @click="handleSearch"
    >
      Buscar
    </Button>
  </div>
</template>
```

### 6.4 Organisms - Componentes Complejos

#### VotingWidget Component

```vue
<!-- app/frontend/components/organisms/VotingWidget.vue -->
<script setup lang="ts">
import { ref, computed } from 'vue'
import axios from 'axios'
import Button from '@/components/atoms/Button.vue'
import Badge from '@/components/atoms/Badge.vue'

export interface VotingWidgetProps {
  proposalId: number
  initialVotesCount: number
  userVoted: boolean
  userVoteType?: 'in_favor' | 'against' | 'neutral' | null
}

const props = defineProps<VotingWidgetProps>()

const votesCount = ref(props.initialVotesCount)
const hasVoted = ref(props.userVoted)
const voteType = ref<'in_favor' | 'against' | 'neutral' | null>(props.userVoteType || null)
const isLoading = ref(false)
const error = ref<string | null>(null)

const vote = async (type: 'in_favor' | 'against' | 'neutral') => {
  if (isLoading.value || hasVoted.value) return

  isLoading.value = true
  error.value = null

  try {
    const { data } = await axios.post(
      `/proposals/${props.proposalId}/vote`,
      { vote_type: type },
      {
        headers: {
          'X-CSRF-Token': window.PlebisHub.csrfToken,
        },
      }
    )

    votesCount.value = data.votes_count
    hasVoted.value = true
    voteType.value = type
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Error al registrar voto'
    console.error('Error voting:', err)
  } finally {
    isLoading.value = false
  }
}

const removeVote = async () => {
  if (isLoading.value || !hasVoted.value) return

  isLoading.value = true
  error.value = null

  try {
    const { data } = await axios.delete(
      `/proposals/${props.proposalId}/vote`,
      {
        headers: {
          'X-CSRF-Token': window.PlebisHub.csrfToken,
        },
      }
    )

    votesCount.value = data.votes_count
    hasVoted.value = false
    voteType.value = null
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Error al eliminar voto'
    console.error('Error removing vote:', err)
  } finally {
    isLoading.value = false
  }
}

const voteButtonVariant = (type: 'in_favor' | 'against' | 'neutral') => {
  if (voteType.value === type) return 'primary'
  return 'ghost'
}

const voteButtonLabel = computed(() => {
  if (!hasVoted.value) return 'Votar'
  return 'Cambiar voto'
})
</script>

<template>
  <div class="voting-widget bg-white rounded-lg shadow-md p-6">
    <h3 class="text-lg font-semibold mb-4">¿Cuál es tu opinión?</h3>

    <div v-if="error" class="mb-4 p-3 bg-red-50 border border-red-200 rounded-md text-red-800 text-sm">
      {{ error }}
    </div>

    <div class="flex gap-3 mb-4">
      <Button
        variant="success"
        size="lg"
        :disabled="isLoading"
        :class="{ 'ring-2 ring-green-400': voteType === 'in_favor' }"
        @click="vote('in_favor')"
      >
        <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
          <path d="M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z" />
        </svg>
        A favor
      </Button>

      <Button
        variant="danger"
        size="lg"
        :disabled="isLoading"
        :class="{ 'ring-2 ring-red-400': voteType === 'against' }"
        @click="vote('against')"
      >
        <svg class="w-5 h-5 mr-2 transform rotate-180" fill="currentColor" viewBox="0 0 20 20">
          <path d="M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z" />
        </svg>
        En contra
      </Button>

      <Button
        variant="tertiary"
        size="lg"
        :disabled="isLoading"
        :class="{ 'ring-2 ring-gray-400': voteType === 'neutral' }"
        @click="vote('neutral')"
      >
        <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        Neutral
      </Button>
    </div>

    <div v-if="hasVoted" class="flex items-center justify-between p-3 bg-primary-50 border border-primary-200 rounded-md">
      <div class="flex items-center">
        <svg class="w-5 h-5 text-primary-600 mr-2" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
        </svg>
        <span class="text-sm font-medium text-primary-900">Has votado: {{ voteType }}</span>
      </div>
      <button
        type="button"
        class="text-sm text-primary-600 hover:text-primary-800 underline"
        :disabled="isLoading"
        @click="removeVote"
      >
        Retirar voto
      </button>
    </div>

    <div class="mt-4 text-center">
      <Badge variant="info" size="lg">
        {{ votesCount }} votos totales
      </Badge>
    </div>
  </div>
</template>
```

### 6.5 Composables Reutilizables

#### useForm Composable

```typescript
// app/frontend/composables/useForm.ts
import { ref, reactive, computed } from 'vue'
import type { Ref } from 'vue'

export interface ValidationRule {
  validator: (value: any) => boolean
  message: string
}

export interface FieldRules {
  [key: string]: ValidationRule[]
}

export interface FormErrors {
  [key: string]: string | null
}

export function useForm<T extends Record<string, any>>(
  initialValues: T,
  rules: FieldRules = {}
) {
  const values = reactive<T>({ ...initialValues })
  const errors = reactive<FormErrors>({})
  const touched = reactive<Record<string, boolean>>({})
  const isSubmitting = ref(false)

  const isDirty = computed(() => {
    return Object.keys(touched).some((key) => touched[key])
  })

  const isValid = computed(() => {
    return Object.values(errors).every((error) => error === null)
  })

  const validateField = (fieldName: string): boolean => {
    const fieldRules = rules[fieldName]
    if (!fieldRules) {
      errors[fieldName] = null
      return true
    }

    for (const rule of fieldRules) {
      if (!rule.validator(values[fieldName])) {
        errors[fieldName] = rule.message
        return false
      }
    }

    errors[fieldName] = null
    return true
  }

  const validateAll = (): boolean => {
    let isFormValid = true

    Object.keys(rules).forEach((fieldName) => {
      const fieldValid = validateField(fieldName)
      if (!fieldValid) {
        isFormValid = false
      }
    })

    return isFormValid
  }

  const setFieldValue = <K extends keyof T>(field: K, value: T[K]) => {
    values[field] = value
    touched[field as string] = true
    validateField(field as string)
  }

  const setFieldError = (fieldName: string, error: string) => {
    errors[fieldName] = error
  }

  const reset = () => {
    Object.assign(values, initialValues)
    Object.keys(errors).forEach((key) => {
      errors[key] = null
    })
    Object.keys(touched).forEach((key) => {
      touched[key] = false
    })
  }

  const handleSubmit = async (
    onSubmit: (values: T) => Promise<void> | void
  ) => {
    const isFormValid = validateAll()

    if (!isFormValid) {
      return
    }

    isSubmitting.value = true

    try {
      await onSubmit(values)
    } catch (error) {
      console.error('Form submission error:', error)
      throw error
    } finally {
      isSubmitting.value = false
    }
  }

  return {
    values,
    errors,
    touched,
    isDirty,
    isValid,
    isSubmitting,
    setFieldValue,
    setFieldError,
    validateField,
    validateAll,
    reset,
    handleSubmit,
  }
}

// Validation helpers
export const validators = {
  required: (message = 'Este campo es requerido'): ValidationRule => ({
    validator: (value: any) => {
      if (typeof value === 'string') return value.trim().length > 0
      return value !== null && value !== undefined
    },
    message,
  }),

  email: (message = 'Email inválido'): ValidationRule => ({
    validator: (value: string) => {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      return emailRegex.test(value)
    },
    message,
  }),

  minLength: (min: number, message?: string): ValidationRule => ({
    validator: (value: string) => value.length >= min,
    message: message || `Mínimo ${min} caracteres`,
  }),

  maxLength: (max: number, message?: string): ValidationRule => ({
    validator: (value: string) => value.length <= max,
    message: message || `Máximo ${max} caracteres`,
  }),

  pattern: (regex: RegExp, message: string): ValidationRule => ({
    validator: (value: string) => regex.test(value),
    message,
  }),
}
```

**Uso del composable:**

```vue
<script setup lang="ts">
import { useForm, validators } from '@/composables/useForm'
import FormField from '@/components/molecules/FormField.vue'
import Button from '@/components/atoms/Button.vue'

interface LoginForm {
  email: string
  password: string
}

const { values, errors, isSubmitting, setFieldValue, handleSubmit } = useForm<LoginForm>(
  {
    email: '',
    password: '',
  },
  {
    email: [
      validators.required(),
      validators.email(),
    ],
    password: [
      validators.required(),
      validators.minLength(8, 'La contraseña debe tener al menos 8 caracteres'),
    ],
  }
)

const onSubmit = async (formValues: LoginForm) => {
  // Call API
  await axios.post('/login', formValues)
}
</script>

<template>
  <form @submit.prevent="handleSubmit(onSubmit)">
    <FormField
      label="Email"
      type="email"
      :model-value="values.email"
      :error="errors.email"
      required
      @update:model-value="setFieldValue('email', $event)"
    />

    <FormField
      label="Contraseña"
      type="password"
      :model-value="values.password"
      :error="errors.password"
      required
      @update:model-value="setFieldValue('password', $event)"
    />

    <Button
      type="submit"
      :loading="isSubmitting"
      full-width
    >
      Iniciar Sesión
    </Button>
  </form>
</template>
```

---

## 7. PERSONALIZACIÓN EXTREMA - ARQUITECTURA

*(Ver Sección 5.2-5.4 para implementación completa del ThemeEngine)*

### 7.1 API RESTful para Themes

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :themes, only: [:index, :show] do
      member do
        post :activate
      end
    end
  end
end
```

```ruby
# app/controllers/api/v1/themes_controller.rb
module Api
  module V1
    class ThemesController < ApplicationController
      def index
        @themes = ThemeSetting.all
        render json: @themes.map(&:to_theme_json)
      end

      def show
        @theme = ThemeSetting.find(params[:id])
        render json: @theme.to_theme_json
      end

      def activate
        @theme = ThemeSetting.find(params[:id])

        ThemeSetting.update_all(is_active: false)
        @theme.update!(is_active: true)

        render json: { success: true, theme: @theme.to_theme_json }
      end
    end
  end
end
```

### 7.2 Real-time Theme Switcher (Vue Component)

```vue
<!-- app/frontend/components/organisms/ThemeSwitcher.vue -->
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { useTheme } from '@/composables/useTheme'
import type { Theme } from '@/composables/useTheme'

const themes = ref<Theme[]>([])
const isLoading = ref(false)
const { currentTheme, applyTheme } = useTheme()

const fetchThemes = async () => {
  try {
    const { data } = await axios.get('/api/v1/themes')
    themes.value = data
  } catch (error) {
    console.error('Error fetching themes:', error)
  }
}

const activateTheme = async (theme: Theme) => {
  if (!theme.id) return

  isLoading.value = true

  try {
    await axios.post(`/api/v1/themes/${theme.id}/activate`)
    applyTheme(theme)
    window.location.reload() // Reload to apply Rails-side changes
  } catch (error) {
    console.error('Error activating theme:', error)
  } finally {
    isLoading.value = false
  }
}

onMounted(() => {
  fetchThemes()
})
</script>

<template>
  <div class="theme-switcher">
    <h3 class="text-lg font-semibold mb-4">Seleccionar Tema</h3>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div
        v-for="theme in themes"
        :key="theme.id"
        class="theme-card border-2 rounded-lg p-4 cursor-pointer transition-all"
        :class="{
          'border-primary-600 bg-primary-50': currentTheme?.id === theme.id,
          'border-gray-200 hover:border-gray-400': currentTheme?.id !== theme.id,
        }"
        @click="activateTheme(theme)"
      >
        <div class="flex items-center justify-between mb-3">
          <h4 class="font-medium">{{ theme.name }}</h4>
          <svg
            v-if="currentTheme?.id === theme.id"
            class="w-5 h-5 text-primary-600"
            fill="currentColor"
            viewBox="0 0 20 20"
          >
            <path
              fill-rule="evenodd"
              d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
              clip-rule="evenodd"
            />
          </svg>
        </div>

        <div class="flex gap-2">
          <div
            class="w-8 h-8 rounded-full border"
            :style="{ backgroundColor: theme.colors.primary }"
          ></div>
          <div
            class="w-8 h-8 rounded-full border"
            :style="{ backgroundColor: theme.colors.secondary }"
          ></div>
          <div
            class="w-8 h-8 rounded-full border"
            :style="{ backgroundColor: theme.colors.accent }"
          ></div>
        </div>
      </div>
    </div>
  </div>
</template>
```

---

## 8. TESTING Y CALIDAD

### 8.1 Configuración de Tests

**Vitest + Testing Library (ya configurado en Sección 4.6)**

### 8.2 E2E Tests con Playwright

```bash
pnpm add -D @playwright/test
npx playwright install
```

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],

  webServer: {
    command: 'bin/rails server',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

```typescript
// tests/e2e/proposals.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Proposals', () => {
  test('should display proposals list', async ({ page }) => {
    await page.goto('/proposals')

    await expect(page.locator('h1')).toContainText('Propuestas')

    const proposalCards = page.locator('[data-testid="proposal-card"]')
    await expect(proposalCards).toHaveCount(10) // Assumes 10 proposals
  })

  test('should allow voting on proposal', async ({ page }) => {
    // Login first
    await page.goto('/users/sign_in')
    await page.fill('input[name="user[email]"]', 'test@example.com')
    await page.fill('input[name="user[password]"]', 'password')
    await page.click('button[type="submit"]')

    // Navigate to proposal
    await page.goto('/proposals/1')

    // Vote
    await page.click('button:has-text("A favor")')

    await expect(page.locator('text=Has votado')).toBeVisible()
  })

  test('should be accessible', async ({ page }) => {
    await page.goto('/proposals')

    // Check for proper heading hierarchy
    const h1 = await page.locator('h1').count()
    expect(h1).toBeGreaterThan(0)

    // Check for alt text on images
    const images = page.locator('img')
    const count = await images.count()

    for (let i = 0; i < count; i++) {
      const alt = await images.nth(i).getAttribute('alt')
      expect(alt).toBeTruthy()
    }
  })
})
```

### 8.3 Visual Regression Tests con Storybook

```bash
pnpm add -D @storybook/vue3 @storybook/addon-essentials @storybook/addon-a11y chromatic
npx storybook init
```

```.storybook/main.ts
import type { StorybookConfig } from '@storybook/vue3-vite'

const config: StorybookConfig = {
  stories: ['../app/frontend/components/**/*.stories.@(js|jsx|ts|tsx)'],
  addons: [
    '@storybook/addon-links',
    '@storybook/addon-essentials',
    '@storybook/addon-interactions',
    '@storybook/addon-a11y',
  ],
  framework: {
    name: '@storybook/vue3-vite',
    options: {},
  },
  docs: {
    autodocs: 'tag',
  },
}

export default config
```

### 8.4 Linting y Formatting

**ESLint config:**

```javascript
// .eslintrc.cjs
module.exports = {
  root: true,
  env: {
    browser: true,
    es2021: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:vue/vue3-recommended',
    'plugin:@typescript-eslint/recommended',
    'prettier',
  ],
  parser: 'vue-eslint-parser',
  parserOptions: {
    parser: '@typescript-eslint/parser',
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  plugins: ['vue', '@typescript-eslint'],
  rules: {
    'vue/multi-word-component-names': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
  },
}
```

**Prettier config:**

```json
// .prettierrc
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "vueIndentScriptAndStyle": false
}
```

**Husky + lint-staged:**

```bash
pnpm add -D husky lint-staged
npx husky install
npx husky add .husky/pre-commit "npx lint-staged"
```

```json
// package.json additions
{
  "lint-staged": {
    "*.{js,ts,vue}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{css,scss}": [
      "prettier --write"
    ]
  }
}
```

---

## 9. PERFORMANCE Y OPTIMIZACIÓN

### 9.1 Lazy Loading de Componentes

```typescript
// app/frontend/entrypoints/application.ts
import { defineAsyncComponent } from 'vue'

// Lazy load heavy components
const HeavyChart = defineAsyncComponent(() =>
  import('@/components/organisms/HeavyChart.vue')
)

const ProposalModal = defineAsyncComponent(() =>
  import('@/components/organisms/ProposalModal.vue')
)
```

### 9.2 Image Optimization

**Rails helper:**

```ruby
# app/helpers/image_helper.rb
module ImageHelper
  def optimized_image_tag(source, options = {})
    options[:loading] ||= 'lazy'
    options[:decoding] ||= 'async'
    options[:fetchpriority] = 'high' if options.delete(:priority)

    image_tag(source, options)
  end
end
```

**Usage:**

```erb
<%= optimized_image_tag 'hero.jpg', alt: 'Hero image', class: 'w-full' %>
<%= optimized_image_tag 'logo.png', alt: 'Logo', priority: true %>
```

### 9.3 Bundle Analysis

```bash
# Add vite-plugin-bundle-analyzer
pnpm add -D rollup-plugin-visualizer
```

```typescript
// vite.config.ts addition
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig({
  plugins: [
    vue(),
    visualizer({
      open: true,
      gzipSize: true,
      brotliSize: true,
    }),
  ],
})
```

### 9.4 Code Splitting Strategy

```typescript
// vite.config.ts - manualChunks optimization
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vue-vendor': ['vue', 'pinia', 'vue-router'],
          'ui-vendor': ['@headlessui/vue', '@heroicons/vue'],
          'utils': ['@vueuse/core', 'axios'],
          // Separate chunks per Rails Engine
          'proposals-module': ['./app/frontend/components/proposals/**'],
          'votes-module': ['./app/frontend/components/votes/**'],
        },
      },
    },
  },
})
```

---

## 10. BUILD TOOLS Y DEPLOYMENT

### 10.1 Producción Build

```json
// package.json scripts
{
  "scripts": {
    "build": "vite build",
    "build:analyze": "vite build --mode analyze",
    "build:staging": "vite build --mode staging",
    "preview": "vite preview",
    "clean": "rm -rf public/vite"
  }
}
```

### 10.2 CI/CD Pipeline (GitHub Actions)

```.github/workflows/frontend.yml
name: Frontend CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'

      - name: Install pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Lint
        run: pnpm lint

      - name: Type check
        run: pnpm tsc --noEmit

      - name: Unit tests
        run: pnpm test

      - name: Build
        run: pnpm build

      - name: E2E tests
        run: pnpm playwright test

  accessibility:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run axe accessibility tests
        uses: pa11y/pa11y-ci-action@v3
```

### 10.3 Deployment Checklist

**Pre-deployment:**

```bash
# 1. Run all tests
pnpm test && pnpm playwright test

# 2. Check bundle size
pnpm build:analyze

# 3. Lighthouse audit
npx lighthouse http://localhost:3000 --view

# 4. Security audit
pnpm audit

# 5. Check for unused dependencies
npx depcheck
```

**Deploy commands:**

```bash
# Assets precompilation
RAILS_ENV=production bin/rails assets:precompile

# Vite build
pnpm build

# Deploy
git push heroku main
# or
cap production deploy
```

---

## 11. INTEGRACIÓN CON RAILS ENGINES

### 11.1 Engine-Specific Entrypoints

**Estructura:**

```
app/frontend/
├── entrypoints/
│   ├── application.ts          # Global entrypoint
│   ├── engines/
│   │   ├── plebis_proposals.ts
│   │   ├── plebis_votes.ts
│   │   ├── plebis_cms.ts
│   │   └── plebis_participation.ts
```

**Engine entrypoint example:**

```typescript
// app/frontend/entrypoints/engines/plebis_proposals.ts
import { createApp } from 'vue'
import ProposalsList from '@/components/proposals/ProposalsList.vue'
import ProposalForm from '@/components/proposals/ProposalForm.vue'
import VotingWidget from '@/components/organisms/VotingWidget.vue'

// Auto-mount components based on data attributes
document.addEventListener('DOMContentLoaded', () => {
  // Mount ProposalsList
  const proposalsListEl = document.querySelector('[data-vue-proposals-list]')
  if (proposalsListEl) {
    const props = JSON.parse(proposalsListEl.getAttribute('data-props') || '{}')
    createApp(ProposalsList, props).mount(proposalsListEl)
  }

  // Mount VotingWidget
  const votingWidgets = document.querySelectorAll('[data-vue-voting-widget]')
  votingWidgets.forEach((el) => {
    const props = JSON.parse(el.getAttribute('data-props') || '{}')
    createApp(VotingWidget, props).mount(el)
  })
})
```

**Load engine entrypoint in ERB:**

```erb
<!-- engines/plebis_proposals/app/views/plebis_proposals/proposals/index.html.erb -->
<%= vite_javascript_tag 'engines/plebis_proposals' %>

<div data-vue-proposals-list
     data-props='<%= {
       initialProposals: @proposals.to_json,
       currentUserId: current_user&.id
     }.to_json %>'>
</div>
```

### 11.2 Shared Components Across Engines

```typescript
// app/frontend/shared/index.ts
export { default as Button } from '@/components/atoms/Button.vue'
export { default as Input } from '@/components/atoms/Input.vue'
export { default as FormField } from '@/components/molecules/FormField.vue'
export { useForm, validators } from '@/composables/useForm'
export { useTheme } from '@/composables/useTheme'
```

**Usage in engine:**

```typescript
// Engine-specific component
import { Button, FormField, useForm } from '@/shared'
```

---

## 12. PLAN DE IMPLEMENTACIÓN TÉCNICO

### 12.1 Fase 1: Setup y Fundamentos (Semanas 1-2)

**Semana 1:**
- [ ] Instalar Vite Rails gem
- [ ] Configurar pnpm + package.json
- [ ] Instalar Vue 3 + TypeScript
- [ ] Configurar Tailwind CSS
- [ ] Setup vite.config.ts + tsconfig.json
- [ ] Crear primer componente de prueba (Button)
- [ ] Verificar HMR funciona correctamente

**Semana 2:**
- [ ] Configurar ESLint + Prettier + Husky
- [ ] Setup Vitest para unit tests
- [ ] Configurar Storybook
- [ ] Crear Design Tokens (JSON files)
- [ ] Generar CSS variables con Style Dictionary
- [ ] Documentar stack en README

### 12.2 Fase 2: Componentes Core (Semanas 3-5)

**Semana 3: Atoms**
- [ ] Button component + tests + stories
- [ ] Input component + tests + stories
- [ ] Badge component + tests + stories
- [ ] Avatar component + tests + stories
- [ ] Spinner component + tests + stories

**Semana 4: Molecules**
- [ ] FormField component + tests
- [ ] SearchBar component + tests
- [ ] UserCard component + tests
- [ ] AlertBanner component + tests
- [ ] Pagination component + tests

**Semana 5: Composables**
- [ ] useForm composable + tests
- [ ] useTheme composable + tests
- [ ] usePagination composable + tests
- [ ] useDebounce composable + tests
- [ ] Documentation in Storybook

### 12.3 Fase 3: Engines Migration (Semanas 6-14)

**Semana 6-7: plebis_proposals (3 weeks)**
- [ ] ProposalsList component
- [ ] ProposalCard component
- [ ] ProposalForm component
- [ ] Voting Widget component
- [ ] Comments component
- [ ] Migration tests + E2E

**Semana 8-9: plebis_votes**
- [ ] Vote button variants
- [ ] Vote statistics component
- [ ] Vote history component
- [ ] Tests

**Semana 10-11: plebis_cms**
- [ ] Content editor integration
- [ ] Media uploader component
- [ ] Content preview
- [ ] Tests

**Semana 12-14: Remaining engines**
- [ ] plebis_participation components
- [ ] plebis_impulsa components
- [ ] plebis_verification components
- [ ] plebis_microcredit components
- [ ] plebis_collaborations components

### 12.4 Fase 4: Theme System (Semanas 15-17)

**Semana 15:**
- [ ] ThemeSetting model + migration
- [ ] Color variant generator (hex → HSL → variants)
- [ ] CSS generation logic
- [ ] Theme export/import JSON

**Semana 16:**
- [ ] ActiveAdmin resource for themes
- [ ] Color picker integration
- [ ] Live preview panel
- [ ] Font selector

**Semana 17:**
- [ ] ThemeSwitcher Vue component
- [ ] API endpoints (themes#index, #show, #activate)
- [ ] Client-side theme application
- [ ] Documentation + tutorial

### 12.5 Fase 5: Testing & Optimization (Semanas 18-20)

**Semana 18:**
- [ ] Achieve >80% test coverage
- [ ] Add missing component tests
- [ ] Add E2E tests for critical paths
- [ ] Accessibility audit (axe-core)

**Semana 19:**
- [ ] Performance audit (Lighthouse)
- [ ] Bundle size optimization
- [ ] Lazy loading implementation
- [ ] Image optimization
- [ ] Code splitting verification

**Semana 20:**
- [ ] Cross-browser testing
- [ ] Mobile responsiveness testing
- [ ] Security audit
- [ ] Documentation completion
- [ ] Training for team

### 12.6 Checklist Final

**Pre-Launch:**

- [ ] All tests passing (unit + E2E)
- [ ] Lighthouse score >90/100
- [ ] Accessibility WCAG 2.1 AA compliant
- [ ] Bundle size <150 KB (gzip)
- [ ] Cross-browser tested (Chrome, Firefox, Safari, Edge)
- [ ] Mobile tested (iOS Safari, Android Chrome)
- [ ] Security headers configured
- [ ] CSP policy configured
- [ ] Error tracking setup (Sentry/Rollbar)
- [ ] Performance monitoring setup
- [ ] Backup plan documented
- [ ] Rollback plan tested
- [ ] Team trained on new stack
- [ ] Documentation complete
- [ ] Changelog updated

**Post-Launch Monitoring:**

- [ ] Monitor Core Web Vitals
- [ ] Track JavaScript errors
- [ ] Monitor bundle size
- [ ] Track user feedback
- [ ] Review accessibility issues
- [ ] Performance regressions check

---

## CONCLUSIÓN

Este documento proporciona una guía técnica completa para la modernización del front-end de PlebisHub. La estrategia de migración incremental permite mantener la aplicación funcionando mientras se actualiza, minimizando riesgos.

**Tecnologías Clave:**
- **Vue 3 + TypeScript**: Framework reactivo moderno con type-safety
- **Vite 5**: Bundler ultra-rápido con HMR instantáneo
- **Tailwind CSS**: Framework CSS utility-first para customización extrema
- **Design Tokens**: Sistema de diseño escalable y mantenible
- **Vitest + Playwright**: Testing robusto con cobertura completa

**Beneficios Esperados:**
- **Performance**: 40-60% mejora en tiempo de carga
- **Mantenibilidad**: 70% reducción en tiempo de cambios CSS
- **Developer Experience**: HMR, TypeScript, testing automático
- **Customización**: Theme system con panel admin integrado
- **Calidad**: >80% test coverage, Lighthouse >90/100

**Próximos Pasos:**
1. Revisar este documento con el equipo
2. Aprobar el stack tecnológico propuesto
3. Asignar recursos (1-2 front-end developers)
4. Comenzar Fase 1: Setup (2 semanas)
5. Iterar según feedback

**Contacto para dudas técnicas:**
Referirse al DOCUMENTO_DISEÑADOR_PRINCIPAL.md para detalles de diseño visual.
