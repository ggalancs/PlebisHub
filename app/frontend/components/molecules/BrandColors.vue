<script setup lang="ts">
import { computed } from 'vue'

interface ColorSwatch {
  name: string
  value: string
  textColor?: string
  description?: string
}

interface Props {
  variant?: 'palette' | 'swatches' | 'compact'
  showLabels?: boolean
  showHex?: boolean
  interactive?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'palette',
  showLabels: true,
  showHex: true,
  interactive: false,
})

const emit = defineEmits<{
  colorClick: [color: ColorSwatch]
  colorCopy: [hex: string]
}>()

// Brand color palette
const primaryColors = computed<ColorSwatch[]>(() => [
  { name: 'Primary 50', value: '#faf5fb', textColor: '#1a1a1a', description: 'Lightest purple' },
  { name: 'Primary 100', value: '#f4ebf6', textColor: '#1a1a1a', description: 'Very light purple' },
  { name: 'Primary 200', value: '#ead7ee', textColor: '#1a1a1a', description: 'Light purple' },
  { name: 'Primary 300', value: '#dab9e0', textColor: '#1a1a1a', description: 'Soft purple' },
  { name: 'Primary 400', value: '#c491cd', textColor: '#1a1a1a', description: 'Medium light purple' },
  { name: 'Primary 500', value: '#a96bb6', textColor: '#ffffff', description: 'Medium purple' },
  { name: 'Primary 600', value: '#8a4f98', textColor: '#ffffff', description: 'Medium dark purple' },
  { name: 'Primary 700', value: '#612d62', textColor: '#ffffff', description: 'Brand primary (default)' },
  { name: 'Primary 800', value: '#5a2a59', textColor: '#ffffff', description: 'Dark purple' },
  { name: 'Primary 900', value: '#4c244a', textColor: '#ffffff', description: 'Darkest purple' },
])

const secondaryColors = computed<ColorSwatch[]>(() => [
  { name: 'Secondary 50', value: '#f0fdfa', textColor: '#1a1a1a', description: 'Lightest teal' },
  { name: 'Secondary 100', value: '#ccfbf1', textColor: '#1a1a1a', description: 'Very light teal' },
  { name: 'Secondary 200', value: '#99f6e4', textColor: '#1a1a1a', description: 'Light teal' },
  { name: 'Secondary 300', value: '#5eead4', textColor: '#1a1a1a', description: 'Soft teal' },
  { name: 'Secondary 400', value: '#2dd4bf', textColor: '#1a1a1a', description: 'Medium light teal' },
  { name: 'Secondary 500', value: '#14b8a6', textColor: '#ffffff', description: 'Medium teal' },
  { name: 'Secondary 600', value: '#269283', textColor: '#ffffff', description: 'Brand secondary (default)' },
  { name: 'Secondary 700', value: '#0f766e', textColor: '#ffffff', description: 'Medium dark teal' },
  { name: 'Secondary 800', value: '#115e59', textColor: '#ffffff', description: 'Dark teal' },
  { name: 'Secondary 900', value: '#134e4a', textColor: '#ffffff', description: 'Darkest teal' },
])

const handleColorClick = (color: ColorSwatch) => {
  if (props.interactive) {
    emit('colorClick', color)

    // Copy to clipboard
    if (navigator.clipboard) {
      navigator.clipboard.writeText(color.value)
      emit('colorCopy', color.value)
    }
  }
}
</script>

<template>
  <div class="brand-colors" :class="[`brand-colors--${variant}`]">
    <!-- Primary Colors -->
    <div class="brand-colors__group">
      <h3 v-if="showLabels" class="brand-colors__title">
        Primary Colors (Purple)
      </h3>
      <div class="brand-colors__swatches">
        <div
          v-for="color in primaryColors"
          :key="color.name"
          class="brand-colors__swatch"
          :class="{ 'brand-colors__swatch--interactive': interactive }"
          :style="{ backgroundColor: color.value, color: color.textColor }"
          :title="color.description"
          @click="handleColorClick(color)"
        >
          <span v-if="showLabels" class="brand-colors__name">
            {{ color.name }}
          </span>
          <span v-if="showHex" class="brand-colors__hex">
            {{ color.value }}
          </span>
        </div>
      </div>
    </div>

    <!-- Secondary Colors -->
    <div class="brand-colors__group">
      <h3 v-if="showLabels" class="brand-colors__title">
        Secondary Colors (Teal)
      </h3>
      <div class="brand-colors__swatches">
        <div
          v-for="color in secondaryColors"
          :key="color.name"
          class="brand-colors__swatch"
          :class="{ 'brand-colors__swatch--interactive': interactive }"
          :style="{ backgroundColor: color.value, color: color.textColor }"
          :title="color.description"
          @click="handleColorClick(color)"
        >
          <span v-if="showLabels" class="brand-colors__name">
            {{ color.name }}
          </span>
          <span v-if="showHex" class="brand-colors__hex">
            {{ color.value }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.brand-colors {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.brand-colors__group {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.brand-colors__title {
  font-family: 'Montserrat', sans-serif;
  font-size: 1.25rem;
  font-weight: 600;
  color: #1a1a1a;
  margin: 0;
}

.brand-colors__swatches {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 1rem;
}

.brand-colors__swatch {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100px;
  padding: 1rem;
  border-radius: 8px;
  transition: all 0.2s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.brand-colors__swatch--interactive {
  cursor: pointer;
}

.brand-colors__swatch--interactive:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.brand-colors__swatch--interactive:active {
  transform: translateY(0);
}

.brand-colors__name {
  font-size: 0.875rem;
  font-weight: 600;
  margin-bottom: 0.25rem;
  text-align: center;
}

.brand-colors__hex {
  font-size: 0.75rem;
  font-family: 'Monaco', 'Courier New', monospace;
  opacity: 0.8;
  text-align: center;
}

/* Compact variant */
.brand-colors--compact .brand-colors__swatches {
  grid-template-columns: repeat(auto-fill, minmax(60px, 1fr));
  gap: 0.5rem;
}

.brand-colors--compact .brand-colors__swatch {
  min-height: 60px;
  padding: 0.5rem;
}

.brand-colors--compact .brand-colors__name {
  font-size: 0.625rem;
}

.brand-colors--compact .brand-colors__hex {
  font-size: 0.625rem;
}

/* Swatches variant - horizontal strips */
.brand-colors--swatches .brand-colors__swatches {
  display: flex;
  flex-direction: row;
  gap: 0;
  overflow: hidden;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.brand-colors--swatches .brand-colors__swatch {
  flex: 1;
  min-height: 80px;
  border-radius: 0;
  box-shadow: none;
}

.brand-colors--swatches .brand-colors__swatch:first-child {
  border-top-left-radius: 8px;
  border-bottom-left-radius: 8px;
}

.brand-colors--swatches .brand-colors__swatch:last-child {
  border-top-right-radius: 8px;
  border-bottom-right-radius: 8px;
}

/* Responsive */
@media (max-width: 768px) {
  .brand-colors__swatches {
    grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
  }

  .brand-colors--swatches .brand-colors__swatches {
    flex-direction: column;
  }

  .brand-colors--swatches .brand-colors__swatch:first-child {
    border-radius: 8px 8px 0 0;
  }

  .brand-colors--swatches .brand-colors__swatch:last-child {
    border-radius: 0 0 8px 8px;
  }
}
</style>
