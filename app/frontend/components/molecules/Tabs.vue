<script setup lang="ts">
import { computed, ref, provide, watch } from 'vue'
import Icon from '../atoms/Icon.vue'
import Badge from '../atoms/Badge.vue'

export interface TabItem {
  /** Tab key/id */
  key: string
  /** Tab label */
  label: string
  /** Tab icon */
  icon?: string
  /** Disabled state */
  disabled?: boolean
  /** Badge text */
  badge?: string | number
  /** Badge variant */
  badgeVariant?: 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info'
}

export interface TabsProps {
  /** Active tab key */
  modelValue?: string
  /** Tab items */
  items: TabItem[]
  /** Tab variant */
  variant?: 'underline' | 'pills' | 'cards'
  /** Size variant */
  size?: 'sm' | 'md' | 'lg'
  /** Full width tabs */
  fullWidth?: boolean
  /** Vertical orientation */
  vertical?: boolean
  /** Lazy load tab panels */
  lazy?: boolean
}

const props = withDefaults(defineProps<TabsProps>(), {
  modelValue: '',
  variant: 'underline',
  size: 'md',
  fullWidth: false,
  vertical: false,
  lazy: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: string]
  'tab-change': [key: string]
}>()

// Track which tabs have been loaded (for lazy loading)
const loadedTabs = ref<Set<string>>(new Set())

// Initialize with the active tab
const activeTab = computed({
  get: () => props.modelValue || (props.items[0]?.key ?? ''),
  set: (value) => {
    emit('update:modelValue', value)
    emit('tab-change', value)
  },
})

// Mark active tab as loaded
watch(
  activeTab,
  (newTab) => {
    if (newTab) {
      loadedTabs.value.add(newTab)
    }
  },
  { immediate: true }
)

// Provide active tab to children
provide('activeTab', activeTab)
provide('loadedTabs', loadedTabs)
provide('lazy', props.lazy)

const handleTabClick = (tab: TabItem) => {
  if (tab.disabled) return
  activeTab.value = tab.key
}

const tabListClasses = computed(() => {
  const classes: string[] = ['flex']

  if (props.vertical) {
    classes.push('flex-col space-y-1')
  } else {
    classes.push(props.fullWidth ? 'w-full' : 'inline-flex')
  }

  if (props.variant === 'underline' && !props.vertical) {
    classes.push('border-b border-gray-200')
  }

  if (props.variant === 'pills' || props.variant === 'cards') {
    classes.push(props.vertical ? 'space-y-1' : 'space-x-1')
  }

  return classes.join(' ')
})

const getTabClasses = (tab: TabItem) => {
  const isActive = activeTab.value === tab.key
  const classes: string[] = [
    'inline-flex items-center gap-2',
    'transition-colors duration-200',
    'focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2',
  ]

  // Size classes
  const sizeClasses = {
    sm: 'px-3 py-2 text-sm',
    md: 'px-4 py-2.5 text-base',
    lg: 'px-5 py-3 text-lg',
  }
  classes.push(sizeClasses[props.size])

  // Full width
  if (props.fullWidth && !props.vertical) {
    classes.push('flex-1 justify-center')
  }

  // Variant-specific classes
  if (props.variant === 'underline') {
    classes.push('border-b-2', 'font-medium')

    if (isActive) {
      classes.push('border-primary-600 text-primary-600')
    } else if (tab.disabled) {
      classes.push('border-transparent text-gray-400 cursor-not-allowed')
    } else {
      classes.push('border-transparent text-gray-600 hover:text-gray-900 hover:border-gray-300')
    }
  } else if (props.variant === 'pills') {
    classes.push('rounded-md font-medium')

    if (isActive) {
      classes.push('bg-primary-600 text-white')
    } else if (tab.disabled) {
      classes.push('text-gray-400 cursor-not-allowed')
    } else {
      classes.push('text-gray-600 hover:bg-gray-100 hover:text-gray-900')
    }
  } else if (props.variant === 'cards') {
    classes.push('rounded-t-md border border-b-0 font-medium')

    if (isActive) {
      classes.push('bg-white text-primary-600 border-gray-200')
    } else if (tab.disabled) {
      classes.push('bg-gray-50 text-gray-400 border-gray-200 cursor-not-allowed')
    } else {
      classes.push('bg-gray-50 text-gray-600 border-gray-200 hover:bg-gray-100 hover:text-gray-900')
    }
  }

  if (tab.disabled) {
    classes.push('cursor-not-allowed opacity-50')
  } else {
    classes.push('cursor-pointer')
  }

  return classes.join(' ')
}

const iconSize = computed(() => {
  return props.size === 'sm' ? 'sm' : props.size === 'lg' ? 'lg' : 'md'
})
</script>

<template>
  <div :class="['tabs-container', { 'flex gap-4': vertical }]">
    <!-- Tab list -->
    <div
      role="tablist"
      :aria-orientation="vertical ? 'vertical' : 'horizontal'"
      :class="tabListClasses"
    >
      <button
        v-for="tab in items"
        :key="tab.key"
        role="tab"
        :aria-selected="activeTab === tab.key"
        :aria-controls="`panel-${tab.key}`"
        :aria-disabled="tab.disabled"
        :tabindex="activeTab === tab.key ? 0 : -1"
        :class="getTabClasses(tab)"
        @click="handleTabClick(tab)"
      >
        <Icon v-if="tab.icon" :name="tab.icon" :size="iconSize" />
        <span>{{ tab.label }}</span>
        <Badge v-if="tab.badge !== undefined" :variant="tab.badgeVariant || 'primary'" size="sm">
          {{ tab.badge }}
        </Badge>
      </button>
    </div>

    <!-- Tab panels -->
    <div :class="['tab-panels', { 'flex-1': vertical }]">
      <slot :active-tab="activeTab" />
    </div>
  </div>
</template>
