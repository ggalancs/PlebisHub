<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'
import Button from '../atoms/Button.vue'

export interface EmptyStateProps {
  /** Icon name */
  icon?: string
  /** Title text */
  title: string
  /** Description text */
  description?: string
  /** Image source (alternative to icon) */
  imageSrc?: string
  /** Image alt text */
  imageAlt?: string
  /** Primary action button label */
  primaryAction?: string
  /** Secondary action button label */
  secondaryAction?: string
  /** Size variant */
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<EmptyStateProps>(), {
  size: 'md',
  icon: 'inbox',
})

const emit = defineEmits<{
  'primary-action': []
  'secondary-action': []
}>()

const containerClasses = computed(() => {
  const classes = ['flex', 'flex-col', 'items-center', 'justify-center', 'text-center']

  const paddingMap = {
    sm: 'p-6',
    md: 'p-8',
    lg: 'p-12',
  }

  classes.push(paddingMap[props.size])

  return classes.join(' ')
})

const iconSizeClasses = computed(() => {
  const sizeMap = {
    sm: 'w-12 h-12',
    md: 'w-16 h-16',
    lg: 'w-20 h-20',
  }

  return sizeMap[props.size]
})

const imageSizeClasses = computed(() => {
  const sizeMap = {
    sm: 'w-32 h-32',
    md: 'w-48 h-48',
    lg: 'w-64 h-64',
  }

  return sizeMap[props.size]
})

const titleClasses = computed(() => {
  const classes = ['font-semibold', 'text-gray-900', 'mb-2']

  const sizeMap = {
    sm: 'text-base',
    md: 'text-lg',
    lg: 'text-xl',
  }

  classes.push(sizeMap[props.size])

  return classes.join(' ')
})

const descriptionClasses = computed(() => {
  const classes = ['text-gray-600', 'mb-4']

  const sizeMap = {
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg',
  }

  classes.push(sizeMap[props.size])

  return classes.join(' ')
})

const maxWidthClasses = computed(() => {
  const sizeMap = {
    sm: 'max-w-xs',
    md: 'max-w-md',
    lg: 'max-w-lg',
  }

  return sizeMap[props.size]
})

const handlePrimaryAction = () => {
  emit('primary-action')
}

const handleSecondaryAction = () => {
  emit('secondary-action')
}
</script>

<template>
  <div :class="[containerClasses, maxWidthClasses]">
    <!-- Image or Icon -->
    <div v-if="$slots.icon || imageSrc || icon" class="mb-4">
      <slot name="icon">
        <img
          v-if="imageSrc"
          :src="imageSrc"
          :alt="imageAlt || ''"
          :class="['object-contain', imageSizeClasses]"
        />
        <div
          v-else
          :class="[
            'flex items-center justify-center',
            'rounded-full',
            'bg-gray-100',
            iconSizeClasses,
          ]"
        >
          <Icon :name="icon" class="text-gray-400" size="lg" />
        </div>
      </slot>
    </div>

    <!-- Title -->
    <h3 :class="titleClasses">{{ title }}</h3>

    <!-- Description -->
    <p v-if="description || $slots.description" :class="descriptionClasses">
      <slot name="description">
        {{ description }}
      </slot>
    </p>

    <!-- Actions -->
    <div
      v-if="$slots.actions || primaryAction || secondaryAction"
      class="mt-2 flex flex-col gap-2 sm:flex-row"
    >
      <slot name="actions">
        <Button v-if="primaryAction" @click="handlePrimaryAction">
          {{ primaryAction }}
        </Button>
        <Button v-if="secondaryAction" variant="secondary" @click="handleSecondaryAction">
          {{ secondaryAction }}
        </Button>
      </slot>
    </div>
  </div>
</template>
