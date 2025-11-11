<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface CollapsibleProps {
  /**
   * Title text
   */
  title: string
  /**
   * Whether the collapsible is open
   * @default false
   */
  modelValue?: boolean
  /**
   * Whether the collapsible is disabled
   * @default false
   */
  disabled?: boolean
  /**
   * Icon to show when collapsed
   * @default 'chevron-right'
   */
  iconCollapsed?: string
  /**
   * Icon to show when expanded
   * @default 'chevron-down'
   */
  iconExpanded?: string
}

const props = withDefaults(defineProps<CollapsibleProps>(), {
  modelValue: false,
  disabled: false,
  iconCollapsed: 'chevron-right',
  iconExpanded: 'chevron-down',
})

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  toggle: [value: boolean]
}>()

const contentRef = ref<HTMLElement | null>(null)

const toggle = () => {
  if (props.disabled) return
  const newValue = !props.modelValue
  emit('update:modelValue', newValue)
  emit('toggle', newValue)
}

const headerClasses = computed(() => {
  const base = 'flex items-center justify-between w-full px-4 py-3 text-left transition-colors'
  const interactive = !props.disabled
    ? 'hover:bg-gray-50 cursor-pointer'
    : 'cursor-not-allowed opacity-50'
  return [base, interactive]
})

const iconName = computed(() => {
  return props.modelValue ? props.iconExpanded : props.iconCollapsed
})
</script>

<template>
  <div class="collapsible overflow-hidden rounded-lg border border-gray-200">
    <button
      type="button"
      :class="headerClasses"
      :disabled="disabled || undefined"
      :aria-expanded="modelValue"
      :aria-controls="'collapsible-content'"
      @click="toggle"
    >
      <span class="font-medium text-gray-900">{{ title }}</span>

      <Icon :name="iconName" :size="20" class="text-gray-500 transition-transform" />
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
        v-if="modelValue"
        id="collapsible-content"
        ref="contentRef"
        class="collapsible-content px-4 pb-4 text-gray-600"
      >
        <slot />
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.collapsible-content {
  overflow: hidden;
}
</style>
