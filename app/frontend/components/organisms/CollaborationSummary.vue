<script setup lang="ts">
import { computed } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Badge from '@/components/atoms/Badge.vue'
import Icon from '@/components/atoms/Icon.vue'
import Avatar from '@/components/atoms/Avatar.vue'
import Button from '@/components/atoms/Button.vue'

export interface Collaboration {
  /** Unique identifier */
  id: string
  /** Collaboration title */
  title: string
  /** Collaboration description */
  description: string
  /** Collaboration type */
  type: 'project' | 'initiative' | 'event' | 'campaign' | 'workshop' | 'other'
  /** Location (optional) */
  location?: string
  /** Start date (optional) */
  startDate?: string
  /** End date (optional) */
  endDate?: string
  /** Minimum number of collaborators */
  minCollaborators?: number
  /** Maximum number of collaborators */
  maxCollaborators?: number
  /** Required skills */
  skills: string[]
  /** Collaboration image URL */
  imageUrl?: string
  /** Creator information */
  creator: {
    id: string
    name: string
    avatar?: string
  }
  /** Current collaborators count */
  currentCollaborators: number
  /** Collaboration status */
  status: 'open' | 'in_progress' | 'completed' | 'cancelled'
  /** Created date */
  createdAt: string
  /** Updated date */
  updatedAt?: string
}

interface Props {
  /** Collaboration data */
  collaboration: Collaboration
  /** Loading state */
  loading?: boolean
  /** Show actions */
  showActions?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  showActions: true,
})

interface Emits {
  /** Emitted when join button is clicked */
  (e: 'join'): void
  /** Emitted when leave button is clicked */
  (e: 'leave'): void
  /** Emitted when edit button is clicked */
  (e: 'edit'): void
  /** Emitted when delete button is clicked */
  (e: 'delete'): void
  /** Emitted when contact button is clicked */
  (e: 'contact'): void
}

const emit = defineEmits<Emits>()

// Type labels
const typeLabels: Record<Collaboration['type'], string> = {
  project: 'Proyecto',
  initiative: 'Iniciativa',
  event: 'Evento',
  campaign: 'Campaña',
  workshop: 'Taller',
  other: 'Otro',
}

// Status labels
const statusLabels: Record<Collaboration['status'], string> = {
  open: 'Abierta',
  in_progress: 'En Progreso',
  completed: 'Completada',
  cancelled: 'Cancelada',
}

// Status variants (using 'danger' instead of 'error' to match Badge variants)
const statusVariants: Record<Collaboration['status'], 'success' | 'warning' | 'danger' | 'info'> = {
  open: 'success',
  in_progress: 'info',
  completed: 'success',
  cancelled: 'danger',
}

// Type label
const typeLabel = computed(() => typeLabels[props.collaboration.type])

// Status label
const statusLabel = computed(() => statusLabels[props.collaboration.status])

// Status variant
const statusVariant = computed(() => statusVariants[props.collaboration.status])

// Format date
const formatDate = (dateString?: string): string => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('es-ES', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  }).format(date)
}

// Format date short
const formatDateShort = (dateString?: string): string => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('es-ES', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(date)
}

// Collaborators progress
const collaboratorsProgress = computed(() => {
  if (!props.collaboration.maxCollaborators) return 0
  return Math.round((props.collaboration.currentCollaborators / props.collaboration.maxCollaborators) * 100)
})

// Is full
const isFull = computed(() => {
  if (!props.collaboration.maxCollaborators) return false
  return props.collaboration.currentCollaborators >= props.collaboration.maxCollaborators
})

// Can join
const canJoin = computed(() => {
  return props.collaboration.status === 'open' && !isFull.value
})
</script>

<template>
  <Card :loading="loading" class="collaboration-summary">
    <!-- Header -->
    <div class="mb-6">
      <div class="flex items-start justify-between mb-4">
        <div class="flex-1">
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            {{ collaboration.title }}
          </h2>
          <div class="flex items-center gap-2 flex-wrap">
            <Badge :variant="statusVariant">
              {{ statusLabel }}
            </Badge>
            <Badge variant="info">
              {{ typeLabel }}
            </Badge>
            <div v-if="collaboration.location" class="flex items-center gap-1 text-sm text-gray-600 dark:text-gray-400">
              <Icon name="map-pin" class="w-4 h-4" />
              <span>{{ collaboration.location }}</span>
            </div>
          </div>
        </div>
        <div v-if="collaboration.imageUrl" class="ml-4 flex-shrink-0">
          <img
            :src="collaboration.imageUrl"
            :alt="collaboration.title"
            class="w-24 h-24 object-cover rounded-lg"
          />
        </div>
      </div>

      <!-- Description -->
      <p class="text-gray-700 dark:text-gray-300 mb-4 whitespace-pre-wrap">
        {{ collaboration.description }}
      </p>

      <!-- Creator -->
      <div class="flex items-center gap-2 mb-4">
        <Avatar
          :src="collaboration.creator.avatar"
          :alt="collaboration.creator.name"
          size="sm"
        />
        <div class="text-sm">
          <span class="text-gray-600 dark:text-gray-400">Creado por </span>
          <span class="font-semibold text-gray-900 dark:text-white">{{ collaboration.creator.name }}</span>
        </div>
      </div>
    </div>

    <!-- Details Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
      <!-- Dates -->
      <div v-if="collaboration.startDate || collaboration.endDate" class="collaboration-summary__section">
        <h3 class="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3 flex items-center gap-2">
          <Icon name="calendar" class="w-4 h-4" />
          Fechas
        </h3>
        <div class="space-y-2">
          <div v-if="collaboration.startDate" class="flex justify-between text-sm">
            <span class="text-gray-600 dark:text-gray-400">Inicio:</span>
            <span class="font-medium text-gray-900 dark:text-white">{{ formatDate(collaboration.startDate) }}</span>
          </div>
          <div v-if="collaboration.endDate" class="flex justify-between text-sm">
            <span class="text-gray-600 dark:text-gray-400">Fin:</span>
            <span class="font-medium text-gray-900 dark:text-white">{{ formatDate(collaboration.endDate) }}</span>
          </div>
        </div>
      </div>

      <!-- Collaborators -->
      <div class="collaboration-summary__section">
        <h3 class="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3 flex items-center gap-2">
          <Icon name="users" class="w-4 h-4" />
          Colaboradores
        </h3>
        <div class="space-y-2">
          <div class="flex justify-between text-sm">
            <span class="text-gray-600 dark:text-gray-400">Actuales:</span>
            <span class="font-medium text-gray-900 dark:text-white">{{ collaboration.currentCollaborators }}</span>
          </div>
          <div v-if="collaboration.minCollaborators" class="flex justify-between text-sm">
            <span class="text-gray-600 dark:text-gray-400">Mínimo:</span>
            <span class="font-medium text-gray-900 dark:text-white">{{ collaboration.minCollaborators }}</span>
          </div>
          <div v-if="collaboration.maxCollaborators" class="flex justify-between text-sm">
            <span class="text-gray-600 dark:text-gray-400">Máximo:</span>
            <span class="font-medium text-gray-900 dark:text-white">{{ collaboration.maxCollaborators }}</span>
          </div>
          <div v-if="collaboration.maxCollaborators" class="mt-3">
            <div class="flex justify-between text-xs text-gray-600 dark:text-gray-400 mb-1">
              <span>Progreso</span>
              <span>{{ collaboratorsProgress }}%</span>
            </div>
            <div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
              <div
                class="h-2 rounded-full transition-all duration-300"
                :class="{
                  'bg-green-500': collaboratorsProgress < 80,
                  'bg-yellow-500': collaboratorsProgress >= 80 && collaboratorsProgress < 100,
                  'bg-red-500': collaboratorsProgress >= 100,
                }"
                :style="{ width: `${Math.min(collaboratorsProgress, 100)}%` }"
              />
            </div>
            <div v-if="isFull" class="text-xs text-red-600 dark:text-red-400 mt-1">
              Cupo completo
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Skills -->
    <div v-if="collaboration.skills.length > 0" class="mb-6">
      <h3 class="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3 flex items-center gap-2">
        <Icon name="zap" class="w-4 h-4" />
        Habilidades Requeridas
      </h3>
      <div class="flex flex-wrap gap-2">
        <Badge
          v-for="skill in collaboration.skills"
          :key="skill"
          variant="info"
          size="sm"
        >
          {{ skill }}
        </Badge>
      </div>
    </div>

    <!-- Metadata -->
    <div class="border-t border-gray-200 dark:border-gray-700 pt-4 mb-4">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs text-gray-600 dark:text-gray-400">
        <div class="flex items-center gap-2">
          <Icon name="clock" class="w-4 h-4" />
          <span>Creado: {{ formatDateShort(collaboration.createdAt) }}</span>
        </div>
        <div v-if="collaboration.updatedAt" class="flex items-center gap-2">
          <Icon name="refresh-cw" class="w-4 h-4" />
          <span>Actualizado: {{ formatDateShort(collaboration.updatedAt) }}</span>
        </div>
      </div>
    </div>

    <!-- Actions -->
    <div v-if="showActions" class="flex flex-wrap gap-3">
      <Button
        v-if="canJoin"
        variant="primary"
        @click="emit('join')"
      >
        <Icon name="user-plus" class="w-4 h-4" />
        Unirse
      </Button>
      <Button
        v-if="collaboration.status === 'in_progress'"
        variant="secondary"
        @click="emit('leave')"
      >
        <Icon name="user-minus" class="w-4 h-4" />
        Abandonar
      </Button>
      <Button
        variant="secondary"
        @click="emit('contact')"
      >
        <Icon name="message-circle" class="w-4 h-4" />
        Contactar
      </Button>
      <div class="flex-1" />
      <Button
        variant="secondary"
        @click="emit('edit')"
      >
        <Icon name="edit" class="w-4 h-4" />
        Editar
      </Button>
      <Button
        variant="danger"
        @click="emit('delete')"
      >
        <Icon name="trash" class="w-4 h-4" />
        Eliminar
      </Button>
    </div>
  </Card>
</template>

<style scoped>
.collaboration-summary {
  @apply p-6;
}

.collaboration-summary__section {
  @apply p-4 bg-gray-50 dark:bg-gray-800 rounded-lg;
}
</style>
