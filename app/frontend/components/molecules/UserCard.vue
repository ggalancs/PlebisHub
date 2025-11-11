<script setup lang="ts">
import { computed } from 'vue'
import Avatar from '../atoms/Avatar.vue'
import Badge from '../atoms/Badge.vue'
import Button from '../atoms/Button.vue'
import Icon from '../atoms/Icon.vue'

export interface UserCardProps {
  /** User's full name */
  name: string
  /** User's title or role */
  title?: string
  /** User's description or bio */
  description?: string
  /** Avatar image URL */
  avatarSrc?: string
  /** Avatar initials fallback */
  avatarInitials?: string
  /** Status badge text */
  statusBadge?: string
  /** Status badge variant */
  statusVariant?: 'default' | 'success' | 'warning' | 'danger' | 'info'
  /** Card variant */
  variant?: 'default' | 'compact' | 'detailed'
  /** Link URL */
  href?: string
  /** Primary action button label */
  primaryAction?: string
  /** Secondary action button label */
  secondaryAction?: string
  /** Show stats section */
  showStats?: boolean
  /** Followers count */
  followersCount?: number
  /** Following count */
  followingCount?: number
  /** Posts/Items count */
  postsCount?: number
  /** Verified badge */
  verified?: boolean
}

const props = withDefaults(defineProps<UserCardProps>(), {
  variant: 'default',
  statusVariant: 'default',
  showStats: false,
})

const emit = defineEmits<{
  click: [event: MouseEvent]
  'primary-action': []
  'secondary-action': []
}>()

const handleClick = (event: MouseEvent) => {
  if (props.href) return // Let link handle it
  emit('click', event)
}

const handlePrimaryAction = () => {
  emit('primary-action')
}

const handleSecondaryAction = () => {
  emit('secondary-action')
}

const component = computed(() => {
  return props.href ? 'a' : 'div'
})

const cardClasses = computed(() => {
  const classes = [
    'user-card',
    'bg-white',
    'border',
    'border-gray-200',
    'rounded-lg',
    'transition-shadow',
  ]

  if (props.variant === 'compact') {
    classes.push('p-4')
  } else if (props.variant === 'detailed') {
    classes.push('p-6')
  } else {
    classes.push('p-4')
  }

  if (props.href) {
    classes.push('hover:shadow-md', 'cursor-pointer')
  }

  return classes.join(' ')
})

const formatCount = (count: number | undefined): string => {
  if (count === undefined) return '0'
  if (count >= 1000000) return `${(count / 1000000).toFixed(1)}M`
  if (count >= 1000) return `${(count / 1000).toFixed(1)}K`
  return count.toString()
}
</script>

<template>
  <component :is="component" :href="href" :class="cardClasses" @click="handleClick">
    <!-- Compact Variant -->
    <div v-if="variant === 'compact'" class="flex items-center gap-3">
      <Avatar :src="avatarSrc" :alt="name" :initials="avatarInitials" size="md" />

      <div class="min-w-0 flex-1">
        <div class="flex items-center gap-2">
          <h3 class="truncate font-semibold text-gray-900">{{ name }}</h3>
          <Icon v-if="verified" name="badge-check" size="sm" class="flex-shrink-0 text-blue-500" />
        </div>
        <p v-if="title" class="truncate text-sm text-gray-600">{{ title }}</p>
      </div>

      <Badge v-if="statusBadge" :variant="statusVariant" size="sm">
        {{ statusBadge }}
      </Badge>
    </div>

    <!-- Default & Detailed Variants -->
    <div v-else>
      <!-- Header with Avatar -->
      <div class="mb-4 flex items-start gap-4">
        <Avatar
          :src="avatarSrc"
          :alt="name"
          :initials="avatarInitials"
          :size="variant === 'detailed' ? 'xl' : 'lg'"
        />

        <div class="min-w-0 flex-1">
          <div class="mb-1 flex items-center gap-2">
            <h3 class="truncate text-lg font-semibold text-gray-900">{{ name }}</h3>
            <Icon
              v-if="verified"
              name="badge-check"
              size="sm"
              class="flex-shrink-0 text-blue-500"
            />
            <Badge v-if="statusBadge" :variant="statusVariant" size="sm">
              {{ statusBadge }}
            </Badge>
          </div>
          <p v-if="title" class="mb-2 text-sm text-gray-600">{{ title }}</p>
          <p
            v-if="description && variant === 'detailed'"
            class="line-clamp-2 text-sm text-gray-600"
          >
            {{ description }}
          </p>
        </div>
      </div>

      <!-- Stats -->
      <div
        v-if="
          showStats &&
          (followersCount !== undefined || followingCount !== undefined || postsCount !== undefined)
        "
        class="mb-4 flex gap-6 border-b border-t border-gray-200 py-3"
      >
        <div v-if="followersCount !== undefined" class="flex flex-col">
          <span class="text-lg font-semibold text-gray-900">{{ formatCount(followersCount) }}</span>
          <span class="text-xs text-gray-500">Followers</span>
        </div>
        <div v-if="followingCount !== undefined" class="flex flex-col">
          <span class="text-lg font-semibold text-gray-900">{{ formatCount(followingCount) }}</span>
          <span class="text-xs text-gray-500">Following</span>
        </div>
        <div v-if="postsCount !== undefined" class="flex flex-col">
          <span class="text-lg font-semibold text-gray-900">{{ formatCount(postsCount) }}</span>
          <span class="text-xs text-gray-500">Posts</span>
        </div>
      </div>

      <!-- Actions -->
      <div v-if="$slots.actions || primaryAction || secondaryAction" class="flex gap-2">
        <slot name="actions">
          <Button v-if="primaryAction" size="sm" class="flex-1" @click.stop="handlePrimaryAction">
            {{ primaryAction }}
          </Button>
          <Button
            v-if="secondaryAction"
            variant="secondary"
            size="sm"
            class="flex-1"
            @click.stop="handleSecondaryAction"
          >
            {{ secondaryAction }}
          </Button>
        </slot>
      </div>

      <!-- Custom Footer Slot -->
      <div v-if="$slots.footer" class="mt-3 border-t border-gray-200 pt-3">
        <slot name="footer" />
      </div>
    </div>
  </component>
</template>
