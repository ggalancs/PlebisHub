<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import ProposalCard from './ProposalCard.vue'
import type { Proposal } from './ProposalCard.vue'
import SearchBar from '@/components/molecules/SearchBar.vue'
import Dropdown from '@/components/molecules/Dropdown.vue'
import Pagination from '@/components/molecules/Pagination.vue'
import EmptyState from '@/components/molecules/EmptyState.vue'
import Spinner from '@/components/atoms/Spinner.vue'
import { usePagination, useDebounce } from '@/composables'

export type SortOption = 'recent' | 'popular' | 'hot' | 'time'
export type FilterOption = 'all' | 'active' | 'finished' | 'threshold' | 'discarded'

interface Props {
  /** List of proposals */
  proposals: Proposal[]
  /** Loading state */
  loading?: boolean
  /** Current page for server-side pagination */
  currentPage?: number
  /** Total number of proposals for server-side pagination */
  total?: number
  /** Page size */
  pageSize?: number
  /** Enable search */
  searchable?: boolean
  /** Enable filters */
  filterable?: boolean
  /** Enable sorting */
  sortable?: boolean
  /** Show pagination */
  showPagination?: boolean
  /** Client-side or server-side pagination */
  paginationType?: 'client' | 'server'
  /** User is authenticated */
  isAuthenticated?: boolean
  /** Empty state message */
  emptyMessage?: string
  /** Empty state description */
  emptyDescription?: string
}

interface Emits {
  (e: 'support', proposalId: number | string): void
  (e: 'view', proposalId: number | string): void
  (e: 'page-change', page: number): void
  (e: 'search', query: string): void
  (e: 'filter', filter: FilterOption): void
  (e: 'sort', sort: SortOption): void
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  currentPage: 1,
  total: 0,
  pageSize: 10,
  searchable: true,
  filterable: true,
  sortable: true,
  showPagination: true,
  paginationType: 'client',
  isAuthenticated: false,
  emptyMessage: 'No hay propuestas',
  emptyDescription: 'No se encontraron propuestas que coincidan con los criterios de búsqueda.',
})

const emit = defineEmits<Emits>()

// Local state
const searchQuery = ref('')
const selectedFilter = ref<FilterOption>('all')
const selectedSort = ref<SortOption>('recent')
const supportingProposalId = ref<number | string | null>(null)

// Debounced search
const debouncedSearch = useDebounce(searchQuery, 300)

// Watch for debounced search changes
watch(debouncedSearch, (value) => {
  emit('search', value)
  if (props.paginationType === 'client') {
    pagination.currentPage.value = 1
  }
})

// Filter options
const filterOptions = [
  { value: 'all', label: 'Todas' },
  { value: 'active', label: 'Activas' },
  { value: 'threshold', label: 'Umbral alcanzado' },
  { value: 'finished', label: 'Finalizadas' },
  { value: 'discarded', label: 'Descartadas' },
]

// Sort options
const sortOptions = [
  { value: 'recent', label: 'Más recientes' },
  { value: 'popular', label: 'Más populares' },
  { value: 'hot', label: 'Más candentes' },
  { value: 'time', label: 'Más antiguas' },
]

// Filtered proposals
const filteredProposals = computed(() => {
  let result = [...props.proposals]

  // Client-side search
  if (props.paginationType === 'client' && debouncedSearch.value) {
    const query = debouncedSearch.value.toLowerCase()
    result = result.filter(
      (p) =>
        p.title.toLowerCase().includes(query) ||
        p.description.toLowerCase().includes(query)
    )
  }

  // Client-side filter
  if (props.paginationType === 'client') {
    switch (selectedFilter.value) {
      case 'active':
        result = result.filter((p) => !p.finished && !p.discarded)
        break
      case 'finished':
        result = result.filter((p) => p.finished)
        break
      case 'threshold':
        result = result.filter((p) => p.redditThreshold && !p.finished)
        break
      case 'discarded':
        result = result.filter((p) => p.discarded)
        break
    }
  }

  // Client-side sort
  if (props.paginationType === 'client') {
    switch (selectedSort.value) {
      case 'recent':
        result.sort((a, b) => {
          const dateA = typeof a.createdAt === 'string' ? new Date(a.createdAt) : a.createdAt
          const dateB = typeof b.createdAt === 'string' ? new Date(b.createdAt) : b.createdAt
          return dateB.getTime() - dateA.getTime()
        })
        break
      case 'popular':
        result.sort((a, b) => b.supportsCount - a.supportsCount)
        break
      case 'hot':
        result.sort((a, b) => b.hotness - a.hotness)
        break
      case 'time':
        result.sort((a, b) => {
          const dateA = typeof a.createdAt === 'string' ? new Date(a.createdAt) : a.createdAt
          const dateB = typeof b.createdAt === 'string' ? new Date(b.createdAt) : b.createdAt
          return dateA.getTime() - dateB.getTime()
        })
        break
    }
  }

  return result
})

// Pagination setup
const totalItems = computed(() => {
  return props.paginationType === 'server' ? props.total : filteredProposals.value.length
})

const pagination = usePagination({
  total: totalItems.value,
  pageSize: props.pageSize,
  currentPage: props.currentPage,
})

// Watch for prop changes
watch(() => props.total, (newTotal) => {
  pagination.total.value = newTotal
})

watch(() => props.currentPage, (newPage) => {
  pagination.currentPage.value = newPage
})

watch(() => filteredProposals.value.length, (newLength) => {
  if (props.paginationType === 'client') {
    pagination.total.value = newLength
  }
})

// Paginated proposals
const paginatedProposals = computed(() => {
  if (props.paginationType === 'server') {
    return filteredProposals.value
  }
  return pagination.paginateArray(filteredProposals.value)
})

// Handle filter change
const handleFilterChange = (filter: string) => {
  selectedFilter.value = filter as FilterOption
  emit('filter', filter as FilterOption)
  if (props.paginationType === 'client') {
    pagination.currentPage.value = 1
  }
}

// Handle sort change
const handleSortChange = (sort: string) => {
  selectedSort.value = sort as SortOption
  emit('sort', sort as SortOption)
  if (props.paginationType === 'client') {
    pagination.currentPage.value = 1
  }
}

// Handle page change
const handlePageChange = (page: number) => {
  pagination.goToPage(page)
  emit('page-change', page)

  // Scroll to top of list
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// Handle support
const handleSupport = async (proposalId: number | string) => {
  supportingProposalId.value = proposalId
  emit('support', proposalId)

  // Reset after a delay (parent should handle the actual state update)
  setTimeout(() => {
    supportingProposalId.value = null
  }, 1000)
}

// Handle view
const handleView = (proposalId: number | string) => {
  emit('view', proposalId)
}

// Show empty state
const showEmptyState = computed(() => {
  return !props.loading && paginatedProposals.value.length === 0
})
</script>

<template>
  <div class="proposals-list">
    <!-- Search and Filters Bar -->
    <div v-if="searchable || filterable || sortable" class="mb-6 space-y-4">
      <!-- Search -->
      <SearchBar
        v-if="searchable"
        v-model="searchQuery"
        placeholder="Buscar propuestas..."
        :disabled="loading"
      />

      <!-- Filters and Sort -->
      <div v-if="filterable || sortable" class="flex flex-col sm:flex-row gap-4">
        <!-- Filter -->
        <Dropdown
          v-if="filterable"
          :options="filterOptions"
          :model-value="selectedFilter"
          placeholder="Filtrar por estado"
          :disabled="loading"
          class="flex-1"
          @update:model-value="handleFilterChange"
        />

        <!-- Sort -->
        <Dropdown
          v-if="sortable"
          :options="sortOptions"
          :model-value="selectedSort"
          placeholder="Ordenar por"
          :disabled="loading"
          class="flex-1"
          @update:model-value="handleSortChange"
        />
      </div>
    </div>

    <!-- Results Count -->
    <div v-if="!loading && paginatedProposals.length > 0" class="mb-4">
      <p class="text-sm text-gray-600 dark:text-gray-400">
        Mostrando {{ pagination.startIndex.value + 1 }}-{{ pagination.endIndex.value }}
        de {{ totalItems }} propuestas
      </p>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="flex justify-center items-center py-12">
      <Spinner size="lg" />
    </div>

    <!-- Empty State -->
    <EmptyState
      v-else-if="showEmptyState"
      :title="emptyMessage"
      :description="emptyDescription"
      icon="search"
    >
      <template #actions>
        <button
          v-if="searchQuery || selectedFilter !== 'all'"
          class="px-4 py-2 text-sm font-medium text-primary border border-primary rounded-lg hover:bg-primary hover:text-white transition-colors"
          @click="() => { searchQuery = ''; selectedFilter = 'all' }"
        >
          Limpiar filtros
        </button>
      </template>
    </EmptyState>

    <!-- Proposals Grid -->
    <div
      v-else
      class="grid grid-cols-1 gap-6"
      :class="{
        'opacity-50 pointer-events-none': loading,
      }"
    >
      <ProposalCard
        v-for="proposal in paginatedProposals"
        :key="proposal.id"
        :proposal="proposal"
        :is-authenticated="isAuthenticated"
        :loading-support="supportingProposalId === proposal.id"
        @support="handleSupport"
        @view="handleView"
      />
    </div>

    <!-- Pagination -->
    <div v-if="showPagination && pagination.isPaginationNeeded.value && !loading" class="mt-8">
      <Pagination
        :current-page="pagination.currentPage.value"
        :total-pages="pagination.totalPages.value"
        @page-change="handlePageChange"
        @prev="pagination.prevPage"
        @next="pagination.nextPage"
      />
    </div>
  </div>
</template>

<style scoped>
.proposals-list {
  /* Container styles */
}
</style>
