<script setup lang="ts">
import { computed } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Button from '@/components/atoms/Button.vue'
import Badge from '@/components/atoms/Badge.vue'
import Icon from '@/components/atoms/Icon.vue'
import ProgressBar from '@/components/molecules/ProgressBar.vue'

export type VerificationLevel = 'none' | 'basic' | 'standard' | 'advanced' | 'complete'
export type VerificationItemStatus = 'pending' | 'completed' | 'rejected' | 'expired'

export interface VerificationItem {
  id: string
  label: string
  description?: string
  status: VerificationItemStatus
  required: boolean
  completedAt?: Date | string
  expiresAt?: Date | string
  rejectionReason?: string
}

interface Props {
  /** Current verification level */
  level: VerificationLevel
  /** Verification items */
  items: VerificationItem[]
  /** Show progress bar */
  showProgress?: boolean
  /** Show item details */
  showDetails?: boolean
  /** Compact mode */
  compact?: boolean
  /** Loading state */
  loading?: boolean
}

interface Emits {
  (e: 'verify-item', itemId: string): void
  (e: 'resubmit', itemId: string): void
  (e: 'start-verification'): void
}

const props = withDefaults(defineProps<Props>(), {
  showProgress: true,
  showDetails: true,
  compact: false,
  loading: false,
})

const emit = defineEmits<Emits>()

// Level configuration
const levelConfig = {
  none: {
    label: 'Sin Verificar',
    description: 'No has iniciado el proceso de verificación',
    color: 'gray',
    icon: 'x-circle',
    progress: 0,
  },
  basic: {
    label: 'Verificación Básica',
    description: 'Has completado la verificación básica',
    color: 'blue',
    icon: 'check-circle',
    progress: 25,
  },
  standard: {
    label: 'Verificación Estándar',
    description: 'Has completado la verificación estándar',
    color: 'indigo',
    icon: 'shield',
    progress: 50,
  },
  advanced: {
    label: 'Verificación Avanzada',
    description: 'Has completado la verificación avanzada',
    color: 'purple',
    icon: 'shield-check',
    progress: 75,
  },
  complete: {
    label: 'Verificación Completa',
    description: 'Has completado todos los niveles de verificación',
    color: 'green',
    icon: 'award',
    progress: 100,
  },
}

// Current level info
const currentLevel = computed(() => levelConfig[props.level])

// Status configuration
const statusConfig = {
  pending: {
    label: 'Pendiente',
    color: 'yellow',
    icon: 'clock',
  },
  completed: {
    label: 'Completado',
    color: 'green',
    icon: 'check-circle',
  },
  rejected: {
    label: 'Rechazado',
    color: 'red',
    icon: 'x-circle',
  },
  expired: {
    label: 'Expirado',
    color: 'orange',
    icon: 'alert-triangle',
  },
}

// Calculate completion percentage
const completionPercentage = computed(() => {
  if (props.items.length === 0) return 0
  const completed = props.items.filter(item => item.status === 'completed').length
  return Math.round((completed / props.items.length) * 100)
})

// Required items
const requiredItems = computed(() => props.items.filter(item => item.required))
const optionalItems = computed(() => props.items.filter(item => !item.required))

// Pending items count
const pendingCount = computed(() => {
  return props.items.filter(item => item.status === 'pending').length
})

// Rejected items count
const rejectedCount = computed(() => {
  return props.items.filter(item => item.status === 'rejected').length
})

// Can proceed to next level
const canProceed = computed(() => {
  return requiredItems.value.every(item => item.status === 'completed')
})

// Format date
const formatDate = (date: Date | string): string => {
  return new Intl.DateTimeFormat('es-ES', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(new Date(date))
}

// Check if expired
const isExpired = (item: VerificationItem): boolean => {
  if (!item.expiresAt) return false
  return new Date(item.expiresAt) < new Date()
}

// Handlers
const handleVerifyItem = (itemId: string) => {
  emit('verify-item', itemId)
}

const handleResubmit = (itemId: string) => {
  emit('resubmit', itemId)
}

const handleStartVerification = () => {
  emit('start-verification')
}
</script>

<template>
  <Card :loading="loading" class="verification-status">
    <!-- Header -->
    <div class="verification-status__header">
      <div class="flex items-start justify-between mb-4">
        <div class="flex-1">
          <h3 class="text-xl font-bold mb-1">Estado de Verificación</h3>
          <p v-if="!compact" class="text-sm text-gray-600 dark:text-gray-400">
            {{ currentLevel.description }}
          </p>
        </div>
        <Badge :variant="currentLevel.color as any" size="lg">
          <Icon :name="currentLevel.icon" class="w-4 h-4 mr-1" />
          {{ currentLevel.label }}
        </Badge>
      </div>

      <!-- Progress -->
      <div v-if="showProgress" class="mt-4">
        <div class="flex items-center justify-between mb-2">
          <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
            Progreso General
          </span>
          <span class="text-sm text-gray-600 dark:text-gray-400">
            {{ completionPercentage }}% completado
          </span>
        </div>
        <ProgressBar :value="completionPercentage" />
      </div>

      <!-- Summary -->
      <div v-if="!compact" class="mt-4 grid grid-cols-3 gap-4 text-center">
        <div class="p-3 bg-gray-50 dark:bg-gray-800 rounded">
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ items.length }}
          </div>
          <div class="text-xs text-gray-600 dark:text-gray-400">Total</div>
        </div>
        <div class="p-3 bg-yellow-50 dark:bg-yellow-900 rounded">
          <div class="text-2xl font-bold text-yellow-900 dark:text-yellow-200">
            {{ pendingCount }}
          </div>
          <div class="text-xs text-yellow-700 dark:text-yellow-400">Pendientes</div>
        </div>
        <div v-if="rejectedCount > 0" class="p-3 bg-red-50 dark:bg-red-900 rounded">
          <div class="text-2xl font-bold text-red-900 dark:text-red-200">
            {{ rejectedCount }}
          </div>
          <div class="text-xs text-red-700 dark:text-red-400">Rechazados</div>
        </div>
        <div v-else class="p-3 bg-green-50 dark:bg-green-900 rounded">
          <div class="text-2xl font-bold text-green-900 dark:text-green-200">
            {{ items.length - pendingCount }}
          </div>
          <div class="text-xs text-green-700 dark:text-green-400">Completados</div>
        </div>
      </div>
    </div>

    <!-- Items List -->
    <div class="verification-status__items">
      <!-- Required Items -->
      <div v-if="requiredItems.length > 0" class="mb-6">
        <h4 class="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3">
          Elementos Requeridos
        </h4>
        <div class="space-y-3">
          <div
            v-for="item in requiredItems"
            :key="item.id"
            :class="[
              'verification-status__item',
              item.status === 'completed' && 'bg-green-50 dark:bg-green-900 border-green-200 dark:border-green-800',
              item.status === 'rejected' && 'bg-red-50 dark:bg-red-900 border-red-200 dark:border-red-800',
              item.status === 'expired' && 'bg-orange-50 dark:bg-orange-900 border-orange-200 dark:border-orange-800',
              item.status === 'pending' && 'bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700',
            ]"
          >
            <div class="flex items-start gap-3">
              <Icon
                :name="statusConfig[item.status].icon"
                :class="[
                  'w-5 h-5 flex-shrink-0 mt-0.5',
                  item.status === 'completed' && 'text-green-600 dark:text-green-400',
                  item.status === 'rejected' && 'text-red-600 dark:text-red-400',
                  item.status === 'expired' && 'text-orange-600 dark:text-orange-400',
                  item.status === 'pending' && 'text-gray-400',
                ]"
              />
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between mb-1">
                  <h5 class="text-sm font-medium">{{ item.label }}</h5>
                  <Badge :variant="statusConfig[item.status].color as any" size="sm">
                    {{ statusConfig[item.status].label }}
                  </Badge>
                </div>
                <p v-if="showDetails && item.description" class="text-xs text-gray-600 dark:text-gray-400 mb-2">
                  {{ item.description }}
                </p>
                <div v-if="showDetails" class="flex items-center gap-4 text-xs text-gray-500">
                  <span v-if="item.completedAt">
                    Completado: {{ formatDate(item.completedAt) }}
                  </span>
                  <span v-if="item.expiresAt" :class="isExpired(item) && 'text-red-600 font-semibold'">
                    {{ isExpired(item) ? 'Expiró' : 'Expira' }}: {{ formatDate(item.expiresAt) }}
                  </span>
                </div>
                <p v-if="item.rejectionReason" class="text-xs text-red-600 dark:text-red-400 mt-2">
                  <strong>Motivo:</strong> {{ item.rejectionReason }}
                </p>
              </div>
              <div v-if="item.status === 'pending'" class="flex-shrink-0">
                <Button
                  size="sm"
                  variant="primary"
                  @click="handleVerifyItem(item.id)"
                >
                  Verificar
                </Button>
              </div>
              <div v-else-if="item.status === 'rejected' || item.status === 'expired'" class="flex-shrink-0">
                <Button
                  size="sm"
                  variant="outline"
                  @click="handleResubmit(item.id)"
                >
                  Reenviar
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Optional Items -->
      <div v-if="optionalItems.length > 0">
        <h4 class="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3">
          Elementos Opcionales
        </h4>
        <div class="space-y-3">
          <div
            v-for="item in optionalItems"
            :key="item.id"
            :class="[
              'verification-status__item',
              item.status === 'completed' && 'bg-green-50 dark:bg-green-900 border-green-200 dark:border-green-800',
              item.status === 'pending' && 'bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-700',
            ]"
          >
            <div class="flex items-start gap-3">
              <Icon
                :name="statusConfig[item.status].icon"
                :class="[
                  'w-5 h-5 flex-shrink-0 mt-0.5',
                  item.status === 'completed' && 'text-green-600 dark:text-green-400',
                  item.status === 'pending' && 'text-gray-400',
                ]"
              />
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between mb-1">
                  <h5 class="text-sm font-medium">{{ item.label }}</h5>
                  <Badge :variant="statusConfig[item.status].color as any" size="sm">
                    {{ statusConfig[item.status].label }}
                  </Badge>
                </div>
                <p v-if="showDetails && item.description" class="text-xs text-gray-600 dark:text-gray-400">
                  {{ item.description }}
                </p>
              </div>
              <div v-if="item.status === 'pending'" class="flex-shrink-0">
                <Button
                  size="sm"
                  variant="outline"
                  @click="handleVerifyItem(item.id)"
                >
                  Verificar
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-if="items.length === 0" class="text-center py-12">
        <Icon name="shield-off" class="w-16 h-16 text-gray-300 dark:text-gray-700 mx-auto mb-4" />
        <h4 class="text-lg font-semibold text-gray-700 dark:text-gray-300 mb-2">
          No hay elementos de verificación
        </h4>
        <p class="text-sm text-gray-500 dark:text-gray-400 mb-4">
          Inicia el proceso de verificación para acceder a todas las funciones
        </p>
        <Button variant="primary" @click="handleStartVerification">
          Iniciar Verificación
        </Button>
      </div>
    </div>

    <!-- Next Steps -->
    <div v-if="pendingCount > 0 && !compact" class="verification-status__next-steps">
      <div class="p-4 bg-blue-50 dark:bg-blue-900 border border-blue-200 dark:border-blue-800 rounded">
        <div class="flex items-start gap-3">
          <Icon name="info" class="w-5 h-5 text-blue-600 dark:text-blue-400 flex-shrink-0" />
          <div>
            <h5 class="text-sm font-semibold text-blue-900 dark:text-blue-200 mb-1">
              Próximos Pasos
            </h5>
            <p class="text-xs text-blue-700 dark:text-blue-300">
              {{ pendingCount === 1
                ? 'Tienes 1 elemento pendiente de verificación.'
                : `Tienes ${pendingCount} elementos pendientes de verificación.`
              }}
              {{ canProceed
                ? 'Los elementos opcionales te darán acceso a más funciones.'
                : 'Completa los elementos requeridos para continuar.'
              }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </Card>
</template>

<style scoped>
.verification-status {
  @apply w-full;
}

.verification-status__header {
  @apply pb-6 border-b border-gray-200 dark:border-gray-700;
}

.verification-status__items {
  @apply py-6;
}

.verification-status__item {
  @apply p-4 border rounded-lg transition-all duration-200;
}

.verification-status__next-steps {
  @apply pt-6 border-t border-gray-200 dark:border-gray-700;
}
</style>
