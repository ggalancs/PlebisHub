# frozen_string_literal: true

# DEPRECATED: This class is deprecated and will be removed in a future version.
# Use PlebisCms::Notice directly instead.
#
# This alias maintains backward compatibility with existing code that references
# the Notice model without the PlebisCms namespace.
class Notice < PlebisCms::Notice
  paginates_per 5
end
