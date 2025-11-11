<script setup lang="ts">
import { computed } from 'vue'

export interface SkeletonProps {
  /**
   * Shape of the skeleton
   * @default 'rectangle'
   */
  variant?: 'rectangle' | 'circle' | 'text'
  /**
   * Width of the skeleton
   */
  width?: string | number
  /**
   * Height of the skeleton
   */
  height?: string | number
  /**
   * Number of skeleton lines (for text variant)
   * @default 1
   */
  lines?: number
  /**
   * Animation style
   * @default 'pulse'
   */
  animation?: 'pulse' | 'wave' | 'none'
  /**
   * Whether the skeleton is loading
   * @default true
   */
  loading?: boolean
}

const props = withDefaults(defineProps<SkeletonProps>(), {
  variant: 'rectangle',
  width: undefined,
  height: undefined,
  lines: 1,
  animation: 'pulse',
  loading: true,
})

const formatDimension = (value: string | number | undefined): string | undefined => {
  if (value === undefined) return undefined
  return typeof value === 'number' ? `${value}px` : value
}

const skeletonClasses = computed(() => {
  const base = 'skeleton bg-gray-200'

  const shapes = {
    rectangle: 'rounded',
    circle: 'rounded-full',
    text: 'rounded h-4',
  }

  const animations = {
    pulse: 'animate-pulse',
    wave: 'skeleton-wave',
    none: '',
  }

  return [base, shapes[props.variant], animations[props.animation]]
})

const skeletonStyle = computed(() => {
  const style: Record<string, string> = {}

  if (props.width) {
    style.width = formatDimension(props.width) as string
  } else if (props.variant === 'circle' && props.height) {
    // For circles, width should match height if not specified
    style.width = formatDimension(props.height) as string
  }

  if (props.height) {
    style.height = formatDimension(props.height) as string
  } else if (props.variant === 'circle' && props.width) {
    // For circles, height should match width if not specified
    style.height = formatDimension(props.width) as string
  }

  return style
})

const textLineWidth = (index: number): string => {
  // Last line is typically shorter
  if (index === props.lines - 1 && props.lines > 1) {
    return '70%'
  }
  return '100%'
}
</script>

<template>
  <div v-if="loading" class="skeleton-wrapper">
    <template v-if="variant === 'text'">
      <div
        v-for="i in lines"
        :key="i"
        :class="skeletonClasses"
        :style="{ width: textLineWidth(i - 1), marginBottom: i < lines ? '0.5rem' : '0' }"
      />
    </template>

    <div v-else :class="skeletonClasses" :style="skeletonStyle" />
  </div>

  <slot v-else />
</template>

<style scoped>
@keyframes wave {
  0% {
    background-position: -200% 0;
  }
  100% {
    background-position: 200% 0;
  }
}

.skeleton-wave {
  background: linear-gradient(90deg, #f0f0f0 0%, #e0e0e0 20%, #f0f0f0 40%, #f0f0f0 100%);
  background-size: 200% 100%;
  animation: wave 1.5s linear infinite;
}

.skeleton {
  display: inline-block;
  min-height: 1em;
}
</style>
