<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface RatingProps {
  modelValue?: number
  max?: number
  size?: 'sm' | 'md' | 'lg'
  readonly?: boolean
  disabled?: boolean
}

const props = withDefaults(defineProps<RatingProps>(), {
  modelValue: 0,
  max: 5,
  size: 'md',
  readonly: false,
  disabled: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: number]
}>()

const sizeClasses = computed(() => {
  const map = { sm: 'w-4 h-4', md: 'w-5 h-5', lg: 'w-6 h-6' }
  return map[props.size]
})

const handleClick = (index: number) => {
  if (props.readonly || props.disabled) return
  emit('update:modelValue', index + 1)
}
</script>

<template>
  <div class="flex gap-1">
    <button
      v-for="index in max"
      :key="index"
      type="button"
      :disabled="disabled"
      :class="[
        sizeClasses,
        readonly || disabled ? 'cursor-default' : 'cursor-pointer hover:scale-110',
        'transition-transform',
      ]"
      @click="handleClick(index - 1)"
    >
      <Icon
        name="star"
        :class="[
          index <= modelValue ? 'fill-current text-yellow-400' : 'text-gray-300',
          disabled ? 'opacity-50' : '',
        ]"
      />
    </button>
  </div>
</template>
