<script setup lang="ts">
import { computed } from 'vue'

export interface DividerProps {
  /**
   * Text to display in the divider
   */
  label?: string
  /**
   * Position of the label
   * @default 'center'
   */
  labelPosition?: 'left' | 'center' | 'right'
  /**
   * Orientation of the divider
   * @default 'horizontal'
   */
  orientation?: 'horizontal' | 'vertical'
  /**
   * Visual variant
   * @default 'solid'
   */
  variant?: 'solid' | 'dashed' | 'dotted'
}

const props = withDefaults(defineProps<DividerProps>(), {
  label: '',
  labelPosition: 'center',
  orientation: 'horizontal',
  variant: 'solid',
})

const containerClasses = computed(() => {
  if (props.orientation === 'vertical') {
    return 'divider-vertical flex items-center'
  }
  return 'divider-horizontal flex items-center w-full'
})

const lineClasses = computed(() => {
  const base = 'divider-line flex-1 border-gray-300'
  const variants = {
    solid: 'border-solid',
    dashed: 'border-dashed',
    dotted: 'border-dotted',
  }

  if (props.orientation === 'vertical') {
    return [base, variants[props.variant], 'border-l h-full min-h-[40px]']
  }
  return [base, variants[props.variant], 'border-t']
})

const labelClasses = computed(() => {
  return 'divider-label px-4 text-sm text-gray-500 whitespace-nowrap'
})

const showLeftLine = computed(() => {
  if (props.orientation === 'vertical') return false
  return !props.label || props.labelPosition !== 'left'
})

const showRightLine = computed(() => {
  if (props.orientation === 'vertical') return false
  return !props.label || props.labelPosition !== 'right'
})
</script>

<template>
  <div
    :class="containerClasses"
    role="separator"
    :aria-orientation="orientation"
    :aria-label="label || undefined"
  >
    <div v-if="showLeftLine" :class="lineClasses" />

    <slot>
      <span v-if="label" :class="labelClasses">
        {{ label }}
      </span>
    </slot>

    <div v-if="showRightLine" :class="lineClasses" />
  </div>
</template>

<style scoped>
.divider-vertical {
  height: 100%;
}
</style>
