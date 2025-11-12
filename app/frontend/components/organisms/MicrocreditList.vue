<script setup lang="ts">
import { ref, computed } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Button from '@/components/atoms/Button.vue'
import Input from '@/components/atoms/Input.vue'
import Select from '@/components/atoms/Select.vue'
import Icon from '@/components/atoms/Icon.vue'
import MicrocreditCard from './MicrocreditCard.vue'
import type { Microcredit, MicrocreditStatus, RiskLevel } from './MicrocreditCard.vue'

export type SortBy = 'newest' | 'oldest' | 'amount-high' | 'amount-low' | 'interest-high' | 'interest-low' | 'deadline'

interface Props {
  /** List of microcredits */
  microcredits: Microcredit[]
  /** Loading state */
  loading?: boolean
  /** Show filters */
  showFilters?: boolean
  /** Show search */
  showSearch?: boolean
  /** Show sort */
  showSort?: boolean
  /** Compact card mode */
  compactCards?: boolean
  /** Items per page */
  itemsPerPage?: number
  /** Show pagination */
  showPagination?: boolean
  /** User invested microcredit IDs */
  investedIds?: string[]
}

interface Emits {
  (e: 'invest', microcreditId: string): void
  (e: 'view-details', microcreditId: string): void
  (e: 'contact-borrower', borrowerId: string): void
  (e: 'load-more'): void
}

const props = withDefaults(defineProps<Props>(), {
  loading: false,
  showFilters: true,
  showSearch: true,
  showSort: true,
  compactCards: false,
  itemsPerPage: 10,
  showPagination: true,
  investedIds: () => [],
})

const emit = defineEmits<Emits>()

// Search and filters
const searchQuery = ref('')
const selectedStatus = ref<MicrocreditStatus | 'all'>('all')
const selectedRiskLevel = ref<RiskLevel | 'all'>('all')
const selectedCategory = ref<string>('all')
const sortBy = ref<SortBy>('newest')

// Pagination
const currentPage = ref(1)

// Status options
const statusOptions = [
  { value: 'all', label: 'Todos los Estados' },
  { value: 'pending', label: 'Pendiente' },
  { value: 'funding', label: 'En Financiación' },
  { value: 'funded', label: 'Financiado' },
  { value: 'repaying', label: 'En Repago' },
  { value: 'completed', label: 'Completado' },
  { value: 'defaulted', label: 'Impagado' },
]

// Risk level options
const riskLevelOptions = [
  { value: 'all', label: 'Todos los Niveles' },
  { value: 'low', label: 'Riesgo Bajo' },
  { value: 'medium', label: 'Riesgo Medio' },
  { value: 'high', label: 'Riesgo Alto' },
]

// Category options
const categoryOptions = computed(() => {
  const categories = new Set<string>()
  props.microcredits.forEach(mc => {
    if (mc.category) {
      categories.add(mc.category)
    }
  })
  return [
    { value: 'all', label: 'Todas las Categorías' },
    ...Array.from(categories).sort().map(cat => ({ value: cat, label: cat })),
  ]
})

// Sort options
const sortOptions = [
  { value: 'newest', label: 'Más Recientes' },
  { value: 'oldest', label: 'Más Antiguos' },
  { value: 'amount-high', label: 'Mayor Cantidad' },
  { value: 'amount-low', label: 'Menor Cantidad' },
  { value: 'interest-high', label: 'Mayor Interés' },
  { value: 'interest-low', label: 'Menor Interés' },
  { value: 'deadline', label: 'Próximos a Vencer' },
]

// Filtered microcredits
const filteredMicrocredits = computed(() => {
  let filtered = [...props.microcredits]

  // Search
  if (searchQuery.value.trim()) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(mc =>
      mc.title.toLowerCase().includes(query) ||
      mc.description.toLowerCase().includes(query) ||
      mc.borrower.name.toLowerCase().includes(query) ||
      mc.category?.toLowerCase().includes(query)
    )
  }

  // Status filter
  if (selectedStatus.value !== 'all') {
    filtered = filtered.filter(mc => mc.status === selectedStatus.value)
  }

  // Risk level filter
  if (selectedRiskLevel.value !== 'all') {
    filtered = filtered.filter(mc => mc.riskLevel === selectedRiskLevel.value)
  }

  // Category filter
  if (selectedCategory.value !== 'all') {
    filtered = filtered.filter(mc => mc.category === selectedCategory.value)
  }

  // Sort
  switch (sortBy.value) {
    case 'newest':
      filtered.sort((a, b) => {
        const dateA = a.fundedDate ? new Date(a.fundedDate).getTime() : 0
        const dateB = b.fundedDate ? new Date(b.fundedDate).getTime() : 0
        return dateB - dateA
      })
      break
    case 'oldest':
      filtered.sort((a, b) => {
        const dateA = a.fundedDate ? new Date(a.fundedDate).getTime() : 0
        const dateB = b.fundedDate ? new Date(b.fundedDate).getTime() : 0
        return dateA - dateB
      })
      break
    case 'amount-high':
      filtered.sort((a, b) => b.amountRequested - a.amountRequested)
      break
    case 'amount-low':
      filtered.sort((a, b) => a.amountRequested - b.amountRequested)
      break
    case 'interest-high':
      filtered.sort((a, b) => b.interestRate - a.interestRate)
      break
    case 'interest-low':
      filtered.sort((a, b) => a.interestRate - b.interestRate)
      break
    case 'deadline':
      filtered.sort((a, b) => {
        if (!a.deadline) return 1
        if (!b.deadline) return -1
        return new Date(a.deadline).getTime() - new Date(b.deadline).getTime()
      })
      break
  }

  return filtered
})

// Paginated microcredits
const paginatedMicrocredits = computed(() => {
  if (!props.showPagination) {
    return filteredMicrocredits.value
  }

  const start = (currentPage.value - 1) * props.itemsPerPage
  const end = start + props.itemsPerPage
  return filteredMicrocredits.value.slice(start, end)
})

// Total pages
const totalPages = computed(() => {
  return Math.ceil(filteredMicrocredits.value.length / props.itemsPerPage)
})

// Has filters active
const hasActiveFilters = computed(() => {
  return (
    searchQuery.value.trim() !== '' ||
    selectedStatus.value !== 'all' ||
    selectedRiskLevel.value !== 'all' ||
    selectedCategory.value !== 'all'
  )
})

// Check if user has invested
const hasInvested = (microcreditId: string): boolean => {
  return props.investedIds.includes(microcreditId)
}

// Handlers
const handleInvest = (microcreditId: string) => {
  emit('invest', microcreditId)
}

const handleViewDetails = (microcreditId: string) => {
  emit('view-details', microcreditId)
}

const handleContactBorrower = (borrowerId: string) => {
  emit('contact-borrower', borrowerId)
}

const handleClearFilters = () => {
  searchQuery.value = ''
  selectedStatus.value = 'all'
  selectedRiskLevel.value = 'all'
  selectedCategory.value = 'all'
  currentPage.value = 1
}

const handlePageChange = (page: number) => {
  currentPage.value = page
  // Scroll to top
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const handleLoadMore = () => {
  emit('load-more')
}
</script>

<template>
  <div class="microcredit-list">
    <!-- Header with Search and Filters -->
    <Card v-if="showSearch || showFilters || showSort" class="mb-6">
      <div class="space-y-4">
        <!-- Search -->
        <div v-if="showSearch">
          <Input
            v-model="searchQuery"
            type="text"
            placeholder="Buscar microcréditos..."
            class="w-full"
          >
            <template #prefix>
              <Icon name="search" class="w-4 h-4 text-gray-400" />
            </template>
          </Input>
        </div>

        <!-- Filters Row -->
        <div v-if="showFilters" class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Select
            v-model="selectedStatus"
            :options="statusOptions"
            class="w-full"
          />
          <Select
            v-model="selectedRiskLevel"
            :options="riskLevelOptions"
            class="w-full"
          />
          <Select
            v-model="selectedCategory"
            :options="categoryOptions"
            class="w-full"
          />
        </div>

        <!-- Sort and Clear -->
        <div class="flex items-center justify-between gap-4">
          <Select
            v-if="showSort"
            v-model="sortBy"
            :options="sortOptions"
            class="flex-1"
          />
          <Button
            v-if="hasActiveFilters"
            variant="ghost"
            size="sm"
            @click="handleClearFilters"
          >
            <Icon name="x" class="w-4 h-4 mr-2" />
            Limpiar Filtros
          </Button>
        </div>
      </div>
    </Card>

    <!-- Results Count -->
    <div class="mb-4 flex items-center justify-between">
      <p class="text-sm text-gray-600 dark:text-gray-400">
        {{ filteredMicrocredits.length }} {{ filteredMicrocredits.length === 1 ? 'microcrédito' : 'microcréditos' }}
        <span v-if="hasActiveFilters">encontrados</span>
      </p>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <Card v-for="i in itemsPerPage" :key="i" :loading="true" class="h-64" />
    </div>

    <!-- Empty State -->
    <Card v-else-if="filteredMicrocredits.length === 0" class="text-center py-12">
      <Icon name="inbox" class="w-16 h-16 mx-auto mb-4 text-gray-400" />
      <h3 class="text-lg font-semibold mb-2">
        {{ hasActiveFilters ? 'No se encontraron microcréditos' : 'No hay microcréditos disponibles' }}
      </h3>
      <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
        {{ hasActiveFilters
          ? 'Intenta cambiar los filtros de búsqueda'
          : 'Aún no hay microcréditos disponibles'
        }}
      </p>
      <Button v-if="hasActiveFilters" variant="outline" @click="handleClearFilters">
        <Icon name="x" class="w-4 h-4 mr-2" />
        Limpiar Filtros
      </Button>
    </Card>

    <!-- Microcredits Grid -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <MicrocreditCard
        v-for="microcredit in paginatedMicrocredits"
        :key="microcredit.id"
        :microcredit="microcredit"
        :has-invested="hasInvested(microcredit.id)"
        :compact="compactCards"
        @invest="handleInvest"
        @view-details="handleViewDetails"
        @contact-borrower="handleContactBorrower"
      />
    </div>

    <!-- Pagination -->
    <div v-if="showPagination && totalPages > 1 && !loading" class="mt-8 flex items-center justify-center gap-2">
      <Button
        variant="outline"
        size="sm"
        :disabled="currentPage === 1"
        @click="handlePageChange(currentPage - 1)"
      >
        <Icon name="chevron-left" class="w-4 h-4" />
      </Button>

      <div class="flex items-center gap-1">
        <Button
          v-for="page in Math.min(totalPages, 5)"
          :key="page"
          :variant="currentPage === page ? 'primary' : 'ghost'"
          size="sm"
          @click="handlePageChange(page)"
        >
          {{ page }}
        </Button>
        <span v-if="totalPages > 5" class="px-2 text-gray-500">...</span>
        <Button
          v-if="totalPages > 5 && currentPage !== totalPages"
          variant="ghost"
          size="sm"
          @click="handlePageChange(totalPages)"
        >
          {{ totalPages }}
        </Button>
      </div>

      <Button
        variant="outline"
        size="sm"
        :disabled="currentPage === totalPages"
        @click="handlePageChange(currentPage + 1)"
      >
        <Icon name="chevron-right" class="w-4 h-4" />
      </Button>
    </div>

    <!-- Load More Button -->
    <div v-if="!showPagination && !loading" class="mt-8 text-center">
      <Button variant="outline" @click="handleLoadMore">
        <Icon name="refresh-cw" class="w-4 h-4 mr-2" />
        Cargar Más
      </Button>
    </div>
  </div>
</template>

<style scoped>
.microcredit-list {
  @apply w-full;
}
</style>
