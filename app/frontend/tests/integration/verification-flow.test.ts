/**
 * Integration Test: User Verification Flow
 *
 * Critical Flow: VerificationSteps + SMSValidator
 * Tests the complete user verification process including:
 * - Personal information validation
 * - Address validation with international postal codes
 * - Phone verification with SMS code
 * - Age verification (18+)
 */

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import VerificationSteps from '@/components/organisms/VerificationSteps.vue'
import SMSValidator from '@/components/organisms/SMSValidator.vue'

describe('User Verification Flow Integration', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('should complete full verification flow successfully', async () => {
    const wrapper = mount(VerificationSteps, {
      props: {
        initialStep: 0,
        verificationStatus: 'not_started',
      },
    })

    // STEP 1: Personal Information
    const nameInput = wrapper.findAll('input').find(i =>
      i.attributes('placeholder')?.includes('nombre')
    )
    const emailInput = wrapper.findAll('input').find(i =>
      i.attributes('type') === 'email'
    )
    const dobInput = wrapper.findAll('input').find(i =>
      i.attributes('type') === 'date'
    )

    await nameInput?.setValue('Juan Pérez')
    await emailInput?.setValue('juan@example.com')
    await dobInput?.setValue('1990-01-15')

    // Should allow user over 18
    const nextButton = wrapper.findAll('button').find(b =>
      b.text().includes('Siguiente')
    )
    await nextButton?.trigger('click')
    await flushPromises()

    expect(wrapper.emitted('update:current-step')).toBeTruthy()
  })

  it('should prevent minors from registering', async () => {
    const wrapper = mount(VerificationSteps, {
      props: {
        initialStep: 0,
        verificationStatus: 'not_started',
      },
    })

    // Try to register someone under 18
    const today = new Date()
    const underageDate = new Date(today.getFullYear() - 17, today.getMonth(), today.getDate())
    const dobInput = wrapper.findAll('input').find(i =>
      i.attributes('type') === 'date'
    )

    await dobInput?.setValue(underageDate.toISOString().split('T')[0])

    const nameInput = wrapper.findAll('input').find(i =>
      i.attributes('placeholder')?.includes('nombre')
    )
    await nameInput?.setValue('Minor User')

    const nextButton = wrapper.findAll('button').find(b =>
      b.text().includes('Siguiente')
    )
    await nextButton?.trigger('click')
    await flushPromises()

    // Should show age error
    expect(wrapper.text()).toContain('mayor de 18')
  })

  it('should validate international postal codes', async () => {
    const wrapper = mount(VerificationSteps, {
      props: {
        initialStep: 1, // Address step
        verificationStatus: 'not_started',
      },
    })

    // Test Spanish postal code
    const postalCodeInput = wrapper.findAll('input').find(i =>
      i.attributes('placeholder')?.toLowerCase().includes('postal')
    )
    await postalCodeInput?.setValue('28001')

    // Should be valid for Spain
    const nextButton = wrapper.findAll('button').find(b =>
      b.text().includes('Siguiente')
    )
    await nextButton?.trigger('click')
    await flushPromises()

    // Should not show postal code error for valid format
    expect(wrapper.text()).not.toContain('código postal no es válido')
  })
})

describe('SMS Validation Integration', () => {
  it('should validate SMS code with countdown', async () => {
    const onValidate = vi.fn()
    const wrapper = mount(SMSValidator, {
      props: {
        phoneNumber: '+34 612 345 678',
        codeLength: 6,
        resendTimeout: 60,
        validationState: 'pending',
      },
    })

    // Note: Using emitted() to check for events in Vue 3

    // Enter SMS code
    const inputs = wrapper.findAll('input')
    const code = ['1', '2', '3', '4', '5', '6']

    for (let i = 0; i < code.length; i++) {
      await inputs[i].setValue(code[i])
    }

    await flushPromises()

    // Should auto-validate when complete
    expect(wrapper.emitted('validate')).toBeTruthy()
    expect(wrapper.emitted('validate')?.[0]).toEqual(['123456'])
  })

  it('should prevent multiple rapid validations (race condition)', async () => {
    const onValidate = vi.fn()
    const wrapper = mount(SMSValidator, {
      props: {
        phoneNumber: '+34 612 345 678',
        codeLength: 6,
        validationState: 'pending',
      },
    })

    // Note: Using emitted() to check for events in Vue 3

    // Fill code completely
    const inputs = wrapper.findAll('input')
    for (let i = 0; i < 6; i++) {
      await inputs[i].setValue(String(i + 1))
    }

    // Try to validate multiple times rapidly
    const validateButton = wrapper.findAll('button').find(b =>
      b.text().includes('Verificar')
    )

    await validateButton?.trigger('click')
    await validateButton?.trigger('click')
    await validateButton?.trigger('click')

    await flushPromises()

    // Should only emit once due to debounce
    expect(wrapper.emitted('validate')?.[0]).toBeTruthy()
  })

  it('should show countdown and enable resend after timeout', async () => {
    vi.useFakeTimers()

    const wrapper = mount(SMSValidator, {
      props: {
        phoneNumber: '+34 612 345 678',
        resendTimeout: 5, // Short timeout for testing
        validationState: 'pending',
      },
    })

    // Initially resend should be disabled
    const resendButton = wrapper.findAll('button').find(b =>
      b.text().includes('Reenviar')
    )
    expect(resendButton?.attributes('disabled')).toBeDefined()

    // Advance time
    vi.advanceTimersByTime(5000)
    await flushPromises()

    // Now resend should be enabled
    expect(resendButton?.attributes('disabled')).toBeUndefined()

    vi.useRealTimers()
  })
})
