<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  variant?: 'horizontal' | 'vertical' | 'mark' | 'type'
  theme?: 'color' | 'monochrome' | 'inverted'
  size?: 'sm' | 'md' | 'lg' | 'xl'
  customColors?: {
    primary?: string
    secondary?: string
  }
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'horizontal',
  theme: 'color',
  size: 'md',
})

// Size mappings
const sizeMap = {
  sm: { width: 120, height: 32 },
  md: { width: 180, height: 48 },
  lg: { width: 260, height: 64 },
  xl: { width: 360, height: 88 },
}

const dimensions = computed(() => {
  const base = sizeMap[props.size]

  // Adjust dimensions based on variant
  if (props.variant === 'vertical') {
    return { width: base.height * 2.5, height: base.height * 2.5 }
  }
  if (props.variant === 'mark') {
    return { width: base.height, height: base.height }
  }
  if (props.variant === 'type') {
    return { width: base.width * 0.7, height: base.height * 0.8 }
  }

  return base
})

// Color scheme based on theme
const colors = computed(() => {
  if (props.customColors) {
    return {
      primary: props.customColors.primary || '#612d62',
      primaryLight: props.customColors.primary || '#8a4f98',
      secondary: props.customColors.secondary || '#269283',
      secondaryLight: props.customColors.secondary || '#14b8a6',
    }
  }

  if (props.theme === 'monochrome') {
    return {
      primary: '#1a1a1a',
      primaryLight: '#1a1a1a',
      secondary: '#1a1a1a',
      secondaryLight: '#1a1a1a',
    }
  }

  if (props.theme === 'inverted') {
    return {
      primary: '#c491cd',
      primaryLight: '#a96bb6',
      secondary: '#5eead4',
      secondaryLight: '#2dd4bf',
    }
  }

  // Default color theme
  return {
    primary: '#612d62',
    primaryLight: '#8a4f98',
    secondary: '#269283',
    secondaryLight: '#14b8a6',
  }
})

// Generate gradient IDs (unique per instance)
const gradientId = computed(() => `logo-gradient-${Math.random().toString(36).substr(2, 9)}`)
</script>

<template>
  <svg
    :width="dimensions.width"
    :height="dimensions.height"
    :viewBox="`0 0 ${dimensions.width} ${dimensions.height}`"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    class="logo"
    :class="[`logo--${variant}`, `logo--${theme}`, `logo--${size}`]"
    role="img"
    aria-label="PlebisHub Logo"
  >
    <defs>
      <linearGradient :id="`${gradientId}-primary`" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" :style="`stop-color:${colors.primary};stop-opacity:1`" />
        <stop offset="100%" :style="`stop-color:${colors.primaryLight};stop-opacity:1`" />
      </linearGradient>
      <linearGradient :id="`${gradientId}-secondary`" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" :style="`stop-color:${colors.secondary};stop-opacity:1`" />
        <stop offset="100%" :style="`stop-color:${colors.secondaryLight};stop-opacity:1`" />
      </linearGradient>
      <style>
        .logo-text {
          font-family: 'Montserrat', sans-serif;
          font-weight: 700;
        }
      </style>
    </defs>

    <!-- Horizontal Variant -->
    <g v-if="variant === 'horizontal'">
      <!-- Logo Mark -->
      <g class="logo-mark">
        <circle cx="32" cy="32" r="12" :fill="`url(#${gradientId}-primary)`"/>

        <!-- Orbital elements -->
        <circle cx="32" cy="8" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M32 12 L32 20" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="49" cy="15" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M47 17 L40 26" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="56" cy="32" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M52 32 L44 32" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="49" cy="49" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M47 47 L40 38" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="32" cy="56" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M32 52 L32 44" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="15" cy="49" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M17 47 L24 38" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="8" cy="32" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M12 32 L20 32" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="15" cy="15" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M17 17 L24 26" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>
      </g>

      <!-- Logo Type -->
      <g class="logo-type" transform="translate(80, 0)">
        <text x="0" y="40" class="logo-text" font-size="36" :fill="colors.primary">
          Plebis
        </text>
        <text x="110" y="40" class="logo-text" font-size="36" :fill="colors.secondary">
          Hub
        </text>
      </g>
    </g>

    <!-- Mark Only Variant -->
    <g v-else-if="variant === 'mark'">
      <circle cx="32" cy="32" r="12" :fill="`url(#${gradientId}-primary)`"/>

      <circle cx="32" cy="8" r="4" :fill="`url(#${gradientId}-secondary)`"/>
      <path d="M32 12 L32 20" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

      <circle cx="49" cy="15" r="4" :fill="`url(#${gradientId}-secondary)`"/>
      <path d="M47 17 L40 26" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

      <circle cx="56" cy="32" r="4" :fill="`url(#${gradientId}-secondary)`"/>
      <path d="M52 32 L44 32" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

      <circle cx="49" cy="49" r="4" :fill="`url(#${gradientId}-secondary)`"/>
      <path d="M47 47 L40 38" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

      <circle cx="32" cy="56" r="4" :fill="`url(#${gradientId}-secondary)`"/>
      <path d="M32 52 L32 44" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

      <circle cx="15" cy="49" r="4" :fill="`url(#${gradientId}-secondary)`"/>
      <path d="M17 47 L24 38" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

      <circle cx="8" cy="32" r="4" :fill="`url(#${gradientId}-secondary)`"/>
      <path d="M12 32 L20 32" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

      <circle cx="15" cy="15" r="4" :fill="`url(#${gradientId}-secondary)`"/>
      <path d="M17 17 L24 26" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>
    </g>

    <!-- Type Only Variant -->
    <g v-else-if="variant === 'type'">
      <text x="0" y="34" class="logo-text" font-size="32" :fill="colors.primary">
        Plebis
      </text>
      <text x="98" y="34" class="logo-text" font-size="32" :fill="colors.secondary">
        Hub
      </text>
      <line x1="0" y1="42" x2="180" y2="42" :stroke="colors.primary" stroke-width="3" opacity="0.2"/>
    </g>

    <!-- Vertical Variant -->
    <g v-else-if="variant === 'vertical'">
      <!-- Logo Mark centered at top -->
      <g transform="translate(58, 8)">
        <circle cx="32" cy="32" r="12" :fill="`url(#${gradientId}-primary)`"/>

        <circle cx="32" cy="8" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M32 12 L32 20" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="49" cy="15" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M47 17 L40 26" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="56" cy="32" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M52 32 L44 32" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="49" cy="49" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M47 47 L40 38" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="32" cy="56" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M32 52 L32 44" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="15" cy="49" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M17 47 L24 38" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="8" cy="32" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M12 32 L20 32" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>

        <circle cx="15" cy="15" r="4" :fill="`url(#${gradientId}-secondary)`"/>
        <path d="M17 17 L24 26" :stroke="colors.secondary" stroke-width="2" stroke-linecap="round"/>
      </g>

      <!-- Logo Type centered below mark -->
      <text x="90" y="105" class="logo-text" font-size="32" :fill="colors.primary" text-anchor="middle">
        Plebis
      </text>
      <text x="90" y="132" class="logo-text" font-size="32" :fill="colors.secondary" text-anchor="middle">
        Hub
      </text>
    </g>
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

/* Size variants */
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
.logo-text {
  user-select: none;
  -webkit-user-select: none;
}
</style>
