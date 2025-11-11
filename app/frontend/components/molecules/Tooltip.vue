<template>
  <div
    ref="triggerRef"
    class="inline-block"
    @mouseenter="handleMouseEnter"
    @mouseleave="handleMouseLeave"
    @focus="handleFocus"
    @blur="handleBlur"
  >
    <slot />

    <Teleport to="body">
      <Transition
        enter-active-class="transition-opacity duration-150"
        enter-from-class="opacity-0"
        enter-to-class="opacity-100"
        leave-active-class="transition-opacity duration-150"
        leave-from-class="opacity-100"
        leave-to-class="opacity-0"
      >
        <div
          v-if="isVisible"
          :id="tooltipId"
          ref="tooltipRef"
          :class="[
            'pointer-events-none absolute z-50 rounded-md px-3 py-2 text-sm shadow-lg',
            variantClasses,
            maxWidthClasses,
          ]"
          :style="tooltipStyle"
          role="tooltip"
        >
          <slot name="content">{{ content }}</slot>

          <!-- Arrow -->
          <div
            v-if="showArrow"
            :class="['absolute h-2 w-2 rotate-45 transform', variantClasses, arrowPositionClasses]"
          />
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, nextTick, onBeforeUnmount } from 'vue'

/**
 * Tooltip component for displaying helpful information on hover or focus
 */
export interface Props {
  /**
   * Tooltip content text
   */
  content?: string
  /**
   * Placement of the tooltip
   * @default 'top'
   */
  placement?: 'top' | 'bottom' | 'left' | 'right'
  /**
   * Visual variant
   * @default 'dark'
   */
  variant?: 'dark' | 'light'
  /**
   * Delay before showing tooltip (ms)
   * @default 200
   */
  delay?: number
  /**
   * Whether to show arrow
   * @default true
   */
  showArrow?: boolean
  /**
   * Maximum width of tooltip
   * @default 'md'
   */
  maxWidth?: 'sm' | 'md' | 'lg' | 'none'
  /**
   * Whether tooltip is disabled
   * @default false
   */
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  placement: 'top',
  variant: 'dark',
  delay: 200,
  showArrow: true,
  maxWidth: 'md',
  disabled: false,
})

const triggerRef = ref<HTMLElement>()
const tooltipRef = ref<HTMLElement>()
const isVisible = ref(false)
const tooltipStyle = ref<Record<string, string>>({})
let showTimeout: ReturnType<typeof setTimeout> | null = null

const tooltipId = computed(() => `tooltip-${Math.random().toString(36).substr(2, 9)}`)

const variantClasses = computed(() => {
  switch (props.variant) {
    case 'light':
      return 'bg-white text-gray-900 border border-gray-200'
    default:
      return 'bg-gray-900 text-white'
  }
})

const maxWidthClasses = computed(() => {
  switch (props.maxWidth) {
    case 'sm':
      return 'max-w-xs'
    case 'lg':
      return 'max-w-lg'
    case 'none':
      return ''
    default:
      return 'max-w-sm'
  }
})

const arrowPositionClasses = computed(() => {
  switch (props.placement) {
    case 'top':
      return 'bottom-[-4px] left-1/2 -translate-x-1/2'
    case 'bottom':
      return 'top-[-4px] left-1/2 -translate-x-1/2'
    case 'left':
      return 'right-[-4px] top-1/2 -translate-y-1/2'
    case 'right':
      return 'left-[-4px] top-1/2 -translate-y-1/2'
    default:
      return 'bottom-[-4px] left-1/2 -translate-x-1/2'
  }
})

const handleMouseEnter = () => {
  if (props.disabled) return

  if (showTimeout) {
    clearTimeout(showTimeout)
  }

  showTimeout = setTimeout(() => {
    showTooltip()
  }, props.delay)
}

const handleMouseLeave = () => {
  if (showTimeout) {
    clearTimeout(showTimeout)
    showTimeout = null
  }
  hideTooltip()
}

const handleFocus = () => {
  if (props.disabled) return
  showTooltip()
}

const handleBlur = () => {
  hideTooltip()
}

const showTooltip = async () => {
  isVisible.value = true
  await nextTick()
  updatePosition()
}

const hideTooltip = () => {
  isVisible.value = false
}

const updatePosition = () => {
  if (!triggerRef.value || !tooltipRef.value) return

  const triggerRect = triggerRef.value.getBoundingClientRect()
  const tooltipRect = tooltipRef.value.getBoundingClientRect()

  const offset = props.showArrow ? 8 : 4

  let top = 0
  let left = 0

  switch (props.placement) {
    case 'top':
      top = triggerRect.top - tooltipRect.height - offset
      left = triggerRect.left + (triggerRect.width - tooltipRect.width) / 2
      break
    case 'bottom':
      top = triggerRect.bottom + offset
      left = triggerRect.left + (triggerRect.width - tooltipRect.width) / 2
      break
    case 'left':
      top = triggerRect.top + (triggerRect.height - tooltipRect.height) / 2
      left = triggerRect.left - tooltipRect.width - offset
      break
    case 'right':
      top = triggerRect.top + (triggerRect.height - tooltipRect.height) / 2
      left = triggerRect.right + offset
      break
  }

  // Keep tooltip within viewport
  const padding = 8
  if (top < padding) top = padding
  if (left < padding) left = padding
  if (top + tooltipRect.height > window.innerHeight - padding) {
    top = window.innerHeight - tooltipRect.height - padding
  }
  if (left + tooltipRect.width > window.innerWidth - padding) {
    left = window.innerWidth - tooltipRect.width - padding
  }

  tooltipStyle.value = {
    top: `${top}px`,
    left: `${left}px`,
  }
}

onBeforeUnmount(() => {
  if (showTimeout) {
    clearTimeout(showTimeout)
  }
})
</script>
