<script setup lang="ts">
import { computed } from 'vue'
import Button from '@/components/atoms/Button.vue'
import Icon from '@/components/atoms/Icon.vue'

export type VoteType = 'up' | 'down' | 'neutral'
export type VoteVariant = 'default' | 'reddit' | 'simple' | 'compact'

interface Props {
  /** Current vote count */
  count: number
  /** User's current vote */
  userVote?: VoteType | null
  /** Button variant */
  variant?: VoteVariant
  /** Allow downvotes */
  allowDownvote?: boolean
  /** Show vote count */
  showCount?: boolean
  /** Disabled state */
  disabled?: boolean
  /** Loading state */
  loading?: boolean
  /** Size */
  size?: 'sm' | 'md' | 'lg'
  /** Orientation */
  orientation?: 'horizontal' | 'vertical'
}

interface Emits {
  (e: 'vote', type: VoteType): void
}

const props = withDefaults(defineProps<Props>(), {
  userVote: null,
  variant: 'default',
  allowDownvote: true,
  showCount: true,
  disabled: false,
  loading: false,
  size: 'md',
  orientation: 'horizontal',
})

const emit = defineEmits<Emits>()

// Handle vote
const handleVote = (type: VoteType) => {
  if (props.disabled || props.loading) return

  // If clicking same vote, remove it (neutral)
  if (props.userVote === type) {
    emit('vote', 'neutral')
  } else {
    emit('vote', type)
  }
}

// Vote button states
const upvoteActive = computed(() => props.userVote === 'up')
const downvoteActive = computed(() => props.userVote === 'down')

// Button size classes
const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'text-sm p-1'
    case 'lg':
      return 'text-lg p-3'
    default:
      return 'text-base p-2'
  }
})

// Icon size
const iconSize = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'w-4 h-4'
    case 'lg':
      return 'w-6 h-6'
    default:
      return 'w-5 h-5'
  }
})

// Format vote count
const formatCount = (num: number): string => {
  if (num >= 1000000) return `${(num / 1000000).toFixed(1)}M`
  if (num >= 1000) return `${(num / 1000).toFixed(1)}K`
  return num.toString()
}

// Count color
const countColor = computed(() => {
  if (props.userVote === 'up') return 'text-success'
  if (props.userVote === 'down') return 'text-error'
  return 'text-gray-700 dark:text-gray-300'
})
</script>

<template>
  <div
    class="vote-button"
    :class="{
      'vote-button--vertical': orientation === 'vertical',
      'vote-button--horizontal': orientation === 'horizontal',
      [`vote-button--${variant}`]: true,
    }"
  >
    <!-- Default Variant -->
    <template v-if="variant === 'default'">
      <div
        class="flex items-center gap-2"
        :class="{
          'flex-col': orientation === 'vertical',
          'flex-row': orientation === 'horizontal',
        }"
      >
        <!-- Upvote Button -->
        <button
          :class="[
            sizeClasses,
            'vote-button__btn',
            'rounded-lg transition-all duration-200',
            upvoteActive
              ? 'bg-success text-white hover:bg-success-dark'
              : 'bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600',
          ]"
          :disabled="disabled || loading"
          :aria-label="upvoteActive ? 'Remove upvote' : 'Upvote'"
          @click="handleVote('up')"
        >
          <Icon
            :name="upvoteActive ? 'arrow-up-filled' : 'arrow-up'"
            :class="iconSize"
          />
        </button>

        <!-- Vote Count -->
        <span
          v-if="showCount"
          :class="['font-semibold', countColor, sizeClasses]"
        >
          {{ formatCount(count) }}
        </span>

        <!-- Downvote Button -->
        <button
          v-if="allowDownvote"
          :class="[
            sizeClasses,
            'vote-button__btn',
            'rounded-lg transition-all duration-200',
            downvoteActive
              ? 'bg-error text-white hover:bg-error-dark'
              : 'bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600',
          ]"
          :disabled="disabled || loading"
          :aria-label="downvoteActive ? 'Remove downvote' : 'Downvote'"
          @click="handleVote('down')"
        >
          <Icon
            :name="downvoteActive ? 'arrow-down-filled' : 'arrow-down'"
            :class="iconSize"
          />
        </button>
      </div>
    </template>

    <!-- Reddit-style Variant -->
    <template v-else-if="variant === 'reddit'">
      <div
        class="flex items-center bg-gray-50 dark:bg-gray-800 rounded-full border border-gray-200 dark:border-gray-700"
        :class="{
          'flex-col py-1': orientation === 'vertical',
          'flex-row px-2': orientation === 'horizontal',
        }"
      >
        <!-- Upvote -->
        <button
          :class="[
            sizeClasses,
            'vote-button__btn rounded-full transition-colors',
            upvoteActive ? 'text-success' : 'text-gray-500 hover:text-success',
          ]"
          :disabled="disabled || loading"
          @click="handleVote('up')"
        >
          <Icon name="arrow-up" :class="iconSize" />
        </button>

        <!-- Count -->
        <span
          v-if="showCount"
          :class="['font-bold px-2', countColor, `text-${size}`]"
        >
          {{ formatCount(count) }}
        </span>

        <!-- Downvote -->
        <button
          v-if="allowDownvote"
          :class="[
            sizeClasses,
            'vote-button__btn rounded-full transition-colors',
            downvoteActive ? 'text-error' : 'text-gray-500 hover:text-error',
          ]"
          :disabled="disabled || loading"
          @click="handleVote('down')"
        >
          <Icon name="arrow-down" :class="iconSize" />
        </button>
      </div>
    </template>

    <!-- Simple Variant -->
    <template v-else-if="variant === 'simple'">
      <div
        class="flex items-center gap-1"
        :class="{
          'flex-col': orientation === 'vertical',
          'flex-row': orientation === 'horizontal',
        }"
      >
        <!-- Upvote -->
        <button
          :class="[
            'vote-button__btn p-1 rounded transition-colors',
            upvoteActive
              ? 'text-success'
              : 'text-gray-400 hover:text-success dark:text-gray-600 dark:hover:text-success',
          ]"
          :disabled="disabled || loading"
          @click="handleVote('up')"
        >
          <Icon name="thumb-up" :class="iconSize" />
        </button>

        <!-- Count -->
        <span
          v-if="showCount"
          :class="['text-sm font-medium', countColor]"
        >
          {{ formatCount(count) }}
        </span>

        <!-- Downvote -->
        <button
          v-if="allowDownvote"
          :class="[
            'vote-button__btn p-1 rounded transition-colors',
            downvoteActive
              ? 'text-error'
              : 'text-gray-400 hover:text-error dark:text-gray-600 dark:hover:text-error',
          ]"
          :disabled="disabled || loading"
          @click="handleVote('down')"
        >
          <Icon name="thumb-down" :class="iconSize" />
        </button>
      </div>
    </template>

    <!-- Compact Variant -->
    <template v-else-if="variant === 'compact'">
      <button
        :class="[
          'vote-button__compact',
          'flex items-center gap-1 px-2 py-1 rounded-full',
          'text-sm font-medium transition-all',
          upvoteActive
            ? 'bg-success text-white'
            : downvoteActive
            ? 'bg-error text-white'
            : 'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600',
        ]"
        :disabled="disabled || loading"
        @click="handleVote(upvoteActive ? 'neutral' : 'up')"
      >
        <Icon
          :name="upvoteActive ? 'arrow-up-filled' : 'arrow-up'"
          class="w-4 h-4"
        />
        <span>{{ formatCount(count) }}</span>
      </button>
    </template>
  </div>
</template>

<style scoped>
.vote-button {
  display: inline-flex;
}

.vote-button__btn {
  cursor: pointer;
  user-select: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.vote-button__btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.vote-button__btn:active:not(:disabled) {
  transform: scale(0.95);
}

.vote-button--vertical {
  flex-direction: column;
}

.vote-button--horizontal {
  flex-direction: row;
}
</style>
