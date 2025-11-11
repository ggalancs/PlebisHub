<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface MenuItem {
  id: string | number
  label: string
  icon?: string
  disabled?: boolean
  separator?: boolean
  destructive?: boolean
  shortcut?: string
}

export interface MenuProps {
  /**
   * Menu items to display
   */
  items: MenuItem[]
  /**
   * Whether the menu is open
   * @default false
   */
  modelValue?: boolean
  /**
   * Whether to close menu on item click
   * @default true
   */
  closeOnClick?: boolean
}

const props = withDefaults(defineProps<MenuProps>(), {
  modelValue: false,
  closeOnClick: true,
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  select: [item: MenuItem]
}>()

const menuRef = ref<HTMLElement | null>(null)
const focusedIndex = ref(-1)

const selectableItems = props.items.filter((item) => !item.separator && !item.disabled)

const handleItemClick = (item: MenuItem) => {
  if (item.disabled || item.separator) return

  emit('select', item)

  if (props.closeOnClick) {
    emit('update:modelValue', false)
  }
}

const handleKeyDown = (event: KeyboardEvent) => {
  if (!props.modelValue) return

  switch (event.key) {
    case 'Escape':
      event.preventDefault()
      emit('update:modelValue', false)
      break
    case 'ArrowDown':
      event.preventDefault()
      focusNextItem()
      break
    case 'ArrowUp':
      event.preventDefault()
      focusPreviousItem()
      break
    case 'Enter':
    case ' ':
      event.preventDefault()
      if (focusedIndex.value >= 0 && focusedIndex.value < selectableItems.length) {
        handleItemClick(selectableItems[focusedIndex.value])
      }
      break
  }
}

const focusNextItem = () => {
  if (selectableItems.length === 0) return
  focusedIndex.value = (focusedIndex.value + 1) % selectableItems.length
}

const focusPreviousItem = () => {
  if (selectableItems.length === 0) return
  focusedIndex.value = focusedIndex.value <= 0 ? selectableItems.length - 1 : focusedIndex.value - 1
}

const isFocused = (item: MenuItem): boolean => {
  const index = selectableItems.findIndex((i) => i.id === item.id)
  return index === focusedIndex.value
}

onMounted(() => {
  document.addEventListener('keydown', handleKeyDown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeyDown)
})
</script>

<template>
  <div
    v-if="modelValue"
    ref="menuRef"
    class="menu min-w-[200px] rounded-lg border border-gray-200 bg-white py-1 shadow-lg"
    role="menu"
    aria-orientation="vertical"
  >
    <template v-for="item in items" :key="item.id">
      <!-- Separator -->
      <div
        v-if="item.separator"
        class="menu-separator my-1 border-t border-gray-200"
        role="separator"
      />

      <!-- Menu Item -->
      <button
        v-else
        type="button"
        class="menu-item flex w-full items-center gap-3 px-3 py-2 text-left text-sm transition-colors"
        :class="{
          'text-gray-900 hover:bg-gray-100': !item.disabled && !item.destructive,
          'text-red-600 hover:bg-red-50': !item.disabled && item.destructive,
          'cursor-not-allowed text-gray-400': item.disabled,
          'bg-gray-100': isFocused(item) && !item.disabled,
        }"
        :disabled="item.disabled || undefined"
        :aria-disabled="item.disabled || undefined"
        role="menuitem"
        @click="handleItemClick(item)"
      >
        <!-- Icon -->
        <Icon v-if="item.icon" :name="item.icon" :size="16" class="flex-shrink-0" />

        <!-- Label -->
        <span class="flex-1">{{ item.label }}</span>

        <!-- Shortcut -->
        <span v-if="item.shortcut" class="ml-auto text-xs text-gray-400">
          {{ item.shortcut }}
        </span>
      </button>
    </template>
  </div>
</template>

<style scoped>
.menu {
  max-height: 400px;
  overflow-y: auto;
}
</style>
