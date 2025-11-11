<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import Icon from '../atoms/Icon.vue'
import Badge from '../atoms/Badge.vue'

export interface DropdownItem {
  /** Item key/id */
  key: string
  /** Item label */
  label: string
  /** Item icon */
  icon?: string
  /** Disabled state */
  disabled?: boolean
  /** Divider after this item */
  divider?: boolean
  /** Danger/destructive action */
  danger?: boolean
  /** Badge */
  badge?: string | number
  /** Badge variant */
  badgeVariant?: 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info'
}

export interface DropdownProps {
  /** Dropdown items */
  items: DropdownItem[]
  /** Trigger button label */
  label?: string
  /** Trigger button icon */
  icon?: string
  /** Size variant */
  size?: 'sm' | 'md' | 'lg'
  /** Placement */
  placement?: 'bottom-start' | 'bottom-end' | 'top-start' | 'top-end'
  /** Disabled state */
  disabled?: boolean
  /** Full width */
  fullWidth?: boolean
}

const props = withDefaults(defineProps<DropdownProps>(), {
  label: 'Options',
  size: 'md',
  placement: 'bottom-start',
  disabled: false,
  fullWidth: false,
})

const emit = defineEmits<{
  select: [item: DropdownItem]
}>()

const isOpen = ref(false)
const triggerRef = ref<HTMLElement>()
const dropdownRef = ref<HTMLElement>()

const toggleDropdown = () => {
  if (props.disabled) return
  isOpen.value = !isOpen.value
}

const closeDropdown = () => {
  isOpen.value = false
}

const handleItemClick = (item: DropdownItem) => {
  if (item.disabled) return
  emit('select', item)
  closeDropdown()
}

const handleClickOutside = (event: MouseEvent) => {
  if (!isOpen.value) return

  const target = event.target as Node
  if (
    triggerRef.value &&
    !triggerRef.value.contains(target) &&
    dropdownRef.value &&
    !dropdownRef.value.contains(target)
  ) {
    closeDropdown()
  }
}

const handleEscape = (event: KeyboardEvent) => {
  if (event.key === 'Escape' && isOpen.value) {
    closeDropdown()
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
  document.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
  document.removeEventListener('keydown', handleEscape)
})

const triggerClasses = computed(() => {
  const classes = [
    'inline-flex items-center justify-center gap-2',
    'border border-gray-300 bg-white',
    'text-gray-700 font-medium rounded-md',
    'transition-colors duration-200',
    'hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-1',
  ]

  const sizeClasses = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-5 py-2.5 text-lg',
  }

  classes.push(sizeClasses[props.size])

  if (props.fullWidth) {
    classes.push('w-full')
  }

  if (props.disabled) {
    classes.push('opacity-50 cursor-not-allowed hover:bg-white')
  } else {
    classes.push('cursor-pointer')
  }

  if (isOpen.value) {
    classes.push('ring-2 ring-primary-500 ring-offset-1')
  }

  return classes.join(' ')
})

const dropdownClasses = computed(() => {
  const classes = [
    'absolute z-50',
    'min-w-[200px] max-w-xs',
    'bg-white border border-gray-200 rounded-md shadow-lg',
    'py-1',
    'transition-all duration-200',
  ]

  // Placement
  if (props.placement === 'bottom-start') {
    classes.push('left-0 mt-2')
  } else if (props.placement === 'bottom-end') {
    classes.push('right-0 mt-2')
  } else if (props.placement === 'top-start') {
    classes.push('left-0 bottom-full mb-2')
  } else if (props.placement === 'top-end') {
    classes.push('right-0 bottom-full mb-2')
  }

  if (isOpen.value) {
    classes.push('opacity-100 scale-100')
  } else {
    classes.push('opacity-0 scale-95 pointer-events-none')
  }

  return classes.join(' ')
})

const getItemClasses = (item: DropdownItem) => {
  const classes = ['flex items-center gap-2', 'px-4 py-2 text-sm', 'transition-colors duration-150']

  if (item.disabled) {
    classes.push('text-gray-400 cursor-not-allowed')
  } else if (item.danger) {
    classes.push('text-red-600 hover:bg-red-50 cursor-pointer')
  } else {
    classes.push('text-gray-700 hover:bg-gray-100 cursor-pointer')
  }

  return classes.join(' ')
}

const iconSize = computed(() => {
  return props.size === 'sm' ? 'sm' : props.size === 'lg' ? 'lg' : 'md'
})
</script>

<template>
  <div class="dropdown relative inline-block">
    <!-- Trigger button -->
    <button
      ref="triggerRef"
      type="button"
      :class="triggerClasses"
      :disabled="disabled"
      :aria-expanded="isOpen"
      aria-haspopup="true"
      @click="toggleDropdown"
    >
      <Icon v-if="icon" :name="icon" :size="iconSize" />
      <span>{{ label }}</span>
      <Icon :name="isOpen ? 'chevron-up' : 'chevron-down'" :size="iconSize" />
    </button>

    <!-- Dropdown menu -->
    <div v-show="isOpen" ref="dropdownRef" role="menu" :class="dropdownClasses">
      <template v-for="(item, index) in items" :key="item.key">
        <button
          type="button"
          role="menuitem"
          :class="getItemClasses(item)"
          :disabled="item.disabled"
          :aria-disabled="item.disabled"
          @click="handleItemClick(item)"
        >
          <Icon v-if="item.icon" :name="item.icon" :size="iconSize" />
          <span class="flex-1 text-left">{{ item.label }}</span>
          <Badge
            v-if="item.badge !== undefined"
            :variant="item.badgeVariant || 'primary'"
            size="sm"
          >
            {{ item.badge }}
          </Badge>
        </button>

        <div
          v-if="item.divider && index < items.length - 1"
          class="my-1 border-t border-gray-200"
          role="separator"
        />
      </template>
    </div>
  </div>
</template>
