# frozen_string_literal: true

# Los engines comparten el arnés de test de la aplicación anfitriona en lugar de
# mantener una copia propia. Esa copia había divergido y era la causa de la mayor
# parte de los fallos de las suites de engines: sin spec/support/** no había stub
# de EngineActivation, ni DatabaseCleaner, ni helpers de Devise, ni locale fijado,
# ni las factories de test/factories.
require_relative '../../../spec/rails_helper'
