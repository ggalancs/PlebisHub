<script setup lang="ts">
import { computed } from 'vue'
import Button from '@/components/atoms/Button.vue'
import Badge from '@/components/molecules/Badge.vue'
import ProgressBar from '@/components/molecules/ProgressBar.vue'

export interface Proposal {
  id: number | string
  title: string
  description: string
  votes: number
  supportsCount: number
  hotness: number
  createdAt: Date | string
  finishesAt: Date | string
  redditThreshold: boolean
  supported: boolean
  finished: boolean
  discarded: boolean
}

interface Props {
  proposal: Proposal
  /** Show detailed view */
  detailed?: boolean
  /** Show support button */
  showSupportButton?: boolean
  /** Loading state for support action */
  loadingSupport?: boolean
  /** User is authenticated */
  isAuthenticated?: boolean
}

interface Emits {
  (e: 'support', proposalId: number | string): void
  (e: 'view', proposalId: number | string): void
}

const props = withDefaults(defineProps<Props>(), {
  detailed: false,
  showSupportButton: true,
  loadingSupport: false,
  isAuthenticated: false,
})

const emit = defineEmits<Emits>()

// Format date
const formatDate = (date: Date | string): string => {
  const d = typeof date === 'string' ? new Date(date) : date
  return d.toLocaleDateString('es-ES', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

// Calculate days remaining
const daysRemaining = computed(() => {
  const finishDate = typeof props.proposal.finishesAt === 'string'
    ? new Date(props.proposal.finishesAt)
    : props.proposal.finishesAt
  const now = new Date()
  const diff = finishDate.getTime() - now.getTime()
  const days = Math.ceil(diff / (1000 * 60 * 60 * 24))
  return Math.max(0, days)
})

// Status badge variant
const statusVariant = computed(() => {
  if (props.proposal.discarded) return 'danger'
  if (props.proposal.finished) return 'default'
  if (props.proposal.redditThreshold) return 'success'
  return 'info'
})

// Status text
const statusText = computed(() => {
  if (props.proposal.discarded) return 'Descartada'
  if (props.proposal.finished) return 'Finalizada'
  if (props.proposal.redditThreshold) return 'Umbral alcanzado'
  return 'Activa'
})

// Support progress percentage
const supportProgress = computed(() => {
  // Assuming 100 supports as threshold (configurable)
  const threshold = 100
  return Math.min((props.proposal.supportsCount / threshold) * 100, 100)
})

// Handle support click
const handleSupport = () => {
  if (!props.loadingSupport) {
    emit('support', props.proposal.id)
  }
}

// Handle view click
const handleView = () => {
  emit('view', props.proposal.id)
}

// Truncate description for card view
const truncatedDescription = computed(() => {
  if (props.detailed) return props.proposal.description
  const maxLength = 150
  if (props.proposal.description.length <= maxLength) return props.proposal.description
  return props.proposal.description.substring(0, maxLength) + '...'
})
</script>

<template>
  <article
    class="proposal-card bg-white dark:bg-gray-800 rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200 overflow-hidden"
    :class="{
      'opacity-60': proposal.finished || proposal.discarded,
    }"
  >
    <!-- Card Header -->
    <div class="p-6">
      <!-- Status and Date -->
      <div class="flex items-center justify-between mb-3">
        <Badge :variant="statusVariant" size="sm">
          {{ statusText }}
        </Badge>
        <span class="text-sm text-gray-500 dark:text-gray-400">
          {{ formatDate(proposal.createdAt) }}
        </span>
      </div>

      <!-- Title -->
      <h3
        class="text-xl font-bold text-gray-900 dark:text-gray-100 mb-3 hover:text-primary cursor-pointer"
        @click="handleView"
      >
        {{ proposal.title }}
      </h3>

      <!-- Description -->
      <p class="text-gray-700 dark:text-gray-300 mb-4 leading-relaxed">
        {{ truncatedDescription }}
      </p>

      <!-- Support Progress -->
      <div class="mb-4">
        <div class="flex items-center justify-between mb-2">
          <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
            {{ proposal.supportsCount }} apoyos
          </span>
          <span v-if="!proposal.finished" class="text-sm text-gray-500 dark:text-gray-400">
            {{ daysRemaining }} días restantes
          </span>
        </div>
        <ProgressBar
          :value="supportProgress"
          :color="proposal.redditThreshold ? 'success' : 'primary'"
          size="sm"
        />
      </div>

      <!-- Stats Row -->
      <div class="flex items-center gap-6 text-sm text-gray-600 dark:text-gray-400 mb-4">
        <div class="flex items-center gap-2">
          <svg
            class="w-5 h-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21h-4.017c-.163 0-.326-.02-.485-.06L7 20m7-10V5a2 2 0 00-2-2h-.095c-.5 0-.905.405-.905.905 0 .714-.211 1.412-.608 2.006L7 11v9m7-10h-2M7 20H5a2 2 0 01-2-2v-6a2 2 0 012-2h2.5"
            />
          </svg>
          <span>{{ proposal.votes }} votos</span>
        </div>

        <div class="flex items-center gap-2">
          <svg
            class="w-5 h-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"
            />
          </svg>
          <span>{{ proposal.hotness }} hotness</span>
        </div>
      </div>
    </div>

    <!-- Card Footer -->
    <div
      class="px-6 py-4 bg-gray-50 dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700 flex items-center justify-between gap-4"
    >
      <Button
        variant="outline"
        size="sm"
        @click="handleView"
      >
        Ver detalles
      </Button>

      <Button
        v-if="showSupportButton && !proposal.finished && !proposal.discarded"
        :variant="proposal.supported ? 'secondary' : 'primary'"
        size="sm"
        :disabled="!isAuthenticated || proposal.supported || loadingSupport"
        :loading="loadingSupport"
        @click="handleSupport"
      >
        <template v-if="proposal.supported">
          <svg
            class="w-4 h-4 mr-1"
            fill="currentColor"
            viewBox="0 0 20 20"
          >
            <path
              fill-rule="evenodd"
              d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
              clip-rule="evenodd"
            />
          </svg>
          Apoyada
        </template>
        <template v-else>
          Apoyar propuesta
        </template>
      </Button>

      <span
        v-else-if="!isAuthenticated && showSupportButton"
        class="text-sm text-gray-500 dark:text-gray-400"
      >
        Inicia sesión para apoyar
      </span>
    </div>
  </article>
</template>

<style scoped>
.proposal-card {
  transition: all 0.3s ease;
}

.proposal-card:hover {
  transform: translateY(-2px);
}
</style>
