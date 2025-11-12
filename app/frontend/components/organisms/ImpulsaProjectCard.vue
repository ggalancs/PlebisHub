<script setup lang="ts">
import { computed } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Button from '@/components/atoms/Button.vue'
import Badge from '@/components/atoms/Badge.vue'
import Icon from '@/components/atoms/Icon.vue'
import ProgressBar from '@/components/atoms/ProgressBar.vue'

export type ProjectStatus = 'draft' | 'submitted' | 'evaluation' | 'voting' | 'funded' | 'rejected' | 'completed'
export type ProjectCategory = 'social' | 'technology' | 'culture' | 'education' | 'environment' | 'health' | 'other'

export interface ImpulsaProject {
  id: number | string
  title: string
  description: string
  category: ProjectCategory
  fundingGoal: number
  fundingReceived?: number
  votes?: number
  hasVoted?: boolean
  status: ProjectStatus
  author: string
  createdAt: Date | string
  imageUrl?: string
}

interface Props {
  /** Project data */
  project: ImpulsaProject
  /** Compact mode (smaller card) */
  compact?: boolean
  /** Show full description */
  showFullDescription?: boolean
  /** Show vote button */
  showVoteButton?: boolean
  /** User is authenticated */
  isAuthenticated?: boolean
  /** Loading vote */
  loadingVote?: boolean
  /** Disable interactions */
  disabled?: boolean
}

interface Emits {
  (e: 'click'): void
  (e: 'vote'): void
  (e: 'login-required'): void
}

const props = withDefaults(defineProps<Props>(), {
  compact: false,
  showFullDescription: false,
  showVoteButton: true,
  isAuthenticated: false,
  loadingVote: false,
  disabled: false,
})

const emit = defineEmits<Emits>()

// Status configuration
const statusConfig: Record<ProjectStatus, { label: string; variant: 'default' | 'primary' | 'success' | 'warning' | 'error' | 'info' }> = {
  draft: { label: 'Borrador', variant: 'default' },
  submitted: { label: 'Presentado', variant: 'info' },
  evaluation: { label: 'En Evaluación', variant: 'warning' },
  voting: { label: 'En Votación', variant: 'primary' },
  funded: { label: 'Financiado', variant: 'success' },
  rejected: { label: 'No Financiado', variant: 'error' },
  completed: { label: 'Completado', variant: 'success' },
}

// Category configuration
const categoryConfig: Record<ProjectCategory, { label: string; icon: string; color: string }> = {
  social: { label: 'Social', icon: 'users', color: 'text-blue-600' },
  technology: { label: 'Tecnología', icon: 'cpu', color: 'text-purple-600' },
  culture: { label: 'Cultura', icon: 'palette', color: 'text-pink-600' },
  education: { label: 'Educación', icon: 'book', color: 'text-green-600' },
  environment: { label: 'Medio Ambiente', icon: 'leaf', color: 'text-emerald-600' },
  health: { label: 'Salud', icon: 'heart', color: 'text-red-600' },
  other: { label: 'Otro', icon: 'box', color: 'text-gray-600' },
}

// Funding progress
const fundingProgress = computed(() => {
  if (!props.project.fundingReceived || props.project.fundingGoal === 0) return 0
  return Math.min((props.project.fundingReceived / props.project.fundingGoal) * 100, 100)
})

// Format currency
const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('es-ES', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 0,
  }).format(amount)
}

// Format date
const formatDate = (date: Date | string): string => {
  const d = typeof date === 'string' ? new Date(date) : date
  return d.toLocaleDateString('es-ES', { year: 'numeric', month: 'long', day: 'numeric' })
}

// Truncate description
const displayDescription = computed(() => {
  if (props.showFullDescription || props.compact) return props.project.description
  return props.project.description.length > 150
    ? props.project.description.substring(0, 150) + '...'
    : props.project.description
})

// Can vote
const canVote = computed(() => {
  return (
    props.showVoteButton &&
    props.project.status === 'voting' &&
    !props.project.hasVoted &&
    !props.disabled
  )
})

// Handle click
const handleClick = () => {
  if (!props.disabled) {
    emit('click')
  }
}

// Handle vote
const handleVote = () => {
  if (!props.isAuthenticated) {
    emit('login-required')
    return
  }
  if (canVote.value) {
    emit('vote')
  }
}
</script>

<template>
  <Card
    :class="[
      'impulsa-project-card',
      { 'impulsa-project-card--compact': compact, 'cursor-pointer': !disabled },
    ]"
    @click="handleClick"
  >
    <!-- Image -->
    <div v-if="project.imageUrl && !compact" class="impulsa-project-card__image">
      <img :src="project.imageUrl" :alt="project.title" class="w-full h-48 object-cover" />
      <div class="absolute top-3 right-3">
        <Badge :variant="statusConfig[project.status].variant" size="sm">
          {{ statusConfig[project.status].label }}
        </Badge>
      </div>
    </div>

    <template #header>
      <div class="flex items-start justify-between gap-3">
        <div class="flex-1 min-w-0">
          <h3
            :class="[
              'font-bold mb-2',
              compact ? 'text-base' : 'text-lg',
            ]"
          >
            {{ project.title }}
          </h3>
          <div class="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
            <Icon
              :name="categoryConfig[project.category].icon"
              :class="['w-4 h-4', categoryConfig[project.category].color]"
            />
            <span>{{ categoryConfig[project.category].label }}</span>
            <span class="text-gray-400">•</span>
            <span>{{ formatDate(project.createdAt) }}</span>
          </div>
        </div>
        <Badge v-if="!project.imageUrl || compact" :variant="statusConfig[project.status].variant" size="sm">
          {{ statusConfig[project.status].label }}
        </Badge>
      </div>
    </template>

    <!-- Description -->
    <p v-if="!compact" class="text-sm text-gray-700 dark:text-gray-300 mb-4">
      {{ displayDescription }}
    </p>

    <!-- Author -->
    <div v-if="!compact" class="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400 mb-4">
      <Icon name="user" class="w-4 h-4" />
      <span>{{ project.author }}</span>
    </div>

    <!-- Funding Info -->
    <div class="impulsa-project-card__funding mb-4">
      <div class="flex items-center justify-between text-sm mb-2">
        <span class="font-semibold text-gray-900 dark:text-white">
          {{ formatCurrency(project.fundingReceived || 0) }}
        </span>
        <span class="text-gray-600 dark:text-gray-400">
          de {{ formatCurrency(project.fundingGoal) }}
        </span>
      </div>
      <ProgressBar :value="fundingProgress" variant="primary" size="sm" />
      <div class="flex items-center justify-between text-xs text-gray-500 dark:text-gray-400 mt-1">
        <span>{{ Math.round(fundingProgress) }}% financiado</span>
        <span v-if="project.votes !== undefined" class="flex items-center gap-1">
          <Icon name="arrow-up" class="w-3 h-3" />
          {{ project.votes }} votos
        </span>
      </div>
    </div>

    <!-- Actions -->
    <div v-if="showVoteButton && project.status === 'voting'" class="flex gap-2">
      <Button
        v-if="!project.hasVoted"
        variant="primary"
        :size="compact ? 'sm' : 'md'"
        :disabled="disabled || !canVote"
        :loading="loadingVote"
        class="flex-1"
        @click.stop="handleVote"
      >
        <template #icon>
          <Icon name="arrow-up" />
        </template>
        Votar
      </Button>
      <Button
        v-else
        variant="success"
        :size="compact ? 'sm' : 'md'"
        disabled
        class="flex-1"
      >
        <template #icon>
          <Icon name="check-circle" />
        </template>
        Votado
      </Button>
    </div>

    <!-- Login prompt -->
    <div
      v-if="!isAuthenticated && showVoteButton && project.status === 'voting'"
      class="text-xs text-gray-500 dark:text-gray-400 text-center mt-2"
    >
      <Icon name="lock" class="inline w-3 h-3" />
      Inicia sesión para votar
    </div>
  </Card>
</template>

<style scoped>
.impulsa-project-card {
  @apply transition-shadow hover:shadow-lg;
  position: relative;
}

.impulsa-project-card--compact {
  @apply p-3;
}

.impulsa-project-card__image {
  @apply relative -m-6 mb-4;
  margin-top: -1.5rem;
  border-radius: 0.5rem 0.5rem 0 0;
  overflow: hidden;
}

.impulsa-project-card__funding {
  @apply bg-gray-50 dark:bg-gray-800 rounded-lg p-3;
}
</style>
