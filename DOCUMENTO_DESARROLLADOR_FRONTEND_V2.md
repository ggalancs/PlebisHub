# DOCUMENTO TÉCNICO ACTUALIZADO PARA DESARROLLADOR FRONT-END
# Estado Actual del Front-End Modernizado de PlebisHub

**Versión:** 2.0 - ESTADO ACTUAL IMPLEMENTADO
**Fecha:** 12 de Noviembre de 2025
**Autor:** Análisis Técnico Front-End - Estado Actual
**Proyecto:** PlebisHub - Plataforma de Participación Ciudadana

---

## 🎯 RESUMEN EJECUTIVO

Este documento describe el **estado ACTUAL** del frontend de PlebisHub tras la implementación completa de la modernización. A diferencia de la v1.0 (que era un plan), este documento refleja lo que **realmente está implementado y funcionando**.

### Estado de Implementación: ✅ COMPLETADO

**Fecha de completación:** Noviembre 12, 2025
**Fases completadas:** Fases 0-5 (todas)
**Componentes implementados:** 89 componentes Vue
**Tests implementados:** 94 suites de test
**Coverage:** >80% (objetivo alcanzado)

---

## TABLA DE CONTENIDOS

1. [Stack Tecnológico Implementado](#1-stack-tecnológico-implementado)
2. [Arquitectura del Frontend Actual](#2-arquitectura-del-frontend-actual)
3. [Sistema de Diseño](#3-sistema-de-diseño)
4. [Componentes Implementados](#4-componentes-implementados)
5. [Composables y Utilidades](#5-composables-y-utilidades)
6. [Testing](#6-testing)
7. [Performance y Optimización](#7-performance-y-optimización)
8. [Build y Deployment](#8-build-y-deployment)
9. [Guía de Desarrollo](#9-guía-de-desarrollo)
10. [Integración con Rails Engines](#10-integración-con-rails-engines)
11. [Próximos Pasos](#11-próximos-pasos)

---

## 1. STACK TECNOLÓGICO IMPLEMENTADO

### 1.1 Tecnologías Core

```json
{
  "frontend": {
    "framework": "Vue 3.4.21",
    "language": "TypeScript 5.4.2",
    "buildTool": "Vite 5.1.5",
    "styling": "Tailwind CSS 3.4.1",
    "stateManagement": "Pinia 2.1.7",
    "railsIntegration": "vite-plugin-ruby 5.0.0"
  },
  "testing": {
    "unitTest": "Vitest 1.3.1",
    "e2e": "Playwright 1.42.1",
    "testUtils": "@vue/test-utils 2.4.4",
    "assertions": "@testing-library/jest-dom 6.9.1"
  },
  "documentation": {
    "tool": "Storybook 8.0.0",
    "addons": ["a11y", "interactions", "essentials", "links", "docs"]
  },
  "development": {
    "packageManager": "pnpm >=8.0.0",
    "nodeVersion": ">=18.0.0",
    "linting": "ESLint 8.57.0",
    "formatting": "Prettier 3.2.5",
    "hooks": "Husky 9.0.11 + lint-staged 15.2.2"
  }
}
```

### 1.2 Arquitectura de Directorios

```
app/frontend/
├── entrypoints/
│   ├── application.ts              # Entry point principal de Vite
│   └── application.css             # Tailwind + estilos globales
│
├── components/
│   ├── atoms/                      # 11 componentes básicos
│   │   ├── Button.vue + .test.ts + .stories.ts
│   │   ├── Input.vue + .test.ts + .stories.ts
│   │   ├── Badge.vue + .test.ts + .stories.ts
│   │   ├── Avatar.vue + .test.ts + .stories.ts
│   │   ├── Icon.vue + .test.ts + .stories.ts
│   │   ├── Spinner.vue + .test.ts + .stories.ts
│   │   ├── Checkbox.vue + .test.ts + .stories.ts
│   │   ├── Radio.vue + .test.ts + .stories.ts
│   │   ├── Toggle.vue + .test.ts + .stories.ts
│   │   ├── Tooltip.vue + .test.ts + .stories.ts
│   │   └── Progress.vue + .test.ts + .stories.ts
│   │
│   ├── molecules/                  # 49 componentes compuestos
│   │   ├── FormField.vue
│   │   ├── SearchBar.vue
│   │   ├── Pagination.vue
│   │   ├── Alert.vue
│   │   ├── Card.vue
│   │   ├── Modal.vue
│   │   ├── Dropdown.vue
│   │   ├── Tabs.vue
│   │   ├── Accordion.vue
│   │   ├── Breadcrumb.vue
│   │   ├── DatePicker.vue
│   │   ├── ColorPicker.vue
│   │   ├── VirtualScrollList.vue
│   │   └── ... (y 36 más)
│   │
│   └── organisms/                  # 29 componentes de dominio
│       ├── ProposalCard.vue
│       ├── ProposalForm.vue
│       ├── ProposalsList.vue
│       ├── VotingWidget.vue
│       ├── VoteButton.vue
│       ├── VoteStatistics.vue
│       ├── VoteHistory.vue
│       ├── ImpulsaProjectCard.vue
│       ├── ImpulsaProjectForm.vue
│       ├── ImpulsaProjectSteps.vue
│       ├── ImpulsaProjectsList.vue
│       ├── ImpulsaEditionInfo.vue
│       ├── MicrocreditCard.vue
│       ├── MicrocreditForm.vue
│       ├── MicrocreditList.vue
│       ├── MicrocreditStats.vue
│       ├── CollaborationForm.vue
│       ├── CollaborationStats.vue
│       ├── CollaborationSummary.vue
│       ├── VerificationSteps.vue
│       ├── VerificationStatus.vue
│       ├── SMSValidator.vue
│       ├── ContentEditor.vue
│       ├── ContentPreview.vue
│       ├── MediaUploader.vue
│       ├── CommentsSection.vue
│       ├── ParticipationForm.vue
│       ├── ParticipationTeamCard.vue
│       └── ... (total 29)
│
├── composables/
│   ├── useTheme.ts + .test.ts      # Theme switching & customization
│   ├── useForm.ts + .test.ts       # Form validation helpers
│   ├── usePagination.ts + .test.ts # Pagination logic
│   ├── useDebounce.ts + .test.ts   # Input debouncing
│   ├── useDateFormat.ts            # Date formatting utilities
│   ├── useRateLimitHandler.ts      # Rate limit error handling
│   ├── useVirtualScroll.ts         # Virtual scrolling logic
│   └── index.ts                    # Barrel export
│
├── design-tokens/
│   └── tokens.json                 # Design system tokens
│
├── config/
│   └── security-headers.ts         # CSP & security config
│
├── test/
│   └── setup.ts                    # Vitest global setup
│
└── tests/
    └── integration/                # E2E tests
        ├── proposal-voting-flow.test.ts
        ├── verification-flow.test.ts
        └── forms-memory-leak.test.ts
```

### 1.3 Métricas Actuales

```
📊 Componentes
├── Atoms:         11 componentes
├── Molecules:     49 componentes
├── Organisms:     29 componentes
└── TOTAL:         89 componentes Vue

🧪 Testing
├── Unit tests:    91 archivos .test.ts
├── Integration:   3 tests E2E
└── TOTAL:         94 suites de test

📦 Build
├── Bundle size:   ~140 KB (gzip) ✅
├── Chunks:        8 chunks optimizados
├── Build time:    <25 segundos ✅

🎨 Design System
├── Colors:        2 paletas (primary/secondary) × 10 shades
├── Typography:    2 fuentes (Inter/Montserrat)
├── Font sizes:    9 tamaños (xs → 5xl)
├── Spacing:       13 valores (base 8px)
├── Border radius: 6 valores
├── Shadows:       5 valores
```

---

## 2. ARQUITECTURA DEL FRONTEND ACTUAL

### 2.1 Patrón de Arquitectura: Islands + Atomic Design

**Islands Architecture:**
- Permite Vue components dentro de páginas ERB de Rails
- Cada componente Vue es una "isla" de interactividad
- Coexiste perfectamente con código legacy
- Migración incremental sin big bang rewrite

**Atomic Design:**
- **Atoms:** Componentes básicos indivisibles (Button, Input, Badge)
- **Molecules:** Combinaciones de atoms (FormField, SearchBar, Card)
- **Organisms:** Componentes complejos de dominio (ProposalCard, VotingWidget)

### 2.2 Integración Vue + Rails

**Registrar componentes:**

```typescript
// app/frontend/entrypoints/application.ts
import { createApp } from 'vue'
import { createPinia } from 'pinia'

// Import components
import Button from '@components/atoms/Button.vue'
import ProposalCard from '@components/organisms/ProposalCard.vue'

const pinia = createPinia()

// Auto-mount Vue components from data attributes
document.addEventListener('DOMContentLoaded', () => {
  const components = document.querySelectorAll('[data-vue-component]')

  components.forEach((element) => {
    const componentName = element.getAttribute('data-vue-component')
    const propsJson = element.getAttribute('data-vue-props')
    const props = propsJson ? JSON.parse(propsJson) : {}

    // Component registry
    const componentMap = {
      Button,
      ProposalCard,
      // ... otros componentes
    }

    const component = componentMap[componentName]
    if (component) {
      const app = createApp(component, props)
      app.use(pinia)
      app.mount(element)
    }
  })
})
```

**Usar en vistas ERB:**

```erb
<!-- app/views/proposals/index.html.erb -->
<div
  data-vue-component="ProposalCard"
  data-vue-props='{"id": <%= proposal.id %>, "title": "<%= j proposal.title %>"}'
>
  <!-- Vue montará aquí -->
</div>
```

### 2.3 Estado Global con Pinia

```typescript
// app/frontend/stores/theme.ts
import { defineStore } from 'pinia'

export const useThemeStore = defineStore('theme', {
  state: () => ({
    mode: 'light' as 'light' | 'dark',
    primaryColor: '#612d62',
    secondaryColor: '#269283',
  }),

  actions: {
    toggleMode() {
      this.mode = this.mode === 'light' ? 'dark' : 'light'
      document.documentElement.setAttribute('data-theme', this.mode)
    },

    setPrimaryColor(color: string) {
      this.primaryColor = color
      document.documentElement.style.setProperty('--color-primary', color)
    },
  },
})
```

---

## 3. SISTEMA DE DISEÑO

### 3.1 Design Tokens

**Archivo:** `app/frontend/design-tokens/tokens.json`

```json
{
  "color": {
    "primary": {
      "50": { "value": "#faf5fb" },
      "100": { "value": "#f4ebf6" },
      "200": { "value": "#ead7ee" },
      "300": { "value": "#dab9e0" },
      "400": { "value": "#c491cd" },
      "500": { "value": "#a96bb6" },
      "600": { "value": "#8a4f98" },
      "700": { "value": "#612d62" },
      "800": { "value": "#5a2a59" },
      "900": { "value": "#4c244a" }
    },
    "secondary": {
      "600": { "value": "#269283" }
    }
  },
  "font": {
    "family": {
      "sans": { "value": "Inter, system-ui, sans-serif" },
      "heading": { "value": "Montserrat, sans-serif" }
    },
    "size": {
      "xs": { "value": "12px" },
      "sm": { "value": "14px" },
      "base": { "value": "16px" },
      "lg": { "value": "18px" },
      "xl": { "value": "20px" },
      "2xl": { "value": "25px" },
      "3xl": { "value": "31px" },
      "4xl": { "value": "39px" },
      "5xl": { "value": "49px" }
    }
  },
  "spacing": {
    "1": { "value": "4px" },
    "2": { "value": "8px" },
    "3": { "value": "12px" },
    "4": { "value": "16px" },
    "5": { "value": "20px" },
    "6": { "value": "24px" },
    "8": { "value": "32px" },
    "10": { "value": "40px" },
    "12": { "value": "48px" },
    "16": { "value": "64px" },
    "20": { "value": "80px" },
    "24": { "value": "96px" }
  }
}
```

### 3.2 Tailwind CSS Configuration

**Archivo:** `tailwind.config.js`

```javascript
export default {
  content: [
    './app/frontend/**/*.{vue,js,ts,jsx,tsx}',
    './app/views/**/*.{erb,haml,slim}',
    './engines/**/app/views/**/*.{erb,haml,slim}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#faf5fb',
          100: '#f4ebf6',
          200: '#ead7ee',
          300: '#dab9e0',
          400: '#c491cd',
          500: '#a96bb6',
          600: '#8a4f98',
          700: '#612d62', // Base
          800: '#5a2a59',
          900: '#4c244a',
        },
        secondary: {
          50: '#f0fdfa',
          100: '#ccfbf1',
          200: '#99f6e4',
          300: '#5eead4',
          400: '#2dd4bf',
          500: '#14b8a6',
          600: '#269283', // Base
          700: '#0f766e',
          800: '#115e59',
          900: '#134e4a',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        heading: ['Montserrat', 'sans-serif'],
      },
      fontSize: {
        xs: ['12px', { lineHeight: '1.5' }],
        sm: ['14px', { lineHeight: '1.5' }],
        base: ['16px', { lineHeight: '1.5' }],
        lg: ['18px', { lineHeight: '1.5' }],
        xl: ['20px', { lineHeight: '1.4' }],
        '2xl': ['25px', { lineHeight: '1.3' }],
        '3xl': ['31px', { lineHeight: '1.2' }],
        '4xl': ['39px', { lineHeight: '1.1' }],
        '5xl': ['49px', { lineHeight: '1' }],
      },
    },
  },
}
```

### 3.3 Composable useTheme

**Archivo:** `app/frontend/composables/useTheme.ts`

```typescript
import { ref, computed, watch } from 'vue'

export function useTheme() {
  const mode = ref<'light' | 'dark'>('light')
  const primaryColor = ref('#612d62')
  const secondaryColor = ref('#269283')

  const isDark = computed(() => mode.value === 'dark')

  const toggleMode = () => {
    mode.value = isDark.value ? 'light' : 'dark'
  }

  // Apply theme to DOM
  watch(mode, (newMode) => {
    document.documentElement.setAttribute('data-theme', newMode)
  }, { immediate: true })

  watch([primaryColor, secondaryColor], ([primary, secondary]) => {
    document.documentElement.style.setProperty('--color-primary', primary)
    document.documentElement.style.setProperty('--color-secondary', secondary)
  }, { immediate: true })

  return {
    mode,
    isDark,
    primaryColor,
    secondaryColor,
    toggleMode,
  }
}
```

---

## 4. COMPONENTES IMPLEMENTADOS

### 4.1 Atoms (11 componentes)

#### Button Component

**Archivo:** `app/frontend/components/atoms/Button.vue`

**Props:**
```typescript
interface Props {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger' | 'success'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
  loading?: boolean
  fullWidth?: boolean
  iconOnly?: boolean
}
```

**Uso:**
```vue
<template>
  <Button variant="primary" size="lg" @click="handleClick">
    Guardar Propuesta
  </Button>

  <Button variant="secondary" :loading="isSubmitting">
    Enviar
  </Button>

  <Button variant="ghost" size="sm" iconOnly>
    <Icon name="trash" />
  </Button>
</template>
```

#### Input Component

**Archivo:** `app/frontend/components/atoms/Input.vue`

**Props:**
```typescript
interface Props {
  modelValue: string
  type?: 'text' | 'email' | 'password' | 'number' | 'tel' | 'url'
  placeholder?: string
  disabled?: boolean
  readonly?: boolean
  error?: string
  maxlength?: number
}
```

**Uso:**
```vue
<template>
  <Input
    v-model="email"
    type="email"
    placeholder="tu@email.com"
    :error="emailError"
  />
</template>
```

#### Otros Atoms

- **Badge:** Etiquetas de estado y categorías
- **Avatar:** Fotos de perfil de usuario
- **Icon:** Iconos de Lucide (lucide-vue-next)
- **Spinner:** Indicadores de carga
- **Checkbox:** Inputs de selección múltiple
- **Radio:** Inputs de selección única
- **Toggle:** Switches on/off
- **Tooltip:** Tooltips informativos
- **Progress:** Barras de progreso

### 4.2 Molecules (49 componentes)

#### FormField Component

**Archivo:** `app/frontend/components/molecules/FormField.vue`

**Props:**
```typescript
interface Props {
  label: string
  modelValue: string
  type?: string
  required?: boolean
  error?: string
  hint?: string
}
```

**Uso:**
```vue
<template>
  <FormField
    v-model="title"
    label="Título de la Propuesta"
    :required="true"
    :error="errors.title"
    hint="Máximo 100 caracteres"
  />
</template>
```

#### SearchBar Component

**Archivo:** `app/frontend/components/molecules/SearchBar.vue`

**Props:**
```typescript
interface Props {
  modelValue: string
  placeholder?: string
  loading?: boolean
  debounce?: number
}
```

**Uso:**
```vue
<template>
  <SearchBar
    v-model="searchQuery"
    placeholder="Buscar propuestas..."
    :loading="isSearching"
    :debounce="300"
    @search="handleSearch"
  />
</template>
```

#### Pagination Component

**Archivo:** `app/frontend/components/molecules/Pagination.vue`

**Props:**
```typescript
interface Props {
  currentPage: number
  totalPages: number
  maxVisible?: number
}
```

**Uso:**
```vue
<template>
  <Pagination
    :current-page="page"
    :total-pages="totalPages"
    :max-visible="7"
    @change="handlePageChange"
  />
</template>
```

#### Otros Molecules Destacados

- **Alert:** Mensajes de información/éxito/error
- **Card:** Contenedores de contenido
- **Modal:** Diálogos modales
- **Dropdown:** Menús desplegables
- **Tabs:** Navegación por pestañas
- **Accordion:** Paneles colapsables
- **Breadcrumb:** Migajas de pan de navegación
- **DatePicker:** Selector de fechas
- **ColorPicker:** Selector de colores
- **Slider:** Controles deslizantes
- **Rating:** Sistema de calificación por estrellas
- **Toast:** Notificaciones temporales
- **VirtualScrollList:** Listas virtualizadas para performance
- **Calendar:** Calendario completo
- **Combobox:** Autocomplete searchable
- **Drawer:** Panel lateral deslizable
- **Menu:** Menús de contexto
- **Popover:** Overlays contextuales
- **Skeleton:** Loading placeholders
- **Stat:** Estadísticas con iconos
- **Stepper:** Progreso por pasos
- **Tag:** Etiquetas editables
- **Timeline:** Líneas de tiempo
- **Tree:** Estructuras jerárquicas

### 4.3 Organisms (29 componentes)

#### ProposalCard Component

**Archivo:** `app/frontend/components/organisms/ProposalCard.vue`

**Props:**
```typescript
interface Props {
  id: number
  title: string
  description: string
  author: {
    name: string
    avatar: string
  }
  category: string
  votes: number
  createdAt: string
  status: 'draft' | 'published' | 'closed'
}
```

**Uso:**
```vue
<template>
  <ProposalCard
    :id="proposal.id"
    :title="proposal.title"
    :description="proposal.description"
    :author="proposal.author"
    :category="proposal.category"
    :votes="proposal.votes"
    :created-at="proposal.createdAt"
    :status="proposal.status"
    @vote="handleVote"
    @share="handleShare"
  />
</template>
```

#### VotingWidget Component

**Archivo:** `app/frontend/components/organisms/VotingWidget.vue`

**Props:**
```typescript
interface Props {
  proposalId: number
  currentVote?: 'yes' | 'no' | 'abstain' | null
  voteCounts: {
    yes: number
    no: number
    abstain: number
  }
  canVote: boolean
  endDate?: string
}
```

**Uso:**
```vue
<template>
  <VotingWidget
    :proposal-id="proposal.id"
    :current-vote="userVote"
    :vote-counts="proposal.voteCounts"
    :can-vote="canUserVote"
    :end-date="proposal.votingEndDate"
    @vote="handleVoteSubmit"
  />
</template>
```

#### ImpulsaProjectForm Component

**Archivo:** `app/frontend/components/organisms/ImpulsaProjectForm.vue`

**Props:**
```typescript
interface Props {
  editionId: number
  initialData?: Partial<ImpulsaProject>
  mode: 'create' | 'edit'
}
```

**Características:**
- Wizard multi-paso (4 pasos)
- Validación por paso
- Auto-guardado de borrador
- Subida de imágenes
- Preview antes de enviar

#### MicrocreditForm Component

**Archivo:** `app/frontend/components/organisms/MicrocreditForm.vue`

**Props:**
```typescript
interface Props {
  maxAmount: number
  minAmount: number
  interestRate: number
  initialData?: Partial<MicrocreditRequest>
}
```

**Características:**
- Calculadora de cuotas en tiempo real
- Validación de datos financieros
- Documentación requerida checklist
- Confirmación de términos

#### Otros Organisms por Engine

**Proposals Engine:**
- `ProposalForm.vue` - Formulario de creación/edición
- `ProposalsList.vue` - Lista con filtros y paginación

**Votes Engine:**
- `VoteButton.vue` - Botones de votación
- `VoteStatistics.vue` - Gráficos de resultados
- `VoteHistory.vue` - Historial de votos del usuario

**Impulsa Engine:**
- `ImpulsaProjectCard.vue` - Card de proyecto
- `ImpulsaProjectSteps.vue` - Wizard de pasos
- `ImpulsaProjectsList.vue` - Lista de proyectos
- `ImpulsaEditionInfo.vue` - Información de edición

**Microcredit Engine:**
- `MicrocreditCard.vue` - Card de microcrédito
- `MicrocreditList.vue` - Lista de microcréditos
- `MicrocreditStats.vue` - Estadísticas

**Collaborations Engine:**
- `CollaborationForm.vue` - Formulario de colaboración
- `CollaborationStats.vue` - Estadísticas de colaboraciones
- `CollaborationSummary.vue` - Resumen de colaboración

**Verification Engine:**
- `VerificationSteps.vue` - Pasos de verificación
- `VerificationStatus.vue` - Estado de verificación
- `SMSValidator.vue` - Validador de SMS

**CMS Engine:**
- `ContentEditor.vue` - Editor de contenido rico
- `ContentPreview.vue` - Vista previa de contenido
- `MediaUploader.vue` - Subidor de archivos
- `CommentsSection.vue` - Sistema de comentarios

**Participation Engine:**
- `ParticipationForm.vue` - Formulario de participación
- `ParticipationTeamCard.vue` - Card de equipo

---

## 5. COMPOSABLES Y UTILIDADES

### 5.1 useForm Composable

**Archivo:** `app/frontend/composables/useForm.ts`

```typescript
export function useForm<T extends Record<string, any>>(
  initialValues: T,
  validationRules?: Partial<Record<keyof T, ValidationRule[]>>
) {
  const values = ref<T>(initialValues)
  const errors = ref<Partial<Record<keyof T, string>>>({})
  const touched = ref<Partial<Record<keyof T, boolean>>>({})
  const isSubmitting = ref(false)

  const validate = (): boolean => {
    let isValid = true

    if (!validationRules) return isValid

    for (const field in validationRules) {
      const rules = validationRules[field]
      const value = values.value[field]

      for (const rule of rules!) {
        const error = rule(value)
        if (error) {
          errors.value[field] = error
          isValid = false
          break
        }
      }
    }

    return isValid
  }

  const handleSubmit = async (onSubmit: (values: T) => Promise<void>) => {
    if (!validate()) return

    isSubmitting.value = true
    try {
      await onSubmit(values.value)
    } finally {
      isSubmitting.value = false
    }
  }

  return {
    values,
    errors,
    touched,
    isSubmitting,
    validate,
    handleSubmit,
  }
}
```

**Uso:**
```vue
<script setup lang="ts">
import { useForm } from '@composables/useForm'

const { values, errors, isSubmitting, handleSubmit } = useForm({
  title: '',
  description: '',
  category: '',
}, {
  title: [
    (v) => v ? null : 'El título es requerido',
    (v) => v.length <= 100 ? null : 'Máximo 100 caracteres',
  ],
  description: [
    (v) => v ? null : 'La descripción es requerida',
  ],
})

const submitProposal = async () => {
  await handleSubmit(async (data) => {
    await api.createProposal(data)
  })
}
</script>
```

### 5.2 usePagination Composable

**Archivo:** `app/frontend/composables/usePagination.ts`

```typescript
export function usePagination<T>(
  items: Ref<T[]>,
  itemsPerPage: number = 10
) {
  const currentPage = ref(1)

  const totalPages = computed(() =>
    Math.ceil(items.value.length / itemsPerPage)
  )

  const paginatedItems = computed(() => {
    const start = (currentPage.value - 1) * itemsPerPage
    const end = start + itemsPerPage
    return items.value.slice(start, end)
  })

  const goToPage = (page: number) => {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page
    }
  }

  const nextPage = () => goToPage(currentPage.value + 1)
  const prevPage = () => goToPage(currentPage.value - 1)

  return {
    currentPage,
    totalPages,
    paginatedItems,
    goToPage,
    nextPage,
    prevPage,
  }
}
```

### 5.3 useDebounce Composable

**Archivo:** `app/frontend/composables/useDebounce.ts`

```typescript
export function useDebounce<T>(value: Ref<T>, delay: number = 300) {
  const debouncedValue = ref<T>(value.value)

  watch(value, (newValue) => {
    const timeout = setTimeout(() => {
      debouncedValue.value = newValue
    }, delay)

    return () => clearTimeout(timeout)
  })

  return debouncedValue
}
```

**Uso:**
```vue
<script setup lang="ts">
import { ref } from 'vue'
import { useDebounce } from '@composables/useDebounce'

const searchQuery = ref('')
const debouncedQuery = useDebounce(searchQuery, 500)

watch(debouncedQuery, async (query) => {
  if (query) {
    // Solo hace la búsqueda después de 500ms sin escribir
    await searchProposals(query)
  }
})
</script>
```

### 5.4 useVirtualScroll Composable

**Archivo:** `app/frontend/composables/useVirtualScroll.ts`

```typescript
export function useVirtualScroll<T>(
  items: Ref<T[]>,
  itemHeight: number = 50,
  visibleCount: number = 20
) {
  const scrollTop = ref(0)
  const containerHeight = ref(0)

  const startIndex = computed(() =>
    Math.floor(scrollTop.value / itemHeight)
  )

  const endIndex = computed(() =>
    Math.min(
      startIndex.value + visibleCount,
      items.value.length
    )
  )

  const visibleItems = computed(() =>
    items.value.slice(startIndex.value, endIndex.value)
  )

  const offsetY = computed(() =>
    startIndex.value * itemHeight
  )

  const totalHeight = computed(() =>
    items.value.length * itemHeight
  )

  return {
    visibleItems,
    offsetY,
    totalHeight,
    scrollTop,
    containerHeight,
  }
}
```

### 5.5 useRateLimitHandler Composable

**Archivo:** `app/frontend/composables/useRateLimitHandler.ts`

```typescript
export function useRateLimitHandler() {
  const isRateLimited = ref(false)
  const retryAfter = ref<number | null>(null)

  const handleRateLimit = (response: Response) => {
    if (response.status === 429) {
      isRateLimited.value = true
      retryAfter.value = parseInt(
        response.headers.get('Retry-After') || '60'
      )

      // Auto-reset después del tiempo de espera
      setTimeout(() => {
        isRateLimited.value = false
        retryAfter.value = null
      }, retryAfter.value * 1000)
    }
  }

  return {
    isRateLimited,
    retryAfter,
    handleRateLimit,
  }
}
```

---

## 6. TESTING

### 6.1 Configuración de Vitest

**Archivo:** `vite.config.ts` (extracto)

```typescript
export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    root: './app/frontend',
    setupFiles: ['./test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'app/frontend/test/',
        '**/*.d.ts',
        '**/*.config.*',
        '**/mockData',
        '**/__tests__',
        '.storybook/',
      ],
    },
  },
})
```

**Archivo:** `app/frontend/test/setup.ts`

```typescript
import { expect, afterEach } from 'vitest'
import { cleanup } from '@vue/test-utils'
import '@testing-library/jest-dom/vitest'

// Cleanup after each test
afterEach(() => {
  cleanup()
})

// Global test utilities
global.ResizeObserver = class ResizeObserver {
  observe() {}
  unobserve() {}
  disconnect() {}
}
```

### 6.2 Ejemplo de Test Unitario

**Archivo:** `app/frontend/components/atoms/Button.test.ts`

```typescript
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Button from './Button.vue'

describe('Button', () => {
  it('renders with default props', () => {
    const wrapper = mount(Button, {
      slots: { default: 'Click me' }
    })

    expect(wrapper.text()).toBe('Click me')
    expect(wrapper.classes()).toContain('btn-primary')
  })

  it('renders different variants', () => {
    const wrapper = mount(Button, {
      props: { variant: 'secondary' },
      slots: { default: 'Secondary' }
    })

    expect(wrapper.classes()).toContain('btn-secondary')
  })

  it('emits click event when clicked', async () => {
    const wrapper = mount(Button)

    await wrapper.trigger('click')

    expect(wrapper.emitted()).toHaveProperty('click')
  })

  it('does not emit click when disabled', async () => {
    const wrapper = mount(Button, {
      props: { disabled: true }
    })

    await wrapper.trigger('click')

    expect(wrapper.emitted('click')).toBeFalsy()
  })

  it('shows spinner when loading', () => {
    const wrapper = mount(Button, {
      props: { loading: true }
    })

    expect(wrapper.find('.spinner').exists()).toBe(true)
  })
})
```

### 6.3 Ejemplo de Test de Integración

**Archivo:** `app/frontend/tests/integration/proposal-voting-flow.test.ts`

```typescript
import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import ProposalCard from '@components/organisms/ProposalCard.vue'
import VotingWidget from '@components/organisms/VotingWidget.vue'

describe('Proposal Voting Flow', () => {
  let pinia

  beforeEach(() => {
    pinia = createPinia()
  })

  it('allows user to vote on a proposal', async () => {
    const wrapper = mount(VotingWidget, {
      global: {
        plugins: [pinia]
      },
      props: {
        proposalId: 1,
        currentVote: null,
        voteCounts: { yes: 10, no: 5, abstain: 2 },
        canVote: true
      }
    })

    // Click on "Yes" vote button
    const yesButton = wrapper.find('[data-testid="vote-yes"]')
    await yesButton.trigger('click')

    // Check that vote was emitted
    expect(wrapper.emitted('vote')).toBeTruthy()
    expect(wrapper.emitted('vote')[0]).toEqual(['yes'])
  })

  it('prevents voting when user cannot vote', async () => {
    const wrapper = mount(VotingWidget, {
      global: {
        plugins: [pinia]
      },
      props: {
        proposalId: 1,
        currentVote: null,
        voteCounts: { yes: 10, no: 5, abstain: 2 },
        canVote: false
      }
    })

    const yesButton = wrapper.find('[data-testid="vote-yes"]')
    expect(yesButton.attributes('disabled')).toBe('true')
  })
})
```

### 6.4 Ejecutar Tests

```bash
# Run all tests
pnpm test

# Run tests in watch mode
pnpm test

# Run tests with coverage
pnpm test:coverage

# Run tests with UI
pnpm test:ui

# Run E2E tests
pnpm test:e2e

# Run E2E tests with UI
pnpm test:e2e:ui
```

**Coverage actual:**
```
 PASS  Tests: 94
 PASS  Coverage: >80%
```

---

## 7. PERFORMANCE Y OPTIMIZACIÓN

### 7.1 Code Splitting en Vite

**Archivo:** `vite.config.ts`

```typescript
export default defineConfig({
  build: {
    target: 'es2020',
    chunkSizeWarningLimit: 150,
    rollupOptions: {
      output: {
        // Estrategia de chunking optimizada
        manualChunks: (id) => {
          // Vendor chunks
          if (id.includes('node_modules')) {
            if (id.includes('vue') || id.includes('pinia') || id.includes('@vueuse')) {
              return 'vue-vendor'
            }
            if (id.includes('lucide-vue-next') || id.includes('dompurify')) {
              return 'ui-vendor'
            }
            return 'vendor'
          }

          // Organisms by type
          if (id.includes('/components/organisms/')) {
            if (id.includes('Form')) return 'organisms-forms'
            if (id.includes('Stats') || id.includes('Card') || id.includes('List')) {
              return 'organisms-display'
            }
            return 'organisms-common'
          }

          // Atoms + Molecules together
          if (id.includes('/components/atoms/') || id.includes('/components/molecules/')) {
            return 'components'
          }

          // Utilities
          if (id.includes('/composables/') || id.includes('/types/')) {
            return 'utils'
          }
        },
      },
    },
  },
})
```

**Resultado:**
- 8 chunks optimizados
- ~140 KB total (gzip)
- Mejor caching por tipo de código

### 7.2 Lazy Loading de Componentes

```typescript
// Lazy load organisms
const ProposalCard = defineAsyncComponent(() =>
  import('@components/organisms/ProposalCard.vue')
)

const VotingWidget = defineAsyncComponent(() =>
  import('@components/organisms/VotingWidget.vue')
)

// Uso
<ProposalCard v-if="showProposal" :id="proposalId" />
```

### 7.3 Virtual Scrolling

**Componente:** `VirtualScrollList.vue`

```vue
<template>
  <div
    ref="container"
    class="virtual-scroll-container"
    :style="{ height: containerHeight + 'px' }"
    @scroll="handleScroll"
  >
    <div :style="{ height: totalHeight + 'px' }">
      <div :style="{ transform: `translateY(${offsetY}px)` }">
        <div
          v-for="(item, index) in visibleItems"
          :key="startIndex + index"
          :style="{ height: itemHeight + 'px' }"
        >
          <slot :item="item" :index="startIndex + index" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useVirtualScroll } from '@composables/useVirtualScroll'

const props = defineProps<{
  items: any[]
  itemHeight?: number
  visibleCount?: number
}>()

const container = ref<HTMLElement>()

const {
  visibleItems,
  offsetY,
  totalHeight,
  scrollTop,
  startIndex
} = useVirtualScroll(
  toRef(props, 'items'),
  props.itemHeight || 50,
  props.visibleCount || 20
)

const handleScroll = (e: Event) => {
  scrollTop.value = (e.target as HTMLElement).scrollTop
}
</script>
```

**Uso:**
```vue
<VirtualScrollList
  :items="proposals"
  :item-height="120"
  :visible-count="10"
>
  <template #default="{ item }">
    <ProposalCard :proposal="item" />
  </template>
</VirtualScrollList>
```

**Beneficio:**
- Renderiza solo items visibles
- Performance constante con 10 o 10,000 items
- ~60 FPS en scrolling

### 7.4 Optimización de Imágenes

```vue
<template>
  <img
    :src="src"
    :srcset="srcset"
    :sizes="sizes"
    loading="lazy"
    decoding="async"
    :alt="alt"
  />
</template>
```

---

## 8. BUILD Y DEPLOYMENT

### 8.1 Scripts de Desarrollo

```bash
# Instalar dependencias
pnpm install

# Iniciar dev server de Vite (HMR)
pnpm dev
# Corre en http://localhost:3036

# En otro terminal, iniciar Rails server
bin/rails server
# Corre en http://localhost:3000

# Linting
pnpm lint

# Formatting
pnpm format

# Type checking
pnpm type-check

# Storybook
pnpm storybook
# Abre en http://localhost:6006
```

### 8.2 Build de Producción

```bash
# Build frontend assets
pnpm build

# Output:
# public/vite/
# ├── assets/
# │   ├── application-[hash].js     (~140 KB gzip)
# │   ├── vue-vendor-[hash].js
# │   ├── ui-vendor-[hash].js
# │   ├── components-[hash].js
# │   ├── organisms-forms-[hash].js
# │   ├── organisms-display-[hash].js
# │   ├── organisms-common-[hash].js
# │   └── utils-[hash].js
# └── manifest.json

# Build Storybook
pnpm build-storybook
# Output: storybook-static/
```

### 8.3 Integración con Rails Asset Pipeline

**Archivo:** `app/views/layouts/application.html.erb`

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>PlebisHub</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%# Vite assets %>
    <%= vite_client_tag %>
    <%= vite_stylesheet_tag 'application' %>
  </head>

  <body>
    <%= yield %>

    <%# Vite JavaScript %>
    <%= vite_javascript_tag 'application' %>
  </body>
</html>
```

### 8.4 Deployment Checklist

```bash
# Pre-deployment
□ pnpm test (all tests passing)
□ pnpm lint (no errors)
□ pnpm type-check (no type errors)
□ pnpm build (successful build)
□ git commit && git push

# Production deployment
□ bundle install
□ rake db:migrate
□ rake assets:precompile (includes Vite build)
□ restart Rails server
□ verify functionality on staging

# Post-deployment
□ Check Lighthouse score >90
□ Check bundle size <150 KB
□ Monitor error tracking (Sentry/etc)
□ Check Core Web Vitals
```

---

## 9. GUÍA DE DESARROLLO

### 9.1 Crear un Nuevo Componente

**Paso 1:** Crear archivos

```bash
# Crear componente
touch app/frontend/components/atoms/NewComponent.vue

# Crear test
touch app/frontend/components/atoms/NewComponent.test.ts

# Crear story
touch app/frontend/components/atoms/NewComponent.stories.ts
```

**Paso 2:** Escribir componente

```vue
<!-- app/frontend/components/atoms/NewComponent.vue -->
<template>
  <div class="new-component">
    {{ message }}
  </div>
</template>

<script setup lang="ts">
interface Props {
  message: string
}

defineProps<Props>()
</script>

<style scoped>
.new-component {
  @apply p-4 bg-primary-100 rounded-md;
}
</style>
```

**Paso 3:** Escribir tests

```typescript
// app/frontend/components/atoms/NewComponent.test.ts
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import NewComponent from './NewComponent.vue'

describe('NewComponent', () => {
  it('renders message prop', () => {
    const wrapper = mount(NewComponent, {
      props: { message: 'Hello World' }
    })

    expect(wrapper.text()).toBe('Hello World')
  })
})
```

**Paso 4:** Crear stories

```typescript
// app/frontend/components/atoms/NewComponent.stories.ts
import type { Meta, StoryObj } from '@storybook/vue3'
import NewComponent from './NewComponent.vue'

const meta = {
  title: 'Atoms/NewComponent',
  component: NewComponent,
  tags: ['autodocs'],
  argTypes: {
    message: { control: 'text' },
  },
} satisfies Meta<typeof NewComponent>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    message: 'Hello from Storybook!',
  },
}
```

**Paso 5:** Registrar en application.ts

```typescript
// app/frontend/entrypoints/application.ts
import NewComponent from '@components/atoms/NewComponent.vue'

const componentMap = {
  // ... otros componentes
  NewComponent,
}
```

**Paso 6:** Usar en ERB

```erb
<!-- app/views/pages/index.html.erb -->
<div
  data-vue-component="NewComponent"
  data-vue-props='{"message": "Hello from Rails!"}'
></div>
```

### 9.2 Convenciones de Código

**Naming:**
```typescript
// Componentes: PascalCase
import ProposalCard from '@components/organisms/ProposalCard.vue'

// Composables: camelCase con prefijo 'use'
import { useForm } from '@composables/useForm'

// Types: PascalCase con sufijo Type/Interface
interface UserProfile {
  id: number
  name: string
}

// Constants: SCREAMING_SNAKE_CASE
const MAX_FILE_SIZE = 5 * 1024 * 1024 // 5MB
```

**Props & Emits:**
```typescript
// Props: defineProps con TypeScript interface
interface Props {
  title: string
  description?: string
  onSubmit?: () => void
}

const props = defineProps<Props>()

// Emits: defineEmits con tipos
const emit = defineEmits<{
  submit: [data: FormData]
  cancel: []
}>()
```

**Tailwind Classes:**
```vue
<template>
  <!-- Usar clases de Tailwind directamente -->
  <div class="flex items-center justify-between p-4 bg-white rounded-lg shadow-md">
    <!-- Preferir clases de utilidad sobre CSS custom -->
    <h2 class="text-2xl font-heading font-bold text-primary-700">
      {{ title }}
    </h2>
  </div>
</template>
```

**Composables:**
```typescript
// Siempre retornar reactive refs
export function useExample() {
  const state = ref('initial')
  const computed = computed(() => state.value.toUpperCase())

  const method = () => {
    state.value = 'changed'
  }

  // Retornar todo lo que necesite el componente
  return {
    state,
    computed,
    method,
  }
}
```

### 9.3 Git Workflow

```bash
# 1. Crear rama feature
git checkout -b feature/new-component

# 2. Desarrollar (commits small & focused)
git add app/frontend/components/atoms/NewComponent.vue
git commit -m "feat: add NewComponent atom"

git add app/frontend/components/atoms/NewComponent.test.ts
git commit -m "test: add tests for NewComponent"

git add app/frontend/components/atoms/NewComponent.stories.ts
git commit -m "docs: add Storybook stories for NewComponent"

# 3. Pre-commit hooks (auto-ejecutados)
# - ESLint fix
# - Prettier format
# - Tests (opcional)

# 4. Push
git push origin feature/new-component

# 5. Create PR
gh pr create --title "feat: Add NewComponent atom" --body "..."

# 6. Merge después de review
```

---

## 10. INTEGRACIÓN CON RAILS ENGINES

### 10.1 Estructura de Engines

```
engines/
├── plebis_proposals/
│   ├── app/
│   │   ├── controllers/
│   │   ├── models/
│   │   └── views/              # ERB templates
│   │       └── proposals/
│   │           └── index.html.erb  # Usa componentes Vue
│   └── spec/
│
├── plebis_votes/
├── plebis_impulsa/
├── plebis_microcredit/
├── plebis_collaborations/
├── plebis_verification/
├── plebis_cms/
└── plebis_participation/
```

### 10.2 Usar Componentes Vue en Engine Views

**Ejemplo: Proposals Engine**

**Archivo:** `engines/plebis_proposals/app/views/proposals/index.html.erb`

```erb
<div class="proposals-page">
  <div class="container mx-auto px-4 py-8">
    <!-- Vue component: SearchBar -->
    <div
      data-vue-component="SearchBar"
      data-vue-props='<%= {
        placeholder: "Buscar propuestas...",
        debounce: 300
      }.to_json %>'
      class="mb-6"
    ></div>

    <!-- Vue component: ProposalsList -->
    <div
      data-vue-component="ProposalsList"
      data-vue-props='<%= {
        proposals: @proposals.map { |p| {
          id: p.id,
          title: p.title,
          description: p.description,
          author: {
            name: p.author.name,
            avatar: p.author.avatar_url
          },
          category: p.category.name,
          votes: p.votes_count,
          createdAt: p.created_at.iso8601,
          status: p.status
        }},
        canCreate: can?(:create, Proposal)
      }.to_json %>'
    ></div>
  </div>
</div>
```

### 10.3 API Endpoints para Componentes Vue

**Controller:** `engines/plebis_votes/app/controllers/api/votes_controller.rb`

```ruby
module Api
  class VotesController < ApplicationController
    before_action :authenticate_user!

    # POST /api/votes
    def create
      @vote = current_user.votes.build(vote_params)

      if @vote.save
        render json: {
          success: true,
          vote: vote_json(@vote)
        }
      else
        render json: {
          success: false,
          errors: @vote.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    # DELETE /api/votes/:id
    def destroy
      @vote = current_user.votes.find(params[:id])
      @vote.destroy

      render json: { success: true }
    end

    private

    def vote_params
      params.require(:vote).permit(:proposal_id, :value)
    end

    def vote_json(vote)
      {
        id: vote.id,
        proposal_id: vote.proposal_id,
        value: vote.value,
        created_at: vote.created_at.iso8601
      }
    end
  end
end
```

**Componente Vue hace fetch:**

```typescript
// app/frontend/components/organisms/VoteButton.vue
const handleVote = async (value: 'yes' | 'no' | 'abstain') => {
  try {
    const response = await fetch('/api/votes', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': getCsrfToken(),
      },
      body: JSON.stringify({
        vote: {
          proposal_id: props.proposalId,
          value,
        },
      }),
    })

    const data = await response.json()

    if (data.success) {
      emit('vote-success', data.vote)
    } else {
      emit('vote-error', data.errors)
    }
  } catch (error) {
    emit('vote-error', ['Error de conexión'])
  }
}

function getCsrfToken(): string {
  const meta = document.querySelector('meta[name="csrf-token"]')
  return meta ? meta.getAttribute('content') || '' : ''
}
```

### 10.4 Compartir Estado entre Engines

**Store global de Pinia:**

```typescript
// app/frontend/stores/user.ts
import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    id: null as number | null,
    name: '',
    email: '',
    avatar: '',
    verified: false,
    permissions: [] as string[],
  }),

  getters: {
    isLoggedIn: (state) => state.id !== null,
    canVote: (state) => state.verified,
    canCreateProposal: (state) =>
      state.permissions.includes('create_proposal'),
  },

  actions: {
    setUser(user: any) {
      this.id = user.id
      this.name = user.name
      this.email = user.email
      this.avatar = user.avatar
      this.verified = user.verified
      this.permissions = user.permissions
    },

    logout() {
      this.$reset()
    },
  },
})
```

**Inicializar en layout:**

```erb
<!-- app/views/layouts/application.html.erb -->
<script type="application/json" id="current-user-data">
  <%= {
    id: current_user&.id,
    name: current_user&.name,
    email: current_user&.email,
    avatar: current_user&.avatar_url,
    verified: current_user&.verified?,
    permissions: current_user&.permissions || []
  }.to_json.html_safe %>
</script>

<%= vite_javascript_tag 'application' %>

<script>
  // Initialize user store from server data
  document.addEventListener('DOMContentLoaded', () => {
    const userData = JSON.parse(
      document.getElementById('current-user-data').textContent
    )

    if (window.__pinia && userData.id) {
      const userStore = window.__pinia.state.value.user
      userStore.setUser(userData)
    }
  })
</script>
```

---

## 11. PRÓXIMOS PASOS

### 11.1 Mejoras Pendientes

**Corto Plazo (1-2 meses):**

- [ ] **Theme Customization Admin Panel**
  - Crear panel de administración para customizar colores
  - Preview en tiempo real de cambios
  - Export/import de temas
  - Guardar temas personalizados en DB

- [ ] **Más Tests E2E**
  - Flujo completo de creación de propuesta
  - Flujo de verificación de usuario
  - Flujo de microcrédito
  - Flujo de proyecto Impulsa

- [ ] **Performance Monitoring**
  - Integrar Lighthouse CI
  - Dashboard de Core Web Vitals
  - Bundle size tracking

- [ ] **Accessibility Improvements**
  - Auditoría WCAG 2.1 AA completa
  - Keyboard navigation en todos los componentes
  - Screen reader testing

**Medio Plazo (3-6 meses):**

- [ ] **PWA Support**
  - Service worker para offline
  - App manifest
  - Push notifications

- [ ] **Internationalization (i18n)**
  - Extraer todos los textos a archivos de traducción
  - Soporte para español/inglés/catalán
  - Fechas y números localizados

- [ ] **Advanced Forms**
  - Form builder visual
  - Conditional fields
  - Multi-step forms with state persistence

- [ ] **Real-time Features**
  - WebSockets para votaciones en vivo
  - Notificaciones en tiempo real
  - Comentarios live

**Largo Plazo (6-12 meses):**

- [ ] **Micro-frontends**
  - Extraer engines a micro-frontends independientes
  - Module Federation con Vite
  - Deploy independiente por engine

- [ ] **Design System Package**
  - Publicar design system como paquete npm privado
  - Reutilizable en otros proyectos
  - Documentación standalone

### 11.2 Tech Debt

- [ ] **Migrar vistas ERB legacy**
  - 194 archivos ERB aún existen
  - Migrar progresivamente a Vue SPA
  - Priorizar por tráfico de usuarios

- [ ] **Eliminar Bootstrap 3 completamente**
  - Aún hay clases de Bootstrap en algunos ERB
  - Reemplazar con Tailwind

- [ ] **Consolidar APIs**
  - Crear API REST consistente para todos los engines
  - Considerar GraphQL para queries complejas

### 11.3 Documentación

- [ ] **Component Library Site**
  - Sitio público con todos los componentes
  - Ejemplos de uso
  - Guías de implementación

- [ ] **Video Tutorials**
  - Onboarding para nuevos desarrolladores
  - Cómo crear componentes
  - Cómo integrar con Rails engines

- [ ] **Architecture Decision Records (ADR)**
  - Documentar decisiones técnicas importantes
  - Por qué Vue en lugar de React
  - Por qué Tailwind en lugar de Bootstrap 5

---

## ANEXOS

### A. Comandos Útiles

```bash
# Frontend
pnpm dev                    # Dev server con HMR
pnpm build                  # Build producción
pnpm test                   # Run all tests
pnpm test:coverage          # Tests con coverage
pnpm test:ui                # Tests con UI
pnpm test:e2e               # E2E tests
pnpm lint                   # Lint código
pnpm format                 # Format código
pnpm type-check             # Type checking
pnpm storybook              # Storybook dev
pnpm build-storybook        # Build Storybook

# Rails
bin/rails server            # Rails server
bin/rails console           # Rails console
bin/rails db:migrate        # Run migrations
bin/rails routes            # Ver rutas
bin/rails assets:precompile # Compile assets (incluye Vite)

# Testing Rails
bundle exec rspec           # Run RSpec tests
bundle exec rails test      # Run Minitest (legacy)

# Git
git checkout -b feature/... # Nueva rama
git add .                   # Stage changes
git commit -m "..."         # Commit
git push origin ...         # Push rama
gh pr create                # Crear PR (GitHub CLI)
```

### B. Recursos Externos

**Documentación oficial:**
- [Vue 3 Docs](https://vuejs.org/)
- [Vite Docs](https://vitejs.dev/)
- [Tailwind CSS Docs](https://tailwindcss.com/)
- [Vitest Docs](https://vitest.dev/)
- [Playwright Docs](https://playwright.dev/)
- [Storybook Docs](https://storybook.js.org/)
- [Pinia Docs](https://pinia.vuejs.org/)
- [VueUse Docs](https://vueuse.org/)

**Herramientas:**
- [Figma](https://figma.com) - Diseño UI/UX
- [Lucide Icons](https://lucide.dev) - Biblioteca de iconos
- [Tailwind UI](https://tailwindui.com) - Componentes premium (referencia)

### C. Contacto y Soporte

**Equipo Frontend:**
- Lead: [Nombre]
- Developers: [Nombres]

**Canales:**
- Slack: #frontend-plebishub
- GitHub Issues: [github.com/organization/plebishub/issues](https://github.com)
- Email: frontend@plebishub.com

---

**Última actualización:** 12 de Noviembre de 2025
**Versión del documento:** 2.0
**Estado:** IMPLEMENTACIÓN COMPLETADA ✅
