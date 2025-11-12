<script setup lang="ts">
/**
 * LogoMark - Internal component for the PlebisHub logo mark (network icon)
 * Extracted to eliminate code duplication in Logo.vue
 */

import type { HexColor } from '@/types/brand'

interface Props {
  primaryGradientId: string
  secondaryGradientId: string
  secondaryColor: HexColor
}

defineProps<Props>()
</script>

<template>
  <g class="logo-mark">
    <!-- Central circle - represents the community/pueblo -->
    <circle cx="32" cy="32" r="12" :fill="`url(#${primaryGradientId})`" />

    <!-- Orbital elements - represent citizen participation -->
    <!-- Top -->
    <circle cx="32" cy="8" r="4" :fill="`url(#${secondaryGradientId})`" />
    <path d="M32 12 L32 20" :stroke="secondaryColor" stroke-width="2" stroke-linecap="round" />

    <!-- Top Right -->
    <circle cx="49" cy="15" r="4" :fill="`url(#${secondaryGradientId})`" />
    <path d="M47 17 L40 26" :stroke="secondaryColor" stroke-width="2" stroke-linecap="round" />

    <!-- Right -->
    <circle cx="56" cy="32" r="4" :fill="`url(#${secondaryGradientId})`" />
    <path d="M52 32 L44 32" :stroke="secondaryColor" stroke-width="2" stroke-linecap="round" />

    <!-- Bottom Right -->
    <circle cx="49" cy="49" r="4" :fill="`url(#${secondaryGradientId})`" />
    <path d="M47 47 L40 38" :stroke="secondaryColor" stroke-width="2" stroke-linecap="round" />

    <!-- Bottom -->
    <circle cx="32" cy="56" r="4" :fill="`url(#${secondaryGradientId})`" />
    <path d="M32 52 L32 44" :stroke="secondaryColor" stroke-width="2" stroke-linecap="round" />

    <!-- Bottom Left -->
    <circle cx="15" cy="49" r="4" :fill="`url(#${secondaryGradientId})`" />
    <path d="M17 47 L24 38" :stroke="secondaryColor" stroke-width="2" stroke-linecap="round" />

    <!-- Left -->
    <circle cx="8" cy="32" r="4" :fill="`url(#${secondaryGradientId})`" />
    <path d="M12 32 L20 32" :stroke="secondaryColor" stroke-width="2" stroke-linecap="round" />

    <!-- Top Left -->
    <circle cx="15" cy="15" r="4" :fill="`url(#${secondaryGradientId})`" />
    <path d="M17 17 L24 26" :stroke="secondaryColor" stroke-width="2" stroke-linecap="round" />
  </g>
</template>
