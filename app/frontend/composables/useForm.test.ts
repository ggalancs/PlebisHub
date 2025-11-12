import { describe, it, expect, vi } from 'vitest'
import { nextTick } from 'vue'
import { useForm, validators } from './useForm'

describe('useForm', () => {
  describe('initialization', () => {
    it('should initialize with provided values', () => {
      const form = useForm({
        email: 'test@example.com',
        password: 'password123',
      })

      expect(form.values.email).toBe('test@example.com')
      expect(form.values.password).toBe('password123')
    })

    it('should initialize all fields as untouched', () => {
      const form = useForm({
        email: '',
        password: '',
      })

      expect(form.touched.email).toBe(false)
      expect(form.touched.password).toBe(false)
      expect(form.isTouched.value).toBe(false)
    })

    it('should initialize all fields as not dirty', () => {
      const form = useForm({
        email: '',
        password: '',
      })

      expect(form.dirty.email).toBe(false)
      expect(form.dirty.password).toBe(false)
      expect(form.isDirty.value).toBe(false)
    })

    it('should initialize with no errors', () => {
      const form = useForm({
        email: '',
        password: '',
      })

      expect(form.errors.value.email).toBe(null)
      expect(form.errors.value.password).toBe(null)
      expect(form.isValid.value).toBe(true)
    })
  })

  describe('setFieldValue', () => {
    it('should update field value', () => {
      const form = useForm({ email: '' })

      form.setFieldValue('email', 'test@example.com')
      expect(form.values.email).toBe('test@example.com')
    })

    it('should mark field as dirty when value changes', () => {
      const form = useForm({ email: 'initial@example.com' })

      form.setFieldValue('email', 'changed@example.com')
      expect(form.dirty.email).toBe(true)
      expect(form.isDirty.value).toBe(true)
    })

    it('should not mark field as dirty when value is same as initial', () => {
      const form = useForm({ email: 'test@example.com' })

      form.setFieldValue('email', 'changed@example.com')
      expect(form.dirty.email).toBe(true)

      form.setFieldValue('email', 'test@example.com')
      expect(form.dirty.email).toBe(false)
    })
  })

  describe('setFieldTouched', () => {
    it('should mark field as touched', () => {
      const form = useForm({ email: '' })

      form.setFieldTouched('email')
      expect(form.touched.email).toBe(true)
      expect(form.isTouched.value).toBe(true)
    })

    it('should mark field as not touched when passed false', () => {
      const form = useForm({ email: '' })

      form.setFieldTouched('email', true)
      expect(form.touched.email).toBe(true)

      form.setFieldTouched('email', false)
      expect(form.touched.email).toBe(false)
    })
  })

  describe('setFieldError', () => {
    it('should set field error', () => {
      const form = useForm({ email: '' })

      form.setFieldError('email', 'Email is invalid')
      expect(form.errors.value.email).toBe('Email is invalid')
      expect(form.isValid.value).toBe(false)
    })

    it('should clear field error when set to null', () => {
      const form = useForm({ email: '' })

      form.setFieldError('email', 'Error')
      expect(form.errors.value.email).toBe('Error')

      form.setFieldError('email', null)
      expect(form.errors.value.email).toBe(null)
      expect(form.isValid.value).toBe(true)
    })
  })

  describe('validation', () => {
    it('should validate field with rules', async () => {
      const form = useForm(
        { email: '' },
        {
          email: [{ validator: (v) => v.length > 0, message: 'Email is required' }],
        }
      )

      const isValid = await form.validateField('email')
      expect(isValid).toBe(false)
      expect(form.errors.value.email).toBe('Email is required')
    })

    it('should pass validation when field is valid', async () => {
      const form = useForm(
        { email: 'test@example.com' },
        {
          email: [{ validator: (v) => v.length > 0, message: 'Email is required' }],
        }
      )

      const isValid = await form.validateField('email')
      expect(isValid).toBe(true)
      expect(form.errors.value.email).toBe(null)
    })

    it('should validate with multiple rules', async () => {
      const form = useForm(
        { email: 'test' },
        {
          email: [
            { validator: (v) => v.length > 0, message: 'Email is required' },
            { validator: (v) => v.includes('@'), message: 'Email must contain @' },
          ],
        }
      )

      const isValid = await form.validateField('email')
      expect(isValid).toBe(false)
      expect(form.errors.value.email).toBe('Email must contain @')
    })

    it('should stop at first failing rule', async () => {
      const secondValidator = vi.fn(() => false)

      const form = useForm(
        { email: '' },
        {
          email: [
            { validator: (v) => v.length > 0, message: 'Required' },
            { validator: secondValidator, message: 'Invalid' },
          ],
        }
      )

      await form.validateField('email')
      expect(secondValidator).not.toHaveBeenCalled()
    })

    it('should validate entire form', async () => {
      const form = useForm(
        {
          email: '',
          password: '12345',
        },
        {
          email: [{ validator: (v) => v.length > 0, message: 'Email required' }],
          password: [{ validator: (v) => v.length >= 8, message: 'Password too short' }],
        }
      )

      const isValid = await form.validateForm()
      expect(isValid).toBe(false)
      expect(form.errors.value.email).toBe('Email required')
      expect(form.errors.value.password).toBe('Password too short')
    })

    it('should support async validators', async () => {
      const asyncValidator = vi.fn(
        () => new Promise<boolean>((resolve) => setTimeout(() => resolve(false), 10))
      )

      const form = useForm(
        { username: 'test' },
        {
          username: [{ validator: asyncValidator, message: 'Username taken' }],
        }
      )

      const isValid = await form.validateField('username')
      expect(isValid).toBe(false)
      expect(form.errors.value.username).toBe('Username taken')
      expect(asyncValidator).toHaveBeenCalledWith('test')
    })

    it('should set validating state during validation', async () => {
      const form = useForm(
        { email: 'test@example.com' },
        {
          email: [
            {
              validator: () => new Promise((resolve) => setTimeout(() => resolve(true), 50)),
              message: 'Error',
            },
          ],
        }
      )

      const validationPromise = form.validateField('email')
      expect(form.validating.email).toBe(true)
      expect(form.isValidating.value).toBe(true)

      await validationPromise
      expect(form.validating.email).toBe(false)
      expect(form.isValidating.value).toBe(false)
    })
  })

  describe('validation on change', () => {
    it('should not validate on change if field is not touched', async () => {
      const validator = vi.fn(() => true)

      const form = useForm(
        { email: '' },
        {
          email: [{ validator, message: 'Error' }],
        }
      )

      form.setFieldValue('email', 'test@example.com')
      await nextTick()

      expect(validator).not.toHaveBeenCalled()
    })

    it('should validate on change if field is touched', async () => {
      const form = useForm(
        { email: '' },
        {
          email: [{ validator: (v) => v.includes('@'), message: 'Invalid email' }],
        }
      )

      form.setFieldTouched('email')
      form.setFieldValue('email', 'test')
      await nextTick()
      await new Promise((resolve) => setTimeout(resolve, 10))

      expect(form.errors.value.email).toBe('Invalid email')
    })
  })

  describe('resetForm', () => {
    it('should reset all values to initial state', () => {
      const form = useForm({ email: 'initial@example.com', password: 'password' })

      form.setFieldValue('email', 'changed@example.com')
      form.setFieldValue('password', 'newpassword')
      form.resetForm()

      expect(form.values.email).toBe('initial@example.com')
      expect(form.values.password).toBe('password')
    })

    it('should clear all errors', () => {
      const form = useForm({ email: '' })

      form.setFieldError('email', 'Error')
      form.resetForm()

      expect(form.errors.value.email).toBe(null)
    })

    it('should reset touched and dirty states', () => {
      const form = useForm({ email: '' })

      form.setFieldTouched('email')
      form.setFieldValue('email', 'test@example.com')
      form.resetForm()

      expect(form.touched.email).toBe(false)
      expect(form.dirty.email).toBe(false)
    })

    it('should reset submitting state', () => {
      const form = useForm({ email: '' })

      form.isSubmitting.value = true
      form.resetForm()

      expect(form.isSubmitting.value).toBe(false)
    })
  })

  describe('resetField', () => {
    it('should reset specific field to initial value', () => {
      const form = useForm({ email: 'initial@example.com' })

      form.setFieldValue('email', 'changed@example.com')
      form.resetField('email')

      expect(form.values.email).toBe('initial@example.com')
    })

    it('should clear field error', () => {
      const form = useForm({ email: '' })

      form.setFieldError('email', 'Error')
      form.resetField('email')

      expect(form.errors.value.email).toBe(null)
    })

    it('should reset field touched and dirty states', () => {
      const form = useForm({ email: '' })

      form.setFieldTouched('email')
      form.setFieldValue('email', 'test@example.com')
      form.resetField('email')

      expect(form.touched.email).toBe(false)
      expect(form.dirty.email).toBe(false)
    })
  })

  describe('clearErrors', () => {
    it('should clear all field errors', () => {
      const form = useForm({ email: '', password: '' })

      form.setFieldError('email', 'Email error')
      form.setFieldError('password', 'Password error')
      form.clearErrors()

      expect(form.errors.value.email).toBe(null)
      expect(form.errors.value.password).toBe(null)
    })
  })

  describe('handleSubmit', () => {
    it('should prevent default event', async () => {
      const form = useForm({ email: 'test@example.com' })
      const mockEvent = { preventDefault: vi.fn() } as any
      const onSubmit = vi.fn()

      const handleSubmit = form.handleSubmit(onSubmit)
      await handleSubmit(mockEvent)

      expect(mockEvent.preventDefault).toHaveBeenCalled()
    })

    it('should mark all fields as touched', async () => {
      const form = useForm({ email: '', password: '' })
      const onSubmit = vi.fn()

      const handleSubmit = form.handleSubmit(onSubmit)
      await handleSubmit()

      expect(form.touched.email).toBe(true)
      expect(form.touched.password).toBe(true)
    })

    it('should validate form before submitting', async () => {
      const form = useForm(
        { email: '' },
        {
          email: [{ validator: (v) => v.length > 0, message: 'Required' }],
        }
      )
      const onSubmit = vi.fn()

      const handleSubmit = form.handleSubmit(onSubmit)
      await handleSubmit()

      expect(onSubmit).not.toHaveBeenCalled()
      expect(form.errors.value.email).toBe('Required')
    })

    it('should call onSubmit if form is valid', async () => {
      const form = useForm(
        { email: 'test@example.com' },
        {
          email: [{ validator: (v) => v.length > 0, message: 'Required' }],
        }
      )
      const onSubmit = vi.fn()

      const handleSubmit = form.handleSubmit(onSubmit)
      await handleSubmit()

      expect(onSubmit).toHaveBeenCalledWith({ email: 'test@example.com' })
    })

    it('should set submitting state during submission', async () => {
      const form = useForm({ email: 'test@example.com' })
      const onSubmit = vi.fn(() => new Promise((resolve) => setTimeout(resolve, 50)))

      const handleSubmit = form.handleSubmit(onSubmit)
      const submitPromise = handleSubmit()

      expect(form.isSubmitting.value).toBe(true)

      await submitPromise
      expect(form.isSubmitting.value).toBe(false)
    })

    it('should handle async onSubmit', async () => {
      const form = useForm({ email: 'test@example.com' })
      const onSubmit = vi.fn(async () => {
        await new Promise((resolve) => setTimeout(resolve, 10))
      })

      const handleSubmit = form.handleSubmit(onSubmit)
      await handleSubmit()

      expect(onSubmit).toHaveBeenCalled()
      expect(form.isSubmitting.value).toBe(false)
    })

    it('should handle submission errors gracefully', async () => {
      const form = useForm({ email: 'test@example.com' })
      const onSubmit = vi.fn(() => {
        throw new Error('Submission error')
      })

      const handleSubmit = form.handleSubmit(onSubmit)
      await handleSubmit()

      expect(form.isSubmitting.value).toBe(false)
    })
  })

  describe('validators', () => {
    describe('required', () => {
      it('should validate required fields', () => {
        const rule = validators.required()

        expect(rule.validator('')).toBe(false)
        expect(rule.validator('  ')).toBe(false)
        expect(rule.validator('value')).toBe(true)
        expect(rule.validator(null)).toBe(false)
        expect(rule.validator(undefined)).toBe(false)
      })

      it('should validate required arrays', () => {
        const rule = validators.required()

        expect(rule.validator([])).toBe(false)
        expect(rule.validator([1, 2])).toBe(true)
      })
    })

    describe('email', () => {
      it('should validate email format', () => {
        const rule = validators.email()

        expect(rule.validator('test@example.com')).toBe(true)
        expect(rule.validator('invalid')).toBe(false)
        expect(rule.validator('invalid@')).toBe(false)
        expect(rule.validator('@example.com')).toBe(false)
        expect(rule.validator('')).toBe(true) // Empty is valid (use required separately)
      })
    })

    describe('minLength', () => {
      it('should validate minimum length', () => {
        const rule = validators.minLength(5)

        expect(rule.validator('1234')).toBe(false)
        expect(rule.validator('12345')).toBe(true)
        expect(rule.validator('123456')).toBe(true)
        expect(rule.validator('')).toBe(true) // Empty is valid
      })
    })

    describe('maxLength', () => {
      it('should validate maximum length', () => {
        const rule = validators.maxLength(5)

        expect(rule.validator('123456')).toBe(false)
        expect(rule.validator('12345')).toBe(true)
        expect(rule.validator('1234')).toBe(true)
      })
    })

    describe('min', () => {
      it('should validate minimum value', () => {
        const rule = validators.min(18)

        expect(rule.validator(17)).toBe(false)
        expect(rule.validator(18)).toBe(true)
        expect(rule.validator(19)).toBe(true)
      })
    })

    describe('max', () => {
      it('should validate maximum value', () => {
        const rule = validators.max(100)

        expect(rule.validator(101)).toBe(false)
        expect(rule.validator(100)).toBe(true)
        expect(rule.validator(99)).toBe(true)
      })
    })

    describe('pattern', () => {
      it('should validate against regex pattern', () => {
        const rule = validators.pattern(/^\d{3}-\d{3}-\d{4}$/, 'Invalid phone')

        expect(rule.validator('123-456-7890')).toBe(true)
        expect(rule.validator('1234567890')).toBe(false)
        expect(rule.validator('')).toBe(true) // Empty is valid
      })
    })

    describe('url', () => {
      it('should validate URL format', () => {
        const rule = validators.url()

        expect(rule.validator('https://example.com')).toBe(true)
        expect(rule.validator('http://example.com')).toBe(true)
        expect(rule.validator('invalid')).toBe(false)
        expect(rule.validator('')).toBe(true) // Empty is valid
      })
    })
  })
})
