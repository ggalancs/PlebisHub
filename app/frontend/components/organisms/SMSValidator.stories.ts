import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import SMSValidator from './SMSValidator.vue'
import type { ValidationState } from './SMSValidator.vue'

const meta = {
  title: 'Organisms/SMSValidator',
  component: SMSValidator,
  tags: ['autodocs'],
  argTypes: {
    phoneNumber: {
      control: 'text',
      description: 'Phone number being verified',
    },
    codeLength: {
      control: { type: 'number', min: 4, max: 8 },
      description: 'Number of digits in code',
    },
    resendTimeout: {
      control: { type: 'number', min: 30, max: 300 },
      description: 'Seconds before resend is allowed',
    },
    validationState: {
      control: 'select',
      options: ['pending', 'validating', 'valid', 'invalid', 'expired'],
      description: 'Current validation state',
    },
    loading: {
      control: 'boolean',
      description: 'Loading state',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
    autofocus: {
      control: 'boolean',
      description: 'Auto-focus first input',
    },
  },
} satisfies Meta<typeof SMSValidator>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    phoneNumber: '+34 600123456',
  },
}

export const CodeLength4: Story = {
  args: {
    phoneNumber: '+34 600123456',
    codeLength: 4,
  },
}

export const CodeLength6: Story = {
  args: {
    phoneNumber: '+34 600123456',
    codeLength: 6,
  },
}

export const CodeLength8: Story = {
  args: {
    phoneNumber: '+34 600123456',
    codeLength: 8,
  },
}

export const StatePending: Story = {
  args: {
    phoneNumber: '+34 600123456',
    validationState: 'pending',
  },
}

export const StateValidating: Story = {
  args: {
    phoneNumber: '+34 600123456',
    validationState: 'validating',
  },
}

export const StateValid: Story = {
  args: {
    phoneNumber: '+34 600123456',
    validationState: 'valid',
  },
}

export const StateInvalid: Story = {
  args: {
    phoneNumber: '+34 600123456',
    validationState: 'invalid',
  },
}

export const StateExpired: Story = {
  args: {
    phoneNumber: '+34 600123456',
    validationState: 'expired',
  },
}

export const Loading: Story = {
  args: {
    phoneNumber: '+34 600123456',
    loading: true,
  },
}

export const Disabled: Story = {
  args: {
    phoneNumber: '+34 600123456',
    disabled: true,
  },
}

export const ShortTimeout: Story = {
  args: {
    phoneNumber: '+34 600123456',
    resendTimeout: 30,
  },
}

export const LongTimeout: Story = {
  args: {
    phoneNumber: '+34 600123456',
    resendTimeout: 180,
  },
}

export const NoAutofocus: Story = {
  args: {
    phoneNumber: '+34 600123456',
    autofocus: false,
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { SMSValidator },
    setup() {
      const phoneNumber = ref('+34 600123456')
      const validationState = ref<ValidationState>('pending')
      const loading = ref(false)
      const attempts = ref(0)

      const handleValidate = (code: string) => {
        console.log('Validating code:', code)
        attempts.value++
        loading.value = true
        validationState.value = 'validating'

        setTimeout(() => {
          if (code === '123456') {
            validationState.value = 'valid'
            alert('¡Código correcto! Verificación completada.')
          } else {
            validationState.value = 'invalid'
          }
          loading.value = false
        }, 1500)
      }

      const handleResend = () => {
        console.log('Resending code...')
        validationState.value = 'pending'
        alert('Nuevo código enviado a ' + phoneNumber.value)
      }

      const handleCancel = () => {
        if (confirm('¿Cancelar la verificación?')) {
          console.log('Verification cancelled')
        }
      }

      return {
        phoneNumber,
        validationState,
        loading,
        attempts,
        handleValidate,
        handleResend,
        handleCancel,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Validación de SMS Interactiva</h2>
        <p class="text-sm text-gray-600 mb-2">
          Código correcto: <strong>123456</strong>
        </p>
        <p class="text-sm text-gray-600 mb-6">
          Intentos: {{ attempts }}
        </p>
        <SMSValidator
          :phone-number="phoneNumber"
          :validation-state="validationState"
          :loading="loading"
          @validate="handleValidate"
          @resend="handleResend"
          @cancel="handleCancel"
        />
      </div>
    `,
  }),
  args: {},
}

export const DifferentPhoneNumbers: Story = {
  render: () => ({
    components: { SMSValidator },
    setup() {
      const phones = [
        '+34 600123456',
        '+33 612345678',
        '+44 7911 123456',
        '+1 (555) 123-4567',
      ]
      return { phones }
    },
    template: `
      <div class="p-6 space-y-8">
        <h2 class="text-2xl font-bold mb-6">Diferentes Formatos de Teléfono</h2>
        <div v-for="phone in phones" :key="phone">
          <h3 class="text-sm font-semibold mb-3 text-gray-700">{{ phone }}</h3>
          <SMSValidator :phone-number="phone" />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const AllStates: Story = {
  render: () => ({
    components: { SMSValidator },
    setup() {
      const states: ValidationState[] = ['pending', 'validating', 'valid', 'invalid', 'expired']
      return { states }
    },
    template: `
      <div class="p-6 space-y-8">
        <h2 class="text-2xl font-bold mb-6">Todos los Estados de Validación</h2>
        <div v-for="state in states" :key="state">
          <h3 class="text-sm font-semibold mb-3 capitalize text-gray-700">{{ state }}</h3>
          <SMSValidator
            phone-number="+34 600123456"
            :validation-state="state"
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const DifferentCodeLengths: Story = {
  render: () => ({
    components: { SMSValidator },
    setup() {
      const lengths = [4, 5, 6, 7, 8]
      return { lengths }
    },
    template: `
      <div class="p-6 space-y-8">
        <h2 class="text-2xl font-bold mb-6">Diferentes Longitudes de Código</h2>
        <div v-for="length in lengths" :key="length">
          <h3 class="text-sm font-semibold mb-3 text-gray-700">{{ length }} dígitos</h3>
          <SMSValidator
            phone-number="+34 600123456"
            :code-length="length"
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const ResendFlow: Story = {
  render: () => ({
    components: { SMSValidator },
    setup() {
      const resentCount = ref(0)

      const handleResend = () => {
        resentCount.value++
      }

      return {
        resentCount,
        handleResend,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Flujo de Reenvío</h2>
        <p class="text-sm text-gray-600 mb-6">
          Códigos reenviados: <strong>{{ resentCount }}</strong>
        </p>
        <SMSValidator
          phone-number="+34 600123456"
          :resend-timeout="10"
          @resend="handleResend"
        />
        <p class="text-xs text-gray-500 mt-4">
          El timeout está reducido a 10 segundos para esta demostración
        </p>
      </div>
    `,
  }),
  args: {},
}

export const ValidationWorkflow: Story = {
  render: () => ({
    components: { SMSValidator },
    setup() {
      const validationState = ref<ValidationState>('pending')
      const codeHistory = ref<string[]>([])

      const handleValidate = (code: string) => {
        codeHistory.value.push(code)

        if (code === '999999') {
          validationState.value = 'expired'
        } else if (code === '123456') {
          validationState.value = 'valid'
        } else {
          validationState.value = 'invalid'
        }
      }

      const handleResend = () => {
        validationState.value = 'pending'
      }

      const reset = () => {
        validationState.value = 'pending'
        codeHistory.value = []
      }

      return {
        validationState,
        codeHistory,
        handleValidate,
        handleResend,
        reset,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Flujo de Validación Completo</h2>
        <div class="mb-4 p-4 bg-blue-50 border border-blue-200 rounded">
          <p class="text-sm text-blue-800 mb-2">Códigos de prueba:</p>
          <ul class="text-xs text-blue-700 list-disc list-inside">
            <li><strong>123456</strong> - Válido</li>
            <li><strong>999999</strong> - Expirado</li>
            <li>Cualquier otro - Inválido</li>
          </ul>
        </div>
        <SMSValidator
          phone-number="+34 600123456"
          :validation-state="validationState"
          @validate="handleValidate"
          @resend="handleResend"
        />
        <div v-if="codeHistory.length > 0" class="mt-6 p-4 bg-gray-50 rounded">
          <h3 class="font-semibold mb-2 text-sm">Historial de Intentos:</h3>
          <ul class="text-xs space-y-1">
            <li v-for="(code, index) in codeHistory" :key="index">
              Intento {{ index + 1 }}: {{ code }}
            </li>
          </ul>
          <button
            @click="reset"
            class="mt-3 px-3 py-1 bg-gray-600 text-white rounded text-xs hover:bg-gray-700"
          >
            Reiniciar
          </button>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const MobileView: Story = {
  render: () => ({
    components: { SMSValidator },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Vista Móvil (max-width: 400px)</h2>
        <div class="max-w-sm mx-auto border border-gray-300 rounded-lg p-4">
          <SMSValidator phone-number="+34 600123456" />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const WithCountdown: Story = {
  render: () => ({
    components: { SMSValidator },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Con Cuenta Regresiva Activa</h2>
        <p class="text-sm text-gray-600 mb-6">
          El botón de reenvío se habilitará después del countdown
        </p>
        <SMSValidator
          phone-number="+34 600123456"
          :resend-timeout="120"
        />
      </div>
    `,
  }),
  args: {},
}

export const ErrorRecovery: Story = {
  render: () => ({
    components: { SMSValidator },
    setup() {
      const validationState = ref<ValidationState>('pending')
      const errorCount = ref(0)

      const handleValidate = (code: string) => {
        if (code !== '123456') {
          errorCount.value++
          validationState.value = 'invalid'
          setTimeout(() => {
            validationState.value = 'pending'
          }, 2000)
        } else {
          validationState.value = 'valid'
          errorCount.value = 0
        }
      }

      return {
        validationState,
        errorCount,
        handleValidate,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Recuperación de Errores</h2>
        <p class="text-sm text-gray-600 mb-2">
          Código correcto: <strong>123456</strong>
        </p>
        <p class="text-sm text-red-600 mb-6">
          Errores: {{ errorCount }}
        </p>
        <SMSValidator
          phone-number="+34 600123456"
          :validation-state="validationState"
          @validate="handleValidate"
        />
      </div>
    `,
  }),
  args: {},
}
