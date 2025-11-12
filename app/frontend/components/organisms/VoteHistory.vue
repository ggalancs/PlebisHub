<script setup lang="ts">
import { computed } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Badge from '@/components/atoms/Badge.vue'
import Icon from '@/components/atoms/Icon.vue'
import EmptyState from '@/components/molecules/EmptyState.vue'
import { usePagination } from '@/composables'

export interface VoteHistoryItem {
  id: number | string
  itemTitle: string
  itemType: 'proposal' | 'comment' | 'post' | 'other'
  voteType: 'up' | 'down'
  votedAt: Date | string
  itemUrl?: string
}

interface Props {
  /** Vote history items */
  history: VoteHistoryItem[]
  /** Loading state */
  loading?: boolean
  /** Show pagination */
  showPagination?: boolean
  /** Items per page */
  pageSize?: number
  /** Empty message */
  emptyMessage?: string
}

interface Emits {
  (e: 'item-click', item: VoteHistoryItem): void
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  showPagination: true,
  pageSize: 10,
  emptyMessage: 'No tienes historial de votos',
})

const emit = defineEmits<Emits>()

// Pagination
const pagination = usePagination({
  total: props.history.length,
  pageSize: props.pageSize,
})

// Paginated history
const paginatedHistory = computed(() => {
  if (!props.showPagination) return props.history
  return pagination.paginateArray(props.history)
})

// Format date
const formatDate = (date: Date | string): string => {
  const d = typeof date === 'string' ? new Date(date) : date
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  const hours = Math.floor(diff / (1000 * 60 * 60))
  const days = Math.floor(hours / 24)

  if (days > 7) {
    return d.toLocaleDateString()
  } else if (days > 0) {
    return `hace ${days} ${days === 1 ? 'día' : 'días'}`
  } else if (hours > 0) {
    return `hace ${hours} ${hours === 1 ? 'hora' : 'horas'}`
  } else {
    return 'hace un momento'
  }
}

// Get item type label
const getItemTypeLabel = (type: string): string => {
  const labels: Record<string, string> = {
    proposal: 'Propuesta',
    comment: 'Comentario',
    post: 'Publicación',
    other: 'Otro',
  }
  return labels[type] || 'Elemento'
}

// Get item type icon
const getItemTypeIcon = (type: string): string => {
  const icons: Record<string, string> = {
    proposal: 'file-text',
    comment: 'message',
    post: 'document',
    other: 'box',
  }
  return icons[type] || 'box'
}

// Handle item click
const handleItemClick = (item: VoteHistoryItem) => {
  emit('item-click', item)
}
</script>

<template>
  <Card :loading="loading" class="vote-history">
    <template #header>
      <h3 class="text-lg font-semibold">Historial de Votos</h3>
    </template>

    <!-- Empty State -->
    <EmptyState
      v-if="!loading && history.length === 0"
      :title="emptyMessage"
      description="Cuando votes por propuestas o comentarios, aparecerán aquí"
      icon="history"
    />

    <!-- History List -->
    <div v-else class="space-y-3">
      <div
        v-for="item in paginatedHistory"
        :key="item.id"
        class="history-item"
        :class="{ 'cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-800': item.itemUrl }"
        @click="handleItemClick(item)"
      >
        <!-- Vote Icon -->
        <div class="history-item__icon">
          <div
            class="w-10 h-10 rounded-full flex items-center justify-center"
            :class="{
              'bg-success/10 text-success': item.voteType === 'up',
              'bg-error/10 text-error': item.voteType === 'down',
            }"
          >
            <Icon
              :name="item.voteType === 'up' ? 'arrow-up' : 'arrow-down'"
              class="w-5 h-5"
            />
          </div>
        </div>

        <!-- Content -->
        <div class="history-item__content flex-1">
          <div class="flex items-start justify-between gap-2">
            <div class="flex-1">
              <h4 class="font-medium text-sm text-gray-900 dark:text-white mb-1">
                {{ item.itemTitle }}
              </h4>
              <div class="flex items-center gap-2 text-xs text-gray-600 dark:text-gray-400">
                <Badge size="sm" variant="default">
                  <template #icon>
                    <Icon :name="getItemTypeIcon(item.itemType)" />
                  </template>
                  {{ getItemTypeLabel(item.itemType) }}
                </Badge>
                <span>{{ formatDate(item.votedAt) }}</span>
              </div>
            </div>

            <!-- Vote Type Badge -->
            <Badge
              :variant="item.voteType === 'up' ? 'success' : 'error'"
              size="sm"
            >
              {{ item.voteType === 'up' ? 'A favor' : 'En contra' }}
            </Badge>
          </div>
        </div>

        <!-- Link Icon -->
        <div v-if="item.itemUrl" class="history-item__link">
          <Icon name="external-link" class="w-4 h-4 text-gray-400" />
        </div>
      </div>
    </div>

    <!-- Pagination -->
    <div
      v-if="showPagination && pagination.isPaginationNeeded.value && !loading"
      class="mt-6 flex items-center justify-between"
    >
      <p class="text-sm text-gray-600 dark:text-gray-400">
        Mostrando {{ pagination.startIndex.value + 1 }}-{{ pagination.endIndex.value }}
        de {{ history.length }}
      </p>
      <div class="flex gap-2">
        <button
          class="px-3 py-1 text-sm border border-gray-300 dark:border-gray-600 rounded hover:bg-gray-50 dark:hover:bg-gray-800 disabled:opacity-50"
          :disabled="!pagination.canGoToPrevPage.value"
          @click="pagination.prevPage"
        >
          Anterior
        </button>
        <button
          class="px-3 py-1 text-sm border border-gray-300 dark:border-gray-600 rounded hover:bg-gray-50 dark:hover:bg-gray-800 disabled:opacity-50"
          :disabled="!pagination.canGoToNextPage.value"
          @click="pagination.nextPage"
        >
          Siguiente
        </button>
      </div>
    </div>
  </Card>
</template>

<style scoped>
.vote-history {
  /* Container styles */
}

.history-item {
  @apply flex items-center gap-4 p-4 border border-gray-200 dark:border-gray-700 rounded-lg transition-colors;
}

.history-item__icon {
  @apply flex-shrink-0;
}

.history-item__content {
  @apply flex-1 min-w-0;
}

.history-item__link {
  @apply flex-shrink-0;
}
</style>
