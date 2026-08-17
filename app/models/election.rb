# frozen_string_literal: true

# La funcionalidad vive en el engine PlebisVotes. La aplicacion solo conserva
# este punto de personalizacion, al estilo de las subclases de Devise.
class Election < PlebisVotes::Election
end
