<script setup lang="ts">
import { computed } from 'vue'

interface Props {
  variant?: 'dots' | 'circles' | 'network' | 'waves'
  opacity?: number
  primaryColor?: string
  secondaryColor?: string
  scale?: number
}

withDefaults(defineProps<Props>(), {
  variant: 'network',
  opacity: 0.1,
  primaryColor: '#612d62',
  secondaryColor: '#269283',
  scale: 1,
})

const patternId = computed(() => `brand-pattern-${Math.random().toString(36).substr(2, 9)}`)
</script>

<template>
  <svg
    class="brand-pattern"
    :class="[`brand-pattern--${variant}`]"
    width="100%"
    height="100%"
    xmlns="http://www.w3.org/2000/svg"
  >
    <defs>
      <!-- Dots Pattern -->
      <pattern
        v-if="variant === 'dots'"
        :id="patternId"
        x="0"
        y="0"
        width="40"
        height="40"
        patternUnits="userSpaceOnUse"
      >
        <circle cx="20" cy="20" r="2" :fill="primaryColor" :opacity="opacity" />
      </pattern>

      <!-- Circles Pattern -->
      <pattern
        v-else-if="variant === 'circles'"
        :id="patternId"
        x="0"
        y="0"
        width="80"
        height="80"
        patternUnits="userSpaceOnUse"
      >
        <circle
          cx="40"
          cy="40"
          r="30"
          :stroke="primaryColor"
          :opacity="opacity"
          stroke-width="2"
          fill="none"
        />
        <circle
          cx="40"
          cy="40"
          r="15"
          :stroke="secondaryColor"
          :opacity="opacity * 1.5"
          stroke-width="2"
          fill="none"
        />
      </pattern>

      <!-- Network Pattern (Default) -->
      <pattern
        v-else-if="variant === 'network'"
        :id="patternId"
        x="0"
        y="0"
        width="100"
        height="100"
        patternUnits="userSpaceOnUse"
      >
        <!-- Central node -->
        <circle cx="50" cy="50" r="4" :fill="primaryColor" :opacity="opacity * 2" />

        <!-- Connected nodes -->
        <circle cx="20" cy="20" r="3" :fill="secondaryColor" :opacity="opacity * 1.5" />
        <circle cx="80" cy="20" r="3" :fill="secondaryColor" :opacity="opacity * 1.5" />
        <circle cx="80" cy="80" r="3" :fill="secondaryColor" :opacity="opacity * 1.5" />
        <circle cx="20" cy="80" r="3" :fill="secondaryColor" :opacity="opacity * 1.5" />

        <!-- Connection lines -->
        <line x1="20" y1="20" x2="50" y2="50" :stroke="primaryColor" :opacity="opacity" stroke-width="1" />
        <line x1="80" y1="20" x2="50" y2="50" :stroke="primaryColor" :opacity="opacity" stroke-width="1" />
        <line x1="80" y1="80" x2="50" y2="50" :stroke="primaryColor" :opacity="opacity" stroke-width="1" />
        <line x1="20" y1="80" x2="50" y2="50" :stroke="primaryColor" :opacity="opacity" stroke-width="1" />
      </pattern>

      <!-- Waves Pattern -->
      <pattern
        v-else-if="variant === 'waves'"
        :id="patternId"
        x="0"
        y="0"
        width="100"
        height="50"
        patternUnits="userSpaceOnUse"
      >
        <path
          d="M0,25 Q25,15 50,25 T100,25"
          :stroke="primaryColor"
          :opacity="opacity"
          stroke-width="2"
          fill="none"
        />
        <path
          d="M0,35 Q25,25 50,35 T100,35"
          :stroke="secondaryColor"
          :opacity="opacity * 0.7"
          stroke-width="2"
          fill="none"
        />
      </pattern>
    </defs>

    <rect width="100%" height="100%" :fill="`url(#${patternId})`" />
  </svg>
</template>

<style scoped>
.brand-pattern {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}

.brand-pattern--dots,
.brand-pattern--circles,
.brand-pattern--network,
.brand-pattern--waves {
  opacity: 1;
}
</style>
