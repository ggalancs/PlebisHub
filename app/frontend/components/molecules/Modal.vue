<script setup lang="ts">
import { ref, watch, onMounted, onUnmounted } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface ModalProps {
  /** Show/hide modal */
  modelValue: boolean
  /** Modal title */
  title?: string
  /** Size variant */
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'full'
  /** Show close button */
  showClose?: boolean
  /** Close on overlay click */
  closeOnOverlay?: boolean
  /** Close on escape key */
  closeOnEscape?: boolean
}

const props = withDefaults(defineProps<ModalProps>(), {
  modelValue: false,
  size: 'md',
  showClose: true,
  closeOnOverlay: true,
  closeOnEscape: true,
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  close: []
}>()

const modalRef = ref<HTMLElement>()

const closeModal = () => {
  emit('update:modelValue', false)
  emit('close')
}

const handleOverlayClick = (event: MouseEvent) => {
  if (!props.closeOnOverlay) return
  if (event.target === event.currentTarget) {
    closeModal()
  }
}

const handleEscape = (event: KeyboardEvent) => {
  if (props.closeOnEscape && event.key === 'Escape' && props.modelValue) {
    closeModal()
  }
}

// Prevent body scroll when modal is open
watch(
  () => props.modelValue,
  (isOpen) => {
    if (isOpen) {
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = ''
    }
  }
)

onMounted(() => {
  document.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleEscape)
  document.body.style.overflow = ''
})

const sizeClasses = {
  sm: 'max-w-md',
  md: 'max-w-lg',
  lg: 'max-w-2xl',
  xl: 'max-w-4xl',
  full: 'max-w-full mx-4',
}
</script>

<template>
  <Teleport to="body">
    <Transition
      enter-active-class="transition ease-out duration-200"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition ease-in duration-150"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div
        v-if="modelValue"
        class="fixed inset-0 z-50 overflow-y-auto"
        aria-labelledby="modal-title"
        role="dialog"
        aria-modal="true"
        @click="handleOverlayClick"
      >
        <!-- Overlay -->
        <div class="fixed inset-0 bg-black bg-opacity-50 transition-opacity" />

        <!-- Modal container -->
        <div class="flex min-h-full items-center justify-center p-4">
          <Transition
            enter-active-class="transition ease-out duration-200"
            enter-from-class="opacity-0 scale-95"
            enter-to-class="opacity-100 scale-100"
            leave-active-class="transition ease-in duration-150"
            leave-from-class="opacity-100 scale-100"
            leave-to-class="opacity-0 scale-95"
          >
            <div
              v-if="modelValue"
              ref="modalRef"
              :class="[
                'relative w-full',
                sizeClasses[size],
                'rounded-lg bg-white shadow-xl',
                'transform transition-all',
              ]"
              @click.stop
            >
              <!-- Header -->
              <div
                v-if="title || showClose || $slots.header"
                class="flex items-center justify-between border-b border-gray-200 px-6 py-4"
              >
                <slot name="header">
                  <h3 id="modal-title" class="text-lg font-semibold text-gray-900">
                    {{ title }}
                  </h3>
                </slot>

                <button
                  v-if="showClose"
                  type="button"
                  class="text-gray-400 transition-colors hover:text-gray-600"
                  aria-label="Close modal"
                  @click="closeModal"
                >
                  <Icon name="x" size="md" />
                </button>
              </div>

              <!-- Body -->
              <div class="px-6 py-4">
                <slot />
              </div>

              <!-- Footer -->
              <div
                v-if="$slots.footer"
                class="flex items-center justify-end gap-3 border-t border-gray-200 bg-gray-50 px-6 py-4"
              >
                <slot name="footer" :close="closeModal" />
              </div>
            </div>
          </Transition>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>
