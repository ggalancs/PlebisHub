import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import MediaUploader from './MediaUploader.vue'
import type { UploadFile } from './MediaUploader.vue'

// Mock File and FileReader
interface MockFileReader {
  onload: ((event: { target: { result: string } }) => void) | null
  readAsDataURL: (blob: Blob) => void
}

;(globalThis as typeof globalThis & { FileReader: unknown }).FileReader = class FileReader {
  onload: ((event: { target: { result: string } }) => void) | null = null

  readAsDataURL = vi.fn(function(this: MockFileReader) {
    setTimeout(() => {
      if (this.onload) {
        this.onload({ target: { result: 'data:image/png;base64,mock' } })
      }
    }, 0)
  })
}

describe('MediaUploader', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(MediaUploader)
      expect(wrapper.find('.media-uploader').exists()).toBe(true)
    })

    it('should render drop zone', () => {
      const wrapper = mount(MediaUploader)
      expect(wrapper.find('.media-uploader__dropzone').exists()).toBe(true)
    })

    it('should render hidden file input', () => {
      const wrapper = mount(MediaUploader)
      expect(wrapper.find('input[type="file"]').exists()).toBe(true)
      expect(wrapper.find('input[type="file"]').classes()).toContain('hidden')
    })

    it('should show max file size', () => {
      const wrapper = mount(MediaUploader, {
        props: {
          maxSize: 5 * 1024 * 1024,
        },
      })
      expect(wrapper.text()).toContain('5 MB')
    })

    it('should show max files count when multiple is true', () => {
      const wrapper = mount(MediaUploader, {
        props: {
          maxFiles: 10,
          multiple: true,
        },
      })
      expect(wrapper.text()).toContain('10 archivos')
    })
  })

  describe('file validation', () => {
    it('should accept valid file types', () => {
      const wrapper = mount(MediaUploader, {
        props: {
          accept: 'image/*',
        },
      })
      expect(wrapper.find('input').attributes('accept')).toBe('image/*')
    })

    it('should set multiple attribute when multiple is true', () => {
      const wrapper = mount(MediaUploader, {
        props: {
          multiple: true,
        },
      })
      expect(wrapper.find('input').attributes('multiple')).toBeDefined()
    })

    it('should not set multiple attribute when multiple is false', () => {
      const wrapper = mount(MediaUploader, {
        props: {
          multiple: false,
        },
      })
      expect(wrapper.find('input').attributes('multiple')).toBeUndefined()
    })
  })

  describe('drag and drop', () => {
    it('should add dragging class on drag over', async () => {
      const wrapper = mount(MediaUploader)
      const dropzone = wrapper.find('.media-uploader__dropzone')

      const dragEvent = new Event('dragover') as DragEvent
      Object.defineProperty(dragEvent, 'dataTransfer', { value: { files: [] } })

      await dropzone.trigger('dragover', dragEvent)
      await nextTick()

      expect(dropzone.classes()).toContain('media-uploader__dropzone--dragging')
    })

    it('should remove dragging class on drag leave', async () => {
      const wrapper = mount(MediaUploader)
      const dropzone = wrapper.find('.media-uploader__dropzone')

      await dropzone.trigger('dragover')
      await dropzone.trigger('dragleave')
      await nextTick()

      expect(dropzone.classes()).not.toContain('media-uploader__dropzone--dragging')
    })

    it('should not add dragging class when disabled', async () => {
      const wrapper = mount(MediaUploader, {
        props: {
          disabled: true,
        },
      })

      const dropzone = wrapper.find('.media-uploader__dropzone')
      await dropzone.trigger('dragover')
      await nextTick()

      expect(dropzone.classes()).not.toContain('media-uploader__dropzone--dragging')
    })
  })

  describe('file picker', () => {
    it('should open file picker on dropzone click', async () => {
      const wrapper = mount(MediaUploader)
      const input = wrapper.find('input[type="file"]')
      const clickSpy = vi.spyOn(input.element as HTMLInputElement, 'click')

      const dropzone = wrapper.find('.media-uploader__dropzone')
      await dropzone.trigger('click')

      expect(clickSpy).toHaveBeenCalled()
    })

    it('should not open file picker when disabled', async () => {
      const wrapper = mount(MediaUploader, {
        props: {
          disabled: true,
        },
      })

      const input = wrapper.find('input[type="file"]')
      const clickSpy = vi.spyOn(input.element as HTMLInputElement, 'click')

      const dropzone = wrapper.find('.media-uploader__dropzone')
      await dropzone.trigger('click')

      expect(clickSpy).not.toHaveBeenCalled()
    })
  })

  describe('file display', () => {
    const mockFiles: UploadFile[] = [
      {
        id: '1',
        file: new File(['content'], 'test.jpg', { type: 'image/jpeg' }),
        progress: 100,
        status: 'success',
      },
    ]

    it('should show preview grid when showPreview is true', () => {
      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
          showPreview: true,
        },
      })

      expect(wrapper.find('.media-uploader__grid').exists()).toBe(true)
    })

    it('should show file list when showPreview is false', () => {
      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
          showPreview: false,
        },
      })

      expect(wrapper.find('.media-uploader__list').exists()).toBe(true)
    })

    it('should display file name', () => {
      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
        },
      })

      expect(wrapper.text()).toContain('test.jpg')
    })

    it('should show remove button for each file', () => {
      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
        },
      })

      expect(wrapper.find('.media-uploader__remove').exists()).toBe(true)
    })
  })

  describe('file removal', () => {
    it('should emit remove event when clicking remove button', async () => {
      const mockFiles: UploadFile[] = [
        {
          id: '1',
          file: new File(['content'], 'test.jpg', { type: 'image/jpeg' }),
          progress: 100,
          status: 'success',
        },
      ]

      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
        },
      })

      const removeButton = wrapper.find('.media-uploader__remove')
      await removeButton.trigger('click')

      expect(wrapper.emitted('remove')).toBeTruthy()
      expect(wrapper.emitted('remove')?.[0]).toEqual(['1'])
    })

    it('should update modelValue after removal', async () => {
      const mockFiles: UploadFile[] = [
        {
          id: '1',
          file: new File(['content'], 'test.jpg', { type: 'image/jpeg' }),
          progress: 100,
          status: 'success',
        },
      ]

      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
        },
      })

      const removeButton = wrapper.find('.media-uploader__remove')
      await removeButton.trigger('click')

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0][0]).toEqual([])
    })
  })

  describe('upload progress', () => {
    it('should show progress bar for uploading files', () => {
      const mockFiles: UploadFile[] = [
        {
          id: '1',
          file: new File(['content'], 'test.jpg', { type: 'image/jpeg' }),
          progress: 50,
          status: 'uploading',
        },
      ]

      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
        },
      })

      expect(wrapper.findComponent({ name: 'ProgressBar' }).exists()).toBe(true)
    })

    it('should show success badge for completed files', () => {
      const mockFiles: UploadFile[] = [
        {
          id: '1',
          file: new File(['content'], 'test.jpg', { type: 'image/jpeg' }),
          progress: 100,
          status: 'success',
        },
      ]

      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
        },
      })

      const badges = wrapper.findAllComponents({ name: 'Badge' })
      const successBadge = badges.find((badge) => badge.props('variant') === 'success')
      expect(successBadge).toBeTruthy()
    })

    it('should show error badge for failed files', () => {
      const mockFiles: UploadFile[] = [
        {
          id: '1',
          file: new File(['content'], 'test.jpg', { type: 'image/jpeg' }),
          progress: 0,
          status: 'error',
          error: 'Upload failed',
        },
      ]

      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
        },
      })

      const badges = wrapper.findAllComponents({ name: 'Badge' })
      const errorBadge = badges.find((badge) => badge.props('variant') === 'error')
      expect(errorBadge).toBeTruthy()
    })

    it('should display error message', () => {
      const mockFiles: UploadFile[] = [
        {
          id: '1',
          file: new File(['content'], 'test.jpg', { type: 'image/jpeg' }),
          progress: 0,
          status: 'error',
          error: 'Upload failed',
        },
      ]

      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
        },
      })

      expect(wrapper.text()).toContain('Upload failed')
    })
  })

  describe('file limits', () => {
    it('should show add more button when under limit', () => {
      const mockFiles: UploadFile[] = [
        {
          id: '1',
          file: new File(['content'], 'test.jpg', { type: 'image/jpeg' }),
          progress: 100,
          status: 'success',
        },
      ]

      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
          maxFiles: 5,
        },
      })

      expect(wrapper.find('.media-uploader__add-more').exists()).toBe(true)
    })

    it('should show remaining slots', () => {
      const mockFiles: UploadFile[] = [
        {
          id: '1',
          file: new File(['content'], 'test.jpg', { type: 'image/jpeg' }),
          progress: 100,
          status: 'success',
        },
      ]

      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
          maxFiles: 5,
        },
      })

      expect(wrapper.text()).toContain('4 restantes')
    })

    it('should not show add more button when limit reached', () => {
      const mockFiles: UploadFile[] = Array.from({ length: 5 }, (_, i) => ({
        id: `${i}`,
        file: new File(['content'], `test${i}.jpg`, { type: 'image/jpeg' }),
        progress: 100,
        status: 'success' as const,
      }))

      const wrapper = mount(MediaUploader, {
        props: {
          modelValue: mockFiles,
          maxFiles: 5,
        },
      })

      expect(wrapper.find('.media-uploader__add-more').exists()).toBe(false)
    })
  })

  describe('exposed methods', () => {
    it('should expose updateFileProgress method', () => {
      const wrapper = mount(MediaUploader)
      expect(wrapper.vm.updateFileProgress).toBeDefined()
    })

    it('should expose updateFileStatus method', () => {
      const wrapper = mount(MediaUploader)
      expect(wrapper.vm.updateFileStatus).toBeDefined()
    })

    it('should expose clearFiles method', () => {
      const wrapper = mount(MediaUploader)
      expect(wrapper.vm.clearFiles).toBeDefined()
    })
  })

  describe('file size formatting', () => {
    it('should format bytes correctly', () => {
      const wrapper = mount(MediaUploader, {
        props: {
          maxSize: 1024,
        },
      })
      expect(wrapper.text()).toContain('1 KB')
    })

    it('should format kilobytes correctly', () => {
      const wrapper = mount(MediaUploader, {
        props: {
          maxSize: 1024 * 1024,
        },
      })
      expect(wrapper.text()).toContain('1 MB')
    })
  })

  describe('disabled state', () => {
    it('should add disabled class when disabled', () => {
      const wrapper = mount(MediaUploader, {
        props: {
          disabled: true,
        },
      })

      expect(wrapper.find('.media-uploader__dropzone--disabled').exists()).toBe(true)
    })
  })
})
