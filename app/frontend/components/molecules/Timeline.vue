<script setup lang="ts">
import Icon from '../atoms/Icon.vue'
import Badge from '../atoms/Badge.vue'

export interface TimelineItem {
  /** Title of the event */
  title: string
  /** Description or content */
  description?: string
  /** Timestamp */
  timestamp?: string
  /** Icon name */
  icon?: string
  /** Status color */
  variant?: 'default' | 'success' | 'warning' | 'danger' | 'info'
  /** Badge text (optional) */
  badge?: string
}

export interface TimelineProps {
  /** Timeline items */
  items: TimelineItem[]
  /** Position of timeline line */
  position?: 'left' | 'center'
}

withDefaults(defineProps<TimelineProps>(), {
  position: 'left',
})

const getIconClasses = (variant: string) => {
  const classes = [
    'flex',
    'items-center',
    'justify-center',
    'w-10',
    'h-10',
    'rounded-full',
    'border-4',
    'border-white',
    'flex-shrink-0',
    'z-10',
  ]

  const variantClasses: Record<string, string> = {
    default: 'bg-gray-400',
    success: 'bg-green-500',
    warning: 'bg-yellow-500',
    danger: 'bg-red-500',
    info: 'bg-blue-500',
  }

  classes.push(variantClasses[variant] || variantClasses.default)

  return classes.join(' ')
}

const getBadgeVariant = (variant: string) => {
  const variantMap: Record<string, 'default' | 'success' | 'warning' | 'danger' | 'info'> = {
    default: 'default',
    success: 'success',
    warning: 'warning',
    danger: 'danger',
    info: 'info',
  }

  return variantMap[variant] || 'default'
}
</script>

<template>
  <div :class="['timeline', position === 'center' ? 'mx-auto max-w-4xl' : '']">
    <div
      v-for="(item, index) in items"
      :key="index"
      :class="['timeline-item', 'relative', 'pb-8', index === items.length - 1 ? 'pb-0' : '']"
    >
      <!-- Connecting Line -->
      <div
        v-if="index < items.length - 1"
        :class="[
          'absolute',
          'top-10',
          'w-0.5',
          'bg-gray-200',
          position === 'center' ? 'left-1/2 h-full -translate-x-1/2' : 'left-5 h-full',
        ]"
      />

      <!-- Item Content -->
      <div :class="['flex', 'gap-4', position === 'center' ? 'items-center' : 'items-start']">
        <!-- Timestamp (for center position) -->
        <div
          v-if="position === 'center' && item.timestamp"
          class="flex-1 text-right text-sm text-gray-500"
        >
          {{ item.timestamp }}
        </div>

        <!-- Icon Circle -->
        <div :class="getIconClasses(item.variant || 'default')">
          <Icon v-if="item.icon" :name="item.icon" size="sm" class="text-white" />
        </div>

        <!-- Content -->
        <div :class="['flex-1', position === 'center' ? '' : '']">
          <div class="rounded-lg border border-gray-200 bg-white p-4">
            <div class="mb-1 flex items-start justify-between gap-2">
              <h4 class="font-semibold text-gray-900">{{ item.title }}</h4>
              <Badge
                v-if="item.badge"
                :variant="getBadgeVariant(item.variant || 'default')"
                size="sm"
              >
                {{ item.badge }}
              </Badge>
            </div>

            <p v-if="item.description" class="mb-2 text-sm text-gray-600">
              {{ item.description }}
            </p>

            <div v-if="position === 'left' && item.timestamp" class="text-xs text-gray-500">
              {{ item.timestamp }}
            </div>

            <!-- Custom slot for item content -->
            <div v-if="$slots[`item-${index}`]">
              <slot :name="`item-${index}`" :item="item" />
            </div>
          </div>
        </div>

        <!-- Empty space for center alignment -->
        <div v-if="position === 'center'" class="flex-1" />
      </div>
    </div>
  </div>
</template>
