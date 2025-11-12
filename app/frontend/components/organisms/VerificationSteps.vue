<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Button from '@/components/atoms/Button.vue'
import Input from '@/components/atoms/Input.vue'
import Select from '@/components/atoms/Select.vue'
import Icon from '@/components/atoms/Icon.vue'
import ProgressBar from '@/components/molecules/ProgressBar.vue'
import Badge from '@/components/atoms/Badge.vue'

export type VerificationStep = 'personal' | 'document' | 'address' | 'phone' | 'review'
export type DocumentType = 'dni' | 'passport' | 'nie' | 'residence_card'
export type VerificationStatus = 'not_started' | 'in_progress' | 'pending_review' | 'verified' | 'rejected'

export interface PersonalInfo {
  firstName: string
  lastName: string
  dateOfBirth: string
  nationality: string
}

export interface DocumentInfo {
  documentType: DocumentType
  documentNumber: string
  expirationDate: string
  frontImage?: File
  backImage?: File
}

export interface AddressInfo {
  street: string
  number: string
  floor?: string
  door?: string
  postalCode: string
  city: string
  province: string
}

export interface PhoneInfo {
  countryCode: string
  phoneNumber: string
  verificationCode?: string
}

export interface VerificationData {
  personal: Partial<PersonalInfo>
  document: Partial<DocumentInfo>
  address: Partial<AddressInfo>
  phone: Partial<PhoneInfo>
}

interface Props {
  /** Initial verification data */
  initialData?: Partial<VerificationData>
  /** Current step */
  currentStep?: VerificationStep
  /** Current verification status */
  verificationStatus?: VerificationStatus
  /** Loading state */
  loading?: boolean
  /** Disabled state */
  disabled?: boolean
  /** Show progress */
  showProgress?: boolean
}

interface Emits {
  (e: 'step-change', step: VerificationStep): void
  (e: 'submit', data: VerificationData): void
  (e: 'send-verification-code'): void
  (e: 'cancel'): void
}

const props = withDefaults(defineProps<Props>(), {
  currentStep: 'personal',
  verificationStatus: 'not_started',
  loading: false,
  disabled: false,
  showProgress: true,
})

const emit = defineEmits<Emits>()

// Form data
const formData = ref<VerificationData>({
  personal: {},
  document: {},
  address: {},
  phone: {},
  ...props.initialData,
})

// Current step
const step = ref<VerificationStep>(props.currentStep)

// Watch for prop changes
watch(() => props.currentStep, (newStep) => {
  step.value = newStep
})

// Steps configuration
const steps: Array<{ id: VerificationStep; label: string; icon: string }> = [
  { id: 'personal', label: 'Datos Personales', icon: 'user' },
  { id: 'document', label: 'Documento', icon: 'credit-card' },
  { id: 'address', label: 'Dirección', icon: 'map-pin' },
  { id: 'phone', label: 'Teléfono', icon: 'phone' },
  { id: 'review', label: 'Revisión', icon: 'check-circle' },
]

// Document type options
const documentTypes = [
  { value: 'dni', label: 'DNI' },
  { value: 'passport', label: 'Pasaporte' },
  { value: 'nie', label: 'NIE' },
  { value: 'residence_card', label: 'Tarjeta de Residencia' },
]

// Country codes
const countryCodes = [
  { value: '+34', label: '+34 (España)' },
  { value: '+33', label: '+33 (Francia)' },
  { value: '+44', label: '+44 (Reino Unido)' },
  { value: '+49', label: '+49 (Alemania)' },
  { value: '+351', label: '+351 (Portugal)' },
  { value: '+1', label: '+1 (EE.UU./Canadá)' },
]

// Validation errors
const errors = ref<Record<string, string>>({})

// Progress percentage
const progress = computed(() => {
  const stepIndex = steps.findIndex(s => s.id === step.value)
  return ((stepIndex) / (steps.length - 1)) * 100
})

// Validation functions
const validatePersonal = (): boolean => {
  errors.value = {}
  let isValid = true

  if (!formData.value.personal.firstName || formData.value.personal.firstName.length < 2) {
    errors.value.firstName = 'El nombre debe tener al menos 2 caracteres'
    isValid = false
  }

  if (!formData.value.personal.lastName || formData.value.personal.lastName.length < 2) {
    errors.value.lastName = 'Los apellidos deben tener al menos 2 caracteres'
    isValid = false
  }

  if (!formData.value.personal.dateOfBirth) {
    errors.value.dateOfBirth = 'La fecha de nacimiento es requerida'
    isValid = false
  } else {
    const birthDate = new Date(formData.value.personal.dateOfBirth)
    const today = new Date()

    let age = today.getFullYear() - birthDate.getFullYear()
    const monthDiff = today.getMonth() - birthDate.getMonth()

    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--
    }

    if (age < 18) {
      errors.value.dateOfBirth = 'Debes ser mayor de 18 años'
      isValid = false
    }

    // Validar fechas futuras
    if (birthDate > today) {
      errors.value.dateOfBirth = 'La fecha de nacimiento no puede ser futura'
      isValid = false
    }
  }

  if (!formData.value.personal.nationality) {
    errors.value.nationality = 'La nacionalidad es requerida'
    isValid = false
  }

  return isValid
}

const validateDocument = (): boolean => {
  errors.value = {}
  let isValid = true

  if (!formData.value.document.documentType) {
    errors.value.documentType = 'Selecciona un tipo de documento'
    isValid = false
  }

  if (!formData.value.document.documentNumber || formData.value.document.documentNumber.length < 5) {
    errors.value.documentNumber = 'El número de documento es requerido'
    isValid = false
  }

  if (!formData.value.document.expirationDate) {
    errors.value.expirationDate = 'La fecha de caducidad es requerida'
    isValid = false
  } else {
    const expDate = new Date(formData.value.document.expirationDate)
    const today = new Date()
    if (expDate <= today) {
      errors.value.expirationDate = 'El documento ha caducado'
      isValid = false
    }
  }

  return isValid
}

const validatePostalCode = (postalCode: string, country: string): boolean => {
  const patterns: Record<string, RegExp> = {
    ES: /^\d{5}$/,
    GB: /^[A-Z]{1,2}\d{1,2}[A-Z]?\s?\d[A-Z]{2}$/i,
    US: /^\d{5}(-\d{4})?$/,
    CA: /^[A-Z]\d[A-Z]\s?\d[A-Z]\d$/i,
    FR: /^\d{5}$/,
    DE: /^\d{5}$/,
  }

  const pattern = patterns[country] || /^[\w\s-]{3,10}$/
  return pattern.test(postalCode)
}

const validateAddress = (): boolean => {
  errors.value = {}
  let isValid = true

  if (!formData.value.address.street || formData.value.address.street.length < 3) {
    errors.value.street = 'La calle es requerida'
    isValid = false
  }

  if (!formData.value.address.number) {
    errors.value.number = 'El número es requerido'
    isValid = false
  }

  if (!formData.value.address.postalCode) {
    errors.value.postalCode = 'El código postal es requerido'
    isValid = false
  } else if (!validatePostalCode(formData.value.address.postalCode, formData.value.personal.nationality || 'ES')) {
    errors.value.postalCode = 'El código postal no es válido para tu país'
    isValid = false
  }

  if (!formData.value.address.city || formData.value.address.city.length < 2) {
    errors.value.city = 'La ciudad es requerida'
    isValid = false
  }

  if (!formData.value.address.province || formData.value.address.province.length < 2) {
    errors.value.province = 'La provincia es requerida'
    isValid = false
  }

  return isValid
}

const validatePhoneNumber = (phone: string, countryCode: string): boolean => {
  const cleaned = phone.replace(/[\s\-\(\)]/g, '')

  if (!/^\d+$/.test(cleaned)) {
    return false
  }

  const lengths: Record<string, { min: number; max: number }> = {
    '+34': { min: 9, max: 9 },
    '+33': { min: 9, max: 9 },
    '+44': { min: 10, max: 10 },
    '+49': { min: 10, max: 11 },
    '+1': { min: 10, max: 10 },
  }

  const range = lengths[countryCode] || { min: 8, max: 15 }
  return cleaned.length >= range.min && cleaned.length <= range.max
}

const validatePhone = (): boolean => {
  errors.value = {}
  let isValid = true

  if (!formData.value.phone.countryCode) {
    errors.value.countryCode = 'Selecciona un código de país'
    isValid = false
  }

  if (!formData.value.phone.phoneNumber) {
    errors.value.phoneNumber = 'El número de teléfono es requerido'
    isValid = false
  } else if (!validatePhoneNumber(formData.value.phone.phoneNumber, formData.value.phone.countryCode || '+34')) {
    errors.value.phoneNumber = 'El número de teléfono no es válido'
    isValid = false
  }

  return isValid
}

// Navigation
const goToStep = (newStep: VerificationStep) => {
  step.value = newStep
  emit('step-change', newStep)
}

const nextStep = () => {
  let isValid = false

  switch (step.value) {
    case 'personal':
      isValid = validatePersonal()
      if (isValid) goToStep('document')
      break
    case 'document':
      isValid = validateDocument()
      if (isValid) goToStep('address')
      break
    case 'address':
      isValid = validateAddress()
      if (isValid) goToStep('phone')
      break
    case 'phone':
      isValid = validatePhone()
      if (isValid) goToStep('review')
      break
  }
}

const previousStep = () => {
  const currentIndex = steps.findIndex(s => s.id === step.value)
  if (currentIndex > 0) {
    goToStep(steps[currentIndex - 1].id)
  }
}

// Form actions
const handleSubmit = () => {
  emit('submit', formData.value)
}

const handleSendCode = () => {
  if (validatePhone()) {
    emit('send-verification-code')
  }
}

const handleCancel = () => {
  emit('cancel')
}

// Badge variant type
type BadgeVariant = 'default' | 'primary' | 'success' | 'warning' | 'error' | 'info'

// Status badge
const statusConfig: Record<VerificationStatus, { label: string; color: BadgeVariant }> = {
  not_started: { label: 'No Iniciado', color: 'default' },
  in_progress: { label: 'En Progreso', color: 'info' },
  pending_review: { label: 'Pendiente de Revisión', color: 'warning' },
  verified: { label: 'Verificado', color: 'success' },
  rejected: { label: 'Rechazado', color: 'error' },
}

const currentStatus = computed(() => statusConfig[props.verificationStatus])
</script>

<template>
  <Card class="verification-steps">
    <!-- Header -->
    <div class="verification-steps__header">
      <div class="flex items-start justify-between mb-4">
        <div>
          <h2 class="text-2xl font-bold mb-1">Verificación de Identidad</h2>
          <p class="text-sm text-gray-600 dark:text-gray-400">
            Completa todos los pasos para verificar tu identidad
          </p>
        </div>
        <Badge :variant="currentStatus.color" size="lg">
          {{ currentStatus.label }}
        </Badge>
      </div>

      <!-- Progress -->
      <div v-if="showProgress" class="mb-6">
        <div class="flex items-center justify-between mb-2">
          <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
            Paso {{ steps.findIndex(s => s.id === step) + 1 }} de {{ steps.length }}
          </span>
          <span class="text-sm text-gray-600 dark:text-gray-400">
            {{ Math.round(progress) }}% completado
          </span>
        </div>
        <ProgressBar :value="progress" />
      </div>

      <!-- Steps indicator -->
      <div class="flex items-center justify-between mb-6">
        <div
          v-for="(stepItem, index) in steps"
          :key="stepItem.id"
          class="flex items-center"
          :class="{ 'flex-1': index < steps.length - 1 }"
        >
          <div
            :class="[
              'w-8 h-8 rounded-full flex items-center justify-center text-sm transition-all',
              step === stepItem.id
                ? 'bg-primary text-white ring-4 ring-primary ring-opacity-20'
                : steps.findIndex(s => s.id === step) > index
                ? 'bg-green-600 text-white'
                : 'bg-gray-200 dark:bg-gray-700 text-gray-500',
            ]"
          >
            <Icon :name="stepItem.icon" class="w-4 h-4" />
          </div>
          <div
            v-if="index < steps.length - 1"
            :class="[
              'flex-1 h-0.5 mx-2',
              steps.findIndex(s => s.id === step) > index
                ? 'bg-green-600'
                : 'bg-gray-200 dark:bg-gray-700',
            ]"
          />
        </div>
      </div>
    </div>

    <!-- Form Steps -->
    <form @submit.prevent="handleSubmit" class="verification-steps__form">
      <!-- Step 1: Personal Info -->
      <div v-if="step === 'personal'" class="verification-steps__step">
        <h3 class="text-lg font-bold mb-4">Datos Personales</h3>
        <div class="space-y-4">
          <Input
            v-model="formData.personal.firstName"
            label="Nombre"
            placeholder="Tu nombre"
            :error="errors.firstName"
            :disabled="disabled || loading"
            required
          />
          <Input
            v-model="formData.personal.lastName"
            label="Apellidos"
            placeholder="Tus apellidos"
            :error="errors.lastName"
            :disabled="disabled || loading"
            required
          />
          <Input
            v-model="formData.personal.dateOfBirth"
            type="date"
            label="Fecha de Nacimiento"
            :error="errors.dateOfBirth"
            :disabled="disabled || loading"
            required
          />
          <Input
            v-model="formData.personal.nationality"
            label="Nacionalidad"
            placeholder="Ej: Española"
            :error="errors.nationality"
            :disabled="disabled || loading"
            required
          />
        </div>
      </div>

      <!-- Step 2: Document -->
      <div v-if="step === 'document'" class="verification-steps__step">
        <h3 class="text-lg font-bold mb-4">Documento de Identidad</h3>
        <div class="space-y-4">
          <Select
            v-model="formData.document.documentType"
            label="Tipo de Documento"
            :options="documentTypes"
            :error="errors.documentType"
            :disabled="disabled || loading"
            required
          />
          <Input
            v-model="formData.document.documentNumber"
            label="Número de Documento"
            placeholder="12345678A"
            :error="errors.documentNumber"
            :disabled="disabled || loading"
            required
          />
          <Input
            v-model="formData.document.expirationDate"
            type="date"
            label="Fecha de Caducidad"
            :error="errors.expirationDate"
            :disabled="disabled || loading"
            required
          />
          <div class="text-sm text-gray-600 dark:text-gray-400 p-4 bg-blue-50 dark:bg-blue-900 rounded">
            <Icon name="info" class="w-4 h-4 inline mr-2" />
            En el siguiente paso podrás subir imágenes de tu documento
          </div>
        </div>
      </div>

      <!-- Step 3: Address -->
      <div v-if="step === 'address'" class="verification-steps__step">
        <h3 class="text-lg font-bold mb-4">Dirección de Residencia</h3>
        <div class="space-y-4">
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div class="sm:col-span-2">
              <Input
                v-model="formData.address.street"
                label="Calle"
                placeholder="Nombre de la calle"
                :error="errors.street"
                :disabled="disabled || loading"
                required
              />
            </div>
            <Input
              v-model="formData.address.number"
              label="Número"
              placeholder="123"
              :error="errors.number"
              :disabled="disabled || loading"
              required
            />
          </div>
          <div class="grid grid-cols-2 gap-4">
            <Input
              v-model="formData.address.floor"
              label="Piso (opcional)"
              placeholder="1º"
              :disabled="disabled || loading"
            />
            <Input
              v-model="formData.address.door"
              label="Puerta (opcional)"
              placeholder="A"
              :disabled="disabled || loading"
            />
          </div>
          <Input
            v-model="formData.address.postalCode"
            label="Código Postal"
            placeholder="28001"
            :error="errors.postalCode"
            :disabled="disabled || loading"
            required
          />
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <Input
              v-model="formData.address.city"
              label="Ciudad"
              placeholder="Madrid"
              :error="errors.city"
              :disabled="disabled || loading"
              required
            />
            <Input
              v-model="formData.address.province"
              label="Provincia"
              placeholder="Madrid"
              :error="errors.province"
              :disabled="disabled || loading"
              required
            />
          </div>
        </div>
      </div>

      <!-- Step 4: Phone -->
      <div v-if="step === 'phone'" class="verification-steps__step">
        <h3 class="text-lg font-bold mb-4">Verificación de Teléfono</h3>
        <div class="space-y-4">
          <div class="grid grid-cols-3 gap-4">
            <Select
              v-model="formData.phone.countryCode"
              label="Código"
              :options="countryCodes"
              :error="errors.countryCode"
              :disabled="disabled || loading"
              required
            />
            <div class="col-span-2">
              <Input
                v-model="formData.phone.phoneNumber"
                label="Número de Teléfono"
                placeholder="600123456"
                :error="errors.phoneNumber"
                :disabled="disabled || loading"
                required
              />
            </div>
          </div>
          <Button
            variant="outline"
            @click="handleSendCode"
            :disabled="disabled || loading"
            type="button"
          >
            <Icon name="send" class="w-4 h-4 mr-2" />
            Enviar Código de Verificación
          </Button>
          <Input
            v-model="formData.phone.verificationCode"
            label="Código de Verificación"
            placeholder="123456"
            :disabled="disabled || loading"
          />
        </div>
      </div>

      <!-- Step 5: Review -->
      <div v-if="step === 'review'" class="verification-steps__step">
        <h3 class="text-lg font-bold mb-4">Revisión de Datos</h3>
        <div class="space-y-4">
          <div class="p-4 bg-gray-50 dark:bg-gray-800 rounded">
            <h4 class="font-semibold mb-2">Datos Personales</h4>
            <p class="text-sm">
              {{ formData.personal.firstName }} {{ formData.personal.lastName }}<br />
              Fecha de nacimiento: {{ formData.personal.dateOfBirth }}<br />
              Nacionalidad: {{ formData.personal.nationality }}
            </p>
          </div>
          <div class="p-4 bg-gray-50 dark:bg-gray-800 rounded">
            <h4 class="font-semibold mb-2">Documento</h4>
            <p class="text-sm">
              Tipo: {{ documentTypes.find(d => d.value === formData.document.documentType)?.label }}<br />
              Número: {{ formData.document.documentNumber }}<br />
              Caducidad: {{ formData.document.expirationDate }}
            </p>
          </div>
          <div class="p-4 bg-gray-50 dark:bg-gray-800 rounded">
            <h4 class="font-semibold mb-2">Dirección</h4>
            <p class="text-sm">
              {{ formData.address.street }} {{ formData.address.number }}
              <span v-if="formData.address.floor">, {{ formData.address.floor }}</span>
              <span v-if="formData.address.door">{{ formData.address.door }}</span><br />
              {{ formData.address.postalCode }} {{ formData.address.city }}<br />
              {{ formData.address.province }}
            </p>
          </div>
          <div class="p-4 bg-gray-50 dark:bg-gray-800 rounded">
            <h4 class="font-semibold mb-2">Teléfono</h4>
            <p class="text-sm">
              {{ formData.phone.countryCode }} {{ formData.phone.phoneNumber }}
            </p>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="verification-steps__actions">
        <div class="flex flex-col sm:flex-row gap-3 justify-between">
          <div class="flex gap-3">
            <Button
              v-if="step !== 'personal'"
              variant="outline"
              @click="previousStep"
              :disabled="disabled || loading"
              type="button"
            >
              <Icon name="chevron-left" class="w-4 h-4 mr-1" />
              Anterior
            </Button>
            <Button
              variant="ghost"
              @click="handleCancel"
              :disabled="loading"
              type="button"
            >
              Cancelar
            </Button>
          </div>

          <div class="flex gap-3">
            <Button
              v-if="step !== 'review'"
              variant="primary"
              @click="nextStep"
              :disabled="disabled || loading"
              type="button"
            >
              Siguiente
              <Icon name="chevron-right" class="w-4 h-4 ml-1" />
            </Button>

            <Button
              v-if="step === 'review'"
              variant="primary"
              type="submit"
              :loading="loading"
              :disabled="disabled"
            >
              <Icon name="check" class="w-4 h-4 mr-1" />
              Enviar Verificación
            </Button>
          </div>
        </div>
      </div>
    </form>
  </Card>
</template>

<style scoped>
.verification-steps {
  @apply w-full;
}

.verification-steps__header {
  @apply pb-6 border-b border-gray-200 dark:border-gray-700;
}

.verification-steps__step {
  @apply min-h-[400px] py-6;
}

.verification-steps__actions {
  @apply mt-6 pt-6 border-t border-gray-200 dark:border-gray-700;
}
</style>
