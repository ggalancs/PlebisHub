// Brand Settings Color Tools
// Handles complementary color preview and auto-generation of color variants

;(function () {
  'use strict'

  // Color conversion utilities
  function hexToHSL(hex) {
    if (!hex || typeof hex !== 'string') return { h: 0, s: 0, l: 50 }
    hex = hex.replace('#', '')
    if (hex.length !== 6) return { h: 0, s: 0, l: 50 }

    var r = parseInt(hex.substring(0, 2), 16) / 255
    var g = parseInt(hex.substring(2, 4), 16) / 255
    var b = parseInt(hex.substring(4, 6), 16) / 255

    var max = Math.max(r, g, b)
    var min = Math.min(r, g, b)
    var h = 0,
      s = 0,
      l = (max + min) / 2

    if (max !== min) {
      var d = max - min
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
      if (max === r) {
        h = ((g - b) / d + (g < b ? 6 : 0)) / 6
      } else if (max === g) {
        h = ((b - r) / d + 2) / 6
      } else {
        h = ((r - g) / d + 4) / 6
      }
    }
    return { h: h * 360, s: s * 100, l: l * 100 }
  }

  function hue2rgb(p, q, t) {
    if (t < 0) t += 1
    if (t > 1) t -= 1
    if (t < 1 / 6) return p + (q - p) * 6 * t
    if (t < 1 / 2) return q
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6
    return p
  }

  function hslToHex(h, s, l) {
    h = ((h % 360) + 360) % 360
    h /= 360
    s /= 100
    l /= 100
    var r, g, b
    if (s === 0) {
      r = g = b = l
    } else {
      var q = l < 0.5 ? l * (1 + s) : l + s - l * s
      var p = 2 * l - q
      r = hue2rgb(p, q, h + 1 / 3)
      g = hue2rgb(p, q, h)
      b = hue2rgb(p, q, h - 1 / 3)
    }
    var toHex = function (x) {
      var hx = Math.round(x * 255).toString(16)
      return hx.length === 1 ? '0' + hx : hx
    }
    return '#' + toHex(r) + toHex(g) + toHex(b)
  }

  function lightenColor(hex) {
    var hsl = hexToHSL(hex)
    return hslToHex(hsl.h, hsl.s, Math.min(hsl.l + 25, 95))
  }

  function darkenColor(hex) {
    var hsl = hexToHSL(hex)
    return hslToHex(hsl.h, hsl.s, Math.max(hsl.l - 20, 5))
  }

  function complementaryColor(hex) {
    var hsl = hexToHSL(hex)
    return hslToHex(hsl.h + 180, hsl.s, hsl.l)
  }

  function updateComplementaryPreview(primaryHex) {
    var complementary = complementaryColor(primaryHex)
    var preview = document.getElementById('complementary_color_preview')
    var valueEl = document.getElementById('complementary_color_value')

    console.log('[BrandColorTools] Updating complementary:', primaryHex, '->', complementary)

    if (preview) {
      preview.style.backgroundColor = complementary
      preview.style.setProperty('background-color', complementary, 'important')
    }
    if (valueEl) {
      valueEl.textContent = complementary.toUpperCase()
      valueEl.style.color = complementary
    }
    return complementary
  }

  // Main initialization
  var initialized = false
  var lastPrimaryValue = ''
  var pollingInterval = null

  function initColorTools() {
    var primaryInput = document.getElementById('brand_setting_primary_color')
    var primaryTextInput = document.getElementById('brand_setting_primary_color_text')

    if (!primaryInput) {
      console.log('[BrandColorTools] Primary input not found, skipping init')
      return false
    }

    if (initialized) {
      console.log('[BrandColorTools] Already initialized')
      return true
    }

    console.log('[BrandColorTools] Initializing with primary value:', primaryInput.value)
    initialized = true
    lastPrimaryValue = primaryInput.value

    var autoGenCheckbox = document.getElementById('auto_generate_variants')
    var primaryLightInput = document.getElementById('brand_setting_primary_light_color')
    var primaryDarkInput = document.getElementById('brand_setting_primary_dark_color')
    var secondaryInput = document.getElementById('brand_setting_secondary_color')
    var secondaryLightInput = document.getElementById('brand_setting_secondary_light_color')
    var secondaryDarkInput = document.getElementById('brand_setting_secondary_dark_color')
    var applyComplementaryBtn = document.getElementById('apply_complementary_btn')

    // Update complementary on page load
    updateComplementaryPreview(primaryInput.value)

    // Validate hex color format
    function isValidHex(hex) {
      return /^#[0-9A-Fa-f]{6}$/.test(hex)
    }

    // Handle primary color changes (from either picker or text input)
    function handlePrimaryChange(newValue, source) {
      console.log(
        '[BrandColorTools] handlePrimaryChange called, value:',
        newValue,
        'source:',
        source
      )

      if (!isValidHex(newValue)) {
        console.log('[BrandColorTools] Invalid hex, skipping update')
        return
      }

      if (newValue !== lastPrimaryValue) {
        lastPrimaryValue = newValue
        updateComplementaryPreview(newValue)

        // Sync the other input
        if (source === 'picker' && primaryTextInput) {
          primaryTextInput.value = newValue.toUpperCase()
        } else if (source === 'text' && primaryInput) {
          primaryInput.value = newValue
        }

        // Auto-generate variants if enabled
        if (autoGenCheckbox && autoGenCheckbox.checked) {
          if (primaryLightInput) primaryLightInput.value = lightenColor(newValue)
          if (primaryDarkInput) primaryDarkInput.value = darkenColor(newValue)
        }
      }
    }

    // Listen to color picker events
    primaryInput.addEventListener('input', function () {
      console.log('[BrandColorTools] picker input event fired')
      handlePrimaryChange(this.value, 'picker')
    })
    primaryInput.addEventListener('change', function () {
      console.log('[BrandColorTools] picker change event fired')
      handlePrimaryChange(this.value, 'picker')
    })

    // Listen to text input events for INSTANT feedback
    if (primaryTextInput) {
      primaryTextInput.addEventListener('input', function () {
        var val = this.value.trim()
        // Add # if not present
        if (val && val[0] !== '#') {
          val = '#' + val
        }
        console.log('[BrandColorTools] text input event fired, value:', val)
        if (isValidHex(val)) {
          handlePrimaryChange(val, 'text')
        }
      })
      primaryTextInput.addEventListener('change', function () {
        var val = this.value.trim()
        if (val && val[0] !== '#') {
          val = '#' + val
          this.value = val.toUpperCase()
        }
        console.log('[BrandColorTools] text change event fired, value:', val)
        if (isValidHex(val)) {
          handlePrimaryChange(val, 'text')
        }
      })
      // Also handle keyup for faster feedback
      primaryTextInput.addEventListener('keyup', function () {
        var val = this.value.trim()
        if (val && val[0] !== '#') {
          val = '#' + val
        }
        if (isValidHex(val)) {
          handlePrimaryChange(val, 'text')
        }
      })
    }

    // Polling fallback - check every 100ms for color picker changes
    if (pollingInterval) clearInterval(pollingInterval)
    pollingInterval = setInterval(function () {
      if (primaryInput && primaryInput.value !== lastPrimaryValue) {
        console.log('[BrandColorTools] Polling detected change')
        handlePrimaryChange(primaryInput.value, 'picker')
      }
    }, 100)

    // Apply complementary button
    if (applyComplementaryBtn) {
      applyComplementaryBtn.onclick = function (e) {
        e.preventDefault()
        e.stopPropagation()
        var complementary = complementaryColor(primaryInput.value)
        console.log('[BrandColorTools] Applying complementary:', complementary)
        if (secondaryInput) secondaryInput.value = complementary
        if (autoGenCheckbox && autoGenCheckbox.checked) {
          if (secondaryLightInput) secondaryLightInput.value = lightenColor(complementary)
          if (secondaryDarkInput) secondaryDarkInput.value = darkenColor(complementary)
        }
        var btn = this
        btn.textContent = 'Applied!'
        btn.style.background = '#17a2b8'
        setTimeout(function () {
          btn.textContent = 'Use as Secondary'
          btn.style.background = '#28a745'
        }, 1500)
        return false
      }
    }

    // Handle secondary color changes
    if (secondaryInput) {
      function handleSecondaryChange() {
        if (autoGenCheckbox && autoGenCheckbox.checked) {
          if (secondaryLightInput) secondaryLightInput.value = lightenColor(secondaryInput.value)
          if (secondaryDarkInput) secondaryDarkInput.value = darkenColor(secondaryInput.value)
        }
      }
      secondaryInput.addEventListener('input', handleSecondaryChange)
      secondaryInput.addEventListener('change', handleSecondaryChange)
    }

    console.log('[BrandColorTools] Initialization complete')
    return true
  }

  // Try to initialize on various events
  function tryInit() {
    if (!initialized) {
      initColorTools()
    }
  }

  // Initialize on DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', tryInit)
  } else {
    tryInit()
  }

  // Turbolinks/Turbo support
  document.addEventListener('turbolinks:load', function () {
    initialized = false
    lastPrimaryValue = ''
    tryInit()
  })
  document.addEventListener('turbo:load', function () {
    initialized = false
    lastPrimaryValue = ''
    tryInit()
  })

  // ActiveAdmin page:load event
  document.addEventListener('page:load', function () {
    initialized = false
    lastPrimaryValue = ''
    tryInit()
  })

  // Retry initialization multiple times
  setTimeout(tryInit, 100)
  setTimeout(tryInit, 300)
  setTimeout(tryInit, 500)
  setTimeout(tryInit, 1000)
  setTimeout(tryInit, 2000)

  // Expose for debugging
  window.BrandColorTools = {
    init: initColorTools,
    hexToHSL: hexToHSL,
    hslToHex: hslToHex,
    complementaryColor: complementaryColor,
    updateComplementaryPreview: updateComplementaryPreview,
  }

  console.log('[BrandColorTools] Script loaded, window.BrandColorTools available for debugging')
})()
