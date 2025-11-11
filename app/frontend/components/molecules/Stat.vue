<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'
import Badge from '../atoms/Badge.vue'

export interface StatProps {
  /** Stat label */
  label: string
  /** Stat value */
  value: string | number
  /** Change value (e.g., +12.5 or -5.2) */
  change?: number
  /** Change label (e.g., "vs last month") */
  changeLabel?: string
  /** Icon name */
  icon?: string
  /** Variant color */
  variant?: 'default' | 'success' | 'warning' | 'danger' | 'info' | 'primary'
  /** Size */
  size?: 'sm' | 'md' | 'lg'
  /** Prefix (e.g., "$", "€") */
  prefix?: string
  /** Suffix (e.g., "%", "K", "M") */
  suffix?: string
  /** Show trend icon */
  showTrend?: boolean
  /** Loading state */
  loading?: boolean
}

const props = withDefaults(defineProps<StatProps>(), {
  variant: 'default',
  size: 'md',
  showTrend: true,
  loading: false,
})

const cardClasses = computed(() => {
  const classes = ['stat', 'bg-white', 'border', 'rounded-lg', 'transition-all']

  const sizeMap = {
    sm: 'p-4',
    md: 'p-5',
    lg: 'p-6',
  }

  classes.push(sizeMap[props.size])

  const variantBorderMap: Record<string, string> = {
    default: 'border-gray-200',
    success: 'border-green-200',
    warning: 'border-yellow-200',
    danger: 'border-red-200',
    info: 'border-blue-200',
    primary: 'border-primary-200',
  }

  classes.push(variantBorderMap[props.variant])

  return classes.join(' ')
})

const valueClasses = computed(() => {
  const classes = ['font-bold']

  const sizeMap = {
    sm: 'text-2xl',
    md: 'text-3xl',
    lg: 'text-4xl',
  }

  classes.push(sizeMap[props.size])

  const variantColorMap: Record<string, string> = {
    default: 'text-gray-900',
    success: 'text-green-600',
    warning: 'text-yellow-600',
    danger: 'text-red-600',
    info: 'text-blue-600',
    primary: 'text-primary-600',
  }

  classes.push(variantColorMap[props.variant])

  return classes.join(' ')
})

const iconClasses = computed(() => {
  const classes = ['flex', 'items-center', 'justify-center', 'rounded-full', 'p-2']

  const variantBgMap: Record<string, string> = {
    default: 'bg-gray-100',
    success: 'bg-green-100',
    warning: 'bg-yellow-100',
    danger: 'bg-red-100',
    info: 'bg-blue-100',
    primary: 'bg-primary-100',
  }

  classes.push(variantBgMap[props.variant])

  return classes.join(' ')
})

const iconColorClasses = computed(() => {
  const variantColorMap: Record<string, string> = {
    default: 'text-gray-600',
    success: 'text-green-600',
    warning: 'text-yellow-600',
    danger: 'text-red-600',
    info: 'text-blue-600',
    primary: 'text-primary-600',
  }

  return variantColorMap[props.variant]
})

const changeVariant = computed(() => {
  if (!props.change) return 'default'
  return props.change > 0 ? 'success' : props.change < 0 ? 'danger' : 'default'
})

const changeTrendIcon = computed(() => {
  if (!props.change) return null
  return props.change > 0 ? 'trending-up' : props.change < 0 ? 'trending-down' : null
})

const formattedChange = computed(() => {
  if (props.change === undefined) return null
  const abs = Math.abs(props.change)
  const sign = props.change > 0 ? '+' : props.change < 0 ? '-' : ''
  return `${sign}${abs}%`
})
</script>

<template>
  <div :class="cardClasses">
    <div class="flex items-start justify-between">
      <div class="flex-1">
        <!-- Label -->
        <p class="mb-1 text-sm font-medium text-gray-600">{{ label }}</p>

        <!-- Value -->
        <div v-if="loading" class="flex items-center gap-2">
          <div class="h-8 w-24 animate-pulse rounded bg-gray-200" />
        </div>
        <div v-else :class="valueClasses">
          <span v-if="prefix" class="text-2xl text-gray-500">{{ prefix }}</span>
          {{ value }}
          <span v-if="suffix" class="ml-1 text-lg text-gray-500">{{ suffix }}</span>
        </div>

        <!-- Change -->
        <div v-if="change !== undefined && !loading" class="mt-2 flex items-center gap-2">
          <Badge :variant="changeVariant" size="sm" class="flex items-center gap-1">
            <Icon v-if="showTrend && changeTrendIcon" :name="changeTrendIcon" size="sm" />
            <span>{{ formattedChange }}</span>
          </Badge>
          <span v-if="changeLabel" class="text-xs text-gray-500">{{ changeLabel }}</span>
        </div>
      </div>

      <!-- Icon -->
      <div v-if="icon" :class="iconClasses">
        <Icon :name="icon" :class="iconColorClasses" />
      </div>
    </div>

    <!-- Custom footer slot -->
    <div v-if="$slots.footer" class="mt-3 border-t border-gray-200 pt-3">
      <slot name="footer" />
    </div>
  </div>
</template>
