<script setup lang="ts">
import { computed } from 'vue'
import Icon from '@/components/atoms/Icon.vue'
import type { ProjectStatus } from './ImpulsaProjectCard.vue'

export interface ProjectStep {
  id: string
  label: string
  description?: string
  icon?: string
  status: 'completed' | 'current' | 'pending' | 'skipped'
  date?: Date | string
}

interface Props {
  /** Array of steps */
  steps: ProjectStep[]
  /** Current step ID */
  currentStep?: string
  /** Orientation */
  orientation?: 'horizontal' | 'vertical'
  /** Show descriptions */
  showDescriptions?: boolean
  /** Show dates */
  showDates?: boolean
  /** Clickable steps */
  clickable?: boolean
  /** Compact mode */
  compact?: boolean
}

interface Emits {
  (e: 'step-click', step: ProjectStep): void
}

const props = withDefaults(defineProps<Props>(), {
  orientation: 'horizontal',
  showDescriptions: true,
  showDates: false,
  clickable: false,
  compact: false,
})

const emit = defineEmits<Emits>()

// Get step status class
const getStepClass = (step: ProjectStep): string => {
  const baseClass = 'impulsa-project-steps__step'

  switch (step.status) {
    case 'completed':
      return `${baseClass} ${baseClass}--completed`
    case 'current':
      return `${baseClass} ${baseClass}--current`
    case 'skipped':
      return `${baseClass} ${baseClass}--skipped`
    default:
      return `${baseClass} ${baseClass}--pending`
  }
}

// Get connector class
const getConnectorClass = (step: ProjectStep, index: number): string => {
  const baseClass = 'impulsa-project-steps__connector'

  // If current or previous step is completed, connector is active
  if (step.status === 'completed' || step.status === 'skipped') {
    return `${baseClass} ${baseClass}--active`
  }

  return baseClass
}

// Format date
const formatDate = (date: Date | string): string => {
  return new Intl.DateTimeFormat('es-ES', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(new Date(date))
}

// Handle step click
const handleStepClick = (step: ProjectStep) => {
  if (props.clickable) {
    emit('step-click', step)
  }
}

// Get icon for step
const getStepIcon = (step: ProjectStep): string => {
  if (step.icon) return step.icon

  switch (step.status) {
    case 'completed':
      return 'check-circle'
    case 'current':
      return 'circle'
    case 'skipped':
      return 'x-circle'
    default:
      return 'circle'
  }
}

// Current step index
const currentStepIndex = computed(() => {
  return props.steps.findIndex(s => s.id === props.currentStep)
})
</script>

<template>
  <div
    :class="[
      'impulsa-project-steps',
      `impulsa-project-steps--${orientation}`,
      compact && 'impulsa-project-steps--compact',
    ]"
  >
    <div
      v-for="(step, index) in steps"
      :key="step.id"
      class="impulsa-project-steps__item"
    >
      <!-- Step -->
      <div
        :class="getStepClass(step)"
        @click="handleStepClick(step)"
        :style="{ cursor: clickable ? 'pointer' : 'default' }"
      >
        <!-- Step Indicator -->
        <div class="impulsa-project-steps__indicator">
          <div class="impulsa-project-steps__circle">
            <Icon
              :name="getStepIcon(step)"
              class="impulsa-project-steps__icon"
            />
          </div>
        </div>

        <!-- Step Content -->
        <div class="impulsa-project-steps__content">
          <div class="impulsa-project-steps__label">
            {{ step.label }}
          </div>

          <div
            v-if="showDescriptions && step.description && !compact"
            class="impulsa-project-steps__description"
          >
            {{ step.description }}
          </div>

          <div
            v-if="showDates && step.date"
            class="impulsa-project-steps__date"
          >
            {{ formatDate(step.date) }}
          </div>
        </div>
      </div>

      <!-- Connector -->
      <div
        v-if="index < steps.length - 1"
        :class="getConnectorClass(step, index)"
      />
    </div>
  </div>
</template>

<style scoped>
.impulsa-project-steps {
  @apply w-full;
}

/* Horizontal Layout */
.impulsa-project-steps--horizontal {
  @apply flex items-start;
}

.impulsa-project-steps--horizontal .impulsa-project-steps__item {
  @apply flex items-start flex-1;
}

.impulsa-project-steps--horizontal .impulsa-project-steps__item:last-child {
  @apply flex-initial;
}

.impulsa-project-steps--horizontal .impulsa-project-steps__step {
  @apply flex flex-col items-center text-center;
}

.impulsa-project-steps--horizontal .impulsa-project-steps__connector {
  @apply flex-1 h-0.5 mt-5 mx-2 bg-gray-200 dark:bg-gray-700 transition-colors;
}

.impulsa-project-steps--horizontal .impulsa-project-steps__connector--active {
  @apply bg-primary;
}

/* Vertical Layout */
.impulsa-project-steps--vertical {
  @apply flex flex-col space-y-0;
}

.impulsa-project-steps--vertical .impulsa-project-steps__item {
  @apply flex flex-col;
}

.impulsa-project-steps--vertical .impulsa-project-steps__step {
  @apply flex items-start;
}

.impulsa-project-steps--vertical .impulsa-project-steps__indicator {
  @apply flex-shrink-0;
}

.impulsa-project-steps--vertical .impulsa-project-steps__content {
  @apply ml-4 flex-1 text-left;
}

.impulsa-project-steps--vertical .impulsa-project-steps__connector {
  @apply w-0.5 h-8 ml-5 bg-gray-200 dark:bg-gray-700 transition-colors;
}

.impulsa-project-steps--vertical .impulsa-project-steps__connector--active {
  @apply bg-primary;
}

/* Step Styles */
.impulsa-project-steps__step {
  @apply transition-all duration-200;
}

.impulsa-project-steps__step--pending {
  @apply text-gray-400 dark:text-gray-600;
}

.impulsa-project-steps__step--current {
  @apply text-primary font-semibold;
}

.impulsa-project-steps__step--completed {
  @apply text-green-600 dark:text-green-400;
}

.impulsa-project-steps__step--skipped {
  @apply text-gray-400 dark:text-gray-600 line-through;
}

/* Indicator */
.impulsa-project-steps__indicator {
  @apply relative;
}

.impulsa-project-steps__circle {
  @apply w-10 h-10 rounded-full border-2 flex items-center justify-center transition-all duration-200;
}

.impulsa-project-steps__step--pending .impulsa-project-steps__circle {
  @apply border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-800;
}

.impulsa-project-steps__step--current .impulsa-project-steps__circle {
  @apply border-primary bg-primary shadow-lg ring-4 ring-primary ring-opacity-20;
}

.impulsa-project-steps__step--completed .impulsa-project-steps__circle {
  @apply border-green-600 dark:border-green-400 bg-green-600 dark:bg-green-400;
}

.impulsa-project-steps__step--skipped .impulsa-project-steps__circle {
  @apply border-gray-300 dark:border-gray-700 bg-gray-100 dark:bg-gray-800;
}

/* Icon */
.impulsa-project-steps__icon {
  @apply w-5 h-5;
}

.impulsa-project-steps__step--pending .impulsa-project-steps__icon {
  @apply text-gray-400 dark:text-gray-600;
}

.impulsa-project-steps__step--current .impulsa-project-steps__icon {
  @apply text-white;
}

.impulsa-project-steps__step--completed .impulsa-project-steps__icon {
  @apply text-white;
}

.impulsa-project-steps__step--skipped .impulsa-project-steps__icon {
  @apply text-gray-400 dark:text-gray-600;
}

/* Content */
.impulsa-project-steps__content {
  @apply mt-2;
}

.impulsa-project-steps--vertical .impulsa-project-steps__content {
  @apply mt-0;
}

.impulsa-project-steps__label {
  @apply text-sm font-medium;
}

.impulsa-project-steps__description {
  @apply text-xs mt-1 text-gray-600 dark:text-gray-400;
}

.impulsa-project-steps__date {
  @apply text-xs mt-1 text-gray-500 dark:text-gray-500;
}

/* Compact Mode */
.impulsa-project-steps--compact .impulsa-project-steps__circle {
  @apply w-8 h-8;
}

.impulsa-project-steps--compact .impulsa-project-steps__icon {
  @apply w-4 h-4;
}

.impulsa-project-steps--compact .impulsa-project-steps__label {
  @apply text-xs;
}

.impulsa-project-steps--compact .impulsa-project-steps__connector {
  @apply mx-1;
}

/* Responsive */
@media (max-width: 640px) {
  .impulsa-project-steps--horizontal {
    @apply flex-col;
  }

  .impulsa-project-steps--horizontal .impulsa-project-steps__item {
    @apply flex-col w-full;
  }

  .impulsa-project-steps--horizontal .impulsa-project-steps__step {
    @apply flex-row items-start text-left;
  }

  .impulsa-project-steps--horizontal .impulsa-project-steps__indicator {
    @apply flex-shrink-0;
  }

  .impulsa-project-steps--horizontal .impulsa-project-steps__content {
    @apply ml-4 text-left mt-0;
  }

  .impulsa-project-steps--horizontal .impulsa-project-steps__connector {
    @apply w-0.5 h-8 ml-5 mr-0 mt-0;
  }
}
</style>
