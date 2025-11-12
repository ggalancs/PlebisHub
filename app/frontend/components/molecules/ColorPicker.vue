<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import Icon from '../atoms/Icon.vue'
import Input from '../atoms/Input.vue'

export interface Props {
  modelValue: string | null
  label?: string
  description?: string
  placeholder?: string
  disabled?: boolean
  required?: boolean
  error?: string
  format?: 'hex' | 'rgb' | 'hsl'
  showAlpha?: boolean
  presets?: string[]
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  disabled: false,
  required: false,
  format: 'hex',
  showAlpha: false,
  size: 'md',
  placeholder: 'Select color',
  presets: () => [
    '#FF0000', '#00FF00', '#0000FF', '#FFFF00',
    '#FF00FF', '#00FFFF', '#000000', '#FFFFFF',
    '#808080', '#800000', '#008000', '#000080',
  ],
})

const emit = defineEmits<{
  'update:modelValue': [value: string | null]
  change: [value: string | null]
}>()

const isOpen = ref(false)
const currentColor = ref('#FF0000')
const alpha = ref(1)

// Convert HEX to RGB
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

// Convert RGB to HEX
const rgbToHex = (r: number, g: number, b: number): string => {
  return (
    '#' +
    [r, g, b]
      .map((x) => {
        const hex = Math.round(x).toString(16)
        return hex.length === 1 ? '0' + hex : hex
      })
      .join('')
  )
}

// Convert RGB to HSL
const rgbToHsl = (
  r: number,
  g: number,
  b: number
): { h: number; s: number; l: number } => {
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

  return {
    h: Math.round(h * 360),
    s: Math.round(s * 100),
    l: Math.round(l * 100),
  }
}

// Convert HSL to RGB
const hslToRgb = (
  h: number,
  s: number,
  l: number
): { r: number; g: number; b: number } => {
  h /= 360
  s /= 100
  l /= 100

  let r: number, g: number, b: number

  if (s === 0) {
    r = g = b = l
  } else {
    const hue2rgb = (p: number, q: number, t: number) => {
      if (t < 0) t += 1
      if (t > 1) t -= 1
      if (t < 1 / 6) return p + (q - p) * 6 * t
      if (t < 1 / 2) return q
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6
      return p
    }

    const q = l < 0.5 ? l * (1 + s) : l + s - l * s
    const p = 2 * l - q

    r = hue2rgb(p, q, h + 1 / 3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1 / 3)
  }

  return {
    r: Math.round(r * 255),
    g: Math.round(g * 255),
    b: Math.round(b * 255),
  }
}

// Format color based on format prop
const formatColor = (hex: string, a: number): string => {
  const rgb = hexToRgb(hex)
  if (!rgb) return hex

  switch (props.format) {
    case 'rgb':
      if (props.showAlpha) {
        return `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${a})`
      }
      return `rgb(${rgb.r}, ${rgb.g}, ${rgb.b})`
    case 'hsl':
      const hsl = rgbToHsl(rgb.r, rgb.g, rgb.b)
      if (props.showAlpha) {
        return `hsla(${hsl.h}, ${hsl.s}%, ${hsl.l}%, ${a})`
      }
      return `hsl(${hsl.h}, ${hsl.s}%, ${hsl.l}%)`
    case 'hex':
    default:
      if (props.showAlpha && a < 1) {
        const alphaHex = Math.round(a * 255)
          .toString(16)
          .padStart(2, '0')
        return `${hex}${alphaHex}`
      }
      return hex
  }
}

// Display value
const displayValue = computed(() => {
  if (!props.modelValue) return ''
  return props.modelValue
})

// Display color for preview
const displayColor = computed(() => {
  if (!currentColor.value) return '#000000'
  return currentColor.value
})

// Update color
const updateColor = (hex: string) => {
  currentColor.value = hex
  const formatted = formatColor(hex, alpha.value)
  emit('update:modelValue', formatted)
  emit('change', formatted)
}

// Update alpha
const updateAlpha = (value: number) => {
  alpha.value = value
  const formatted = formatColor(currentColor.value, value)
  emit('update:modelValue', formatted)
  emit('change', formatted)
}

// Select preset
const selectPreset = (preset: string) => {
  updateColor(preset)
}

// Toggle dropdown
const toggleDropdown = () => {
  if (props.disabled) return
  isOpen.value = !isOpen.value
}

// Close dropdown
const closeDropdown = () => {
  isOpen.value = false
}

// Clear selection
const clearSelection = () => {
  if (props.disabled) return
  currentColor.value = '#FF0000'
  alpha.value = 1
  emit('update:modelValue', null)
  emit('change', null)
}

// Size classes
const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'text-sm'
    case 'lg':
      return 'text-lg'
    default:
      return 'text-base'
  }
})

// Click outside handler
const handleClickOutside = (e: MouseEvent) => {
  if (!isOpen.value) return

  const target = e.target as Node
  const container = document.querySelector('.colorpicker-container')

  if (container && !container.contains(target)) {
    closeDropdown()
  }
}

// Parse initial color
watch(
  () => props.modelValue,
  (value) => {
    if (value) {
      // Extract hex color from various formats
      if (value.startsWith('#')) {
        currentColor.value = value.substring(0, 7)
        if (value.length > 7) {
          const alphaHex = value.substring(7, 9)
          alpha.value = parseInt(alphaHex, 16) / 255
        }
      } else if (value.startsWith('rgb')) {
        const match = value.match(/(\d+),\s*(\d+),\s*(\d+)/)
        if (match) {
          const r = parseInt(match[1])
          const g = parseInt(match[2])
          const b = parseInt(match[3])
          currentColor.value = rgbToHex(r, g, b)
        }
        const alphaMatch = value.match(/rgba?\([^,]+,[^,]+,[^,]+,\s*([\d.]+)\)/)
        if (alphaMatch) {
          alpha.value = parseFloat(alphaMatch[1])
        }
      }
    }
  },
  { immediate: true }
)

watch(isOpen, (value) => {
  if (value) {
    document.addEventListener('click', handleClickOutside)
  } else {
    document.removeEventListener('click', handleClickOutside)
  }
})

// Basic color palette (organized by hue)
const basicColors = [
  // Reds
  '#FF0000', '#FF3333', '#FF6666', '#FF9999', '#FFCCCC',
  // Oranges
  '#FF8800', '#FFAA33', '#FFCC66', '#FFDD99', '#FFEECC',
  // Yellows
  '#FFFF00', '#FFFF33', '#FFFF66', '#FFFF99', '#FFFFCC',
  // Greens
  '#00FF00', '#33FF33', '#66FF66', '#99FF99', '#CCFFCC',
  // Cyans
  '#00FFFF', '#33FFFF', '#66FFFF', '#99FFFF', '#CCFFFF',
  // Blues
  '#0000FF', '#3333FF', '#6666FF', '#9999FF', '#CCCCFF',
  // Purples
  '#8800FF', '#AA33FF', '#CC66FF', '#DD99FF', '#EECCFF',
  // Magentas
  '#FF00FF', '#FF33FF', '#FF66FF', '#FF99FF', '#FFCCFF',
  // Grays
  '#000000', '#333333', '#666666', '#999999', '#CCCCCC', '#FFFFFF',
]
</script>

<template>
  <div class="colorpicker-container" :class="sizeClasses">
    <!-- Label -->
    <label v-if="label" class="mb-2 block text-sm font-medium text-gray-700">
      {{ label }}
      <span v-if="required" class="ml-1 text-red-500" aria-label="required">*</span>
    </label>

    <!-- Description -->
    <p v-if="description" class="mb-2 text-sm text-gray-500">
      {{ description }}
    </p>

    <!-- Input -->
    <div class="relative">
      <div
        class="flex w-full cursor-pointer items-center rounded-md border bg-white"
        :class="[
          error ? 'border-red-500' : 'border-gray-300',
          disabled ? 'cursor-not-allowed bg-gray-100' : 'hover:border-gray-400',
        ]"
        @click="toggleDropdown"
      >
        <!-- Color preview -->
        <div class="ml-2 flex items-center gap-2">
          <div
            class="h-6 w-6 rounded border border-gray-300"
            :style="{ backgroundColor: displayColor }"
          ></div>
        </div>

        <div class="flex-1 px-3 py-2 text-gray-700" :class="{ 'text-gray-400': !displayValue }">
          {{ displayValue || placeholder }}
        </div>

        <div class="flex items-center gap-1 pr-2">
          <button
            v-if="displayValue && !disabled"
            type="button"
            class="rounded p-1 hover:bg-gray-100"
            @click.stop="clearSelection"
            aria-label="Clear selection"
          >
            <Icon name="x" :size="16" />
          </button>

          <Icon name="palette" :size="20" class="text-gray-400" />
        </div>
      </div>

      <!-- Color Picker Dropdown -->
      <Transition
        enter-active-class="transition-opacity duration-100"
        leave-active-class="transition-opacity duration-100"
        enter-from-class="opacity-0"
        leave-to-class="opacity-0"
      >
        <div
          v-if="isOpen"
          class="absolute z-50 mt-1 w-64 rounded-lg border border-gray-200 bg-white p-4 shadow-lg"
          @click.stop
        >
          <!-- Basic colors palette -->
          <div class="mb-4">
            <div class="mb-2 text-xs font-medium text-gray-500">Colors</div>
            <div class="grid grid-cols-6 gap-2">
              <button
                v-for="color in basicColors"
                :key="color"
                type="button"
                class="h-8 w-8 rounded border-2 transition-all hover:scale-110"
                :class="{
                  'border-primary-600': currentColor === color,
                  'border-gray-300': currentColor !== color,
                }"
                :style="{ backgroundColor: color }"
                @click="updateColor(color)"
                :title="color"
              ></button>
            </div>
          </div>

          <!-- Preset colors -->
          <div v-if="presets && presets.length > 0" class="mb-4">
            <div class="mb-2 text-xs font-medium text-gray-500">Presets</div>
            <div class="flex flex-wrap gap-2">
              <button
                v-for="preset in presets"
                :key="preset"
                type="button"
                class="h-8 w-8 rounded border-2 transition-all hover:scale-110"
                :class="{
                  'border-primary-600': currentColor === preset,
                  'border-gray-300': currentColor !== preset,
                }"
                :style="{ backgroundColor: preset }"
                @click="selectPreset(preset)"
                :title="preset"
              ></button>
            </div>
          </div>

          <!-- Alpha slider -->
          <div v-if="showAlpha" class="mb-4">
            <div class="mb-2 flex items-center justify-between">
              <span class="text-xs font-medium text-gray-500">Opacity</span>
              <span class="text-xs text-gray-600">{{ Math.round(alpha * 100) }}%</span>
            </div>
            <input
              type="range"
              min="0"
              max="1"
              step="0.01"
              :value="alpha"
              @input="updateAlpha(parseFloat(($event.target as HTMLInputElement).value))"
              class="w-full"
            />
          </div>

          <!-- Color input -->
          <div>
            <div class="mb-2 text-xs font-medium text-gray-500">Color Code</div>
            <Input
              :model-value="formatColor(currentColor, alpha)"
              size="sm"
              readonly
              class="font-mono text-xs"
            />
          </div>
        </div>
      </Transition>
    </div>

    <!-- Error Message -->
    <p v-if="error" class="mt-2 text-sm text-red-600">
      {{ error }}
    </p>
  </div>
</template>
