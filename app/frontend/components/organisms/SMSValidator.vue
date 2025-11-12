<script setup lang="ts">
import { ref, computed, watch, watchEffect, onMounted } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Button from '@/components/atoms/Button.vue'
import Input from '@/components/atoms/Input.vue'
import Icon from '@/components/atoms/Icon.vue'

export type ValidationState = 'pending' | 'validating' | 'valid' | 'invalid' | 'expired'

interface Props {
  /** Phone number being verified */
  phoneNumber?: string
  /** Code length */
  codeLength?: number
  /** Countdown duration in seconds */
  resendTimeout?: number
  /** Current validation state */
  validationState?: ValidationState
  /** Loading state */
  loading?: boolean
  /** Disabled state */
  disabled?: boolean
  /** Auto-focus first input */
  autofocus?: boolean
}

interface Emits {
  (e: 'validate', code: string): void
  (e: 'resend'): void
  (e: 'cancel'): void
}

const props = withDefaults(defineProps<Props>(), {
  codeLength: 6,
  resendTimeout: 60,
  validationState: 'pending',
  loading: false,
  disabled: false,
  autofocus: true,
})

const emit = defineEmits<Emits>()

// Code inputs
const codeInputs = ref<string[]>(Array(props.codeLength).fill(''))
const inputRefs = ref<HTMLInputElement[]>([])

// Countdown timer
const countdown = ref(props.resendTimeout)
const isCountdownActive = ref(false)

// Validation debounce
const isValidating = ref(false)

// Error message
const errorMessage = ref('')

// Watch validation state
watch(() => props.validationState, (state) => {
  if (state === 'invalid') {
    errorMessage.value = 'Código incorrecto. Inténtalo de nuevo.'
    clearCode()
  } else if (state === 'expired') {
    errorMessage.value = 'El código ha expirado. Solicita uno nuevo.'
    clearCode()
  } else if (state === 'valid') {
    errorMessage.value = ''
  }
})

// Computed
const fullCode = computed(() => codeInputs.value.join(''))

const isComplete = computed(() => {
  return codeInputs.value.every(digit => digit.length === 1)
})

const canResend = computed(() => {
  return !isCountdownActive.value && !props.loading
})

// Countdown management with automatic cleanup
watchEffect((onCleanup) => {
  if (isCountdownActive.value && countdown.value > 0) {
    const intervalId = window.setInterval(() => {
      countdown.value--
      if (countdown.value <= 0) {
        isCountdownActive.value = false
      }
    }, 1000)

    // Automatic cleanup when component unmounts or countdown stops
    onCleanup(() => {
      clearInterval(intervalId)
    })
  }
})

// Start countdown function
const startCountdown = () => {
  countdown.value = props.resendTimeout
  isCountdownActive.value = true
}

// Stop countdown function
const stopCountdown = () => {
  isCountdownActive.value = false
  countdown.value = 0
}

// Format countdown
const formatCountdown = computed(() => {
  const minutes = Math.floor(countdown.value / 60)
  const seconds = countdown.value % 60
  return `${minutes}:${seconds.toString().padStart(2, '0')}`
})

// Input handlers
const handleInput = (index: number, event: Event) => {
  const target = event.target as HTMLInputElement
  const value = target.value

  // Only allow digits
  const digit = value.replace(/\D/g, '').slice(0, 1)
  codeInputs.value[index] = digit

  // Auto-focus next input
  if (digit && index < props.codeLength - 1) {
    inputRefs.value[index + 1]?.focus()
  }

  // Auto-validate when complete
  if (isComplete.value) {
    handleValidate()
  }
}

const handleKeyDown = (index: number, event: KeyboardEvent) => {
  // Handle backspace
  if (event.key === 'Backspace' && !codeInputs.value[index] && index > 0) {
    inputRefs.value[index - 1]?.focus()
  }

  // Handle arrow keys
  if (event.key === 'ArrowLeft' && index > 0) {
    event.preventDefault()
    inputRefs.value[index - 1]?.focus()
  }
  if (event.key === 'ArrowRight' && index < props.codeLength - 1) {
    event.preventDefault()
    inputRefs.value[index + 1]?.focus()
  }

  // Handle paste
  if (event.key === 'v' && (event.ctrlKey || event.metaKey)) {
    // Paste will be handled by handlePaste
    return
  }
}

const handlePaste = (event: ClipboardEvent) => {
  event.preventDefault()
  const pastedData = event.clipboardData?.getData('text') || ''
  const digits = pastedData.replace(/\D/g, '').slice(0, props.codeLength)

  for (let i = 0; i < digits.length && i < props.codeLength; i++) {
    codeInputs.value[i] = digits[i]
  }

  // Focus last filled input or first empty
  const lastFilledIndex = Math.min(digits.length, props.codeLength) - 1
  inputRefs.value[lastFilledIndex]?.focus()

  // Auto-validate if complete
  if (digits.length === props.codeLength) {
    handleValidate()
  }
}

// Actions
const handleValidate = () => {
  // Prevent multiple concurrent validations (race condition)
  if (isComplete.value && !props.loading && !isValidating.value) {
    isValidating.value = true
    emit('validate', fullCode.value)

    // Reset validating flag after a delay to prevent spam
    setTimeout(() => {
      isValidating.value = false
    }, 1000)
  }
}

const handleResend = () => {
  if (canResend.value) {
    clearCode()
    emit('resend')
    startCountdown()
  }
}

const handleCancel = () => {
  emit('cancel')
}

const clearCode = () => {
  codeInputs.value = Array(props.codeLength).fill('')
  errorMessage.value = ''
  inputRefs.value[0]?.focus()
}

// Lifecycle
onMounted(() => {
  if (props.autofocus) {
    inputRefs.value[0]?.focus()
  }
  startCountdown()
})

// Note: onUnmounted cleanup is now handled automatically by watchEffect

// State indicators
const stateConfig = {
  pending: { icon: 'clock', color: 'text-gray-500', message: 'Ingresa el código recibido' },
  validating: { icon: 'loader', color: 'text-blue-500', message: 'Validando código...' },
  valid: { icon: 'check-circle', color: 'text-green-500', message: '¡Código válido!' },
  invalid: { icon: 'x-circle', color: 'text-red-500', message: 'Código incorrecto' },
  expired: { icon: 'alert-triangle', color: 'text-orange-500', message: 'Código expirado' },
}

const currentState = computed(() => stateConfig[props.validationState])
</script>

<template>
  <Card class="sms-validator">
    <!-- Header -->
    <div class="sms-validator__header">
      <div class="flex items-start justify-between mb-4">
        <div>
          <h3 class="text-xl font-bold mb-1">Verificación por SMS</h3>
          <p class="text-sm text-gray-600 dark:text-gray-400">
            Hemos enviado un código de verificación al número
            <span v-if="phoneNumber" class="font-semibold">{{ phoneNumber }}</span>
          </p>
        </div>
        <div :class="['flex items-center gap-2', currentState.color]">
          <Icon :name="currentState.icon" class="w-5 h-5" />
        </div>
      </div>
    </div>

    <!-- Status Message -->
    <div
      :class="[
        'sms-validator__status',
        validationState === 'valid' && 'bg-green-50 dark:bg-green-900 border-green-200 dark:border-green-800 text-green-800 dark:text-green-200',
        validationState === 'invalid' && 'bg-red-50 dark:bg-red-900 border-red-200 dark:border-red-800 text-red-800 dark:text-red-200',
        validationState === 'expired' && 'bg-orange-50 dark:bg-orange-900 border-orange-200 dark:border-orange-800 text-orange-800 dark:text-orange-200',
        (validationState === 'pending' || validationState === 'validating') && 'bg-blue-50 dark:bg-blue-900 border-blue-200 dark:border-blue-800 text-blue-800 dark:text-blue-200',
      ]"
    >
      <Icon :name="currentState.icon" class="w-4 h-4 flex-shrink-0" />
      <span class="text-sm font-medium">{{ errorMessage || currentState.message }}</span>
    </div>

    <!-- Code Input -->
    <div class="sms-validator__inputs">
      <div class="flex items-center justify-center gap-2">
        <input
          v-for="(digit, index) in codeInputs"
          :key="index"
          :ref="(el) => { if (el) inputRefs[index] = el as HTMLInputElement }"
          v-model="codeInputs[index]"
          type="text"
          inputmode="numeric"
          pattern="[0-9]*"
          maxlength="1"
          :class="[
            'sms-validator__input',
            validationState === 'valid' && 'border-green-500 bg-green-50 dark:bg-green-900',
            validationState === 'invalid' && 'border-red-500 bg-red-50 dark:bg-red-900',
            validationState === 'validating' && 'border-blue-500',
          ]"
          :disabled="disabled || loading"
          @input="handleInput(index, $event)"
          @keydown="handleKeyDown(index, $event)"
          @paste="handlePaste"
        />
      </div>
      <p class="text-xs text-center text-gray-500 mt-2">
        Ingresa los {{ codeLength }} dígitos recibidos por SMS
      </p>
    </div>

    <!-- Actions -->
    <div class="sms-validator__actions">
      <div class="flex flex-col sm:flex-row items-center justify-between gap-4">
        <div class="flex items-center gap-2">
          <Button
            variant="ghost"
            @click="handleResend"
            :disabled="!canResend || disabled"
          >
            <Icon name="refresh-cw" class="w-4 h-4 mr-2" />
            Reenviar Código
          </Button>
          <span v-if="isCountdownActive" class="text-sm text-gray-600 dark:text-gray-400">
            ({{ formatCountdown }})
          </span>
        </div>

        <div class="flex gap-2">
          <Button
            variant="ghost"
            @click="handleCancel"
            :disabled="loading"
          >
            Cancelar
          </Button>
          <Button
            variant="primary"
            @click="handleValidate"
            :loading="loading"
            :disabled="!isComplete || disabled"
          >
            <Icon name="check" class="w-4 h-4 mr-2" />
            Verificar
          </Button>
        </div>
      </div>
    </div>

    <!-- Help Text -->
    <div class="sms-validator__help">
      <p class="text-xs text-center text-gray-500">
        ¿No recibiste el código? Revisa que el número sea correcto o espera
        {{ resendTimeout }} segundos para reenviarlo.
      </p>
    </div>
  </Card>
</template>

<style scoped>
.sms-validator {
  @apply w-full max-w-2xl mx-auto;
}

.sms-validator__header {
  @apply pb-4 border-b border-gray-200 dark:border-gray-700;
}

.sms-validator__status {
  @apply flex items-center gap-2 p-3 rounded border my-6;
}

.sms-validator__inputs {
  @apply py-6;
}

.sms-validator__input {
  @apply w-12 h-14 text-center text-2xl font-bold border-2 rounded-lg transition-all duration-200;
  @apply focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary;
  @apply disabled:opacity-50 disabled:cursor-not-allowed;
  @apply bg-white dark:bg-gray-800 border-gray-300 dark:border-gray-600;
}

.sms-validator__input:focus {
  @apply scale-110;
}

.sms-validator__actions {
  @apply pt-4 border-t border-gray-200 dark:border-gray-700;
}

.sms-validator__help {
  @apply mt-4 pt-4 border-t border-gray-200 dark:border-gray-700;
}
</style>
