<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface BreadcrumbItem {
  /** Item label */
  label: string
  /** Item href/link */
  href?: string
  /** Icon name */
  icon?: string
  /** Disabled state */
  disabled?: boolean
  /** Internal flag for ellipsis */
  isEllipsis?: boolean
}

export interface BreadcrumbProps {
  /** Breadcrumb items */
  items: BreadcrumbItem[]
  /** Separator between items */
  separator?: string | 'slash' | 'chevron' | 'arrow'
  /** Show home icon for first item */
  showHome?: boolean
  /** Size variant */
  size?: 'sm' | 'md' | 'lg'
  /** Max items to show (with ellipsis for overflow) */
  maxItems?: number
}

const props = withDefaults(defineProps<BreadcrumbProps>(), {
  separator: 'chevron',
  showHome: false,
  size: 'md',
  maxItems: 0,
})

const emit = defineEmits<{
  click: [item: BreadcrumbItem, index: number]
}>()

const processedItems = computed(() => {
  if (props.maxItems > 0 && props.items.length > props.maxItems) {
    // Show first item, ellipsis, last (maxItems - 2) items
    // Total items shown = 1 (first) + 1 (ellipsis) + (maxItems - 2) (last items) = maxItems
    const firstItem = props.items[0]
    const lastItems = props.items.slice(-(props.maxItems - 2))

    return [firstItem, { label: '...', disabled: true, isEllipsis: true }, ...lastItems]
  }

  return props.items
})

const handleClick = (item: BreadcrumbItem, index: number, event: Event) => {
  if (item.disabled || item.isEllipsis) {
    event.preventDefault()
    return
  }

  emit('click', item, index)
}

const getSeparatorIcon = computed(() => {
  const separatorMap = {
    slash: 'slash',
    chevron: 'chevron-right',
    arrow: 'arrow-right',
  }

  return separatorMap[props.separator as keyof typeof separatorMap] || 'chevron-right'
})

const showSeparatorIcon = computed(() => {
  return ['slash', 'chevron', 'arrow'].includes(props.separator)
})

const itemClasses = computed(() => {
  const baseClasses = ['inline-flex items-center gap-1.5', 'transition-colors duration-200']

  const sizeClasses = {
    sm: 'text-xs',
    md: 'text-sm',
    lg: 'text-base',
  }

  return [...baseClasses, sizeClasses[props.size]].join(' ')
})

const linkClasses = computed(() => {
  return [
    'text-gray-600 hover:text-primary-600',
    'transition-colors duration-200',
    'focus:outline-none focus:text-primary-600',
  ].join(' ')
})

const currentClasses = computed(() => {
  return 'text-gray-900 font-medium'
})

const disabledClasses = computed(() => {
  return 'text-gray-400 cursor-not-allowed'
})

const separatorClasses = computed(() => {
  const baseClasses = ['inline-flex items-center text-gray-400']

  const sizeClasses = {
    sm: 'mx-1',
    md: 'mx-2',
    lg: 'mx-2.5',
  }

  return [...baseClasses, sizeClasses[props.size]].join(' ')
})

const iconSize = computed(() => {
  return props.size === 'sm' ? 'sm' : props.size === 'lg' ? 'lg' : 'md'
})

const isLast = (index: number) => {
  return index === processedItems.value.length - 1
}

const isFirstItem = (index: number) => {
  return index === 0
}
</script>

<template>
  <nav aria-label="Breadcrumb">
    <ol class="flex flex-wrap items-center">
      <li v-for="(item, index) in processedItems" :key="index" :class="itemClasses">
        <!-- Item content -->
        <component
          :is="item.href && !item.disabled && !item.isEllipsis ? 'a' : 'span'"
          :href="item.href && !item.disabled && !item.isEllipsis ? item.href : undefined"
          :class="[
            isLast(index)
              ? currentClasses
              : item.disabled || item.isEllipsis
                ? disabledClasses
                : linkClasses,
          ]"
          :aria-current="isLast(index) ? 'page' : undefined"
          :aria-disabled="item.disabled || item.isEllipsis ? 'true' : undefined"
          @click="handleClick(item, index, $event)"
        >
          <!-- Home icon for first item -->
          <Icon v-if="isFirstItem(index) && showHome && !item.icon" name="home" :size="iconSize" />

          <!-- Custom icon -->
          <Icon v-else-if="item.icon" :name="item.icon" :size="iconSize" />

          <!-- Label -->
          <span>{{ item.label }}</span>
        </component>

        <!-- Separator -->
        <span v-if="!isLast(index)" :class="separatorClasses" aria-hidden="true">
          <Icon v-if="showSeparatorIcon" :name="getSeparatorIcon" :size="iconSize" />
          <span v-else>{{ separator }}</span>
        </span>
      </li>
    </ol>
  </nav>
</template>
