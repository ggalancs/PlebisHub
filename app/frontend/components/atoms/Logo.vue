<script setup lang="ts">
/**
 * Logo - Modular PlebisHub logo component
 * Refactored for better performance and maintainability
 */

import { computed, onMounted } from 'vue'
import type { LogoProps, LogoDimensions, HexColor } from '@/types/brand'
import { generateComponentId } from '@/utils/id'
import LogoMark from './LogoMark.vue'

const props = withDefaults(defineProps<LogoProps>(), {
  variant: 'horizontal',
  theme: 'color',
  size: 'md',
})

// Generate stable IDs for gradients (SSR-safe)
const componentId = generateComponentId('logo')
const primaryGradientId = computed(() => `${componentId}-primary`)
const secondaryGradientId = computed(() => `${componentId}-secondary`)

// Size mappings - centralized configuration
const SIZE_CONFIG: Record<Required<LogoProps>['size'], LogoDimensions> = {
  sm: { width: 120, height: 32 },
  md: { width: 180, height: 48 },
  lg: { width: 260, height: 64 },
  xl: { width: 360, height: 88 },
}

// Theme color mappings - centralized configuration
const THEME_COLORS = {
  color: {
    primary: '#612d62' as HexColor,
    primaryLight: '#8a4f98' as HexColor,
    secondary: '#269283' as HexColor,
    secondaryLight: '#14b8a6' as HexColor,
  },
  monochrome: {
    primary: '#1a1a1a' as HexColor,
    primaryLight: '#1a1a1a' as HexColor,
    secondary: '#1a1a1a' as HexColor,
    secondaryLight: '#1a1a1a' as HexColor,
  },
  inverted: {
    primary: '#c491cd' as HexColor,
    primaryLight: '#a96bb6' as HexColor,
    secondary: '#5eead4' as HexColor,
    secondaryLight: '#2dd4bf' as HexColor,
  },
} as const

// Computed: dimensions based on variant and size
const dimensions = computed<LogoDimensions>(() => {
  const base = SIZE_CONFIG[props.size]

  switch (props.variant) {
    case 'vertical':
      return { width: base.height * 2.5, height: base.height * 2.5 }
    case 'mark':
      return { width: base.height, height: base.height }
    case 'type':
      return { width: base.width * 0.7, height: base.height * 0.8 }
    default: // 'horizontal'
      return base
  }
})

// Computed: ViewBox for proper SVG scaling
const viewBox = computed<string>(() => {
  const { width, height } = dimensions.value
  return `0 0 ${width} ${height}`
})

// Computed: Color scheme based on theme and custom colors
const colors = computed(() => {
  // Custom colors take precedence
  if (props.customColors) {
    const themeBase = THEME_COLORS[props.theme]
    return {
      primary: props.customColors.primary ?? themeBase.primary,
      primaryLight: props.customColors.primaryLight ?? themeBase.primaryLight,
      secondary: props.customColors.secondary ?? themeBase.secondary,
      secondaryLight: props.customColors.secondaryLight ?? themeBase.secondaryLight,
    }
  }

  return THEME_COLORS[props.theme]
})

// Computed: Font size for text variants
const textFontSize = computed<number>(() => {
  const baseSize = SIZE_CONFIG[props.size].height * 0.75
  return Math.max(20, baseSize) // Minimum 20px for readability
})

// Load web fonts on mount (non-blocking)
onMounted(() => {
  if (typeof document !== 'undefined' && 'fonts' in document) {
    ;(document as any).fonts.load('700 1em Montserrat').catch(() => {
      // Silently fail if font loading fails
    })
  }
})
</script>

<template>
  <svg
    :width="dimensions.width"
    :height="dimensions.height"
    :viewBox="viewBox"
    class="logo"
    :class="[`logo--${variant}`, `logo--${theme}`, `logo--${size}`]"
    role="img"
    aria-label="PlebisHub Logo"
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
  >
    <defs>
      <!-- Primary gradient -->
      <linearGradient :id="primaryGradientId" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" :stop-color="colors.primary" stop-opacity="1" />
        <stop offset="100%" :stop-color="colors.primaryLight" stop-opacity="1" />
      </linearGradient>

      <!-- Secondary gradient -->
      <linearGradient :id="secondaryGradientId" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" :stop-color="colors.secondary" stop-opacity="1" />
        <stop offset="100%" :stop-color="colors.secondaryLight" stop-opacity="1" />
      </linearGradient>
    </defs>

    <!-- Horizontal Variant -->
    <template v-if="variant === 'horizontal'">
      <LogoMark
        :primary-gradient-id="primaryGradientId"
        :secondary-gradient-id="secondaryGradientId"
        :secondary-color="colors.secondary"
      />

      <g class="logo-type" transform="translate(80, 0)">
        <text
          x="0"
          y="40"
          :font-size="textFontSize"
          :fill="colors.primary"
          font-family="Montserrat, sans-serif"
          font-weight="700"
        >
          Plebis
        </text>
        <text
          :x="textFontSize * 3"
          y="40"
          :font-size="textFontSize"
          :fill="colors.secondary"
          font-family="Montserrat, sans-serif"
          font-weight="700"
        >
          Hub
        </text>
      </g>
    </template>

    <!-- Vertical Variant -->
    <template v-else-if="variant === 'vertical'">
      <g transform="translate(58, 8)">
        <LogoMark
          :primary-gradient-id="primaryGradientId"
          :secondary-gradient-id="secondaryGradientId"
          :secondary-color="colors.secondary"
        />
      </g>

      <text
        x="90"
        y="105"
        :font-size="textFontSize"
        :fill="colors.primary"
        font-family="Montserrat, sans-serif"
        font-weight="700"
        text-anchor="middle"
      >
        Plebis
      </text>
      <text
        x="90"
        y="132"
        :font-size="textFontSize"
        :fill="colors.secondary"
        font-family="Montserrat, sans-serif"
        font-weight="700"
        text-anchor="middle"
      >
        Hub
      </text>
    </template>

    <!-- Mark Only Variant -->
    <template v-else-if="variant === 'mark'">
      <LogoMark
        :primary-gradient-id="primaryGradientId"
        :secondary-gradient-id="secondaryGradientId"
        :secondary-color="colors.secondary"
      />
    </template>

    <!-- Type Only Variant -->
    <template v-else-if="variant === 'type'">
      <text
        x="0"
        y="34"
        :font-size="textFontSize * 0.8"
        :fill="colors.primary"
        font-family="Montserrat, sans-serif"
        font-weight="700"
      >
        Plebis
      </text>
      <text
        :x="textFontSize * 2.4"
        y="34"
        :font-size="textFontSize * 0.8"
        :fill="colors.secondary"
        font-family="Montserrat, sans-serif"
        font-weight="700"
      >
        Hub
      </text>
      <line
        x1="0"
        :y1="textFontSize + 8"
        :x2="dimensions.width"
        :y2="textFontSize + 8"
        :stroke="colors.primary"
        stroke-width="3"
        opacity="0.2"
      />
    </template>
  </svg>
</template>

<style scoped>
.logo {
  display: inline-block;
  vertical-align: middle;
  transition: opacity 0.2s ease;
}

.logo:hover {
  opacity: 0.9;
}

/* Size constraints */
.logo--sm {
  max-width: 120px;
}

.logo--md {
  max-width: 180px;
}

.logo--lg {
  max-width: 260px;
}

.logo--xl {
  max-width: 360px;
}

/* Ensure text renders properly */
.logo text {
  user-select: none;
  -webkit-user-select: none;
}

/* Optimize SVG rendering */
.logo {
  shape-rendering: geometricPrecision;
}
</style>
