/**
 * Composable for date formatting
 * Provides consistent date formatting across the application
 */

export function useDateFormat() {
  /**
   * Format date relative to now (e.g., "hace 2 horas")
   */
  const formatRelativeDate = (date: Date | string): string => {
    const d = typeof date === 'string' ? new Date(date) : date

    // Validate date
    if (isNaN(d.getTime())) {
      return 'Fecha inválida'
    }

    const now = new Date()
    const diff = now.getTime() - d.getTime()

    // If future date
    if (diff < 0) {
      return d.toLocaleDateString('es-ES', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    }

    const seconds = Math.floor(diff / 1000)
    const minutes = Math.floor(seconds / 60)
    const hours = Math.floor(minutes / 60)
    const days = Math.floor(hours / 24)
    const weeks = Math.floor(days / 7)
    const months = Math.floor(days / 30)
    const years = Math.floor(days / 365)

    if (years > 0) {
      return `hace ${years} ${years === 1 ? 'año' : 'años'}`
    } else if (months > 0) {
      return `hace ${months} ${months === 1 ? 'mes' : 'meses'}`
    } else if (weeks > 0) {
      return `hace ${weeks} ${weeks === 1 ? 'semana' : 'semanas'}`
    } else if (days > 0) {
      return `hace ${days} ${days === 1 ? 'día' : 'días'}`
    } else if (hours > 0) {
      return `hace ${hours} ${hours === 1 ? 'hora' : 'horas'}`
    } else if (minutes > 0) {
      return `hace ${minutes} ${minutes === 1 ? 'minuto' : 'minutos'}`
    } else {
      return 'hace un momento'
    }
  }

  /**
   * Format absolute date (e.g., "15 de enero de 2025")
   */
  const formatAbsoluteDate = (date: Date | string, options?: Intl.DateTimeFormatOptions): string => {
    const d = typeof date === 'string' ? new Date(date) : date

    if (isNaN(d.getTime())) {
      return 'Fecha inválida'
    }

    return d.toLocaleDateString('es-ES', options || {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  /**
   * Format short date (e.g., "15/01/2025")
   */
  const formatShortDate = (date: Date | string): string => {
    return formatAbsoluteDate(date, {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  }

  return {
    formatRelativeDate,
    formatAbsoluteDate,
    formatShortDate
  }
}
