<script setup lang="ts">
import { computed, inject, type Ref } from 'vue'

export interface TabPanelProps {
  /** Tab panel key (must match tab key) */
  tabKey: string
}

const props = defineProps<TabPanelProps>()

const activeTab = inject<Ref<string>>('activeTab')
const loadedTabs = inject<Ref<Set<string>>>('loadedTabs')
const lazy = inject<boolean>('lazy', false)

const isActive = computed(() => activeTab?.value === props.tabKey)
const hasBeenLoaded = computed(() => loadedTabs?.value.has(props.tabKey) ?? true)

// Show panel if: active OR (not lazy) OR (lazy and has been loaded)
const shouldRender = computed(() => {
  if (!lazy) return true
  return hasBeenLoaded.value
})
</script>

<template>
  <div
    v-if="shouldRender"
    :id="`panel-${tabKey}`"
    role="tabpanel"
    :aria-labelledby="`tab-${tabKey}`"
    :hidden="!isActive"
    :class="{ hidden: !isActive }"
  >
    <slot />
  </div>
</template>
