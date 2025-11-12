<script setup lang="ts">
import { ref, watch, onMounted, onUnmounted, computed } from 'vue'
import Icon from '../atoms/Icon.vue'
import Button from '../atoms/Button.vue'

export interface Props {
  modelValue: boolean
  position?: 'left' | 'right' | 'top' | 'bottom'
  size?: 'sm' | 'md' | 'lg' | 'full'
  title?: string
  description?: string
  closeOnOutsideClick?: boolean
  closeOnEscape?: boolean
  showCloseButton?: boolean
  backdrop?: boolean
  backdropBlur?: boolean
  lockScroll?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  position: 'right',
  size: 'md',
  closeOnOutsideClick: true,
  closeOnEscape: true,
  showCloseButton: true,
  backdrop: true,
  backdropBlur: true,
  lockScroll: true,
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  close: []
  open: []
}>()

const containerRef = ref<HTMLElement | null>(null)

// Position classes
const positionClasses = computed(() => {
  switch (props.position) {
    case 'left':
      return 'left-0 top-0 h-full'
    case 'right':
      return 'right-0 top-0 h-full'
    case 'top':
      return 'top-0 left-0 w-full'
    case 'bottom':
      return 'bottom-0 left-0 w-full'
    default:
      return 'right-0 top-0 h-full'
  }
})

// Size classes
const sizeClasses = computed(() => {
  const isVertical = props.position === 'left' || props.position === 'right'

  if (isVertical) {
    switch (props.size) {
      case 'sm':
        return 'w-64'
      case 'md':
        return 'w-96'
      case 'lg':
        return 'w-[32rem]'
      case 'full':
        return 'w-full'
      default:
        return 'w-96'
    }
  } else {
    switch (props.size) {
      case 'sm':
        return 'h-64'
      case 'md':
        return 'h-96'
      case 'lg':
        return 'h-[32rem]'
      case 'full':
        return 'h-full'
      default:
        return 'h-96'
    }
  }
})

// Transition classes
const transitionClasses = computed(() => {
  switch (props.position) {
    case 'left':
      return 'transition-transform duration-300'
    case 'right':
      return 'transition-transform duration-300'
    case 'top':
      return 'transition-transform duration-300'
    case 'bottom':
      return 'transition-transform duration-300'
    default:
      return 'transition-transform duration-300'
  }
})

// Transform classes for enter/leave
const transformEnterFrom = computed(() => {
  switch (props.position) {
    case 'left':
      return '-translate-x-full'
    case 'right':
      return 'translate-x-full'
    case 'top':
      return '-translate-y-full'
    case 'bottom':
      return 'translate-y-full'
    default:
      return 'translate-x-full'
  }
})

// Handle backdrop click
const handleBackdropClick = (e: MouseEvent) => {
  if (!props.closeOnOutsideClick) return
  if (e.target === e.currentTarget) {
    handleClose()
  }
}

// Handle close
const handleClose = () => {
  emit('update:modelValue', false)
  emit('close')
}

// Handle open
const handleOpen = () => {
  emit('open')
}

// Handle escape key
const handleEscape = (e: KeyboardEvent) => {
  if (props.closeOnEscape && e.key === 'Escape' && props.modelValue) {
    handleClose()
  }
}

// Focus trap
const trapFocus = (e: KeyboardEvent) => {
  if (!containerRef.value || e.key !== 'Tab' || !props.modelValue) return

  const focusableElements = containerRef.value.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  )

  if (focusableElements.length === 0) return

  const firstElement = focusableElements[0] as HTMLElement
  const lastElement = focusableElements[focusableElements.length - 1] as HTMLElement

  if (e.shiftKey && document.activeElement === firstElement) {
    lastElement.focus()
    e.preventDefault()
  } else if (!e.shiftKey && document.activeElement === lastElement) {
    firstElement.focus()
    e.preventDefault()
  }
}

// Body scroll lock
watch(
  () => props.modelValue,
  (isOpen) => {
    if (props.lockScroll) {
      if (isOpen) {
        document.body.style.overflow = 'hidden'
        handleOpen()
      } else {
        document.body.style.overflow = ''
      }
    } else if (isOpen) {
      handleOpen()
    }
  }
)

// Mount/unmount listeners
onMounted(() => {
  document.addEventListener('keydown', handleEscape)
  document.addEventListener('keydown', trapFocus)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleEscape)
  document.removeEventListener('keydown', trapFocus)
  if (props.lockScroll) {
    document.body.style.overflow = ''
  }
})

defineSlots<{
  default?: () => unknown
  header?: () => unknown
  footer?: () => unknown
}>()
</script>

<template>
  <Teleport to="body">
    <Transition
      enter-active-class="transition-opacity duration-200"
      leave-active-class="transition-opacity duration-200"
      enter-from-class="opacity-0"
      leave-to-class="opacity-0"
    >
      <div
        v-if="modelValue"
        class="fixed inset-0 z-50 flex items-center justify-center"
        @click="handleBackdropClick"
      >
        <!-- Backdrop -->
        <div
          v-if="backdrop"
          :class="[
            'absolute inset-0 bg-black/50',
            { 'backdrop-blur-sm': backdropBlur },
          ]"
          aria-hidden="true"
        ></div>

        <!-- Drawer Container -->
        <Transition
          :enter-active-class="transitionClasses"
          :leave-active-class="transitionClasses"
          :enter-from-class="transformEnterFrom"
          :leave-to-class="transformEnterFrom"
        >
          <div
            v-if="modelValue"
            ref="containerRef"
            :class="[
              'fixed bg-white shadow-xl flex flex-col',
              positionClasses,
              sizeClasses,
            ]"
            role="dialog"
            aria-modal="true"
            :aria-labelledby="title ? 'drawer-title' : undefined"
            :aria-describedby="description ? 'drawer-description' : undefined"
          >
            <!-- Header -->
            <div
              v-if="title || description || showCloseButton || $slots.header"
              class="flex items-start justify-between border-b border-gray-200 p-4"
            >
              <div v-if="title || description || $slots.header" class="flex-1">
                <slot name="header">
                  <h2
                    v-if="title"
                    id="drawer-title"
                    class="text-lg font-semibold text-gray-900"
                  >
                    {{ title }}
                  </h2>
                  <p
                    v-if="description"
                    id="drawer-description"
                    class="mt-1 text-sm text-gray-500"
                  >
                    {{ description }}
                  </p>
                </slot>
              </div>

              <Button
                v-if="showCloseButton"
                variant="ghost"
                size="sm"
                class="ml-4"
                @click="handleClose"
                aria-label="Close drawer"
              >
                <Icon name="x" :size="20" />
              </Button>
            </div>

            <!-- Content -->
            <div class="flex-1 overflow-y-auto p-4">
              <slot />
            </div>

            <!-- Footer -->
            <div
              v-if="$slots.footer"
              class="border-t border-gray-200 p-4"
            >
              <slot name="footer" />
            </div>
          </div>
        </Transition>
      </div>
    </Transition>
  </Teleport>
</template>
