<script setup lang="ts">
import { computed } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Button from '@/components/atoms/Button.vue'
import Badge from '@/components/atoms/Badge.vue'
import Icon from '@/components/atoms/Icon.vue'
import Avatar from '@/components/atoms/Avatar.vue'

export type TeamStatus = 'active' | 'recruiting' | 'full' | 'inactive'
export type ActivityLevel = 'high' | 'medium' | 'low'

export interface TeamLeader {
  id: string
  name: string
  avatar?: string
  role?: string
}

export interface ParticipationTeam {
  id: string
  name: string
  description: string
  leader: TeamLeader
  memberCount: number
  maxMembers?: number
  status: TeamStatus
  activityLevel?: ActivityLevel
  tags?: string[]
  meetingSchedule?: string
  lastActivity?: Date | string
  createdAt?: Date | string
  imageUrl?: string
}

interface Props {
  /** Team data */
  team: ParticipationTeam
  /** Show join button */
  showJoinButton?: boolean
  /** Show leave button */
  showLeaveButton?: boolean
  /** User is member */
  isMember?: boolean
  /** User is leader */
  isLeader?: boolean
  /** Compact mode */
  compact?: boolean
  /** Loading state */
  loading?: boolean
  /** Disabled state */
  disabled?: boolean
}

interface Emits {
  (e: 'join', teamId: string): void
  (e: 'leave', teamId: string): void
  (e: 'view-details', teamId: string): void
  (e: 'contact-leader', leaderId: string): void
}

const props = withDefaults(defineProps<Props>(), {
  showJoinButton: true,
  showLeaveButton: true,
  isMember: false,
  isLeader: false,
  compact: false,
  loading: false,
  disabled: false,
})

const emit = defineEmits<Emits>()

// Status configuration
const statusConfig = {
  active: {
    label: 'Activo',
    color: 'green',
    icon: 'check-circle',
  },
  recruiting: {
    label: 'Reclutando',
    color: 'blue',
    icon: 'users',
  },
  full: {
    label: 'Completo',
    color: 'yellow',
    icon: 'alert-circle',
  },
  inactive: {
    label: 'Inactivo',
    color: 'gray',
    icon: 'x-circle',
  },
}

// Activity level configuration
const activityLevelConfig = {
  high: {
    label: 'Alta Actividad',
    color: 'green',
    icon: 'trending-up',
  },
  medium: {
    label: 'Actividad Media',
    color: 'yellow',
    icon: 'activity',
  },
  low: {
    label: 'Baja Actividad',
    color: 'orange',
    icon: 'trending-down',
  },
}

// Current status info
const currentStatus = computed(() => statusConfig[props.team.status])

// Current activity level info
const currentActivityLevel = computed(() => {
  if (!props.team.activityLevel) return null
  return activityLevelConfig[props.team.activityLevel]
})

// Check if team is full
const isFull = computed(() => {
  if (!props.team.maxMembers) return false
  return props.team.memberCount >= props.team.maxMembers
})

// Calculate occupancy percentage
const occupancyPercentage = computed(() => {
  if (!props.team.maxMembers) return 0
  return Math.round((props.team.memberCount / props.team.maxMembers) * 100)
})

// Can join
const canJoin = computed(() => {
  return (
    !props.isMember &&
    !props.disabled &&
    props.team.status !== 'inactive' &&
    !isFull.value
  )
})

// Format date
const formatDate = (date: Date | string): string => {
  return new Intl.DateTimeFormat('es-ES', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(new Date(date))
}

// Format relative time
const formatRelativeTime = (date: Date | string): string => {
  const now = new Date()
  const past = new Date(date)
  const diffMs = now.getTime() - past.getTime()
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))

  if (diffDays === 0) return 'Hoy'
  if (diffDays === 1) return 'Ayer'
  if (diffDays < 7) return `Hace ${diffDays} días`
  if (diffDays < 30) return `Hace ${Math.floor(diffDays / 7)} semanas`
  return formatDate(date)
}

// Handlers
const handleJoin = () => {
  if (canJoin.value) {
    emit('join', props.team.id)
  }
}

const handleLeave = () => {
  emit('leave', props.team.id)
}

const handleViewDetails = () => {
  emit('view-details', props.team.id)
}

const handleContactLeader = () => {
  emit('contact-leader', props.team.leader.id)
}
</script>

<template>
  <Card :loading="loading" class="participation-team-card">
    <!-- Header with Image (optional) -->
    <div v-if="team.imageUrl && !compact" class="participation-team-card__image">
      <img :src="team.imageUrl" :alt="team.name" class="w-full h-48 object-cover" />
    </div>

    <!-- Content -->
    <div class="participation-team-card__content">
      <!-- Header -->
      <div class="flex items-start justify-between mb-3">
        <div class="flex-1 min-w-0">
          <div class="flex items-center gap-2 mb-2">
            <h3 class="text-lg font-bold truncate">{{ team.name }}</h3>
            <Badge v-if="isLeader" variant="secondary" size="sm">
              <Icon name="star" class="w-3 h-3 mr-1" />
              Líder
            </Badge>
            <Badge v-else-if="isMember" variant="info" size="sm">
              <Icon name="check" class="w-3 h-3 mr-1" />
              Miembro
            </Badge>
          </div>
          <p v-if="!compact" class="text-sm text-gray-600 dark:text-gray-400 line-clamp-2">
            {{ team.description }}
          </p>
        </div>
        <Badge :variant="currentStatus.color as any" size="sm" class="ml-2 flex-shrink-0">
          <Icon :name="currentStatus.icon" class="w-3 h-3 mr-1" />
          {{ currentStatus.label }}
        </Badge>
      </div>

      <!-- Team Leader -->
      <div class="flex items-center justify-between mb-4">
        <div class="flex items-center gap-2">
          <Avatar
            :name="team.leader.name"
            :src="team.leader.avatar"
            size="sm"
          />
          <div>
            <p class="text-xs font-medium text-gray-700 dark:text-gray-300">
              {{ team.leader.name }}
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400">
              {{ team.leader.role || 'Coordinador' }}
            </p>
          </div>
        </div>
        <Button
          v-if="!isLeader"
          variant="ghost"
          size="sm"
          @click="handleContactLeader"
        >
          <Icon name="mail" class="w-4 h-4" />
        </Button>
      </div>

      <!-- Members Info -->
      <div class="mb-4">
        <div class="flex items-center justify-between mb-2">
          <div class="flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
            <Icon name="users" class="w-4 h-4" />
            <span>
              {{ team.memberCount }}{{ team.maxMembers ? ` / ${team.maxMembers}` : '' }} miembros
            </span>
          </div>
          <span v-if="team.maxMembers" class="text-xs text-gray-500">
            {{ occupancyPercentage }}%
          </span>
        </div>
        <div
          v-if="team.maxMembers"
          class="h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden"
        >
          <div
            class="h-full bg-gradient-to-r from-blue-500 to-indigo-600 transition-all duration-300"
            :style="{ width: `${occupancyPercentage}%` }"
          ></div>
        </div>
      </div>

      <!-- Activity Level -->
      <div v-if="currentActivityLevel && !compact" class="mb-4">
        <div class="flex items-center gap-2 text-xs text-gray-600 dark:text-gray-400">
          <Icon :name="currentActivityLevel.icon" class="w-3 h-3" />
          <span>{{ currentActivityLevel.label }}</span>
        </div>
      </div>

      <!-- Meeting Schedule -->
      <div v-if="team.meetingSchedule && !compact" class="mb-4">
        <div class="flex items-center gap-2 text-xs text-gray-600 dark:text-gray-400">
          <Icon name="calendar" class="w-3 h-3" />
          <span>{{ team.meetingSchedule }}</span>
        </div>
      </div>

      <!-- Tags -->
      <div v-if="team.tags && team.tags.length > 0 && !compact" class="mb-4">
        <div class="flex flex-wrap gap-2">
          <Badge
            v-for="tag in team.tags.slice(0, 3)"
            :key="tag"
            variant="neutral"
            size="sm"
          >
            {{ tag }}
          </Badge>
          <Badge v-if="team.tags.length > 3" variant="neutral" size="sm">
            +{{ team.tags.length - 3 }}
          </Badge>
        </div>
      </div>

      <!-- Last Activity -->
      <div v-if="team.lastActivity && !compact" class="mb-4">
        <div class="text-xs text-gray-500 dark:text-gray-400">
          Última actividad: {{ formatRelativeTime(team.lastActivity) }}
        </div>
      </div>

      <!-- Actions -->
      <div class="flex items-center gap-2">
        <Button
          v-if="isMember && showLeaveButton"
          variant="outline"
          size="sm"
          :disabled="disabled || isLeader"
          @click="handleLeave"
          class="flex-1"
        >
          <Icon name="log-out" class="w-4 h-4 mr-2" />
          Salir del Equipo
        </Button>
        <Button
          v-else-if="!isMember && showJoinButton"
          variant="primary"
          size="sm"
          :disabled="!canJoin"
          @click="handleJoin"
          class="flex-1"
        >
          <Icon name="user-plus" class="w-4 h-4 mr-2" />
          {{ isFull ? 'Equipo Lleno' : 'Unirme' }}
        </Button>
        <Button
          variant="outline"
          size="sm"
          :disabled="disabled"
          @click="handleViewDetails"
          :class="isMember || !showJoinButton ? 'flex-1' : ''"
        >
          <Icon name="eye" class="w-4 h-4 mr-2" />
          Ver Detalles
        </Button>
      </div>
    </div>

    <!-- Full Banner -->
    <div
      v-if="isFull && !isMember"
      class="participation-team-card__banner participation-team-card__banner--full"
    >
      <Icon name="alert-circle" class="w-4 h-4" />
      <span class="text-sm font-medium">Este equipo está completo</span>
    </div>

    <!-- Inactive Banner -->
    <div
      v-if="team.status === 'inactive'"
      class="participation-team-card__banner participation-team-card__banner--inactive"
    >
      <Icon name="info" class="w-4 h-4" />
      <span class="text-sm font-medium">Este equipo está inactivo</span>
    </div>
  </Card>
</template>

<style scoped>
.participation-team-card {
  @apply w-full overflow-hidden;
}

.participation-team-card__image {
  @apply relative overflow-hidden;
}

.participation-team-card__content {
  @apply p-6;
}

.participation-team-card__banner {
  @apply flex items-center justify-center gap-2 py-3 px-4 border-t;
}

.participation-team-card__banner--full {
  @apply bg-yellow-50 dark:bg-yellow-900 border-yellow-200 dark:border-yellow-800 text-yellow-800 dark:text-yellow-200;
}

.participation-team-card__banner--inactive {
  @apply bg-gray-50 dark:bg-gray-800 border-gray-200 dark:border-gray-700 text-gray-600 dark:text-gray-400;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
