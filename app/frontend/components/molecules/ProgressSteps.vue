<template>
  <nav :aria-label="ariaLabel" :class="['flex', orientationClasses]">
    <ol :class="['flex', orientationClasses, props.orientation === 'vertical' ? 'gap-0' : 'gap-2']">
      <li
        v-for="(step, index) in steps"
        :key="step.id || index"
        :class="['flex items-center', props.orientation === 'vertical' ? 'flex-col' : '']"
      >
        <!-- Step Item -->
        <div :class="['flex items-center gap-3', props.orientation === 'vertical' ? 'pb-8' : '']">
          <!-- Step Circle -->
          <button
            v-if="clickable && !step.disabled"
            type="button"
            :class="[
              'flex items-center justify-center rounded-full font-medium transition-all duration-200',
              sizeClasses,
              getStepClasses(index),
              'hover:scale-110',
            ]"
            :disabled="step.disabled"
            :aria-current="index === currentStep ? 'step' : undefined"
            @click="handleStepClick(index)"
          >
            <Icon v-if="getStepStatus(index) === 'completed'" name="check" :size="iconSize" />
            <Icon v-else-if="step.icon" :name="step.icon" :size="iconSize" />
            <span v-else>{{ index + 1 }}</span>
          </button>

          <div
            v-else
            :class="[
              'flex items-center justify-center rounded-full font-medium',
              sizeClasses,
              getStepClasses(index),
            ]"
            :aria-current="index === currentStep ? 'step' : undefined"
          >
            <Icon v-if="getStepStatus(index) === 'completed'" name="check" :size="iconSize" />
            <Icon v-else-if="step.icon" :name="step.icon" :size="iconSize" />
            <span v-else>{{ index + 1 }}</span>
          </div>

          <!-- Step Label -->
          <div
            v-if="showLabels"
            :class="['flex flex-col', props.orientation === 'vertical' ? 'flex-1' : '']"
          >
            <span :class="['font-medium transition-colors', getLabelClasses(index)]">
              {{ step.label }}
            </span>
            <span v-if="step.description" class="text-sm text-gray-500">
              {{ step.description }}
            </span>
          </div>
        </div>

        <!-- Connector Line -->
        <div
          v-if="index < steps.length - 1"
          :class="[
            'flex-shrink-0',
            props.orientation === 'vertical'
              ? '-mt-8 ml-[calc(theme(spacing.4)+theme(spacing.1))] h-full w-0.5'
              : 'mx-2 h-0.5 flex-1',
            getConnectorClasses(index),
          ]"
          :aria-hidden="true"
        />
      </li>
    </ol>
  </nav>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

/**
 * Progress steps component for showing multi-step workflows
 */
export interface Step {
  /**
   * Unique identifier for the step
   */
  id?: string | number
  /**
   * Label text for the step
   */
  label: string
  /**
   * Optional description shown below the label
   */
  description?: string
  /**
   * Optional icon to display instead of number
   */
  icon?: string
  /**
   * Whether this step is disabled
   */
  disabled?: boolean
}

export interface Props {
  /**
   * Array of step objects
   */
  steps: Step[]
  /**
   * Index of the current active step (0-based)
   */
  currentStep: number
  /**
   * Orientation of the steps
   * @default 'horizontal'
   */
  orientation?: 'horizontal' | 'vertical'
  /**
   * Whether to show step labels
   * @default true
   */
  showLabels?: boolean
  /**
   * Whether steps are clickable
   * @default false
   */
  clickable?: boolean
  /**
   * Size of the step circles
   * @default 'md'
   */
  size?: 'sm' | 'md' | 'lg'
  /**
   * Variant style for the steps
   * @default 'default'
   */
  variant?: 'default' | 'simple'
  /**
   * Accessible label for the steps navigation
   * @default 'Progress'
   */
  ariaLabel?: string
}

const props = withDefaults(defineProps<Props>(), {
  orientation: 'horizontal',
  showLabels: true,
  clickable: false,
  size: 'md',
  variant: 'default',
  ariaLabel: 'Progress',
})

const emit = defineEmits<{
  stepClick: [step: number]
}>()

const orientationClasses = computed(() => {
  return props.orientation === 'vertical' ? 'flex-col' : 'flex-row items-center'
})

const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'w-8 h-8 text-sm'
    case 'lg':
      return 'w-12 h-12 text-lg'
    default:
      return 'w-10 h-10 text-base'
  }
})

const iconSize = computed(() => {
  switch (props.size) {
    case 'sm':
      return 16
    case 'lg':
      return 24
    default:
      return 20
  }
})

const getStepStatus = (index: number): 'completed' | 'current' | 'upcoming' => {
  if (index < props.currentStep) return 'completed'
  if (index === props.currentStep) return 'current'
  return 'upcoming'
}

const getStepClasses = (index: number) => {
  const status = getStepStatus(index)
  const classes = []

  if (props.variant === 'simple') {
    switch (status) {
      case 'completed':
        classes.push('bg-primary text-white')
        break
      case 'current':
        classes.push('bg-primary text-white ring-4 ring-primary/20')
        break
      case 'upcoming':
        classes.push('bg-gray-200 text-gray-400')
        break
    }
  } else {
    switch (status) {
      case 'completed':
        classes.push('bg-primary text-white')
        break
      case 'current':
        classes.push('bg-white text-primary border-2 border-primary')
        break
      case 'upcoming':
        classes.push('bg-gray-100 text-gray-400 border-2 border-gray-300')
        break
    }
  }

  if (props.steps[index].disabled) {
    classes.push('opacity-50 cursor-not-allowed')
  }

  return classes
}

const getLabelClasses = (index: number) => {
  const status = getStepStatus(index)

  switch (status) {
    case 'completed':
      return 'text-primary'
    case 'current':
      return 'text-gray-900'
    case 'upcoming':
      return 'text-gray-400'
  }
}

const getConnectorClasses = (index: number) => {
  // Connector is colored if the current step is past it
  if (index < props.currentStep) {
    return 'bg-primary'
  }
  return 'bg-gray-300'
}

const handleStepClick = (index: number) => {
  if (props.clickable && !props.steps[index].disabled) {
    emit('stepClick', index)
  }
}
</script>
