<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface AlertProps {
  /**
   * Visual variant
   * @default 'info'
   */
  variant?: 'info' | 'success' | 'warning' | 'danger'
  /**
   * Title text
   */
  title?: string
  /**
   * Message text
   */
  message?: string
  /**
   * Whether the alert can be dismissed
   * @default false
   */
  dismissible?: boolean
  /**
   * Icon name to display
   */
  icon?: string
}

const props = withDefaults(defineProps<AlertProps>(), {
  variant: 'info',
  title: '',
  message: '',
  dismissible: false,
  icon: undefined,
})

const emit = defineEmits<{
  dismiss: []
}>()

const handleDismiss = () => {
  emit('dismiss')
}

const alertClasses = computed(() => {
  const base = 'alert flex items-start gap-3 p-4 rounded-lg border'

  const variants = {
    info: 'bg-blue-50 border-blue-200 text-blue-900',
    success: 'bg-green-50 border-green-200 text-green-900',
    warning: 'bg-yellow-50 border-yellow-200 text-yellow-900',
    danger: 'bg-red-50 border-red-200 text-red-900',
  }

  return [base, variants[props.variant]]
})

const iconName = computed(() => {
  if (props.icon) return props.icon

  const defaultIcons = {
    info: 'info',
    success: 'check-circle',
    warning: 'alert-triangle',
    danger: 'alert-circle',
  }

  return defaultIcons[props.variant]
})

const iconColor = computed(() => {
  const colors = {
    info: 'text-blue-600',
    success: 'text-green-600',
    warning: 'text-yellow-600',
    danger: 'text-red-600',
  }

  return colors[props.variant]
})
</script>

<template>
  <div :class="alertClasses" role="alert">
    <!-- Icon -->
    <Icon :name="iconName" :size="20" :class="['flex-shrink-0', iconColor]" />

    <!-- Content -->
    <div class="min-w-0 flex-1">
      <slot>
        <h4 v-if="title" class="mb-1 font-medium">
          {{ title }}
        </h4>
        <p v-if="message" class="text-sm opacity-90">
          {{ message }}
        </p>
      </slot>
    </div>

    <!-- Dismiss button -->
    <button
      v-if="dismissible"
      type="button"
      class="flex-shrink-0 opacity-70 transition-opacity hover:opacity-100"
      :aria-label="'Dismiss alert'"
      @click="handleDismiss"
    >
      <Icon name="x" :size="18" />
    </button>
  </div>
</template>
