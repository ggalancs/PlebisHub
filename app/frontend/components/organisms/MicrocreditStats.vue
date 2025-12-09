<script setup lang="ts">
import { computed } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Icon from '@/components/atoms/Icon.vue'
import ProgressBar from '@/components/molecules/ProgressBar.vue'
import type { Microcredit } from './MicrocreditCard.vue'

interface Props {
  /** List of microcredits for stats */
  microcredits: Microcredit[]
  /** Loading state */
  loading?: boolean
  /** Compact mode */
  compact?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  compact: false,
})

// Total amount requested
const totalAmountRequested = computed(() => {
  return props.microcredits.reduce((sum, mc) => sum + mc.amountRequested, 0)
})

// Total amount funded
const totalAmountFunded = computed(() => {
  return props.microcredits.reduce((sum, mc) => sum + mc.amountFunded, 0)
})

// Funding percentage
const fundingPercentage = computed(() => {
  if (totalAmountRequested.value === 0) return 0
  return Math.round((totalAmountFunded.value / totalAmountRequested.value) * 100)
})

// Total microcredits
const totalMicrocredits = computed(() => props.microcredits.length)

// Active microcredits (funding or repaying)
const activeMicrocredits = computed(() => {
  return props.microcredits.filter(mc => mc.status === 'funding' || mc.status === 'repaying').length
})

// Funded microcredits
const fundedMicrocredits = computed(() => {
  return props.microcredits.filter(mc => mc.status === 'funded' || mc.status === 'repaying' || mc.status === 'completed').length
})

// Completed microcredits
const completedMicrocredits = computed(() => {
  return props.microcredits.filter(mc => mc.status === 'completed').length
})

// Defaulted microcredits
const defaultedMicrocredits = computed(() => {
  return props.microcredits.filter(mc => mc.status === 'defaulted').length
})

// Success rate (completed / (completed + defaulted))
const successRate = computed(() => {
  const total = completedMicrocredits.value + defaultedMicrocredits.value
  if (total === 0) return 0
  return Math.round((completedMicrocredits.value / total) * 100)
})

// Total investors (unique count)
const totalInvestors = computed(() => {
  return props.microcredits.reduce((sum, mc) => sum + (mc.investorsCount || 0), 0)
})

// Average interest rate
const averageInterestRate = computed(() => {
  if (props.microcredits.length === 0) return 0
  const sum = props.microcredits.reduce((total, mc) => total + mc.interestRate, 0)
  return Number((sum / props.microcredits.length).toFixed(2))
})

// Average term in months
const averageTerm = computed(() => {
  if (props.microcredits.length === 0) return 0
  const sum = props.microcredits.reduce((total, mc) => total + mc.termMonths, 0)
  return Math.round(sum / props.microcredits.length)
})

// By status
const byStatus = computed(() => {
  return {
    pending: props.microcredits.filter(mc => mc.status === 'pending').length,
    funding: props.microcredits.filter(mc => mc.status === 'funding').length,
    funded: props.microcredits.filter(mc => mc.status === 'funded').length,
    repaying: props.microcredits.filter(mc => mc.status === 'repaying').length,
    completed: completedMicrocredits.value,
    defaulted: defaultedMicrocredits.value,
  }
})

// By risk level
const byRiskLevel = computed(() => {
  return {
    low: props.microcredits.filter(mc => mc.riskLevel === 'low').length,
    medium: props.microcredits.filter(mc => mc.riskLevel === 'medium').length,
    high: props.microcredits.filter(mc => mc.riskLevel === 'high').length,
  }
})

// By category
const byCategory = computed(() => {
  const categories: Record<string, number> = {}
  props.microcredits.forEach(mc => {
    if (mc.category) {
      categories[mc.category] = (categories[mc.category] || 0) + 1
    }
  })
  return Object.entries(categories)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 5) // Top 5 categories
})

// Format currency
const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('es-ES', {
    style: 'currency',
    currency: 'EUR',
    maximumFractionDigits: 0,
  }).format(amount)
}

// Format number
const formatNumber = (num: number): string => {
  return new Intl.NumberFormat('es-ES').format(num)
}
</script>

<template>
  <div class="microcredit-stats">
    <!-- Main Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
      <!-- Total Funded -->
      <Card :loading="loading" class="microcredit-stats__card">
        <div class="flex items-center justify-between mb-2">
          <Icon name="dollar-sign" class="w-8 h-8 text-green-600 dark:text-green-400" />
          <div class="text-right">
            <div class="text-2xl font-bold text-gray-900 dark:text-white">
              {{ formatCurrency(totalAmountFunded) }}
            </div>
            <div class="text-xs text-gray-600 dark:text-gray-400">
              de {{ formatCurrency(totalAmountRequested) }}
            </div>
          </div>
        </div>
        <div class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Total Financiado
        </div>
        <ProgressBar :value="fundingPercentage" class="h-2" />
      </Card>

      <!-- Total Microcredits -->
      <Card :loading="loading" class="microcredit-stats__card">
        <div class="flex items-center justify-between mb-2">
          <Icon name="file-text" class="w-8 h-8 text-blue-600 dark:text-blue-400" />
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ formatNumber(totalMicrocredits) }}
          </div>
        </div>
        <div class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Total Microcréditos
        </div>
        <div class="text-xs text-gray-600 dark:text-gray-400">
          {{ activeMicrocredits }} activos
        </div>
      </Card>

      <!-- Total Investors -->
      <Card :loading="loading" class="microcredit-stats__card">
        <div class="flex items-center justify-between mb-2">
          <Icon name="users" class="w-8 h-8 text-indigo-600 dark:text-indigo-400" />
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ formatNumber(totalInvestors) }}
          </div>
        </div>
        <div class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Total Inversores
        </div>
        <div class="text-xs text-gray-600 dark:text-gray-400">
          {{ fundedMicrocredits }} proyectos financiados
        </div>
      </Card>

      <!-- Success Rate -->
      <Card :loading="loading" class="microcredit-stats__card">
        <div class="flex items-center justify-between mb-2">
          <Icon name="award" class="w-8 h-8 text-purple-600 dark:text-purple-400" />
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ successRate }}%
          </div>
        </div>
        <div class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Tasa de Éxito
        </div>
        <div class="text-xs text-gray-600 dark:text-gray-400">
          {{ completedMicrocredits }} completados
        </div>
      </Card>
    </div>

    <!-- Secondary Stats Grid -->
    <div v-if="!compact" class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
      <!-- By Status -->
      <Card :loading="loading">
        <div class="mb-4">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white flex items-center gap-2">
            <Icon name="activity" class="w-5 h-5 text-gray-600" />
            Por Estado
          </h3>
        </div>
        <div class="space-y-3">
          <div v-if="byStatus.pending > 0" class="flex items-center justify-between">
            <span class="text-sm text-gray-700 dark:text-gray-300">Pendientes</span>
            <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ byStatus.pending }}</span>
          </div>
          <div v-if="byStatus.funding > 0" class="flex items-center justify-between">
            <span class="text-sm text-gray-700 dark:text-gray-300">En Financiación</span>
            <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ byStatus.funding }}</span>
          </div>
          <div v-if="byStatus.funded > 0" class="flex items-center justify-between">
            <span class="text-sm text-gray-700 dark:text-gray-300">Financiados</span>
            <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ byStatus.funded }}</span>
          </div>
          <div v-if="byStatus.repaying > 0" class="flex items-center justify-between">
            <span class="text-sm text-gray-700 dark:text-gray-300">En Repago</span>
            <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ byStatus.repaying }}</span>
          </div>
          <div v-if="byStatus.completed > 0" class="flex items-center justify-between">
            <span class="text-sm text-gray-700 dark:text-gray-300">Completados</span>
            <span class="text-sm font-semibold text-green-600 dark:text-green-400">{{ byStatus.completed }}</span>
          </div>
          <div v-if="byStatus.defaulted > 0" class="flex items-center justify-between">
            <span class="text-sm text-gray-700 dark:text-gray-300">Impagados</span>
            <span class="text-sm font-semibold text-red-600 dark:text-red-400">{{ byStatus.defaulted }}</span>
          </div>
        </div>
      </Card>

      <!-- By Risk Level -->
      <Card :loading="loading">
        <div class="mb-4">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white flex items-center gap-2">
            <Icon name="shield" class="w-5 h-5 text-gray-600" />
            Por Nivel de Riesgo
          </h3>
        </div>
        <div class="space-y-3">
          <div v-if="byRiskLevel.low > 0">
            <div class="flex items-center justify-between mb-1">
              <span class="text-sm text-gray-700 dark:text-gray-300">Bajo</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ byRiskLevel.low }}</span>
            </div>
            <ProgressBar
              :value="Math.round((byRiskLevel.low / totalMicrocredits) * 100)"
              variant="success"
              class="h-2"
            />
          </div>
          <div v-if="byRiskLevel.medium > 0">
            <div class="flex items-center justify-between mb-1">
              <span class="text-sm text-gray-700 dark:text-gray-300">Medio</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ byRiskLevel.medium }}</span>
            </div>
            <ProgressBar
              :value="Math.round((byRiskLevel.medium / totalMicrocredits) * 100)"
              variant="warning"
              class="h-2"
            />
          </div>
          <div v-if="byRiskLevel.high > 0">
            <div class="flex items-center justify-between mb-1">
              <span class="text-sm text-gray-700 dark:text-gray-300">Alto</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ byRiskLevel.high }}</span>
            </div>
            <ProgressBar
              :value="Math.round((byRiskLevel.high / totalMicrocredits) * 100)"
              variant="danger"
              class="h-2"
            />
          </div>
        </div>
      </Card>

      <!-- Top Categories -->
      <Card :loading="loading">
        <div class="mb-4">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white flex items-center gap-2">
            <Icon name="tag" class="w-5 h-5 text-gray-600" />
            Top Categorías
          </h3>
        </div>
        <div v-if="byCategory.length > 0" class="space-y-3">
          <div v-for="[category, count] in byCategory" :key="category">
            <div class="flex items-center justify-between mb-1">
              <span class="text-sm text-gray-700 dark:text-gray-300">{{ category }}</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ count }}</span>
            </div>
            <ProgressBar
              :value="Math.round((count / totalMicrocredits) * 100)"
              class="h-2"
            />
          </div>
        </div>
        <div v-else class="text-sm text-gray-500 dark:text-gray-400 text-center py-4">
          No hay categorías disponibles
        </div>
      </Card>
    </div>

    <!-- Additional Metrics -->
    <div v-if="!compact" class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <!-- Average Interest Rate -->
      <Card :loading="loading">
        <div class="flex items-center gap-4">
          <div class="p-3 bg-yellow-100 dark:bg-yellow-900 rounded-lg">
            <Icon name="percent" class="w-6 h-6 text-yellow-600 dark:text-yellow-400" />
          </div>
          <div class="flex-1">
            <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">
              Tasa de Interés Promedio
            </div>
            <div class="text-2xl font-bold text-gray-900 dark:text-white">
              {{ averageInterestRate }}%
            </div>
          </div>
        </div>
      </Card>

      <!-- Average Term -->
      <Card :loading="loading">
        <div class="flex items-center gap-4">
          <div class="p-3 bg-cyan-100 dark:bg-cyan-900 rounded-lg">
            <Icon name="calendar" class="w-6 h-6 text-cyan-600 dark:text-cyan-400" />
          </div>
          <div class="flex-1">
            <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">
              Plazo Promedio
            </div>
            <div class="text-2xl font-bold text-gray-900 dark:text-white">
              {{ averageTerm }} meses
            </div>
          </div>
        </div>
      </Card>
    </div>
  </div>
</template>

<style scoped>
.microcredit-stats {
  @apply w-full;
}

.microcredit-stats__card {
  @apply p-6;
}
</style>
