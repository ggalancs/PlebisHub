# Frontend Architecture - PlebisHub

## 🎯 Resumen Ejecutivo

Este documento describe la nueva arquitectura frontend de PlebisHub, modernizada con Vue 3, Vite, TypeScript y Tailwind CSS. La implementación sigue las mejores prácticas actuales y está diseñada para coexistir con el código legacy de Rails durante una migración incremental.

## 📦 Stack Tecnológico

### Core Framework

- **Vue 3.4+** - Framework reactivo con Composition API
- **TypeScript 5.x** - Type-safety y mejor developer experience
- **Vite 5.x** - Build tool ultra-rápido con HMR instantáneo
- **vite_rails** - Integración nativa Rails + Vite

### Styling

- **Tailwind CSS 3.4+** - Utility-first CSS framework
- **PostCSS + Autoprefixer** - Compatibilidad cross-browser
- **Design Tokens** - Sistema centralizado de variables de diseño

### State Management

- **Pinia** - Store oficial para Vue 3
- **@vueuse/core** - Collection de composables útiles

### Testing

- **Vitest** - Unit testing framework (compatible con Jest)
- **@vue/test-utils** - Testing utilities para Vue
- **Playwright** - E2E testing multi-browser
- **@testing-library/jest-dom** - Matchers adicionales

### Documentation

- **Storybook 8+** - Component documentation & visual testing
- **Storybook Addons**: a11y, interactions, essentials, links

### Development Tools

- **ESLint** - Linting JavaScript/TypeScript/Vue
- **Prettier** - Code formatting
- **Husky + lint-staged** - Pre-commit hooks
- **pnpm** - Package manager rápido y eficiente

## 🏗️ Estructura de Directorios

```
app/frontend/
├── entrypoints/
│   ├── application.ts       # Entry point principal de Vite
│   └── application.css      # Estilos globales + Tailwind
├── components/
│   ├── atoms/               # Componentes básicos (Button, Input, etc.)
│   │   ├── Button.vue
│   │   ├── Button.test.ts
│   │   └── Button.stories.ts
│   ├── molecules/           # Componentes compuestos
│   └── organisms/           # Componentes complejos
├── composables/             # Composables reutilizables
├── assets/
│   ├── images/
│   └── fonts/
├── types/                   # TypeScript type definitions
├── design-tokens/           # Design tokens JSON
│   └── tokens.json
└── test/
    └── setup.ts             # Configuración global de tests
```

## 🎨 Design System

### Colores

#### Primary (Morado PlebisHub - #612d62)

- 50-900: Paleta completa de 9 tonos
- Base: `primary-700` (#612d62)

#### Secondary (Verde - #269283)

- 50-900: Paleta completa de 9 tonos
- Base: `secondary-600` (#269283)

### Tipografía

**Fuentes:**

- **Sans**: Inter (body text) - optimizada para pantallas
- **Heading**: Montserrat (headings) - identidad de marca

**Escala modular (1.250 - Major Third):**

- xs: 12px, sm: 14px, base: 16px, lg: 18px, xl: 20px
- 2xl: 25px, 3xl: 31px, 4xl: 39px, 5xl: 49px

### Espaciado

**Sistema base 8px:**

- 1-24 (4px a 96px)
- Uso: `spacing-4` = 16px, `spacing-8` = 32px, etc.

### Componentes Implementados

#### ✅ Button

- **Variantes**: primary, secondary, ghost, danger, success
- **Tamaños**: sm, md, lg
- **Estados**: normal, disabled, loading
- **Features**: fullWidth, iconOnly
- **Tests**: 12 tests unitarios ✅
- **Stories**: 12 stories en Storybook ✅

## 🧪 Testing

### Unit Tests (Vitest)

```bash
# Run all tests
pnpm test

# Watch mode
pnpm test

# Coverage report
pnpm test:coverage

# UI mode
pnpm test:ui
```

**Coverage actual:** 12/12 tests passing ✅

### E2E Tests (Playwright)

```bash
# Run E2E tests
pnpm test:e2e

# UI mode
pnpm test:e2e:ui
```

## 📚 Storybook

### Ejecutar Storybook

```bash
pnpm storybook
# Opens at http://localhost:6006
```

### Build Storybook

```bash
pnpm build-storybook
# Output: storybook-static/
```

### Crear Stories

```typescript
import type { Meta, StoryObj } from '@storybook/vue3'
import MyComponent from './MyComponent.vue'

const meta = {
  title: 'Atoms/MyComponent',
  component: MyComponent,
  tags: ['autodocs'],
} satisfies Meta<typeof MyComponent>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    prop1: 'value',
  },
}
```

## 🔧 Development Workflow

### Setup Inicial

```bash
# Install dependencies
pnpm install

# Run Vite dev server
pnpm dev

# Run Rails server (en otro terminal)
rails server
```

### Linting & Formatting

```bash
# Lint all files
pnpm lint

# Format all files
pnpm format

# Type check
pnpm type-check
```

### Git Hooks

**Pre-commit** (automático):

- ESLint fix
- Prettier format
- Only on staged files (lint-staged)

## 🏝️ Islands Architecture

### ¿Qué es Islands Architecture?

Patrón que permite **coexistir** Vue components dentro de páginas ERB tradicionales. Cada componente Vue es una "isla" de interactividad en un mar de HTML estático.

### Cómo Usar

#### 1. Registrar Componente

```typescript
// app/frontend/entrypoints/application.ts
import { registerComponent } from './application'
import Button from '@components/atoms/Button.vue'

registerComponent('Button', Button)
```

#### 2. Usar en Vista ERB

```erb
<div
  data-vue-component="Button"
  data-vue-props='{"variant": "primary", "size": "lg"}'
>
  <!-- Vue component se montará aquí -->
</div>
```

#### 3. Mounting Automático

El sistema monta automáticamente todos los componentes con `data-vue-component` al cargar la página.

### Helper Rails (Futuro)

```ruby
# app/helpers/vue_component_helper.rb
module VueComponentHelper
  def vue_component(name, props = {})
    content_tag(:div, nil, data: {
      vue_component: name,
      vue_props: props.to_json
    })
  end
end
```

```erb
<%= vue_component('Button', { variant: 'primary', text: 'Click me' }) %>
```

## 🚀 Migration Strategy

### Fase Actual: Foundation ✅

- [x] Setup Vite + Vue 3 + TypeScript
- [x] Tailwind CSS configurado
- [x] Testing (Vitest + Playwright)
- [x] Storybook
- [x] Design Tokens
- [x] Primer componente: Button

### Próximos Pasos

1. **Componentes Atoms** (Semana 2-3)
   - Input, Checkbox, Radio, Badge, Avatar, Icon, Spinner, etc.

2. **Componentes Molecules** (Semana 4-5)
   - FormField, SearchBar, UserCard, AlertBanner, Pagination, etc.

3. **Migración por Engine** (Semana 6-14)
   - plebis_proposals → ProposalCard, VotingWidget
   - plebis_votes → Vote buttons, statistics
   - plebis_cms → Content editor, media uploader
   - Resto de engines

## 📊 Performance Targets

- **Bundle size:** <150KB (gzip)
- **Lighthouse Score:** >90/100
- **Test Coverage:** >80%
- **First Contentful Paint:** <1.5s
- **Time to Interactive:** <3.5s

## 🔐 Security

- **CSP Headers:** Configurados vía secure_headers gem
- **XSS Prevention:** Vue sanitiza por defecto
- **Type Safety:** TypeScript previene errores en runtime

## 📖 Resources

- [Vue 3 Docs](https://vuejs.org/)
- [Vite Docs](https://vitejs.dev/)
- [Tailwind CSS Docs](https://tailwindcss.com/)
- [Vitest Docs](https://vitest.dev/)
- [Storybook Docs](https://storybook.js.org/)

## 🤝 Contributing

1. Crear rama feature: `git checkout -b feature/nuevo-componente`
2. Desarrollar con TDD (tests primero)
3. Crear stories de Storybook
4. Lint & format: automático en pre-commit
5. Push y crear PR

## 📝 Changelog

### v1.0.0 (2025-11-11)

**Implementado:**

- ✅ Stack completo: Vite + Vue 3 + TypeScript + Tailwind
- ✅ Testing: Vitest + Playwright configurados
- ✅ Storybook 8 con addons (a11y, interactions, essentials)
- ✅ Design Tokens y sistema de colores PlebisHub
- ✅ Componente Button completo (5 variantes, 3 tamaños)
- ✅ 12 unit tests para Button (100% passing)
- ✅ 12 Storybook stories para Button
- ✅ Pre-commit hooks (ESLint + Prettier)
- ✅ Islands Architecture para integración con Rails

**Métricas:**

- 650+ paquetes npm instalados
- 12/12 tests passing
- TypeScript strict mode
- ESLint + Prettier configurados

---

**Autor:** Equipo Frontend PlebisHub
**Última actualización:** 2025-11-11
