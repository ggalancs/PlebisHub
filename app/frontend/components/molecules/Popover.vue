<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import Icon from '../atoms/Icon.vue'
import Button from '../atoms/Button.vue'

export interface Props {
  modelValue?: boolean
  trigger?: 'click' | 'hover' | 'focus'
  placement?: 'top' | 'bottom' | 'left' | 'right' | 'top-start' | 'top-end' | 'bottom-start' | 'bottom-end' | 'left-start' | 'left-end' | 'right-start' | 'right-end'
  title?: string
  content?: string
  showArrow?: boolean
  showCloseButton?: boolean
  disabled?: boolean
  offset?: number
  width?: string
  maxWidth?: string
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: undefined,
  trigger: 'click',
  placement: 'bottom',
  showArrow: true,
  showCloseButton: false,
  disabled: false,
  offset: 8,
  width: 'auto',
  maxWidth: '320px',
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  open: []
  close: []
}>()

const triggerRef = ref<HTMLElement | null>(null)
const popoverRef = ref<HTMLElement | null>(null)
const isOpen = ref(false)
const popoverStyle = ref<Record<string, string>>({})

// Computed controlled state
const isControlled = computed(() => props.modelValue !== undefined)
const open = computed(() => (isControlled.value ? props.modelValue : isOpen.value))

// Arrow position classes
const arrowClasses = computed(() => {
  const base = 'absolute w-2 h-2 bg-white transform rotate-45 border'

  switch (props.placement) {
    case 'top':
    case 'top-start':
    case 'top-end':
      return `${base} bottom-[-4px] border-t-0 border-l-0 border-gray-200`
    case 'bottom':
    case 'bottom-start':
    case 'bottom-end':
      return `${base} top-[-4px] border-b-0 border-r-0 border-gray-200`
    case 'left':
    case 'left-start':
    case 'left-end':
      return `${base} right-[-4px] border-l-0 border-b-0 border-gray-200`
    case 'right':
    case 'right-start':
    case 'right-end':
      return `${base} left-[-4px] border-r-0 border-t-0 border-gray-200`
    default:
      return `${base} top-[-4px] border-b-0 border-r-0 border-gray-200`
  }
})

const arrowPositionStyle = computed(() => {
  switch (props.placement) {
    case 'top':
    case 'bottom':
      return { left: '50%', transform: 'translateX(-50%)' }
    case 'top-start':
    case 'bottom-start':
      return { left: '12px' }
    case 'top-end':
    case 'bottom-end':
      return { right: '12px' }
    case 'left':
    case 'right':
      return { top: '50%', transform: 'translateY(-50%)' }
    case 'left-start':
    case 'right-start':
      return { top: '12px' }
    case 'left-end':
    case 'right-end':
      return { bottom: '12px' }
    default:
      return { left: '50%', transform: 'translateX(-50%)' }
  }
})

// Calculate position
const calculatePosition = () => {
  if (!triggerRef.value || !popoverRef.value) return

  const triggerRect = triggerRef.value.getBoundingClientRect()
  const popoverRect = popoverRef.value.getBoundingClientRect()
  const viewport = {
    width: window.innerWidth,
    height: window.innerHeight,
  }

  let top = 0
  let left = 0

  // Calculate base position
  switch (props.placement) {
    case 'top':
      top = triggerRect.top - popoverRect.height - props.offset
      left = triggerRect.left + triggerRect.width / 2 - popoverRect.width / 2
      break
    case 'top-start':
      top = triggerRect.top - popoverRect.height - props.offset
      left = triggerRect.left
      break
    case 'top-end':
      top = triggerRect.top - popoverRect.height - props.offset
      left = triggerRect.right - popoverRect.width
      break
    case 'bottom':
      top = triggerRect.bottom + props.offset
      left = triggerRect.left + triggerRect.width / 2 - popoverRect.width / 2
      break
    case 'bottom-start':
      top = triggerRect.bottom + props.offset
      left = triggerRect.left
      break
    case 'bottom-end':
      top = triggerRect.bottom + props.offset
      left = triggerRect.right - popoverRect.width
      break
    case 'left':
      top = triggerRect.top + triggerRect.height / 2 - popoverRect.height / 2
      left = triggerRect.left - popoverRect.width - props.offset
      break
    case 'left-start':
      top = triggerRect.top
      left = triggerRect.left - popoverRect.width - props.offset
      break
    case 'left-end':
      top = triggerRect.bottom - popoverRect.height
      left = triggerRect.left - popoverRect.width - props.offset
      break
    case 'right':
      top = triggerRect.top + triggerRect.height / 2 - popoverRect.height / 2
      left = triggerRect.right + props.offset
      break
    case 'right-start':
      top = triggerRect.top
      left = triggerRect.right + props.offset
      break
    case 'right-end':
      top = triggerRect.bottom - popoverRect.height
      left = triggerRect.right + props.offset
      break
  }

  // Collision detection and adjustment
  if (left < 0) left = 8
  if (left + popoverRect.width > viewport.width) {
    left = viewport.width - popoverRect.width - 8
  }
  if (top < 0) top = 8
  if (top + popoverRect.height > viewport.height) {
    top = viewport.height - popoverRect.height - 8
  }

  popoverStyle.value = {
    top: `${top}px`,
    left: `${left}px`,
    width: props.width,
    maxWidth: props.maxWidth,
  }
}

// Open/close handlers
const handleOpen = async () => {
  if (props.disabled) return

  if (isControlled.value) {
    emit('update:modelValue', true)
  } else {
    isOpen.value = true
  }

  emit('open')

  await nextTick()
  calculatePosition()
}

const handleClose = () => {
  if (props.disabled) return

  if (isControlled.value) {
    emit('update:modelValue', false)
  } else {
    isOpen.value = false
  }

  emit('close')
}

// Trigger handlers
const handleTriggerClick = () => {
  if (props.trigger === 'click') {
    if (open.value) {
      handleClose()
    } else {
      handleOpen()
    }
  }
}

const handleTriggerMouseEnter = () => {
  if (props.trigger === 'hover') {
    handleOpen()
  }
}

const handleTriggerMouseLeave = () => {
  if (props.trigger === 'hover') {
    handleClose()
  }
}

const handleTriggerFocus = () => {
  if (props.trigger === 'focus') {
    handleOpen()
  }
}

const handleTriggerBlur = () => {
  if (props.trigger === 'focus') {
    handleClose()
  }
}

// Close on outside click
const handleClickOutside = (e: MouseEvent) => {
  if (!open.value || props.trigger !== 'click') return

  const target = e.target as Node
  if (
    triggerRef.value?.contains(target) ||
    popoverRef.value?.contains(target)
  ) {
    return
  }

  handleClose()
}

// Close on escape
const handleEscape = (e: KeyboardEvent) => {
  if (e.key === 'Escape' && open.value) {
    handleClose()
  }
}

// Update position on scroll/resize
const updatePosition = () => {
  if (open.value) {
    calculatePosition()
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
  document.addEventListener('keydown', handleEscape)
  window.addEventListener('scroll', updatePosition, true)
  window.addEventListener('resize', updatePosition)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
  document.removeEventListener('keydown', handleEscape)
  window.removeEventListener('scroll', updatePosition, true)
  window.removeEventListener('resize', updatePosition)
})

defineSlots<{
  trigger?: () => unknown
  default?: () => unknown
  title?: () => unknown
}>()
</script>

<template>
  <div class="relative inline-block">
    <!-- Trigger -->
    <div
      ref="triggerRef"
      @click="handleTriggerClick"
      @mouseenter="handleTriggerMouseEnter"
      @mouseleave="handleTriggerMouseLeave"
      @focus="handleTriggerFocus"
      @blur="handleTriggerBlur"
    >
      <slot name="trigger">
        <Button :disabled="disabled">Open Popover</Button>
      </slot>
    </div>

    <!-- Popover Content -->
    <Teleport to="body">
      <Transition
        enter-active-class="transition-opacity duration-200"
        leave-active-class="transition-opacity duration-200"
        enter-from-class="opacity-0"
        leave-to-class="opacity-0"
      >
        <div
          v-if="open"
          ref="popoverRef"
          :style="popoverStyle"
          class="fixed z-50 rounded-lg border border-gray-200 bg-white shadow-lg"
          role="dialog"
          aria-modal="false"
          :aria-labelledby="title ? 'popover-title' : undefined"
        >
          <!-- Arrow -->
          <div
            v-if="showArrow"
            :class="arrowClasses"
            :style="arrowPositionStyle"
          ></div>

          <!-- Content -->
          <div class="relative p-4">
            <!-- Header -->
            <div
              v-if="title || showCloseButton || $slots.title"
              class="mb-2 flex items-start justify-between"
            >
              <slot name="title">
                <h3
                  v-if="title"
                  id="popover-title"
                  class="text-sm font-semibold text-gray-900"
                >
                  {{ title }}
                </h3>
              </slot>

              <Button
                v-if="showCloseButton"
                variant="ghost"
                size="sm"
                class="ml-2 -mr-2 -mt-2"
                @click="handleClose"
                aria-label="Close popover"
              >
                <Icon name="x" :size="16" />
              </Button>
            </div>

            <!-- Body -->
            <div class="text-sm text-gray-700">
              <slot>
                {{ content }}
              </slot>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>
