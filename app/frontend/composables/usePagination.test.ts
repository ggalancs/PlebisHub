import { describe, it, expect } from 'vitest'
import { usePagination } from './usePagination'

describe('usePagination', () => {
  describe('initialization', () => {
    it('should initialize with default values', () => {
      const pagination = usePagination()

      expect(pagination.currentPage.value).toBe(1)
      expect(pagination.pageSize.value).toBe(10)
      expect(pagination.total.value).toBe(0)
      expect(pagination.totalPages.value).toBe(1)
    })

    it('should initialize with custom values', () => {
      const pagination = usePagination({
        currentPage: 3,
        pageSize: 20,
        total: 100,
      })

      expect(pagination.currentPage.value).toBe(3)
      expect(pagination.pageSize.value).toBe(20)
      expect(pagination.total.value).toBe(100)
      expect(pagination.totalPages.value).toBe(5)
    })
  })

  describe('totalPages calculation', () => {
    it('should calculate total pages correctly', () => {
      const pagination = usePagination({ total: 100, pageSize: 10 })
      expect(pagination.totalPages.value).toBe(10)
    })

    it('should round up for partial pages', () => {
      const pagination = usePagination({ total: 95, pageSize: 10 })
      expect(pagination.totalPages.value).toBe(10)
    })

    it('should return 1 for zero total', () => {
      const pagination = usePagination({ total: 0, pageSize: 10 })
      expect(pagination.totalPages.value).toBe(1)
    })

    it('should handle single item', () => {
      const pagination = usePagination({ total: 1, pageSize: 10 })
      expect(pagination.totalPages.value).toBe(1)
    })
  })

  describe('hasPrevPage and hasNextPage', () => {
    it('should correctly determine previous page availability', () => {
      const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 1 })
      expect(pagination.hasPrevPage.value).toBe(false)

      pagination.currentPage.value = 2
      expect(pagination.hasPrevPage.value).toBe(true)
    })

    it('should correctly determine next page availability', () => {
      const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 10 })
      expect(pagination.hasNextPage.value).toBe(false)

      pagination.currentPage.value = 9
      expect(pagination.hasNextPage.value).toBe(true)
    })

    it('should handle single page', () => {
      const pagination = usePagination({ total: 5, pageSize: 10, currentPage: 1 })
      expect(pagination.hasPrevPage.value).toBe(false)
      expect(pagination.hasNextPage.value).toBe(false)
    })
  })

  describe('isPaginationNeeded', () => {
    it('should return false for single page', () => {
      const pagination = usePagination({ total: 5, pageSize: 10 })
      expect(pagination.isPaginationNeeded.value).toBe(false)
    })

    it('should return true for multiple pages', () => {
      const pagination = usePagination({ total: 20, pageSize: 10 })
      expect(pagination.isPaginationNeeded.value).toBe(true)
    })
  })

  describe('startIndex and endIndex', () => {
    it('should calculate correct indices for first page', () => {
      const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 1 })
      expect(pagination.startIndex.value).toBe(0)
      expect(pagination.endIndex.value).toBe(10)
    })

    it('should calculate correct indices for middle page', () => {
      const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 5 })
      expect(pagination.startIndex.value).toBe(40)
      expect(pagination.endIndex.value).toBe(50)
    })

    it('should calculate correct indices for last page', () => {
      const pagination = usePagination({ total: 95, pageSize: 10, currentPage: 10 })
      expect(pagination.startIndex.value).toBe(90)
      expect(pagination.endIndex.value).toBe(95)
    })

    it('should not exceed total for last page', () => {
      const pagination = usePagination({ total: 95, pageSize: 10, currentPage: 10 })
      expect(pagination.endIndex.value).toBe(95)
    })
  })

  describe('pageRange', () => {
    it('should show all pages when total pages <= 7', () => {
      const pagination = usePagination({ total: 50, pageSize: 10, currentPage: 1 })
      expect(pagination.pageRange.value).toEqual([1, 2, 3, 4, 5])
    })

    it('should show dots on right when current page is near start', () => {
      const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 2, siblingCount: 1 })
      // [1, 2, 3, ..., 10]
      expect(pagination.pageRange.value).toContain('...')
      expect(pagination.pageRange.value[0]).toBe(1)
      expect(pagination.pageRange.value[pagination.pageRange.value.length - 1]).toBe(10)
    })

    it('should show dots on left when current page is near end', () => {
      const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 9, siblingCount: 1 })
      // [1, ..., 8, 9, 10]
      expect(pagination.pageRange.value).toContain('...')
      expect(pagination.pageRange.value[0]).toBe(1)
      expect(pagination.pageRange.value[pagination.pageRange.value.length - 1]).toBe(10)
    })

    it('should show dots on both sides when current page is in middle', () => {
      const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 5, siblingCount: 1 })
      // [1, ..., 4, 5, 6, ..., 10]
      const range = pagination.pageRange.value
      expect(range.filter((p) => p === '...')).toHaveLength(2)
      expect(range[0]).toBe(1)
      expect(range[range.length - 1]).toBe(10)
    })

    it('should return [1] for single page', () => {
      const pagination = usePagination({ total: 5, pageSize: 10, currentPage: 1 })
      expect(pagination.pageRange.value).toEqual([1])
    })
  })

  describe('navigation methods', () => {
    describe('goToPage', () => {
      it('should navigate to specific page', () => {
        const pagination = usePagination({ total: 100, pageSize: 10 })
        pagination.goToPage(5)
        expect(pagination.currentPage.value).toBe(5)
      })

      it('should not exceed total pages', () => {
        const pagination = usePagination({ total: 100, pageSize: 10 })
        pagination.goToPage(999)
        expect(pagination.currentPage.value).toBe(10)
      })

      it('should not go below page 1', () => {
        const pagination = usePagination({ total: 100, pageSize: 10 })
        pagination.goToPage(-5)
        expect(pagination.currentPage.value).toBe(1)
      })

      it('should handle page 0', () => {
        const pagination = usePagination({ total: 100, pageSize: 10 })
        pagination.goToPage(0)
        expect(pagination.currentPage.value).toBe(1)
      })
    })

    describe('nextPage', () => {
      it('should move to next page', () => {
        const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 1 })
        pagination.nextPage()
        expect(pagination.currentPage.value).toBe(2)
      })

      it('should not exceed total pages', () => {
        const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 10 })
        pagination.nextPage()
        expect(pagination.currentPage.value).toBe(10)
      })
    })

    describe('prevPage', () => {
      it('should move to previous page', () => {
        const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 5 })
        pagination.prevPage()
        expect(pagination.currentPage.value).toBe(4)
      })

      it('should not go below page 1', () => {
        const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 1 })
        pagination.prevPage()
        expect(pagination.currentPage.value).toBe(1)
      })
    })

    describe('firstPage', () => {
      it('should navigate to first page', () => {
        const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 5 })
        pagination.firstPage()
        expect(pagination.currentPage.value).toBe(1)
      })
    })

    describe('lastPage', () => {
      it('should navigate to last page', () => {
        const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 1 })
        pagination.lastPage()
        expect(pagination.currentPage.value).toBe(10)
      })
    })
  })

  describe('changePageSize', () => {
    it('should change page size and reset to page 1', () => {
      const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 5 })
      pagination.changePageSize(20)

      expect(pagination.pageSize.value).toBe(20)
      expect(pagination.currentPage.value).toBe(1)
      expect(pagination.totalPages.value).toBe(5)
    })

    it('should not allow page size less than 1', () => {
      const pagination = usePagination({ total: 100, pageSize: 10 })
      pagination.changePageSize(0)
      expect(pagination.pageSize.value).toBe(1)
    })

    it('should handle negative page size', () => {
      const pagination = usePagination({ total: 100, pageSize: 10 })
      pagination.changePageSize(-5)
      expect(pagination.pageSize.value).toBe(1)
    })
  })

  describe('paginateArray', () => {
    it('should paginate array correctly', () => {
      const items = Array.from({ length: 100 }, (_, i) => i + 1)
      const pagination = usePagination({ total: items.length, pageSize: 10, currentPage: 1 })

      const page1 = pagination.paginateArray(items)
      expect(page1).toEqual([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])

      pagination.currentPage.value = 2
      const page2 = pagination.paginateArray(items)
      expect(page2).toEqual([11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
    })

    it('should handle last page with fewer items', () => {
      const items = Array.from({ length: 95 }, (_, i) => i + 1)
      const pagination = usePagination({ total: items.length, pageSize: 10, currentPage: 10 })

      const lastPage = pagination.paginateArray(items)
      expect(lastPage).toEqual([91, 92, 93, 94, 95])
    })

    it('should handle empty array', () => {
      const items: number[] = []
      const pagination = usePagination({ total: 0, pageSize: 10 })

      const result = pagination.paginateArray(items)
      expect(result).toEqual([])
    })

    it('should handle single item', () => {
      const items = [42]
      const pagination = usePagination({ total: 1, pageSize: 10 })

      const result = pagination.paginateArray(items)
      expect(result).toEqual([42])
    })
  })

  describe('reactivity', () => {
    it('should update totalPages when total changes', () => {
      const pagination = usePagination({ total: 100, pageSize: 10 })
      expect(pagination.totalPages.value).toBe(10)

      pagination.total.value = 200
      expect(pagination.totalPages.value).toBe(20)
    })

    it('should update totalPages when pageSize changes', () => {
      const pagination = usePagination({ total: 100, pageSize: 10 })
      expect(pagination.totalPages.value).toBe(10)

      pagination.pageSize.value = 20
      expect(pagination.totalPages.value).toBe(5)
    })

    it('should reset to last page if current page exceeds total after change', () => {
      const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 10 })
      expect(pagination.currentPage.value).toBe(10)

      pagination.total.value = 50
      expect(pagination.currentPage.value).toBe(5)
    })

    it('should update hasPrevPage and hasNextPage reactively', () => {
      const pagination = usePagination({ total: 100, pageSize: 10, currentPage: 5 })

      expect(pagination.hasPrevPage.value).toBe(true)
      expect(pagination.hasNextPage.value).toBe(true)

      pagination.currentPage.value = 1
      expect(pagination.hasPrevPage.value).toBe(false)
      expect(pagination.hasNextPage.value).toBe(true)

      pagination.currentPage.value = 10
      expect(pagination.hasPrevPage.value).toBe(true)
      expect(pagination.hasNextPage.value).toBe(false)
    })
  })

  describe('edge cases', () => {
    it('should handle very large numbers', () => {
      const pagination = usePagination({ total: 1000000, pageSize: 100, currentPage: 1 })
      expect(pagination.totalPages.value).toBe(10000)
    })

    it('should handle decimal page size (rounds down)', () => {
      const pagination = usePagination({ total: 100, pageSize: 10 })
      pagination.pageSize.value = 10.7
      expect(pagination.totalPages.value).toBe(Math.ceil(100 / 10.7))
    })

    it('should handle page 1 with zero total', () => {
      const pagination = usePagination({ total: 0, pageSize: 10, currentPage: 1 })
      expect(pagination.currentPage.value).toBe(1)
      expect(pagination.totalPages.value).toBe(1)
      expect(pagination.startIndex.value).toBe(0)
      expect(pagination.endIndex.value).toBe(0)
    })
  })
})
