<script setup lang="ts">
import { computed } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Badge from '@/components/atoms/Badge.vue'
import Icon from '@/components/atoms/Icon.vue'
import ProgressBar from '@/components/atoms/ProgressBar.vue'

export interface VoteStats {
  totalVotes: number
  upvotes: number
  downvotes: number
  abstentions?: number
  participation?: number
  trend?: 'up' | 'down' | 'stable'
}

interface Props {
  /** Vote statistics data */
  stats: VoteStats
  /** Show percentage breakdown */
  showPercentages?: boolean
  /** Show trend indicator */
  showTrend?: boolean
  /** Show participation rate */
  showParticipation?: boolean
  /** Compact mode */
  compact?: boolean
  /** Loading state */
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  showPercentages: true,
  showTrend: true,
  showParticipation: true,
  compact: false,
  loading: false,
})

// Calculate percentages
const upvotePercentage = computed(() => {
  if (props.stats.totalVotes === 0) return 0
  return Math.round((props.stats.upvotes / props.stats.totalVotes) * 100)
})

const downvotePercentage = computed(() => {
  if (props.stats.totalVotes === 0) return 0
  return Math.round((props.stats.downvotes / props.stats.totalVotes) * 100)
})

const abstentionPercentage = computed(() => {
  if (props.stats.totalVotes === 0 || !props.stats.abstentions) return 0
  return Math.round((props.stats.abstentions / props.stats.totalVotes) * 100)
})

// Net score (upvotes - downvotes)
const netScore = computed(() => {
  return props.stats.upvotes - props.stats.downvotes
})

// Approval rating
const approvalRating = computed(() => {
  const voted = props.stats.upvotes + props.stats.downvotes
  if (voted === 0) return 0
  return Math.round((props.stats.upvotes / voted) * 100)
})

// Trend badge variant
const trendVariant = computed(() => {
  if (!props.stats.trend) return 'default'
  switch (props.stats.trend) {
    case 'up':
      return 'success'
    case 'down':
      return 'error'
    default:
      return 'default'
  }
})

// Trend icon
const trendIcon = computed(() => {
  if (!props.stats.trend) return 'minus'
  switch (props.stats.trend) {
    case 'up':
      return 'trending-up'
    case 'down':
      return 'trending-down'
    default:
      return 'minus'
  }
})

// Format number
const formatNumber = (num: number): string => {
  if (num >= 1000000) return `${(num / 1000000).toFixed(1)}M`
  if (num >= 1000) return `${(num / 1000).toFixed(1)}K`
  return num.toString()
}
</script>

<template>
  <Card :loading="loading" class="vote-statistics">
    <template #header>
      <div class="flex items-center justify-between">
        <h3 class="text-lg font-semibold">Estadísticas de Votación</h3>
        <Badge v-if="showTrend && stats.trend" :variant="trendVariant" size="sm">
          <template #icon>
            <Icon :name="trendIcon" />
          </template>
          {{ stats.trend === 'up' ? 'Al alza' : stats.trend === 'down' ? 'A la baja' : 'Estable' }}
        </Badge>
      </div>
    </template>

    <!-- Main Stats -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
      <!-- Total Votes -->
      <div class="stat-item">
        <div class="stat-label">Total de Votos</div>
        <div class="stat-value">{{ formatNumber(stats.totalVotes) }}</div>
      </div>

      <!-- Upvotes -->
      <div class="stat-item">
        <div class="stat-label text-success">Votos a favor</div>
        <div class="stat-value text-success">{{ formatNumber(stats.upvotes) }}</div>
        <div v-if="showPercentages" class="stat-percentage text-success">
          {{ upvotePercentage }}%
        </div>
      </div>

      <!-- Downvotes -->
      <div class="stat-item">
        <div class="stat-label text-error">Votos en contra</div>
        <div class="stat-value text-error">{{ formatNumber(stats.downvotes) }}</div>
        <div v-if="showPercentages" class="stat-percentage text-error">
          {{ downvotePercentage }}%
        </div>
      </div>

      <!-- Net Score -->
      <div class="stat-item">
        <div class="stat-label">Puntuación Neta</div>
        <div
          class="stat-value"
          :class="{
            'text-success': netScore > 0,
            'text-error': netScore < 0,
          }"
        >
          {{ netScore > 0 ? '+' : '' }}{{ formatNumber(netScore) }}
        </div>
      </div>
    </div>

    <!-- Vote Breakdown -->
    <div v-if="!compact" class="mb-6">
      <h4 class="text-sm font-semibold mb-3">Desglose de Votos</h4>

      <!-- Upvotes Progress -->
      <div class="mb-3">
        <div class="flex items-center justify-between text-sm mb-1">
          <span class="text-success">A favor</span>
          <span class="text-gray-600 dark:text-gray-400">
            {{ stats.upvotes }} ({{ upvotePercentage }}%)
          </span>
        </div>
        <ProgressBar :value="upvotePercentage" variant="success" />
      </div>

      <!-- Downvotes Progress -->
      <div class="mb-3">
        <div class="flex items-center justify-between text-sm mb-1">
          <span class="text-error">En contra</span>
          <span class="text-gray-600 dark:text-gray-400">
            {{ stats.downvotes }} ({{ downvotePercentage }}%)
          </span>
        </div>
        <ProgressBar :value="downvotePercentage" variant="error" />
      </div>

      <!-- Abstentions Progress (if available) -->
      <div v-if="stats.abstentions !== undefined" class="mb-3">
        <div class="flex items-center justify-between text-sm mb-1">
          <span class="text-gray-600 dark:text-gray-400">Abstenciones</span>
          <span class="text-gray-600 dark:text-gray-400">
            {{ stats.abstentions }} ({{ abstentionPercentage }}%)
          </span>
        </div>
        <ProgressBar :value="abstentionPercentage" variant="default" />
      </div>
    </div>

    <!-- Additional Metrics -->
    <div v-if="!compact" class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <!-- Approval Rating -->
      <div class="metric-card">
        <div class="metric-icon bg-primary/10 text-primary">
          <Icon name="check-circle" class="w-6 h-6" />
        </div>
        <div class="metric-content">
          <div class="metric-label">Tasa de Aprobación</div>
          <div class="metric-value">{{ approvalRating }}%</div>
        </div>
      </div>

      <!-- Participation (if available) -->
      <div v-if="showParticipation && stats.participation !== undefined" class="metric-card">
        <div class="metric-icon bg-info/10 text-info">
          <Icon name="users" class="w-6 h-6" />
        </div>
        <div class="metric-content">
          <div class="metric-label">Participación</div>
          <div class="metric-value">{{ stats.participation }}%</div>
        </div>
      </div>
    </div>
  </Card>
</template>

<style scoped>
.vote-statistics {
  /* Container styles */
}

.stat-item {
  @apply text-center p-3 bg-gray-50 dark:bg-gray-800 rounded-lg;
}

.stat-label {
  @apply text-xs text-gray-600 dark:text-gray-400 font-medium mb-1;
}

.stat-value {
  @apply text-2xl font-bold text-gray-900 dark:text-white;
}

.stat-percentage {
  @apply text-sm font-medium mt-1;
}

.metric-card {
  @apply flex items-center gap-3 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg;
}

.metric-icon {
  @apply w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0;
}

.metric-content {
  @apply flex-1;
}

.metric-label {
  @apply text-xs text-gray-600 dark:text-gray-400 font-medium mb-1;
}

.metric-value {
  @apply text-xl font-bold text-gray-900 dark:text-white;
}
</style>
