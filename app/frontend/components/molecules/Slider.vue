<script setup lang="ts">
import { computed, ref } from 'vue'

export interface SliderProps {
  /**
   * Current value
   */
  modelValue: number
  /**
   * Minimum value
   * @default 0
   */
  min?: number
  /**
   * Maximum value
   * @default 100
   */
  max?: number
  /**
   * Step increment
   * @default 1
   */
  step?: number
  /**
   * Whether the slider is disabled
   * @default false
   */
  disabled?: boolean
  /**
   * Show value label
   * @default false
   */
  showValue?: boolean
  /**
   * Size variant
   * @default 'md'
   */
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<SliderProps>(), {
  min: 0,
  max: 100,
  step: 1,
  disabled: false,
  showValue: false,
  size: 'md',
})

const emit = defineEmits<{
  'update:modelValue': [value: number]
  change: [value: number]
}>()

const sliderRef = ref<HTMLInputElement | null>(null)

const handleInput = (event: Event) => {
  const target = event.target as HTMLInputElement
  const value = Number(target.value)
  emit('update:modelValue', value)
}

const handleChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  const value = Number(target.value)
  emit('change', value)
}

const percentage = computed(() => {
  const range = props.max - props.min
  const value = props.modelValue - props.min
  return (value / range) * 100
})

const trackClasses = computed(() => {
  const sizes = {
    sm: 'h-1',
    md: 'h-2',
    lg: 'h-3',
  }
  return ['slider-track', 'relative w-full rounded-full bg-gray-200', sizes[props.size]]
})

const thumbClasses = computed(() => {
  const sizes = {
    sm: 'w-3 h-3',
    md: 'w-4 h-4',
    lg: 'w-5 h-5',
  }
  return [
    'slider-thumb',
    'appearance-none absolute top-1/2 -translate-y-1/2 -translate-x-1/2',
    'rounded-full bg-white border-2 border-primary',
    'cursor-pointer transition-transform hover:scale-110',
    'focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2',
    sizes[props.size],
  ]
})
</script>

<template>
  <div class="slider-container">
    <div :class="trackClasses">
      <!-- Progress fill -->
      <div
        class="slider-fill bg-primary absolute left-0 top-0 h-full rounded-full transition-all"
        :style="{ width: `${percentage}%` }"
      />

      <!-- Input range -->
      <input
        ref="sliderRef"
        type="range"
        :value="modelValue"
        :min="min"
        :max="max"
        :step="step"
        :disabled="disabled"
        class="slider-input absolute inset-0 w-full cursor-pointer appearance-none bg-transparent opacity-0"
        :class="{ 'cursor-not-allowed': disabled }"
        @input="handleInput"
        @change="handleChange"
      />

      <!-- Custom thumb -->
      <div :class="thumbClasses" :style="{ left: `${percentage}%` }" aria-hidden="true" />
    </div>

    <!-- Value label -->
    <div v-if="showValue" class="slider-value mt-2 text-center text-sm text-gray-700">
      {{ modelValue }}
    </div>
  </div>
</template>

<style scoped>
.slider-container {
  position: relative;
  width: 100%;
}

.slider-input:disabled ~ .slider-thumb {
  cursor: not-allowed;
  opacity: 0.5;
}

.slider-input:disabled ~ .slider-fill {
  opacity: 0.5;
}
</style>
