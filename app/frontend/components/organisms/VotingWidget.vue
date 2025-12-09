<script setup lang="ts">
import { computed } from 'vue'
import Button from '@/components/atoms/Button.vue'
import Badge from '@/components/atoms/Badge.vue'
import Icon from '@/components/atoms/Icon.vue'

export interface VoteData {
  /** Current vote count */
  votes: number
  /** Current support count */
  supportsCount: number
  /** Hotness score */
  hotness: number
  /** User has voted */
  hasVoted: boolean
  /** User has supported */
  hasSupported: boolean
  /** Voting is closed */
  closed: boolean
}

interface Props {
  /** Vote data */
  voteData: VoteData
  /** Proposal/item ID */
  itemId: number | string
  /** User is authenticated */
  isAuthenticated?: boolean
  /** Loading vote */
  loadingVote?: boolean
  /** Loading support */
  loadingSupport?: boolean
  /** Show hotness indicator */
  showHotness?: boolean
  /** Compact mode (smaller size) */
  compact?: boolean
  /** Vertical layout */
  vertical?: boolean
  /** Disabled state */
  disabled?: boolean
  /** Custom vote label */
  voteLabel?: string
  /** Custom support label */
  supportLabel?: string
  /** Show labels */
  showLabels?: boolean
}

interface Emits {
  (e: 'vote'): void
  (e: 'support'): void
  (e: 'login-required', action: 'vote' | 'support'): void
}

const props = withDefaults(defineProps<Props>(), {
  isAuthenticated: false,
  loadingVote: false,
  loadingSupport: false,
  showHotness: true,
  compact: false,
  vertical: false,
  disabled: false,
  voteLabel: 'Votar',
  supportLabel: 'Apoyar',
  showLabels: true,
})

const emit = defineEmits<Emits>()

// Hotness level for visual feedback
const hotnessLevel = computed(() => {
  if (props.voteData.hotness >= 15000) return 'very-hot'
  if (props.voteData.hotness >= 10000) return 'hot'
  if (props.voteData.hotness >= 5000) return 'warm'
  return 'cool'
})

// Hotness badge variant
const hotnessBadgeVariant = computed(() => {
  switch (hotnessLevel.value) {
    case 'very-hot':
      return 'danger'
    case 'hot':
      return 'warning'
    case 'warm':
      return 'info'
    default:
      return 'default'
  }
})

// Hotness label
const hotnessLabel = computed(() => {
  switch (hotnessLevel.value) {
    case 'very-hot':
      return '🔥 Muy Candente'
    case 'hot':
      return '🔥 Candente'
    case 'warm':
      return '⚡ Popular'
    default:
      return '💡 Activa'
  }
})

// Format numbers
const formatNumber = (num: number): string => {
  if (num >= 1000000) return `${(num / 1000000).toFixed(1)}M`
  if (num >= 1000) return `${(num / 1000).toFixed(1)}K`
  return num.toString()
}

// Handle vote
const handleVote = () => {
  if (props.disabled || props.voteData.closed) return

  if (!props.isAuthenticated) {
    emit('login-required', 'vote')
    return
  }

  if (props.voteData.hasVoted) return // Already voted
  emit('vote')
}

// Handle support
const handleSupport = () => {
  if (props.disabled || props.voteData.closed) return

  if (!props.isAuthenticated) {
    emit('login-required', 'support')
    return
  }

  if (props.voteData.hasSupported) return // Already supported
  emit('support')
}

// Button variants
const voteButtonVariant = computed(() => {
  if (props.voteData.hasVoted) return 'primary'
  return 'outline'
})

const supportButtonVariant = computed(() => {
  if (props.voteData.hasSupported) return 'success'
  return 'outline'
})

// Disabled states
const voteDisabled = computed(() => {
  return (
    props.disabled ||
    props.loadingVote ||
    props.voteData.closed ||
    props.voteData.hasVoted
  )
})

const supportDisabled = computed(() => {
  return (
    props.disabled ||
    props.loadingSupport ||
    props.voteData.closed ||
    props.voteData.hasSupported
  )
})

// Button size
const buttonSize = computed(() => (props.compact ? 'sm' : 'md'))
</script>

<template>
  <div
    class="voting-widget"
    :class="{
      'voting-widget--vertical': vertical,
      'voting-widget--compact': compact,
      'voting-widget--closed': voteData.closed,
    }"
  >
    <!-- Hotness Badge -->
    <div v-if="showHotness && !compact" class="voting-widget__hotness mb-3">
      <Badge :variant="hotnessBadgeVariant" size="sm">
        {{ hotnessLabel }}
      </Badge>
      <span class="text-xs text-gray-500 dark:text-gray-400 ml-2">
        {{ formatNumber(voteData.hotness) }} pts
      </span>
    </div>

    <!-- Voting Actions -->
    <div
      class="voting-widget__actions"
      :class="{
        'flex flex-col space-y-2': vertical,
        'flex flex-row items-center space-x-3': !vertical,
      }"
    >
      <!-- Vote Button -->
      <div class="voting-widget__action">
        <Button
          :variant="voteButtonVariant"
          :size="buttonSize"
          :disabled="voteDisabled"
          :loading="loadingVote"
          class="voting-widget__button"
          :aria-label="voteData.hasVoted ? 'Ya has votado' : voteLabel"
          @click="handleVote"
        >
          <template #icon>
            <Icon
              :name="voteData.hasVoted ? 'check-circle' : 'arrow-up'"
              :class="{
                'text-primary': voteData.hasVoted,
              }"
            />
          </template>
          <span v-if="showLabels">
            {{ voteData.hasVoted ? 'Votado' : voteLabel }}
          </span>
        </Button>

        <!-- Vote Count -->
        <div
          class="voting-widget__count"
          :class="{
            'text-xs': compact,
            'text-sm': !compact,
          }"
        >
          <Icon name="arrow-up" class="w-3 h-3" />
          <span class="font-semibold">{{ formatNumber(voteData.votes) }}</span>
          <span class="text-gray-500 dark:text-gray-400">
            {{ voteData.votes === 1 ? 'voto' : 'votos' }}
          </span>
        </div>
      </div>

      <!-- Support Button -->
      <div class="voting-widget__action">
        <Button
          :variant="supportButtonVariant"
          :size="buttonSize"
          :disabled="supportDisabled"
          :loading="loadingSupport"
          class="voting-widget__button"
          :aria-label="voteData.hasSupported ? 'Ya has apoyado' : supportLabel"
          @click="handleSupport"
        >
          <template #icon>
            <Icon
              :name="voteData.hasSupported ? 'check-circle' : 'heart'"
              :class="{
                'text-success': voteData.hasSupported,
              }"
            />
          </template>
          <span v-if="showLabels">
            {{ voteData.hasSupported ? 'Apoyado' : supportLabel }}
          </span>
        </Button>

        <!-- Support Count -->
        <div
          class="voting-widget__count"
          :class="{
            'text-xs': compact,
            'text-sm': !compact,
          }"
        >
          <Icon name="heart" class="w-3 h-3" />
          <span class="font-semibold">{{ formatNumber(voteData.supportsCount) }}</span>
          <span class="text-gray-500 dark:text-gray-400">
            {{ voteData.supportsCount === 1 ? 'apoyo' : 'apoyos' }}
          </span>
        </div>
      </div>
    </div>

    <!-- Closed Message -->
    <div v-if="voteData.closed" class="voting-widget__closed-message mt-3">
      <p class="text-xs text-gray-600 dark:text-gray-400 italic">
        La votación ha finalizado
      </p>
    </div>

    <!-- Authentication Required Message -->
    <div
      v-if="!isAuthenticated && !voteData.closed"
      class="voting-widget__auth-message mt-3"
    >
      <p class="text-xs text-gray-600 dark:text-gray-400">
        <Icon name="lock" class="inline w-3 h-3" />
        Inicia sesión para participar
      </p>
    </div>
  </div>
</template>

<style scoped>
.voting-widget {
  @apply p-4 bg-gray-50 dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700;
}

.voting-widget--compact {
  @apply p-2;
}

.voting-widget--closed {
  @apply opacity-75;
}

.voting-widget__hotness {
  @apply flex items-center;
}

.voting-widget__actions {
  @apply w-full;
}

.voting-widget__action {
  @apply flex flex-col space-y-2;
  flex: 1;
}

.voting-widget--vertical .voting-widget__action {
  @apply w-full;
}

.voting-widget__button {
  @apply w-full justify-center;
}

.voting-widget__count {
  @apply flex items-center justify-center space-x-1 text-gray-700 dark:text-gray-300;
}

.voting-widget__closed-message,
.voting-widget__auth-message {
  @apply text-center;
}
</style>
