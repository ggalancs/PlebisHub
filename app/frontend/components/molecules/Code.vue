<template>
  <component
    :is="block ? 'pre' : 'code'"
    :class="['font-mono', block ? blockClasses : inlineClasses, copyable && 'group relative']"
  >
    <code v-if="block" :class="['block', language && `language-${language}`]">{{
      code || content
    }}</code>
    <template v-else>{{ code || content }}</template>

    <!-- Copy button for copyable code -->
    <button
      v-if="copyable"
      type="button"
      :class="[
        'absolute right-2 top-2 rounded-md p-2 transition-all',
        'opacity-0 group-hover:opacity-100',
        'bg-gray-700 text-white hover:bg-gray-600',
        'focus:ring-primary focus:opacity-100 focus:outline-none focus:ring-2',
      ]"
      :title="copied ? 'Copied!' : 'Copy code'"
      @click="handleCopy"
    >
      <Icon :name="copied ? 'check' : 'copy'" :size="16" />
    </button>

    <!-- Language label -->
    <div
      v-if="block && showLanguage && language"
      :class="['absolute left-2 top-2 rounded px-2 py-1 text-xs', 'bg-gray-700 text-gray-300']"
    >
      {{ language }}
    </div>
  </component>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from '../atoms/Icon.vue'

/**
 * Code display component for inline code or code blocks
 */
export interface Props {
  /**
   * The code content to display
   */
  code?: string
  /**
   * Programming language for syntax highlighting
   */
  language?: string
  /**
   * Whether to display as a block or inline
   * @default false
   */
  block?: boolean
  /**
   * Whether to show a copy button
   * @default false
   */
  copyable?: boolean
  /**
   * Whether to show the language label
   * @default true
   */
  showLanguage?: boolean
  /**
   * Maximum height for scrollable code blocks
   */
  maxHeight?: string
  /**
   * Color variant
   * @default 'default'
   */
  variant?: 'default' | 'dark' | 'light'
}

const props = withDefaults(defineProps<Props>(), {
  block: false,
  copyable: false,
  showLanguage: true,
  variant: 'default',
})

const slots = defineSlots<{
  default?: () => unknown
}>()

const copied = ref(false)
let copyTimeout: ReturnType<typeof setTimeout> | null = null

const content = computed(() => {
  if (slots.default) {
    const slotContent = slots.default()
    if (Array.isArray(slotContent) && slotContent.length > 0) {
      // Extract text content from slot
      const firstNode = slotContent[0]
      if (typeof firstNode === 'object' && 'children' in firstNode) {
        return String(firstNode.children)
      }
      return String(firstNode)
    }
  }
  return ''
})

const inlineClasses = computed(() => {
  const classes = ['px-1.5', 'py-0.5', 'rounded', 'text-sm']

  switch (props.variant) {
    case 'dark':
      classes.push('bg-gray-800', 'text-gray-100')
      break
    case 'light':
      classes.push('bg-gray-100', 'text-gray-800')
      break
    default:
      classes.push('bg-gray-100', 'text-primary')
  }

  return classes
})

const blockClasses = computed(() => {
  const classes = ['p-4', 'rounded-lg', 'overflow-x-auto', 'text-sm']

  switch (props.variant) {
    case 'dark':
      classes.push('bg-gray-900', 'text-gray-100')
      break
    case 'light':
      classes.push('bg-gray-50', 'text-gray-900', 'border', 'border-gray-200')
      break
    default:
      classes.push('bg-gray-800', 'text-gray-100')
  }

  if (props.maxHeight) {
    classes.push('overflow-y-auto')
  }

  return classes
})

const handleCopy = async () => {
  const textToCopy = props.code || content.value

  try {
    await navigator.clipboard.writeText(textToCopy)
    copied.value = true

    if (copyTimeout) {
      clearTimeout(copyTimeout)
    }

    copyTimeout = setTimeout(() => {
      copied.value = false
      copyTimeout = null
    }, 2000)
  } catch (err) {
    console.error('Failed to copy code:', err)
  }
}
</script>
