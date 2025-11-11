# PlebisHub Design System - Continuation Prompt for Next Session

## 📊 Current State Summary

**Project:** PlebisHub Design System - Atomic Design Pattern Implementation
**Current Phase:** Molecule Components - Complex Components Remaining
**Branch:** `claude/implement-molecules-accordion-pagination-011CV2ekYKLx6YR7SBLfxwxx`
**Token Budget:** 200,000 tokens per session
**Date:** 2025-11-11

### ✅ Completed Components

**Atoms (11 total):** All completed in previous sessions

- Avatar, Button, Icon, Input, Label, Link, Logo, Spinner, Text, Textarea, Checkbox

**Molecules (40 total):** All simple molecules completed

- **Session 1 (28 components):** Accordion, Alert, AlertBanner, AvatarGroup, Breadcrumb, Card, Divider, Dropdown, EmptyState, FileUpload, FormField, Menu, Modal, NotificationBadge, Pagination, ProgressBar, Rating, SearchBar, Skeleton, Slider, Stat, Stepper, TabPanel, Tabs, Tag, Timeline, Toast, UserCard
- **Session 2 (12 components):** Collapsible, Loading, ProgressSteps, Kbd, Code, Tooltip, Badge, ListItem, ButtonGroup, Toggle, CheckboxGroup, RadioGroup

**Total Test Coverage:** ~800+ comprehensive tests across all molecules

### 🎯 Pending Components (Complex Molecules)

These are the remaining complex molecule components to implement:

1. **Drawer/Sidebar** - Lateral sliding panel with backdrop
   - Positions: left, right, top, bottom
   - Sizes: sm, md, lg, full
   - Features: backdrop blur, close on outside click, escape key handling
   - Complexity: Portal/Teleport, focus trap, body scroll lock

2. **Popover** - Floating content with actions (más complejo que Tooltip)
   - Positioning: auto-placement with collision detection
   - Trigger modes: click, hover, focus
   - Features: arrow indicator, close button, interactive content
   - Complexity: Floating UI positioning logic

3. **DatePicker** - Date selection with calendar
   - Single date, date range, multiple dates
   - Month/year navigation
   - Min/max date constraints
   - Disabled dates array
   - Complexity: Calendar grid generation, date manipulation

4. **TimePicker** - Time selection interface
   - 12h/24h format support
   - Hour, minute, second selection
   - Dropdown or spinner interface
   - Complexity: Time validation, format conversion

5. **Combobox/Autocomplete** - Dropdown with search functionality
   - Async search support
   - Keyboard navigation (arrow keys, enter, escape)
   - Multi-select mode
   - Custom option rendering
   - Complexity: Search/filter logic, keyboard accessibility

6. **ColorPicker** - Color selection interface
   - HEX, RGB, HSL format support
   - Color palette presets
   - Eyedropper integration (if supported)
   - Opacity/alpha channel
   - Complexity: Color format conversion, canvas rendering

7. **Tree** - Hierarchical tree view
   - Expandable/collapsible nodes
   - Checkbox selection with parent-child relationship
   - Drag and drop reordering
   - Virtual scrolling for large trees
   - Complexity: Recursive rendering, state management

8. **Calendar** - Full calendar view component
   - Month/week/day views
   - Event display and management
   - Date range selection
   - Today indicator
   - Complexity: Grid layout, event positioning

**Priority Order (Recommended):**

1. Drawer (most commonly used, medium complexity)
2. Popover (commonly used, medium complexity)
3. Combobox (very useful, medium-high complexity)
4. DatePicker (high complexity, very useful)
5. TimePicker (pairs with DatePicker)
6. ColorPicker (specialized use case)
7. Tree (high complexity)
8. Calendar (very high complexity)

---

## 🏗️ Established Architecture Patterns

### Tech Stack

```json
{
  "framework": "Vue 3.4+",
  "language": "TypeScript 5.x (strict mode)",
  "build": "Vite 5.x",
  "testing": "Vitest + @vue/test-utils",
  "storybook": "Storybook 8+ (@storybook/vue3-vite)",
  "styling": "Tailwind CSS 3.4+",
  "icons": "Lucide Icons (lucide-vue-next)",
  "git": "Husky pre-commit hooks (ESLint + Prettier)"
}
```

### Design Tokens

```typescript
// Color Palette
const colors = {
  primary: '#612d62',    // Purple
  secondary: '#269283',  // Teal
  success: '#10b981',
  warning: '#f59e0b',
  error: '#ef4444',
  info: '#3b82f6',
  neutral: '#6b7280',
}

// Sizes
const sizes = {
  sm: 'Small variant',
  md: 'Medium variant (default)',
  lg: 'Large variant',
}

// Spacing (Tailwind scale)
gap-2, gap-3, gap-4, p-2, p-3, p-4, etc.
```

### File Structure Pattern

```
app/frontend/components/molecules/
├── ComponentName.vue          # Main component
├── ComponentName.test.ts      # 25-50 comprehensive tests
└── ComponentName.stories.ts   # Storybook stories
```

---

## 📝 Component Code Pattern

### 1. Component Structure (ComponentName.vue)

```vue
<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

// 1. Interface Definitions
export interface ComponentOption {
  label: string
  value: string | number
  disabled?: boolean
  icon?: string
}

export interface Props {
  modelValue: string | number | null
  options: ComponentOption[]
  label?: string
  description?: string
  placeholder?: string
  disabled?: boolean
  required?: boolean
  error?: string
  size?: 'sm' | 'md' | 'lg'
  variant?: 'default' | 'outline' | 'ghost'
}

// 2. Props with Defaults
const props = withDefaults(defineProps<Props>(), {
  disabled: false,
  required: false,
  size: 'md',
  variant: 'default',
  placeholder: 'Select...',
})

// 3. Emits (typed)
const emit = defineEmits<{
  'update:modelValue': [value: string | number | null]
  change: [value: string | number | null]
}>()

// 4. Computed Properties
const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'text-sm p-2'
    case 'lg':
      return 'text-lg p-4'
    default:
      return 'text-base p-3'
  }
})

const variantClasses = computed(() => {
  if (props.disabled) {
    return 'bg-gray-100 text-gray-400 cursor-not-allowed'
  }

  switch (props.variant) {
    case 'outline':
      return 'border-2 border-primary-600 bg-white text-primary-600'
    case 'ghost':
      return 'bg-transparent text-primary-600 hover:bg-primary-50'
    default:
      return 'bg-primary-600 text-white hover:bg-primary-700'
  }
})

// 5. Event Handlers
const handleChange = (value: string | number | null) => {
  if (props.disabled) return
  emit('update:modelValue', value)
  emit('change', value)
}

// 6. Slots (if needed)
defineSlots<{
  default?: () => unknown
  prepend?: () => unknown
  append?: () => unknown
}>()
</script>

<template>
  <div class="component-wrapper">
    <!-- Label with required indicator -->
    <label v-if="label" class="mb-2 block text-sm font-medium text-gray-700">
      {{ label }}
      <span v-if="required" class="ml-1 text-red-500" aria-label="required">*</span>
    </label>

    <!-- Description -->
    <p v-if="description" class="mb-2 text-sm text-gray-500">
      {{ description }}
    </p>

    <!-- Main Component -->
    <div
      :class="['component-base-classes', sizeClasses, variantClasses, { 'border-red-500': error }]"
    >
      <!-- Component content -->
      <slot />
    </div>

    <!-- Error Message -->
    <p v-if="error" class="mt-2 text-sm text-red-600">
      {{ error }}
    </p>
  </div>
</template>
```

### 2. Test Structure (ComponentName.test.ts)

```typescript
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ComponentName from './ComponentName.vue'

describe('ComponentName', () => {
  describe('Basic Rendering', () => {
    it('renders correctly', () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: null,
          options: [],
        },
      })
      expect(wrapper.exists()).toBe(true)
    })

    it('renders with label', () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: null,
          options: [],
          label: 'Test Label',
        },
      })
      expect(wrapper.find('label').text()).toBe('Test Label')
    })

    it('renders required indicator', () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: null,
          options: [],
          label: 'Test',
          required: true,
        },
      })
      expect(wrapper.find('span[aria-label="required"]').text()).toBe('*')
    })

    it('renders description', () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: null,
          options: [],
          description: 'Test description',
        },
      })
      expect(wrapper.text()).toContain('Test description')
    })

    it('renders error message', () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: null,
          options: [],
          error: 'Error message',
        },
      })
      expect(wrapper.text()).toContain('Error message')
      expect(wrapper.find('.text-red-600').exists()).toBe(true)
    })
  })

  describe('Props', () => {
    it('applies size classes', async () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: null,
          options: [],
          size: 'sm',
        },
      })
      expect(wrapper.html()).toContain('text-sm')
    })

    it('handles disabled state', () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: null,
          options: [],
          disabled: true,
        },
      })
      expect(wrapper.html()).toContain('cursor-not-allowed')
    })
  })

  describe('Events', () => {
    it('emits update:modelValue on change', async () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: null,
          options: [{ label: 'Option 1', value: '1' }],
        },
      })

      // Trigger change event
      await wrapper.find('input').setValue('1')

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['1'])
    })

    it('emits change event', async () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: null,
          options: [{ label: 'Option 1', value: '1' }],
        },
      })

      await wrapper.find('input').setValue('1')

      expect(wrapper.emitted('change')).toBeTruthy()
      expect(wrapper.emitted('change')?.[0]).toEqual(['1'])
    })

    it('does not emit when disabled', async () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: null,
          options: [{ label: 'Option 1', value: '1' }],
          disabled: true,
        },
      })

      await wrapper.find('input').trigger('click')

      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })
  })

  describe('Accessibility', () => {
    it('has proper ARIA attributes', () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: null,
          options: [],
          label: 'Test',
          required: true,
          error: 'Error',
        },
      })

      const input = wrapper.find('input')
      expect(input.attributes('aria-required')).toBe('true')
      expect(input.attributes('aria-invalid')).toBe('true')
    })
  })

  describe('Edge Cases', () => {
    it('handles empty options array', () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: null,
          options: [],
        },
      })
      expect(wrapper.exists()).toBe(true)
    })

    it('handles numeric values', () => {
      const wrapper = mount(ComponentName, {
        props: {
          modelValue: 1,
          options: [
            { label: 'One', value: 1 },
            { label: 'Two', value: 2 },
          ],
        },
      })
      expect(wrapper.exists()).toBe(true)
    })
  })
})
```

### 3. Stories Structure (ComponentName.stories.ts)

```typescript
import type { Meta, StoryObj } from '@storybook/vue3-vite'
import ComponentName from './ComponentName.vue'

const meta = {
  title: 'Molecules/ComponentName',
  component: ComponentName,
  tags: ['autodocs'],
  argTypes: {
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
    },
    variant: {
      control: 'select',
      options: ['default', 'outline', 'ghost'],
    },
    disabled: {
      control: 'boolean',
    },
    required: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof ComponentName>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    modelValue: null,
    options: [
      { label: 'Option 1', value: '1' },
      { label: 'Option 2', value: '2' },
      { label: 'Option 3', value: '3' },
    ],
  },
}

export const WithLabel: Story = {
  args: {
    modelValue: null,
    options: [
      { label: 'Option 1', value: '1' },
      { label: 'Option 2', value: '2' },
    ],
    label: 'Select an option',
  },
}

export const WithDescription: Story = {
  args: {
    modelValue: null,
    options: [
      { label: 'Option 1', value: '1' },
      { label: 'Option 2', value: '2' },
    ],
    label: 'Select an option',
    description: 'Choose the option that best fits your needs',
  },
}

export const Required: Story = {
  args: {
    modelValue: null,
    options: [
      { label: 'Option 1', value: '1' },
      { label: 'Option 2', value: '2' },
    ],
    label: 'Select an option',
    required: true,
  },
}

export const WithError: Story = {
  args: {
    modelValue: null,
    options: [
      { label: 'Option 1', value: '1' },
      { label: 'Option 2', value: '2' },
    ],
    label: 'Select an option',
    error: 'This field is required',
  },
}

export const Disabled: Story = {
  args: {
    modelValue: null,
    options: [
      { label: 'Option 1', value: '1' },
      { label: 'Option 2', value: '2' },
    ],
    label: 'Select an option',
    disabled: true,
  },
}

export const SmallSize: Story = {
  args: {
    modelValue: null,
    options: [
      { label: 'Option 1', value: '1' },
      { label: 'Option 2', value: '2' },
    ],
    size: 'sm',
  },
}

export const LargeSize: Story = {
  args: {
    modelValue: null,
    options: [
      { label: 'Option 1', value: '1' },
      { label: 'Option 2', value: '2' },
    ],
    size: 'lg',
  },
}
```

---

## 🚀 Workflow for Each Component

### Step-by-Step Process

1. **Create Component File** (`ComponentName.vue`)
   - Define TypeScript interfaces
   - Implement props with defaults
   - Define typed emits
   - Create computed properties for dynamic classes
   - Implement event handlers
   - Build template with accessibility in mind

2. **Create Test File** (`ComponentName.test.ts`)
   - Basic rendering tests (5-10 tests)
   - Props tests (5-10 tests)
   - Events tests (5-10 tests)
   - Accessibility tests (3-5 tests)
   - Edge cases tests (3-5 tests)
   - **Target: 25-50 tests per component**

3. **Create Stories File** (`ComponentName.stories.ts`)
   - Default story
   - All prop variants (size, variant, etc.)
   - State stories (disabled, error, required)
   - Real-world use case stories
   - **Target: 8-12 stories per component**

4. **Run Tests**

   ```bash
   npm test -- ComponentName.test.ts
   ```

   - Verify all tests pass
   - Fix any ESLint errors
   - Ensure 100% pass rate

5. **Commit & Push**

   ```bash
   git add app/frontend/components/molecules/ComponentName.*
   git commit -m "Add ComponentName molecule component with X comprehensive tests

   Features:
   - Feature 1
   - Feature 2
   - Feature 3

   Test coverage (X tests):
   - Test category 1
   - Test category 2
   - Test category 3"

   git push -u origin claude/implement-molecules-accordion-pagination-011CV2ekYKLx6YR7SBLfxwxx
   ```

6. **Verify**
   ```bash
   git status  # Should show "working tree clean"
   ```

---

## ⚠️ Common Errors to Avoid

### 1. ESLint Errors

**Error:** Missing default case in computed property

```typescript
// ❌ WRONG
const classes = computed(() => {
  switch (props.variant) {
    case 'outline':
      return 'border-2'
    case 'ghost':
      return 'bg-transparent'
  }
})

// ✅ CORRECT
const classes = computed(() => {
  switch (props.variant) {
    case 'outline':
      return 'border-2'
    case 'ghost':
      return 'bg-transparent'
    default:
      return 'bg-primary-600' // Always include default
  }
})
```

**Error:** Unused parameters

```typescript
// ❌ WRONG
const getClasses = (item: Item, index: number) => {
  return item.active ? 'active' : ''
}

// ✅ CORRECT
const getClasses = (item: Item, _index: number) => {
  // Prefix unused params with underscore
  return item.active ? 'active' : ''
}
```

**Error:** Using 'any' type

```typescript
// ❌ WRONG
defineSlots<{
  default?: () => any
}>()

// ✅ CORRECT
defineSlots<{
  default?: () => unknown
}>()
```

### 2. Git Errors

**Error:** Untracked files (Stop Hook)

- **Solution:** Always run `git status` before finishing
- Commit ALL files: .vue, .test.ts, .stories.ts

**Error:** Push to wrong branch

- **Solution:** Always use full branch name with -u flag

```bash
git push -u origin claude/implement-molecules-accordion-pagination-011CV2ekYKLx6YR7SBLfxwxx
```

### 3. Test Errors

**Error:** Component not imported in test

```typescript
// ✅ CORRECT
import { mount } from '@vue/test-utils'
import ComponentName from './ComponentName.vue'
import Icon from '../atoms/Icon.vue'

const wrapper = mount(ComponentName, {
  global: {
    components: { Icon }, // Register child components
  },
})
```

**Error:** Async operations not awaited

```typescript
// ❌ WRONG
wrapper.find('button').trigger('click')
expect(wrapper.emitted('click')).toBeTruthy()

// ✅ CORRECT
await wrapper.find('button').trigger('click')
expect(wrapper.emitted('click')).toBeTruthy()
```

---

## 🎨 Complex Component Specific Patterns

### Portal/Teleport Pattern (Drawer, Modal, Popover)

```vue
<template>
  <Teleport to="body">
    <Transition
      enter-active-class="transition-opacity duration-200"
      leave-active-class="transition-opacity duration-200"
      enter-from-class="opacity-0"
      leave-to-class="opacity-0"
    >
      <div v-if="modelValue" class="fixed inset-0 z-50">
        <!-- Backdrop -->
        <div
          class="absolute inset-0 bg-black/50 backdrop-blur-sm"
          @click="handleBackdropClick"
        ></div>

        <!-- Content -->
        <div class="relative z-10">
          <slot />
        </div>
      </div>
    </Transition>
  </Teleport>
</template>
```

### Focus Trap Pattern (Drawer, Modal)

```typescript
import { ref, onMounted, onUnmounted } from 'vue'

const containerRef = ref<HTMLElement | null>(null)

const trapFocus = (e: KeyboardEvent) => {
  if (!containerRef.value || e.key !== 'Tab') return

  const focusableElements = containerRef.value.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  )

  const firstElement = focusableElements[0] as HTMLElement
  const lastElement = focusableElements[focusableElements.length - 1] as HTMLElement

  if (e.shiftKey && document.activeElement === firstElement) {
    lastElement.focus()
    e.preventDefault()
  } else if (!e.shiftKey && document.activeElement === lastElement) {
    firstElement.focus()
    e.preventDefault()
  }
}

onMounted(() => {
  document.addEventListener('keydown', trapFocus)
})

onUnmounted(() => {
  document.removeEventListener('keydown', trapFocus)
})
```

### Body Scroll Lock Pattern (Drawer, Modal)

```typescript
import { watch } from 'vue'

watch(
  () => props.modelValue,
  (isOpen) => {
    if (isOpen) {
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = ''
    }
  }
)

onUnmounted(() => {
  document.body.style.overflow = ''
})
```

### Keyboard Navigation Pattern (Combobox, Dropdown)

```typescript
const handleKeydown = (e: KeyboardEvent) => {
  switch (e.key) {
    case 'ArrowDown':
      e.preventDefault()
      focusNextOption()
      break
    case 'ArrowUp':
      e.preventDefault()
      focusPreviousOption()
      break
    case 'Enter':
      e.preventDefault()
      selectFocusedOption()
      break
    case 'Escape':
      e.preventDefault()
      closeDropdown()
      break
    case 'Home':
      e.preventDefault()
      focusFirstOption()
      break
    case 'End':
      e.preventDefault()
      focusLastOption()
      break
  }
}
```

### Date Utilities Pattern (DatePicker, Calendar)

```typescript
// Date range generation
const getDaysInMonth = (year: number, month: number): number => {
  return new Date(year, month + 1, 0).getDate()
}

const getFirstDayOfMonth = (year: number, month: number): number => {
  return new Date(year, month, 1).getDay()
}

const generateCalendarGrid = (year: number, month: number) => {
  const daysInMonth = getDaysInMonth(year, month)
  const firstDay = getFirstDayOfMonth(year, month)
  const grid: (number | null)[] = []

  // Fill empty cells before first day
  for (let i = 0; i < firstDay; i++) {
    grid.push(null)
  }

  // Fill days
  for (let day = 1; day <= daysInMonth; day++) {
    grid.push(day)
  }

  return grid
}

// Date comparison
const isSameDay = (date1: Date, date2: Date): boolean => {
  return (
    date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate()
  )
}

const isDateInRange = (date: Date, min?: Date, max?: Date): boolean => {
  if (min && date < min) return false
  if (max && date > max) return false
  return true
}
```

### Color Utilities Pattern (ColorPicker)

```typescript
// Color format conversions
const hexToRgb = (hex: string): { r: number; g: number; b: number } | null => {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
  return result
    ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16),
      }
    : null
}

const rgbToHex = (r: number, g: number, b: number): string => {
  return '#' + [r, g, b].map((x) => x.toString(16).padStart(2, '0')).join('')
}

const rgbToHsl = (r: number, g: number, b: number) => {
  r /= 255
  g /= 255
  b /= 255

  const max = Math.max(r, g, b)
  const min = Math.min(r, g, b)
  let h = 0
  let s = 0
  const l = (max + min) / 2

  if (max !== min) {
    const d = max - min
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min)

    switch (max) {
      case r:
        h = ((g - b) / d + (g < b ? 6 : 0)) / 6
        break
      case g:
        h = ((b - r) / d + 2) / 6
        break
      case b:
        h = ((r - g) / d + 4) / 6
        break
    }
  }

  return { h: h * 360, s: s * 100, l: l * 100 }
}
```

---

## 📋 Commands Reference

### Testing

```bash
# Run all tests
npm test

# Run specific test file
npm test -- ComponentName.test.ts

# Run multiple test files
npm test -- CheckboxGroup.test.ts RadioGroup.test.ts

# Run tests in watch mode
npm test -- --watch

# Run tests with coverage
npm test -- --coverage
```

### Storybook

```bash
# Start Storybook dev server
npm run storybook

# Build Storybook
npm run build-storybook
```

### Linting & Formatting

```bash
# Run ESLint
npm run lint

# Run ESLint with auto-fix
npm run lint -- --fix

# Run Prettier
npx prettier --write "app/frontend/components/**/*.{vue,ts}"
```

### Git

```bash
# Check status
git status

# Stage files
git add app/frontend/components/molecules/ComponentName.*

# Commit with detailed message
git commit -m "Add ComponentName molecule component with X comprehensive tests

Features:
- Feature 1
- Feature 2

Test coverage (X tests):
- Category 1
- Category 2"

# Push to remote
git push -u origin claude/implement-molecules-accordion-pagination-011CV2ekYKLx6YR7SBLfxwxx

# View recent commits
git log --oneline -10

# View diff
git diff
```

---

## 🎯 Strategy for Next Session

### Recommended Approach: Complete 4-5 Complex Components

**Priority Order:**

1. **Start with Drawer** (~2-3 hours)
   - Medium complexity
   - Very commonly used
   - Good intro to Portal/Teleport pattern
   - Establish focus trap and scroll lock patterns

2. **Then Popover** (~2-3 hours)
   - Medium complexity
   - Builds on Tooltip experience
   - Introduce positioning logic

3. **Then Combobox** (~3-4 hours)
   - Medium-high complexity
   - Very useful component
   - Establish search/filter patterns
   - Practice keyboard navigation

4. **Then DatePicker** (~4-5 hours)
   - High complexity
   - Very useful
   - Establish date manipulation patterns

5. **If time permits: TimePicker** (~2-3 hours)
   - Pairs well with DatePicker
   - Reuses date patterns

**Time Estimate:** 13-18 hours total for 5 components
**Token Estimate:** ~150k-180k tokens with 200k budget

### Alternative: Complete All 8 Complex Components

If you want to finish everything in one session, you can attempt all 8 components. This would require:

- **Time:** 20-25 hours
- **Tokens:** ~180k-195k (tight but feasible)
- **Strategy:** Start with simpler ones (Drawer, Popover) to build momentum

---

## 🎓 Lessons Learned & Best Practices

### 1. TypeScript Discipline

- Always define interfaces for props, options, emits
- Use `unknown` instead of `any`
- Prefix unused parameters with `_`
- Use strict type checking

### 2. Vue Composition API

- Use `<script setup lang="ts">` consistently
- Leverage `computed` for dynamic classes
- Always use `withDefaults` for default props
- Type emits properly

### 3. Testing Rigor

- Aim for 30-40 tests per component minimum
- Test all props, events, edge cases
- Always test accessibility (ARIA attributes)
- Test disabled states and error states
- Use `await` for async operations

### 4. Accessibility First

- Use semantic HTML (fieldset/legend for forms)
- Include ARIA attributes (aria-label, aria-required, aria-invalid)
- Support keyboard navigation
- Include focus indicators
- Test with screen readers in mind

### 5. Git Hygiene

- Commit each component individually
- Write descriptive commit messages with feature lists
- Always verify clean working tree
- Push immediately after each component

### 6. Error Prevention

- Always include default cases in switch statements
- Verify all child components are imported in tests
- Check for unused variables
- Run tests before committing

### 7. Performance

- Use computed properties for dynamic classes
- Avoid unnecessary re-renders
- Leverage v-if vs v-show appropriately
- Use Teleport for overlays to avoid z-index issues

---

## 📁 Project Structure Reference

```
/home/user/PlebisHub/
├── app/
│   └── frontend/
│       ├── components/
│       │   ├── atoms/
│       │   │   ├── Avatar.vue
│       │   │   ├── Button.vue
│       │   │   ├── Icon.vue
│       │   │   ├── Input.vue
│       │   │   ├── Label.vue
│       │   │   ├── Link.vue
│       │   │   ├── Logo.vue
│       │   │   ├── Spinner.vue
│       │   │   ├── Text.vue
│       │   │   ├── Textarea.vue
│       │   │   └── Checkbox.vue
│       │   └── molecules/
│       │       ├── [40 existing components].vue
│       │       ├── [40 existing components].test.ts
│       │       └── [40 existing components].stories.ts
│       ├── package.json
│       ├── vite.config.ts
│       ├── vitest.config.ts
│       └── tsconfig.json
├── .husky/
│   └── pre-commit  # ESLint + Prettier hooks
├── .git/
└── .claude/
    └── session-continuation-prompt.md  # This file
```

---

## 🚦 Starting Point for Next Session

### Initial Commands to Run

```bash
# 1. Check git status
git status

# 2. Verify we're on correct branch
git branch --show-current
# Should output: claude/implement-molecules-accordion-pagination-011CV2ekYKLx6YR7SBLfxwxx

# 3. Pull latest changes (if any)
git pull origin claude/implement-molecules-accordion-pagination-011CV2ekYKLx6YR7SBLfxwxx

# 4. Verify current components
ls -1 app/frontend/components/molecules/*.vue | wc -l
# Should output: 40

# 5. Check test infrastructure
npm test -- --version
```

### First Component to Create: Drawer

Start with **Drawer** component as it's:

- Very commonly used
- Medium complexity (good warmup)
- Establishes important patterns (Portal, Focus Trap, Scroll Lock)

### Success Criteria

At the end of the next session:

- ✅ 4-8 additional complex molecule components created
- ✅ 120-400 additional comprehensive tests written
- ✅ All tests passing (100% pass rate)
- ✅ All components committed and pushed
- ✅ Git working tree clean
- ✅ Storybook stories created for all components
- ✅ Zero ESLint errors
- ✅ All established patterns followed

---

## 💡 Final Notes

- **Token Management:** Monitor token usage, aim for ~150-180k max
- **Time Management:** Each complex component takes 2-5 hours
- **Quality over Quantity:** Better to complete 4 perfect components than 8 rushed ones
- **Test Coverage:** Maintain 30-40 tests minimum per component
- **Ask for Clarification:** If requirements unclear for complex components, ask user
- **Commit Often:** One commit per component, push immediately
- **Follow Patterns:** Use established patterns from previous 40 components

### User Preferences

- Usuario habla español, pero código en inglés
- Prefiere componentes simples primero, complejos después
- Valora exhaustividad en tests (30-50 tests por componente)
- Espera commits individuales con mensajes descriptivos
- Quiere autonomía: "crea tantos componentes como puedas"

### Branch Information

- **Main branch:** (not specified, typically `main` or `master`)
- **Feature branch:** `claude/implement-molecules-accordion-pagination-011CV2ekYKLx6YR7SBLfxwxx`
- **Always push to:** `origin/claude/implement-molecules-accordion-pagination-011CV2ekYKLx6YR7SBLfxwxx`

---

## ✅ Ready to Start!

When the next session begins:

1. Read this entire prompt
2. Verify git status and branch
3. Start with Drawer component
4. Follow the established patterns
5. Work autonomously until completion
6. Commit and push each component individually

**Goal:** Complete all remaining complex molecule components with the same quality and rigor as the previous 40 components.

**Hasta mañana! 🚀**
