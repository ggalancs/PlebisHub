<script setup lang="ts">
import { computed, ref, onMounted, onUnmounted } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Icon from '@/components/atoms/Icon.vue'
import Badge from '@/components/atoms/Badge.vue'
import ProgressBar from '@/components/molecules/ProgressBar.vue'

export type EditionPhase = 'submission' | 'evaluation' | 'voting' | 'implementation' | 'completed'

export interface EditionDates {
  submissionStart: Date | string
  submissionEnd: Date | string
  evaluationStart: Date | string
  evaluationEnd: Date | string
  votingStart: Date | string
  votingEnd: Date | string
  implementationStart?: Date | string
}

export interface EditionStats {
  totalFunding: number
  projectsSubmitted: number
  projectsInEvaluation?: number
  projectsInVoting?: number
  projectsFunded?: number
  totalVotes?: number
}

export interface ImpulsaEdition {
  id: number | string
  name: string
  year: number
  phase: EditionPhase
  dates: EditionDates
  stats: EditionStats
}

interface Props {
  /** Edition data */
  edition: ImpulsaEdition
  /** Show countdown timer */
  showCountdown?: boolean
  /** Show phase indicator */
  showPhase?: boolean
  /** Show stats */
  showStats?: boolean
  /** Compact mode */
  compact?: boolean
  /** Loading state */
  loading?: boolean
}

interface Emits {
  (e: 'phase-change', phase: EditionPhase): void
}

const props = withDefaults(defineProps<Props>(), {
  showCountdown: true,
  showPhase: true,
  showStats: true,
  compact: false,
  loading: false,
})

const emit = defineEmits<Emits>()

// Current time for countdown
const now = ref(new Date())
let interval: number | undefined

// Update current time every second
onMounted(() => {
  interval = window.setInterval(() => {
    now.value = new Date()
  }, 1000)
})

onUnmounted(() => {
  if (interval) {
    clearInterval(interval)
  }
})

// Phase configuration
const phaseConfig = {
  submission: {
    label: 'Presentación de Proyectos',
    icon: 'file-plus',
    color: 'blue',
    description: 'Período para presentar nuevos proyectos',
  },
  evaluation: {
    label: 'Evaluación Técnica',
    icon: 'clipboard-check',
    color: 'yellow',
    description: 'Los proyectos están siendo evaluados',
  },
  voting: {
    label: 'Votación Ciudadana',
    icon: 'check-circle',
    color: 'green',
    description: 'Los ciudadanos están votando proyectos',
  },
  implementation: {
    label: 'Implementación',
    icon: 'tool',
    color: 'purple',
    description: 'Proyectos financiados en ejecución',
  },
  completed: {
    label: 'Completada',
    icon: 'award',
    color: 'gray',
    description: 'Edición finalizada',
  },
}

// Current phase info
const currentPhaseInfo = computed(() => phaseConfig[props.edition.phase])

// Get phase end date
const phaseEndDate = computed(() => {
  const dates = props.edition.dates
  switch (props.edition.phase) {
    case 'submission':
      return new Date(dates.submissionEnd)
    case 'evaluation':
      return new Date(dates.evaluationEnd)
    case 'voting':
      return new Date(dates.votingEnd)
    default:
      return null
  }
})

// Countdown calculation
const countdown = computed(() => {
  if (!phaseEndDate.value) return null

  const diff = phaseEndDate.value.getTime() - now.value.getTime()
  if (diff <= 0) return null

  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
  const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
  const seconds = Math.floor((diff % (1000 * 60)) / 1000)

  return { days, hours, minutes, seconds }
})

// Format countdown
const formattedCountdown = computed(() => {
  if (!countdown.value) return null

  const { days, hours, minutes, seconds } = countdown.value

  if (days > 0) {
    return `${days}d ${hours}h ${minutes}m`
  } else if (hours > 0) {
    return `${hours}h ${minutes}m ${seconds}s`
  } else {
    return `${minutes}m ${seconds}s`
  }
})

// Phase progress
const phaseProgress = computed(() => {
  const dates = props.edition.dates
  let start: Date
  let end: Date

  switch (props.edition.phase) {
    case 'submission':
      start = new Date(dates.submissionStart)
      end = new Date(dates.submissionEnd)
      break
    case 'evaluation':
      start = new Date(dates.evaluationStart)
      end = new Date(dates.evaluationEnd)
      break
    case 'voting':
      start = new Date(dates.votingStart)
      end = new Date(dates.votingEnd)
      break
    default:
      return 100
  }

  const total = end.getTime() - start.getTime()
  const elapsed = now.value.getTime() - start.getTime()
  const progress = Math.min((elapsed / total) * 100, 100)

  return Math.max(0, Math.round(progress))
})

// Format currency
const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('es-ES', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: 0,
  }).format(amount)
}

// Format number
const formatNumber = (num: number): string => {
  return new Intl.NumberFormat('es-ES').format(num)
}

// Format date
const formatDate = (date: Date | string): string => {
  return new Intl.DateTimeFormat('es-ES', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(new Date(date))
}

// Stats cards
const statsCards = computed(() => [
  {
    label: 'Presupuesto Total',
    value: formatCurrency(props.edition.stats.totalFunding),
    icon: 'dollar-sign',
    color: 'text-green-600 dark:text-green-400',
  },
  {
    label: 'Proyectos Presentados',
    value: formatNumber(props.edition.stats.projectsSubmitted),
    icon: 'folder',
    color: 'text-blue-600 dark:text-blue-400',
  },
  ...(props.edition.stats.projectsInVoting
    ? [{
        label: 'En Votación',
        value: formatNumber(props.edition.stats.projectsInVoting),
        icon: 'check-circle',
        color: 'text-purple-600 dark:text-purple-400',
      }]
    : []),
  ...(props.edition.stats.totalVotes
    ? [{
        label: 'Votos Totales',
        value: formatNumber(props.edition.stats.totalVotes),
        icon: 'users',
        color: 'text-orange-600 dark:text-orange-400',
      }]
    : []),
])
</script>

<template>
  <Card :loading="loading" class="impulsa-edition-info">
    <!-- Header -->
    <div class="impulsa-edition-info__header">
      <div class="flex items-start justify-between">
        <div>
          <h2 class="text-2xl font-bold mb-1">{{ edition.name }}</h2>
          <p class="text-sm text-gray-600 dark:text-gray-400">
            Edición {{ edition.year }}
          </p>
        </div>
        <Badge
          v-if="showPhase"
          :variant="currentPhaseInfo.color as any"
          size="lg"
        >
          <Icon :name="currentPhaseInfo.icon" class="w-4 h-4 mr-1" />
          {{ currentPhaseInfo.label }}
        </Badge>
      </div>

      <p v-if="!compact" class="text-sm text-gray-600 dark:text-gray-400 mt-3">
        {{ currentPhaseInfo.description }}
      </p>
    </div>

    <!-- Countdown -->
    <div
      v-if="showCountdown && formattedCountdown"
      class="impulsa-edition-info__countdown"
    >
      <div class="flex items-center justify-between mb-2">
        <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
          Tiempo Restante en Esta Fase:
        </span>
        <span class="text-2xl font-bold text-primary">
          {{ formattedCountdown }}
        </span>
      </div>
      <ProgressBar :value="phaseProgress" />
    </div>

    <!-- Stats Grid -->
    <div
      v-if="showStats"
      :class="[
        'impulsa-edition-info__stats',
        compact ? 'grid-cols-2' : 'grid-cols-2 md:grid-cols-4',
      ]"
    >
      <div
        v-for="stat in statsCards"
        :key="stat.label"
        class="impulsa-edition-info__stat"
      >
        <Icon :name="stat.icon" :class="['w-5 h-5 mb-2', stat.color]" />
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-1">
          {{ stat.label }}
        </p>
        <p class="text-xl font-bold">{{ stat.value }}</p>
      </div>
    </div>

    <!-- Timeline -->
    <div v-if="!compact" class="impulsa-edition-info__timeline">
      <h3 class="text-sm font-semibold mb-4 text-gray-700 dark:text-gray-300">
        Cronograma de la Edición
      </h3>
      <div class="space-y-3">
        <!-- Submission Phase -->
        <div
          :class="[
            'impulsa-edition-info__phase',
            edition.phase === 'submission' && 'impulsa-edition-info__phase--active',
            phaseProgress === 100 && edition.phase !== 'submission' && 'impulsa-edition-info__phase--completed',
          ]"
        >
          <div class="impulsa-edition-info__phase-indicator">
            <Icon
              :name="edition.phase === 'submission' ? 'circle' : 'check-circle'"
              class="w-5 h-5"
            />
          </div>
          <div class="flex-1">
            <p class="font-medium">Presentación de Proyectos</p>
            <p class="text-xs text-gray-600 dark:text-gray-400">
              {{ formatDate(edition.dates.submissionStart) }} - {{ formatDate(edition.dates.submissionEnd) }}
            </p>
          </div>
        </div>

        <!-- Evaluation Phase -->
        <div
          :class="[
            'impulsa-edition-info__phase',
            edition.phase === 'evaluation' && 'impulsa-edition-info__phase--active',
            ['voting', 'implementation', 'completed'].includes(edition.phase) && 'impulsa-edition-info__phase--completed',
          ]"
        >
          <div class="impulsa-edition-info__phase-indicator">
            <Icon
              :name="edition.phase === 'evaluation' ? 'circle' : ['voting', 'implementation', 'completed'].includes(edition.phase) ? 'check-circle' : 'circle'"
              class="w-5 h-5"
            />
          </div>
          <div class="flex-1">
            <p class="font-medium">Evaluación Técnica</p>
            <p class="text-xs text-gray-600 dark:text-gray-400">
              {{ formatDate(edition.dates.evaluationStart) }} - {{ formatDate(edition.dates.evaluationEnd) }}
            </p>
          </div>
        </div>

        <!-- Voting Phase -->
        <div
          :class="[
            'impulsa-edition-info__phase',
            edition.phase === 'voting' && 'impulsa-edition-info__phase--active',
            ['implementation', 'completed'].includes(edition.phase) && 'impulsa-edition-info__phase--completed',
          ]"
        >
          <div class="impulsa-edition-info__phase-indicator">
            <Icon
              :name="edition.phase === 'voting' ? 'circle' : ['implementation', 'completed'].includes(edition.phase) ? 'check-circle' : 'circle'"
              class="w-5 h-5"
            />
          </div>
          <div class="flex-1">
            <p class="font-medium">Votación Ciudadana</p>
            <p class="text-xs text-gray-600 dark:text-gray-400">
              {{ formatDate(edition.dates.votingStart) }} - {{ formatDate(edition.dates.votingEnd) }}
            </p>
          </div>
        </div>

        <!-- Implementation Phase -->
        <div
          v-if="edition.dates.implementationStart"
          :class="[
            'impulsa-edition-info__phase',
            ['implementation', 'completed'].includes(edition.phase) && 'impulsa-edition-info__phase--active',
          ]"
        >
          <div class="impulsa-edition-info__phase-indicator">
            <Icon
              :name="edition.phase === 'implementation' ? 'circle' : edition.phase === 'completed' ? 'check-circle' : 'circle'"
              class="w-5 h-5"
            />
          </div>
          <div class="flex-1">
            <p class="font-medium">Implementación</p>
            <p class="text-xs text-gray-600 dark:text-gray-400">
              {{ formatDate(edition.dates.implementationStart) }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </Card>
</template>

<style scoped>
.impulsa-edition-info {
  @apply w-full;
}

.impulsa-edition-info__header {
  @apply pb-6 border-b border-gray-200 dark:border-gray-700;
}

.impulsa-edition-info__countdown {
  @apply py-6 border-b border-gray-200 dark:border-gray-700;
}

.impulsa-edition-info__stats {
  @apply grid gap-6 py-6 border-b border-gray-200 dark:border-gray-700;
}

.impulsa-edition-info__stat {
  @apply flex flex-col;
}

.impulsa-edition-info__timeline {
  @apply pt-6;
}

.impulsa-edition-info__phase {
  @apply flex items-start gap-3 text-gray-400 dark:text-gray-600;
}

.impulsa-edition-info__phase--active {
  @apply text-primary;
}

.impulsa-edition-info__phase--completed {
  @apply text-green-600 dark:text-green-400;
}

.impulsa-edition-info__phase-indicator {
  @apply flex-shrink-0;
}
</style>
