<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { usePagination } from '@/composables/usePagination'
import { useDebounce } from '@/composables/useDebounce'
import Card from '@/components/molecules/Card.vue'
import Input from '@/components/atoms/Input.vue'
import Select from '@/components/atoms/Select.vue'
import Button from '@/components/atoms/Button.vue'
import Icon from '@/components/atoms/Icon.vue'
import Pagination from '@/components/molecules/Pagination.vue'
import ImpulsaProjectCard from './ImpulsaProjectCard.vue'
import type { ImpulsaProject, ProjectStatus, ProjectCategory } from './ImpulsaProjectCard.vue'

export type SortOption = 'recent' | 'votes' | 'funding' | 'title'
export type FundingFilter = 'all' | 'low' | 'medium' | 'high'

interface Props {
  /** List of projects */
  projects: ImpulsaProject[]
  /** Loading state */
  loading?: boolean
  /** Compact card display */
  compact?: boolean
  /** Show filters */
  showFilters?: boolean
  /** Show search */
  showSearch?: boolean
  /** Show sort */
  showSort?: boolean
  /** Enable pagination */
  pagination?: boolean
  /** Items per page */
  perPage?: number
  /** Total items (for server-side pagination) */
  total?: number
  /** Current page (for server-side pagination) */
  currentPage?: number
  /** User authentication status */
  isAuthenticated?: boolean
}

interface Emits {
  (e: 'filter-change', filters: FilterState): void
  (e: 'sort-change', sort: SortOption): void
  (e: 'search-change', query: string): void
  (e: 'page-change', page: number): void
  (e: 'project-click', project: ImpulsaProject): void
  (e: 'vote', project: ImpulsaProject): void
  (e: 'login-required'): void
}

interface FilterState {
  status: ProjectStatus | 'all'
  category: ProjectCategory | 'all'
  funding: FundingFilter
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  compact: false,
  showFilters: true,
  showSearch: true,
  showSort: true,
  pagination: true,
  perPage: 12,
  isAuthenticated: false,
})

const emit = defineEmits<Emits>()

// Search
const searchQuery = ref('')
const debouncedSearch = useDebounce(searchQuery, 300)

// Filters
const filters = ref<FilterState>({
  status: 'all',
  category: 'all',
  funding: 'all',
})

// Sort
const sortBy = ref<SortOption>('recent')

// Status filter options
const statusOptions = [
  { value: 'all', label: 'Todos los Estados' },
  { value: 'draft', label: 'Borrador' },
  { value: 'submitted', label: 'Presentado' },
  { value: 'evaluation', label: 'En Evaluación' },
  { value: 'voting', label: 'En Votación' },
  { value: 'funded', label: 'Financiado' },
  { value: 'rejected', label: 'No Financiado' },
  { value: 'completed', label: 'Completado' },
]

// Category filter options
const categoryOptions = [
  { value: 'all', label: 'Todas las Categorías' },
  { value: 'social', label: 'Social' },
  { value: 'technology', label: 'Tecnología' },
  { value: 'culture', label: 'Cultura' },
  { value: 'education', label: 'Educación' },
  { value: 'environment', label: 'Medio Ambiente' },
  { value: 'health', label: 'Salud' },
  { value: 'other', label: 'Otro' },
]

// Funding filter options
const fundingOptions = [
  { value: 'all', label: 'Todos los Montos' },
  { value: 'low', label: 'Hasta 25.000€' },
  { value: 'medium', label: '25.000€ - 100.000€' },
  { value: 'high', label: 'Más de 100.000€' },
]

// Sort options
const sortOptions = [
  { value: 'recent', label: 'Más Recientes' },
  { value: 'votes', label: 'Más Votados' },
  { value: 'funding', label: 'Mayor Financiación' },
  { value: 'title', label: 'Alfabético' },
]

// Filter projects
const filteredProjects = computed(() => {
  let result = [...props.projects]

  // Search filter
  if (debouncedSearch.value) {
    const query = debouncedSearch.value.toLowerCase()
    result = result.filter(project =>
      project.title.toLowerCase().includes(query) ||
      project.description.toLowerCase().includes(query) ||
      project.author.toLowerCase().includes(query)
    )
  }

  // Status filter
  if (filters.value.status !== 'all') {
    result = result.filter(project => project.status === filters.value.status)
  }

  // Category filter
  if (filters.value.category !== 'all') {
    result = result.filter(project => project.category === filters.value.category)
  }

  // Funding filter
  if (filters.value.funding !== 'all') {
    result = result.filter(project => {
      const goal = project.fundingGoal
      if (filters.value.funding === 'low') return goal <= 25000
      if (filters.value.funding === 'medium') return goal > 25000 && goal <= 100000
      if (filters.value.funding === 'high') return goal > 100000
      return true
    })
  }

  return result
})

// Sort projects
const sortedProjects = computed(() => {
  const result = [...filteredProjects.value]

  switch (sortBy.value) {
    case 'recent':
      return result.sort((a, b) => {
        const dateA = new Date(a.createdAt).getTime()
        const dateB = new Date(b.createdAt).getTime()
        return dateB - dateA
      })
    case 'votes':
      return result.sort((a, b) => (b.votes || 0) - (a.votes || 0))
    case 'funding':
      return result.sort((a, b) => b.fundingGoal - a.fundingGoal)
    case 'title':
      return result.sort((a, b) => a.title.localeCompare(b.title))
    default:
      return result
  }
})

// Pagination
const {
  paginatedItems: paginatedProjects,
  currentPage,
  totalPages,
  goToPage,
} = usePagination(sortedProjects, props.perPage)

// Use external pagination if provided
const effectiveCurrentPage = computed(() => props.currentPage || currentPage.value)
const effectiveTotalPages = computed(() => {
  if (props.total !== undefined) {
    return Math.ceil(props.total / props.perPage)
  }
  return totalPages.value
})

// Display projects
const displayProjects = computed(() => {
  if (props.total !== undefined) {
    // Server-side pagination
    return sortedProjects.value
  }
  // Client-side pagination
  return paginatedProjects.value
})

// Watch for filter changes
watch(filters, (newFilters) => {
  emit('filter-change', newFilters)
  if (props.pagination) {
    handlePageChange(1)
  }
}, { deep: true })

// Watch for sort changes
watch(sortBy, (newSort) => {
  emit('sort-change', newSort)
  if (props.pagination) {
    handlePageChange(1)
  }
})

// Watch for search changes
watch(debouncedSearch, (query) => {
  emit('search-change', query)
  if (props.pagination) {
    handlePageChange(1)
  }
})

// Clear filters
const clearFilters = () => {
  filters.value = {
    status: 'all',
    category: 'all',
    funding: 'all',
  }
  searchQuery.value = ''
  sortBy.value = 'recent'
}

// Has active filters
const hasActiveFilters = computed(() => {
  return (
    filters.value.status !== 'all' ||
    filters.value.category !== 'all' ||
    filters.value.funding !== 'all' ||
    searchQuery.value !== ''
  )
})

// Handlers
const handlePageChange = (page: number) => {
  if (props.total !== undefined) {
    emit('page-change', page)
  } else {
    goToPage(page)
  }
}

const handleProjectClick = (project: ImpulsaProject) => {
  emit('project-click', project)
}

const handleVote = (project: ImpulsaProject) => {
  emit('vote', project)
}

const handleLoginRequired = () => {
  emit('login-required')
}

// Results count
const resultsCount = computed(() => {
  if (props.total !== undefined) {
    return props.total
  }
  return filteredProjects.value.length
})
</script>

<template>
  <div class="impulsa-projects-list">
    <!-- Search and Filters -->
    <Card v-if="showSearch || showFilters || showSort" class="mb-6">
      <!-- Search -->
      <div v-if="showSearch" class="mb-4">
        <Input
          v-model="searchQuery"
          placeholder="Buscar proyectos..."
          type="search"
          :disabled="loading"
        >
          <template #prefix>
            <Icon name="search" class="w-4 h-4 text-gray-400" />
          </template>
        </Input>
      </div>

      <!-- Filters and Sort -->
      <div v-if="showFilters || showSort" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <!-- Status Filter -->
        <Select
          v-if="showFilters"
          v-model="filters.status"
          :options="statusOptions"
          :disabled="loading"
        />

        <!-- Category Filter -->
        <Select
          v-if="showFilters"
          v-model="filters.category"
          :options="categoryOptions"
          :disabled="loading"
        />

        <!-- Funding Filter -->
        <Select
          v-if="showFilters"
          v-model="filters.funding"
          :options="fundingOptions"
          :disabled="loading"
        />

        <!-- Sort -->
        <Select
          v-if="showSort"
          v-model="sortBy"
          :options="sortOptions"
          :disabled="loading"
        />
      </div>

      <!-- Clear Filters -->
      <div v-if="hasActiveFilters" class="mt-4 flex items-center justify-between">
        <p class="text-sm text-gray-600 dark:text-gray-400">
          {{ resultsCount }} {{ resultsCount === 1 ? 'proyecto encontrado' : 'proyectos encontrados' }}
        </p>
        <Button
          variant="ghost"
          size="sm"
          @click="clearFilters"
          :disabled="loading"
        >
          <Icon name="x" class="w-4 h-4 mr-1" />
          Limpiar Filtros
        </Button>
      </div>
    </Card>

    <!-- Loading State -->
    <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <Card v-for="i in perPage" :key="i" :loading="true" class="h-64" />
    </div>

    <!-- Empty State -->
    <div
      v-else-if="displayProjects.length === 0"
      class="impulsa-projects-list__empty"
    >
      <Icon name="folder-open" class="w-16 h-16 text-gray-300 dark:text-gray-700 mb-4" />
      <h3 class="text-lg font-semibold text-gray-700 dark:text-gray-300 mb-2">
        {{ hasActiveFilters ? 'No se encontraron proyectos' : 'No hay proyectos disponibles' }}
      </h3>
      <p class="text-sm text-gray-500 dark:text-gray-400 mb-4">
        {{ hasActiveFilters ? 'Intenta ajustar los filtros de búsqueda' : 'Los proyectos aparecerán aquí cuando estén disponibles' }}
      </p>
      <Button
        v-if="hasActiveFilters"
        variant="outline"
        @click="clearFilters"
      >
        Limpiar Filtros
      </Button>
    </div>

    <!-- Projects Grid -->
    <div
      v-else
      :class="[
        'impulsa-projects-list__grid',
        compact ? 'grid-cols-1 md:grid-cols-2 gap-4' : 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6',
      ]"
    >
      <ImpulsaProjectCard
        v-for="project in displayProjects"
        :key="project.id"
        :project="project"
        :compact="compact"
        :is-authenticated="isAuthenticated"
        @click="handleProjectClick(project)"
        @vote="handleVote(project)"
        @login-required="handleLoginRequired"
      />
    </div>

    <!-- Pagination -->
    <div v-if="pagination && effectiveTotalPages > 1" class="mt-8 flex justify-center">
      <Pagination
        :current-page="effectiveCurrentPage"
        :total-pages="effectiveTotalPages"
        @change="handlePageChange"
      />
    </div>
  </div>
</template>

<style scoped>
.impulsa-projects-list {
  @apply w-full;
}

.impulsa-projects-list__grid {
  @apply grid;
}

.impulsa-projects-list__empty {
  @apply flex flex-col items-center justify-center py-16 text-center;
}
</style>
