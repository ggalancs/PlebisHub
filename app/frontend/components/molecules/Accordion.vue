<script setup lang="ts">
import { computed, ref } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface AccordionItem {
  id: string | number
  title: string
  content?: string
  disabled?: boolean
}

export interface AccordionProps {
  /**
   * Array of accordion items to display
   */
  items: AccordionItem[]
  /**
   * Currently open item IDs
   */
  modelValue?: (string | number)[]
  /**
   * Allow multiple items to be open simultaneously
   * @default false
   */
  multiple?: boolean
  /**
   * Visual variant of the accordion
   * @default 'default'
   */
  variant?: 'default' | 'bordered' | 'separated'
  /**
   * Whether the accordion is disabled
   * @default false
   */
  disabled?: boolean
}

const props = withDefaults(defineProps<AccordionProps>(), {
  modelValue: () => [],
  multiple: false,
  variant: 'default',
  disabled: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: (string | number)[]]
  change: [openItems: (string | number)[]]
}>()

const internalOpen = ref<(string | number)[]>([...props.modelValue])

const isOpen = (itemId: string | number): boolean => {
  return internalOpen.value.includes(itemId)
}

const toggleItem = (item: AccordionItem) => {
  if (props.disabled || item.disabled) return

  let newOpen: (string | number)[]

  if (isOpen(item.id)) {
    // Close this item
    newOpen = internalOpen.value.filter((id) => id !== item.id)
  } else {
    // Open this item
    if (props.multiple) {
      newOpen = [...internalOpen.value, item.id]
    } else {
      newOpen = [item.id]
    }
  }

  internalOpen.value = newOpen
  emit('update:modelValue', newOpen)
  emit('change', newOpen)
}

const containerClasses = computed(() => {
  const base = 'accordion'
  const variants = {
    default: '',
    bordered: 'border border-gray-200 rounded-lg overflow-hidden',
    separated: 'space-y-2',
  }
  return [base, variants[props.variant]]
})

const itemClasses = computed(() => (item: AccordionItem) => {
  const base = 'accordion-item'
  const disabled = item.disabled || props.disabled ? 'opacity-50 cursor-not-allowed' : ''
  const variantClasses = {
    default: 'border-b border-gray-200 last:border-b-0',
    bordered: 'border-b border-gray-200 last:border-b-0',
    separated: 'border border-gray-200 rounded-lg overflow-hidden',
  }
  return [base, variantClasses[props.variant], disabled]
})

const headerClasses = computed(() => (item: AccordionItem) => {
  const base = 'flex items-center justify-between w-full px-4 py-3 text-left transition-colors'
  const interactive = !(item.disabled || props.disabled)
    ? 'hover:bg-gray-50 cursor-pointer'
    : 'cursor-not-allowed'
  const open = isOpen(item.id) ? 'bg-gray-50' : ''
  return [base, interactive, open]
})

const contentClasses = 'px-4 pb-3 text-gray-600'

const iconClasses = computed(() => (item: AccordionItem) => {
  const base = 'transition-transform duration-200'
  const rotate = isOpen(item.id) ? 'rotate-180' : ''
  return [base, rotate]
})
</script>

<template>
  <div :class="containerClasses">
    <div v-for="item in items" :key="item.id" :class="itemClasses(item)">
      <button
        :class="headerClasses(item)"
        :disabled="disabled || item.disabled || undefined"
        :aria-expanded="isOpen(item.id)"
        :aria-controls="`accordion-content-${item.id}`"
        :aria-disabled="disabled || item.disabled || undefined"
        type="button"
        @click="toggleItem(item)"
      >
        <slot name="title" :item="item" :is-open="isOpen(item.id)">
          <span class="font-medium text-gray-900">{{ item.title }}</span>
        </slot>

        <slot name="icon" :item="item" :is-open="isOpen(item.id)">
          <Icon name="chevron-down" :size="20" :class="iconClasses(item)" />
        </slot>
      </button>

      <Transition
        enter-active-class="transition-all duration-200 ease-out"
        enter-from-class="opacity-0 max-h-0"
        enter-to-class="opacity-100 max-h-screen"
        leave-active-class="transition-all duration-200 ease-in"
        leave-from-class="opacity-100 max-h-screen"
        leave-to-class="opacity-0 max-h-0"
      >
        <div
          v-if="isOpen(item.id)"
          :id="`accordion-content-${item.id}`"
          :class="contentClasses"
          role="region"
          :aria-labelledby="`accordion-header-${item.id}`"
        >
          <slot name="content" :item="item">
            <p>{{ item.content }}</p>
          </slot>
        </div>
      </Transition>
    </div>
  </div>
</template>

<style scoped>
.accordion-item {
  overflow: hidden;
}
</style>
