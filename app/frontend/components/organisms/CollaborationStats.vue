<script setup lang="ts">
import { computed } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Icon from '@/components/atoms/Icon.vue'
import ProgressBar from '@/components/molecules/ProgressBar.vue'
import type { Collaboration } from './CollaborationSummary.vue'

interface Props {
  /** List of collaborations for stats */
  collaborations: Collaboration[]
  /** Loading state */
  loading?: boolean
  /** Compact mode */
  compact?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  compact: false,
})

// Total collaborations
const totalCollaborations = computed(() => props.collaborations.length)

// Active collaborations (open or in_progress)
const activeCollaborations = computed(() => {
  return props.collaborations.filter(c => c.status === 'open' || c.status === 'in_progress').length
})

// Completed collaborations
const completedCollaborations = computed(() => {
  return props.collaborations.filter(c => c.status === 'completed').length
})

// Cancelled collaborations
const cancelledCollaborations = computed(() => {
  return props.collaborations.filter(c => c.status === 'cancelled').length
})

// Completion rate
const completionRate = computed(() => {
  const total = completedCollaborations.value + cancelledCollaborations.value
  if (total === 0) return 0
  return Math.round((completedCollaborations.value / total) * 100)
})

// Total collaborators
const totalCollaborators = computed(() => {
  return props.collaborations.reduce((sum, c) => sum + c.currentCollaborators, 0)
})

// Average collaborators per collaboration
const averageCollaborators = computed(() => {
  if (props.collaborations.length === 0) return 0
  return Math.round(totalCollaborators.value / props.collaborations.length)
})

// By status
const byStatus = computed(() => {
  return {
    open: props.collaborations.filter(c => c.status === 'open').length,
    in_progress: props.collaborations.filter(c => c.status === 'in_progress').length,
    completed: completedCollaborations.value,
    cancelled: cancelledCollaborations.value,
  }
})

// By type
const byType = computed(() => {
  const types: Record<string, number> = {}
  props.collaborations.forEach(c => {
    types[c.type] = (types[c.type] || 0) + 1
  })
  return Object.entries(types)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 5) // Top 5 types
})

// Type labels
const typeLabels: Record<string, string> = {
  project: 'Proyectos',
  initiative: 'Iniciativas',
  event: 'Eventos',
  campaign: 'Campañas',
  workshop: 'Talleres',
  other: 'Otros',
}

// Popular skills (top 10)
const popularSkills = computed(() => {
  const skillsCount: Record<string, number> = {}
  props.collaborations.forEach(c => {
    c.skills.forEach(skill => {
      skillsCount[skill] = (skillsCount[skill] || 0) + 1
    })
  })
  return Object.entries(skillsCount)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 10)
})

// Collaborations needing more people (not full and open)
const needingPeople = computed(() => {
  return props.collaborations.filter(c => {
    if (c.status !== 'open' || !c.maxCollaborators) return false
    return c.currentCollaborators < c.maxCollaborators
  }).length
})

// Full collaborations
const fullCollaborations = computed(() => {
  return props.collaborations.filter(c => {
    if (!c.maxCollaborators) return false
    return c.currentCollaborators >= c.maxCollaborators
  }).length
})

// Format number
const formatNumber = (num: number): string => {
  return new Intl.NumberFormat('es-ES').format(num)
}
</script>

<template>
  <div class="collaboration-stats">
    <!-- Main Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
      <!-- Total Collaborations -->
      <Card :loading="loading" class="collaboration-stats__card">
        <div class="flex items-center justify-between mb-2">
          <Icon name="folder" class="w-8 h-8 text-blue-600 dark:text-blue-400" />
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ formatNumber(totalCollaborations) }}
          </div>
        </div>
        <div class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Total Colaboraciones
        </div>
        <div class="text-xs text-gray-600 dark:text-gray-400">
          {{ activeCollaborations }} activas
        </div>
      </Card>

      <!-- Total Collaborators -->
      <Card :loading="loading" class="collaboration-stats__card">
        <div class="flex items-center justify-between mb-2">
          <Icon name="users" class="w-8 h-8 text-green-600 dark:text-green-400" />
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ formatNumber(totalCollaborators) }}
          </div>
        </div>
        <div class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Total Colaboradores
        </div>
        <div class="text-xs text-gray-600 dark:text-gray-400">
          {{ averageCollaborators }} promedio por colaboración
        </div>
      </Card>

      <!-- Completion Rate -->
      <Card :loading="loading" class="collaboration-stats__card">
        <div class="flex items-center justify-between mb-2">
          <Icon name="check-circle" class="w-8 h-8 text-purple-600 dark:text-purple-400" />
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ completionRate }}%
          </div>
        </div>
        <div class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Tasa de Finalización
        </div>
        <div class="text-xs text-gray-600 dark:text-gray-400">
          {{ completedCollaborations }} completadas
        </div>
      </Card>

      <!-- Needing People -->
      <Card :loading="loading" class="collaboration-stats__card">
        <div class="flex items-center justify-between mb-2">
          <Icon name="user-plus" class="w-8 h-8 text-orange-600 dark:text-orange-400" />
          <div class="text-2xl font-bold text-gray-900 dark:text-white">
            {{ formatNumber(needingPeople) }}
          </div>
        </div>
        <div class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
          Buscan Colaboradores
        </div>
        <div class="text-xs text-gray-600 dark:text-gray-400">
          {{ fullCollaborations }} con cupo completo
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
          <div v-if="byStatus.open > 0" class="flex items-center justify-between">
            <span class="text-sm text-gray-700 dark:text-gray-300">Abiertas</span>
            <span class="text-sm font-semibold text-green-600 dark:text-green-400">{{ byStatus.open }}</span>
          </div>
          <div v-if="byStatus.in_progress > 0" class="flex items-center justify-between">
            <span class="text-sm text-gray-700 dark:text-gray-300">En Progreso</span>
            <span class="text-sm font-semibold text-blue-600 dark:text-blue-400">{{ byStatus.in_progress }}</span>
          </div>
          <div v-if="byStatus.completed > 0" class="flex items-center justify-between">
            <span class="text-sm text-gray-700 dark:text-gray-300">Completadas</span>
            <span class="text-sm font-semibold text-purple-600 dark:text-purple-400">{{ byStatus.completed }}</span>
          </div>
          <div v-if="byStatus.cancelled > 0" class="flex items-center justify-between">
            <span class="text-sm text-gray-700 dark:text-gray-300">Canceladas</span>
            <span class="text-sm font-semibold text-red-600 dark:text-red-400">{{ byStatus.cancelled }}</span>
          </div>
        </div>
      </Card>

      <!-- By Type -->
      <Card :loading="loading">
        <div class="mb-4">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white flex items-center gap-2">
            <Icon name="grid" class="w-5 h-5 text-gray-600" />
            Por Tipo
          </h3>
        </div>
        <div v-if="byType.length > 0" class="space-y-3">
          <div v-for="[type, count] in byType" :key="type">
            <div class="flex items-center justify-between mb-1">
              <span class="text-sm text-gray-700 dark:text-gray-300">{{ typeLabels[type] || type }}</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ count }}</span>
            </div>
            <ProgressBar
              :value="Math.round((count / totalCollaborations) * 100)"
              class="h-2"
            />
          </div>
        </div>
        <div v-else class="text-sm text-gray-500 dark:text-gray-400 text-center py-4">
          No hay tipos disponibles
        </div>
      </Card>

      <!-- Popular Skills -->
      <Card :loading="loading">
        <div class="mb-4">
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white flex items-center gap-2">
            <Icon name="zap" class="w-5 h-5 text-gray-600" />
            Habilidades Populares
          </h3>
        </div>
        <div v-if="popularSkills.length > 0" class="space-y-3">
          <div v-for="[skill, count] in popularSkills" :key="skill">
            <div class="flex items-center justify-between mb-1">
              <span class="text-sm text-gray-700 dark:text-gray-300 truncate mr-2">{{ skill }}</span>
              <span class="text-sm font-semibold text-gray-900 dark:text-white">{{ count }}</span>
            </div>
            <ProgressBar
              :value="Math.round((count / totalCollaborations) * 100)"
              variant="warning"
              class="h-2"
            />
          </div>
        </div>
        <div v-else class="text-sm text-gray-500 dark:text-gray-400 text-center py-4">
          No hay habilidades disponibles
        </div>
      </Card>
    </div>

    <!-- Additional Metrics -->
    <div v-if="!compact" class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <!-- Most Active Types -->
      <Card :loading="loading">
        <div class="flex items-center gap-4">
          <div class="p-3 bg-blue-100 dark:bg-blue-900 rounded-lg">
            <Icon name="trending-up" class="w-6 h-6 text-blue-600 dark:text-blue-400" />
          </div>
          <div class="flex-1">
            <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">
              Tipo Más Activo
            </div>
            <div class="text-2xl font-bold text-gray-900 dark:text-white">
              {{ byType.length > 0 ? typeLabels[byType[0][0]] || byType[0][0] : 'N/A' }}
            </div>
            <div v-if="byType.length > 0" class="text-xs text-gray-600 dark:text-gray-400">
              {{ byType[0][1] }} colaboraciones
            </div>
          </div>
        </div>
      </Card>

      <!-- Most Popular Skill -->
      <Card :loading="loading">
        <div class="flex items-center gap-4">
          <div class="p-3 bg-yellow-100 dark:bg-yellow-900 rounded-lg">
            <Icon name="star" class="w-6 h-6 text-yellow-600 dark:text-yellow-400" />
          </div>
          <div class="flex-1">
            <div class="text-sm text-gray-600 dark:text-gray-400 mb-1">
              Habilidad Más Demandada
            </div>
            <div class="text-2xl font-bold text-gray-900 dark:text-white truncate">
              {{ popularSkills.length > 0 ? popularSkills[0][0] : 'N/A' }}
            </div>
            <div v-if="popularSkills.length > 0" class="text-xs text-gray-600 dark:text-gray-400">
              {{ popularSkills[0][1] }} colaboraciones
            </div>
          </div>
        </div>
      </Card>
    </div>
  </div>
</template>

<style scoped>
.collaboration-stats {
  @apply w-full;
}

.collaboration-stats__card {
  @apply p-6;
}
</style>
