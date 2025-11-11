<script setup lang="ts">
import { computed } from 'vue'
import Avatar from '../atoms/Avatar.vue'

export interface AvatarGroupItem {
  id: string | number
  name: string
  src?: string
  alt?: string
}

export interface AvatarGroupProps {
  /**
   * Array of avatars to display
   */
  items: AvatarGroupItem[]
  /**
   * Maximum number of avatars to show before truncating
   * @default 5
   */
  max?: number
  /**
   * Size of avatars
   * @default 'md'
   */
  size?: 'sm' | 'md' | 'lg' | 'xl'
  /**
   * Show tooltip on hover with names
   * @default false
   */
  showTooltip?: boolean
}

const props = withDefaults(defineProps<AvatarGroupProps>(), {
  max: 5,
  size: 'md',
  showTooltip: false,
})

const visibleItems = computed(() => {
  if (props.items.length <= props.max) {
    return props.items
  }
  return props.items.slice(0, props.max)
})

const remainingCount = computed(() => {
  const remaining = props.items.length - props.max
  return remaining > 0 ? remaining : 0
})

const allNames = computed(() => {
  return props.items.map((item) => item.name).join(', ')
})

const avatarSizeMap = {
  sm: 'sm' as const,
  md: 'md' as const,
  lg: 'lg' as const,
  xl: 'xl' as const,
}

const overflowClasses = computed(() => {
  const sizes = {
    sm: 'w-8 h-8 text-xs',
    md: 'w-10 h-10 text-sm',
    lg: 'w-12 h-12 text-base',
    xl: 'w-16 h-16 text-lg',
  }
  return [
    'flex items-center justify-center',
    'rounded-full bg-gray-200 text-gray-700 font-medium',
    'border-2 border-white',
    sizes[props.size],
  ]
})
</script>

<template>
  <div
    class="avatar-group flex items-center"
    role="group"
    :aria-label="showTooltip ? allNames : 'Avatar group'"
  >
    <div
      v-for="(item, index) in visibleItems"
      :key="item.id"
      class="relative"
      :style="{ marginLeft: index > 0 ? '-0.5rem' : '0' }"
      :title="showTooltip ? item.name : undefined"
    >
      <Avatar
        :size="avatarSizeMap[size]"
        :src="item.src"
        :alt="item.alt || item.name"
        :name="item.name"
        class="ring-2 ring-white"
      />
    </div>

    <div
      v-if="remainingCount > 0"
      :class="overflowClasses"
      :style="{ marginLeft: '-0.5rem' }"
      :title="showTooltip ? `+${remainingCount} more` : undefined"
    >
      +{{ remainingCount }}
    </div>
  </div>
</template>

<style scoped>
.avatar-group {
  isolation: isolate;
}

.avatar-group > div {
  position: relative;
}

.avatar-group > div:hover {
  z-index: 10;
}
</style>
