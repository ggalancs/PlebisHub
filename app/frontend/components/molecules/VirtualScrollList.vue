<script setup lang="ts" generic="T">
/**
 * VirtualScrollList Component
 *
 * A reusable component for rendering large lists efficiently using virtual scrolling
 * Only renders items visible in the viewport + buffer
 *
 * Usage:
 * <VirtualScrollList
 *   :items="proposals"
 *   :item-height="120"
 *   :container-height="600"
 * >
 *   <template #default="{ item, index }">
 *     <ProposalCard :proposal="item" />
 *   </template>
 * </VirtualScrollList>
 */

import { computed } from 'vue'
import { useVirtualScroll } from '@/composables/useVirtualScroll'

interface Props {
  items: T[]
  itemHeight: number | ((item: T, index: number) => number)
  containerHeight?: number
  buffer?: number
  overscan?: number
  emptyMessage?: string
  loading?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  buffer: 5,
  overscan: 2,
  emptyMessage: 'No hay elementos para mostrar',
  loading: false,
})

const emit = defineEmits<{
  scrollToIndex: [index: number]
  scrollToTop: []
  scrollToBottom: []
}>()

const itemsRef = computed(() => props.items)

const {
  visibleItems,
  totalHeight,
  containerProps,
  wrapperProps,
  scrollToIndex,
  scrollToTop,
  scrollToBottom,
} = useVirtualScroll({
  items: itemsRef,
  itemHeight: props.itemHeight,
  buffer: props.buffer,
  overscan: props.overscan,
  containerHeight: props.containerHeight,
})

// Expose scroll methods
defineExpose({
  scrollToIndex,
  scrollToTop,
  scrollToBottom,
})
</script>

<template>
  <div class="virtual-scroll-container">
    <!-- Loading state -->
    <div
      v-if="loading"
      class="flex items-center justify-center min-h-[400px]"
    >
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-primary"></div>
    </div>

    <!-- Empty state -->
    <div
      v-else-if="items.length === 0"
      class="flex items-center justify-center min-h-[400px] text-gray-500 dark:text-gray-400"
    >
      <p>{{ emptyMessage }}</p>
    </div>

    <!-- Virtual scroll list -->
    <div
      v-else
      v-bind="containerProps"
      class="virtual-scroll-viewport"
    >
      <div v-bind="wrapperProps" class="virtual-scroll-wrapper">
        <div
          v-for="{ item, index, style } in visibleItems"
          :key="index"
          :style="style"
          class="virtual-scroll-item"
        >
          <slot :item="item" :index="index">
            <!-- Default slot content -->
            <div class="p-4 border-b border-gray-200 dark:border-gray-700">
              {{ item }}
            </div>
          </slot>
        </div>
      </div>
    </div>

    <!-- Scroll controls (optional) -->
    <div v-if="items.length > 10" class="virtual-scroll-controls mt-4 flex gap-2 justify-end">
      <button
        @click="scrollToTop"
        class="px-3 py-1 text-sm bg-gray-100 dark:bg-gray-800 rounded hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
        aria-label="Ir al inicio"
      >
        ↑ Inicio
      </button>
      <button
        @click="scrollToBottom"
        class="px-3 py-1 text-sm bg-gray-100 dark:bg-gray-800 rounded hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors"
        aria-label="Ir al final"
      >
        ↓ Final
      </button>
    </div>
  </div>
</template>

<style scoped>
.virtual-scroll-container {
  width: 100%;
  height: 100%;
}

.virtual-scroll-viewport {
  width: 100%;
  height: 100%;
  overflow-y: auto;
  overflow-x: hidden;
  position: relative;
  /* Smooth scrolling */
  scroll-behavior: smooth;
  /* Better scrolling on iOS */
  -webkit-overflow-scrolling: touch;
}

.virtual-scroll-wrapper {
  position: relative;
  width: 100%;
}

.virtual-scroll-item {
  position: absolute;
  width: 100%;
  will-change: transform;
}

/* Custom scrollbar styling */
.virtual-scroll-viewport::-webkit-scrollbar {
  width: 8px;
}

.virtual-scroll-viewport::-webkit-scrollbar-track {
  background: transparent;
}

.virtual-scroll-viewport::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 4px;
}

.virtual-scroll-viewport::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.3);
}

/* Dark mode scrollbar */
.dark .virtual-scroll-viewport::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
}

.dark .virtual-scroll-viewport::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.3);
}
</style>
