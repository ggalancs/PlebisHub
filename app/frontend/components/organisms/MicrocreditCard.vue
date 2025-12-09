<script setup lang="ts">
import { computed } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Button from '@/components/atoms/Button.vue'
import Badge from '@/components/atoms/Badge.vue'
import Icon from '@/components/atoms/Icon.vue'
import Avatar from '@/components/atoms/Avatar.vue'
import ProgressBar from '@/components/molecules/ProgressBar.vue'

export type MicrocreditStatus = 'pending' | 'funding' | 'funded' | 'repaying' | 'completed' | 'defaulted'
export type RiskLevel = 'low' | 'medium' | 'high'

export interface Borrower {
  id: string
  name: string
  avatar?: string
  location?: string
  rating?: number
}

export interface Microcredit {
  id: string
  title: string
  description: string
  borrower: Borrower
  amountRequested: number
  amountFunded: number
  interestRate: number
  termMonths: number
  status: MicrocreditStatus
  riskLevel?: RiskLevel
  category?: string
  deadline?: Date | string
  fundedDate?: Date | string
  completionDate?: Date | string
  investorsCount?: number
  minimumInvestment?: number
  imageUrl?: string
}

interface Props {
  /** Microcredit data */
  microcredit: Microcredit
  /** Show invest button */
  showInvestButton?: boolean
  /** User has invested */
  hasInvested?: boolean
  /** Compact mode */
  compact?: boolean
  /** Loading state */
  loading?: boolean
  /** Disabled state */
  disabled?: boolean
}

interface Emits {
  (e: 'invest', microcreditId: string): void
  (e: 'view-details', microcreditId: string): void
  (e: 'contact-borrower', borrowerId: string): void
}

const props = withDefaults(defineProps<Props>(), {
  showInvestButton: true,
  hasInvested: false,
  compact: false,
  loading: false,
  disabled: false,
})

const emit = defineEmits<Emits>()

// Badge variant type (matches Badge component variants)
type BadgeVariant = 'default' | 'primary' | 'secondary' | 'success' | 'warning' | 'danger' | 'info' | 'neutral'

// Status configuration
const statusConfig: Record<MicrocreditStatus, { label: string; color: BadgeVariant; icon: string }> = {
  pending: {
    label: 'Pendiente',
    color: 'default',
    icon: 'clock',
  },
  funding: {
    label: 'En Financiación',
    color: 'info',
    icon: 'trending-up',
  },
  funded: {
    label: 'Financiado',
    color: 'success',
    icon: 'check-circle',
  },
  repaying: {
    label: 'En Repago',
    color: 'primary',
    icon: 'refresh-cw',
  },
  completed: {
    label: 'Completado',
    color: 'success',
    icon: 'check-circle',
  },
  defaulted: {
    label: 'Impagado',
    color: 'danger',
    icon: 'x-circle',
  },
}

// Risk level configuration
const riskLevelConfig: Record<RiskLevel, { label: string; color: BadgeVariant; icon: string }> = {
  low: {
    label: 'Riesgo Bajo',
    color: 'success',
    icon: 'shield',
  },
  medium: {
    label: 'Riesgo Medio',
    color: 'warning',
    icon: 'shield',
  },
  high: {
    label: 'Riesgo Alto',
    color: 'danger',
    icon: 'alert-triangle',
  },
}

// Current status info
const currentStatus = computed(() => statusConfig[props.microcredit.status])

// Current risk level info
const currentRiskLevel = computed(() => {
  if (!props.microcredit.riskLevel) return null
  return riskLevelConfig[props.microcredit.riskLevel]
})

// Calculate funding percentage
const fundingPercentage = computed(() => {
  return Math.round((props.microcredit.amountFunded / props.microcredit.amountRequested) * 100)
})

// Remaining amount
const remainingAmount = computed(() => {
  return props.microcredit.amountRequested - props.microcredit.amountFunded
})

// Is fully funded
const isFullyFunded = computed(() => {
  return props.microcredit.amountFunded >= props.microcredit.amountRequested
})

// Can invest
const canInvest = computed(() => {
  return (
    !props.disabled &&
    props.microcredit.status === 'funding' &&
    !isFullyFunded.value
  )
})

// Format currency
const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('es-ES', {
    style: 'currency',
    currency: 'EUR',
  }).format(amount)
}


// Days until deadline
const daysUntilDeadline = computed(() => {
  if (!props.microcredit.deadline) return null
  const now = new Date()
  const deadline = new Date(props.microcredit.deadline)
  const diffTime = deadline.getTime() - now.getTime()
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  return diffDays
})

// Expected return
const expectedReturn = computed(() => {
  const principal = props.microcredit.minimumInvestment || 0
  const rate = props.microcredit.interestRate / 100
  const time = props.microcredit.termMonths / 12
  return principal * rate * time
})

// Handlers
const handleInvest = () => {
  if (canInvest.value) {
    emit('invest', props.microcredit.id)
  }
}

const handleViewDetails = () => {
  emit('view-details', props.microcredit.id)
}

const handleContactBorrower = () => {
  emit('contact-borrower', props.microcredit.borrower.id)
}
</script>

<template>
  <Card :loading="loading" class="microcredit-card">
    <!-- Header with Image (optional) -->
    <div v-if="microcredit.imageUrl && !compact" class="microcredit-card__image">
      <img :src="microcredit.imageUrl" :alt="microcredit.title" class="w-full h-48 object-cover" />
      <div v-if="hasInvested" class="microcredit-card__invested-badge">
        <Icon name="check-circle" class="w-4 h-4 mr-1" />
        Has Invertido
      </div>
    </div>

    <!-- Content -->
    <div class="microcredit-card__content">
      <!-- Header -->
      <div class="flex items-start justify-between mb-3">
        <div class="flex-1 min-w-0">
          <div class="flex items-center gap-2 mb-2">
            <h3 class="text-lg font-bold truncate">{{ microcredit.title }}</h3>
            <Badge v-if="hasInvested" variant="info" size="sm">
              <Icon name="trending-up" class="w-3 h-3 mr-1" />
              Invertido
            </Badge>
          </div>
          <p v-if="!compact" class="text-sm text-gray-600 dark:text-gray-400 line-clamp-2">
            {{ microcredit.description }}
          </p>
        </div>
        <Badge :variant="currentStatus.color" size="sm" class="ml-2 flex-shrink-0">
          <Icon :name="currentStatus.icon" class="w-3 h-3 mr-1" />
          {{ currentStatus.label }}
        </Badge>
      </div>

      <!-- Borrower -->
      <div class="flex items-center justify-between mb-4">
        <div class="flex items-center gap-2">
          <Avatar
            :name="microcredit.borrower.name"
            :src="microcredit.borrower.avatar"
            size="sm"
          />
          <div>
            <p class="text-xs font-medium text-gray-700 dark:text-gray-300">
              {{ microcredit.borrower.name }}
            </p>
            <p v-if="microcredit.borrower.location" class="text-xs text-gray-500 dark:text-gray-400">
              <Icon name="map-pin" class="w-3 h-3 inline mr-1" />
              {{ microcredit.borrower.location }}
            </p>
          </div>
        </div>
        <Button
          variant="ghost"
          size="sm"
          @click="handleContactBorrower"
        >
          <Icon name="mail" class="w-4 h-4" />
        </Button>
      </div>

      <!-- Borrower Rating -->
      <div v-if="microcredit.borrower.rating !== undefined" class="mb-4">
        <div class="flex items-center gap-2">
          <div class="flex items-center gap-1">
            <Icon
              v-for="i in 5"
              :key="i"
              name="star"
              :class="[
                'w-4 h-4',
                i <= microcredit.borrower.rating ? 'text-yellow-500 fill-current' : 'text-gray-300 dark:text-gray-600'
              ]"
            />
          </div>
          <span class="text-xs text-gray-600 dark:text-gray-400">
            {{ microcredit.borrower.rating }}/5
          </span>
        </div>
      </div>

      <!-- Funding Progress -->
      <div class="mb-4">
        <div class="flex items-center justify-between mb-2">
          <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
            Financiado
          </span>
          <span class="text-sm font-bold text-gray-900 dark:text-white">
            {{ fundingPercentage }}%
          </span>
        </div>
        <ProgressBar :value="fundingPercentage" />
        <div class="flex items-center justify-between mt-2">
          <span class="text-xs text-gray-600 dark:text-gray-400">
            {{ formatCurrency(microcredit.amountFunded) }} de {{ formatCurrency(microcredit.amountRequested) }}
          </span>
          <span v-if="!isFullyFunded" class="text-xs text-gray-600 dark:text-gray-400">
            Faltan {{ formatCurrency(remainingAmount) }}
          </span>
        </div>
      </div>

      <!-- Key Info Grid -->
      <div class="grid grid-cols-2 gap-3 mb-4">
        <!-- Interest Rate -->
        <div class="microcredit-card__info-box">
          <Icon name="percent" class="w-4 h-4 text-green-600 dark:text-green-400 mb-1" />
          <div class="text-lg font-bold text-gray-900 dark:text-white">
            {{ microcredit.interestRate }}%
          </div>
          <div class="text-xs text-gray-600 dark:text-gray-400">Interés</div>
        </div>

        <!-- Term -->
        <div class="microcredit-card__info-box">
          <Icon name="calendar" class="w-4 h-4 text-blue-600 dark:text-blue-400 mb-1" />
          <div class="text-lg font-bold text-gray-900 dark:text-white">
            {{ microcredit.termMonths }} m
          </div>
          <div class="text-xs text-gray-600 dark:text-gray-400">Plazo</div>
        </div>

        <!-- Investors -->
        <div v-if="microcredit.investorsCount !== undefined" class="microcredit-card__info-box">
          <Icon name="users" class="w-4 h-4 text-indigo-600 dark:text-indigo-400 mb-1" />
          <div class="text-lg font-bold text-gray-900 dark:text-white">
            {{ microcredit.investorsCount }}
          </div>
          <div class="text-xs text-gray-600 dark:text-gray-400">Inversores</div>
        </div>

        <!-- Minimum Investment -->
        <div v-if="microcredit.minimumInvestment" class="microcredit-card__info-box">
          <Icon name="credit-card" class="w-4 h-4 text-purple-600 dark:text-purple-400 mb-1" />
          <div class="text-lg font-bold text-gray-900 dark:text-white">
            {{ formatCurrency(microcredit.minimumInvestment) }}
          </div>
          <div class="text-xs text-gray-600 dark:text-gray-400">Mínimo</div>
        </div>
      </div>

      <!-- Risk Level -->
      <div v-if="currentRiskLevel && !compact" class="mb-4">
        <Badge :variant="currentRiskLevel.color" size="sm">
          <Icon :name="currentRiskLevel.icon" class="w-3 h-3 mr-1" />
          {{ currentRiskLevel.label }}
        </Badge>
      </div>

      <!-- Category -->
      <div v-if="microcredit.category && !compact" class="mb-4">
        <Badge variant="neutral" size="sm">
          {{ microcredit.category }}
        </Badge>
      </div>

      <!-- Deadline -->
      <div v-if="microcredit.deadline && microcredit.status === 'funding' && !compact" class="mb-4">
        <div class="flex items-center gap-2 text-xs text-gray-600 dark:text-gray-400">
          <Icon name="clock" class="w-3 h-3" />
          <span v-if="daysUntilDeadline !== null && daysUntilDeadline > 0">
            {{ daysUntilDeadline }} {{ daysUntilDeadline === 1 ? 'día' : 'días' }} restantes
          </span>
          <span v-else-if="daysUntilDeadline !== null && daysUntilDeadline <= 0" class="text-red-600 font-semibold">
            Plazo vencido
          </span>
        </div>
      </div>

      <!-- Expected Return -->
      <div v-if="!compact && microcredit.minimumInvestment && microcredit.status === 'funding'" class="mb-4">
        <div class="p-3 bg-green-50 dark:bg-green-900 border border-green-200 dark:border-green-800 rounded">
          <div class="text-xs text-green-700 dark:text-green-300 mb-1">
            Retorno esperado (inversión mínima)
          </div>
          <div class="text-lg font-bold text-green-900 dark:text-green-200">
            +{{ formatCurrency(expectedReturn) }}
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="flex items-center gap-2">
        <Button
          v-if="showInvestButton && microcredit.status === 'funding'"
          variant="primary"
          size="sm"
          :disabled="!canInvest"
          @click="handleInvest"
          class="flex-1"
        >
          <Icon name="dollar-sign" class="w-4 h-4 mr-2" />
          {{ isFullyFunded ? 'Completamente Financiado' : 'Invertir Ahora' }}
        </Button>
        <Button
          variant="outline"
          size="sm"
          :disabled="disabled"
          @click="handleViewDetails"
          :class="!showInvestButton || microcredit.status !== 'funding' ? 'flex-1' : ''"
        >
          <Icon name="eye" class="w-4 h-4 mr-2" />
          Ver Detalles
        </Button>
      </div>
    </div>

    <!-- Fully Funded Banner -->
    <div
      v-if="isFullyFunded && microcredit.status === 'funding'"
      class="microcredit-card__banner microcredit-card__banner--funded"
    >
      <Icon name="check-circle" class="w-4 h-4" />
      <span class="text-sm font-medium">¡Objetivo alcanzado!</span>
    </div>

    <!-- Defaulted Banner -->
    <div
      v-if="microcredit.status === 'defaulted'"
      class="microcredit-card__banner microcredit-card__banner--defaulted"
    >
      <Icon name="alert-triangle" class="w-4 h-4" />
      <span class="text-sm font-medium">Este microcrédito ha sido impagado</span>
    </div>
  </Card>
</template>

<style scoped>
.microcredit-card {
  @apply w-full overflow-hidden;
}

.microcredit-card__image {
  @apply relative overflow-hidden;
}

.microcredit-card__invested-badge {
  @apply absolute top-3 right-3 flex items-center px-3 py-1 bg-blue-600 text-white rounded-full text-xs font-medium shadow-lg;
}

.microcredit-card__content {
  @apply p-6;
}

.microcredit-card__info-box {
  @apply flex flex-col items-center justify-center p-3 bg-gray-50 dark:bg-gray-800 rounded-lg text-center;
}

.microcredit-card__banner {
  @apply flex items-center justify-center gap-2 py-3 px-4 border-t;
}

.microcredit-card__banner--funded {
  @apply bg-green-50 dark:bg-green-900 border-green-200 dark:border-green-800 text-green-800 dark:text-green-200;
}

.microcredit-card__banner--defaulted {
  @apply bg-red-50 dark:bg-red-900 border-red-200 dark:border-red-800 text-red-800 dark:text-red-200;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
