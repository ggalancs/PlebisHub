# frozen_string_literal: true

# Backward compatibility alias for PlebisBrand namespace
# The GeoExtra module was originally defined under Podemos module,
# but much of the codebase references it as PlebisBrand::GeoExtra
# This alias ensures compatibility across the application

PlebisBrand = Podemos unless defined?(PlebisBrand)
