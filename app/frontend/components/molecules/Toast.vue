<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface ToastProps {
  /** Toast variant */
  variant?: 'success' | 'warning' | 'danger' | 'info'
  /** Title text */
  title?: string
  /** Message text */
  message: string
  /** Show icon */
  showIcon?: boolean
  /** Custom icon */
  icon?: string
  /** Closable */
  closable?: boolean
  /** Auto-dismiss duration in ms (0 = no auto-dismiss) */
  duration?: number
  /** Show progress bar */
  showProgress?: boolean
}

const props = withDefaults(defineProps<ToastProps>(), {
  variant: 'info',
  showIcon: true,
  closable: true,
  duration: 5000,
  showProgress: true,
})

const emit = defineEmits<{
  close: []
}>()

const isVisible = ref(true)
const progress = ref(100)
let timer: ReturnType<typeof setTimeout> | null = null
let progressInterval: ReturnType<typeof setInterval> | null = null

const closeToast = () => {
  isVisible.value = false
  emit('close')
}

const startTimer = () => {
  if (props.duration > 0) {
    const startTime = Date.now()
    const updateInterval = 50

    timer = setTimeout(() => {
      closeToast()
    }, props.duration)

    if (props.showProgress) {
      progressInterval = setInterval(() => {
        const elapsed = Date.now() - startTime
        progress.value = Math.max(0, 100 - (elapsed / props.duration) * 100)
      }, updateInterval)
    }
  }
}

const stopTimer = () => {
  if (timer) {
    clearTimeout(timer)
    timer = null
  }
  if (progressInterval) {
    clearInterval(progressInterval)
    progressInterval = null
  }
}

onMounted(() => {
  startTimer()
})

onUnmounted(() => {
  stopTimer()
})

const variantClasses = computed(() => {
  const classes: Record<string, string> = {
    success: 'bg-green-50 border-green-200 text-green-800',
    warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
    danger: 'bg-red-50 border-red-200 text-red-800',
    info: 'bg-blue-50 border-blue-200 text-blue-800',
  }
  return classes[props.variant]
})

const variantIconClasses = computed(() => {
  const classes: Record<string, string> = {
    success: 'text-green-600',
    warning: 'text-yellow-600',
    danger: 'text-red-600',
    info: 'text-blue-600',
  }
  return classes[props.variant]
})

const variantProgressClasses = computed(() => {
  const classes: Record<string, string> = {
    success: 'bg-green-600',
    warning: 'bg-yellow-600',
    danger: 'bg-red-600',
    info: 'bg-blue-600',
  }
  return classes[props.variant]
})

const defaultIcon = computed(() => {
  if (props.icon) return props.icon

  const icons: Record<string, string> = {
    success: 'check-circle',
    warning: 'alert-triangle',
    danger: 'x-circle',
    info: 'info',
  }
  return icons[props.variant]
})
</script>

<template>
  <Transition
    enter-active-class="transition ease-out duration-300"
    enter-from-class="opacity-0 transform translate-y-2"
    enter-to-class="opacity-100 transform translate-y-0"
    leave-active-class="transition ease-in duration-200"
    leave-from-class="opacity-100 transform translate-y-0"
    leave-to-class="opacity-0 transform translate-y-2"
  >
    <div
      v-if="isVisible"
      :class="[
        'toast',
        'relative',
        'w-full',
        'max-w-md',
        'border',
        'rounded-lg',
        'shadow-lg',
        'overflow-hidden',
        variantClasses,
      ]"
      role="alert"
      aria-live="polite"
    >
      <div class="flex items-start gap-3 p-4">
        <!-- Icon -->
        <Icon
          v-if="showIcon"
          :name="defaultIcon"
          :class="['flex-shrink-0', 'mt-0.5', variantIconClasses]"
        />

        <!-- Content -->
        <div class="min-w-0 flex-1">
          <h4 v-if="title" class="mb-1 font-semibold">{{ title }}</h4>
          <p class="text-sm">{{ message }}</p>
        </div>

        <!-- Close button -->
        <button
          v-if="closable"
          type="button"
          class="-mr-1 -mt-1 flex-shrink-0 rounded-md p-1 transition-colors hover:bg-black/10"
          aria-label="Close notification"
          @click="closeToast"
        >
          <Icon name="x" size="sm" />
        </button>
      </div>

      <!-- Progress bar -->
      <div
        v-if="showProgress && duration > 0"
        class="absolute bottom-0 left-0 h-1 transition-all duration-100"
        :class="variantProgressClasses"
        :style="{ width: `${progress}%` }"
      />
    </div>
  </Transition>
</template>
