# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaHelper, type: :helper do
  # Create a test object that includes the helper to ensure proper coverage tracking
  let(:test_object) do
    Class.new do
      include ImpulsaHelper
    end.new
  end

  describe '#filetypes_to_file_filter' do
    context 'when filetype is nil' do
      it 'returns nil' do
        expect(test_object.filetypes_to_file_filter(nil)).to be_nil
      end
    end

    context 'when filetype is not in FILETYPES' do
      it 'raises a NoMethodError' do
        expect do
          test_object.filetypes_to_file_filter(:unknown_type)
        end.to raise_error(NoMethodError)
      end
    end

    context 'when filetype is :sheet' do
      it 'returns the correct file filter string with extensions and MIME types' do
        # Expected extensions: xls, xlsx, ods
        # EXTENSIONS hash should map these to MIME types
        result = test_object.filetypes_to_file_filter(:sheet)

        # Should include dot-prefixed extensions
        expect(result).to include('.xls')
        expect(result).to include('.xlsx')
        expect(result).to include('.ods')

        # Should include MIME types
        expect(result).to include('application/vnd.ms-excel') # xls
        expect(result).to include('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') # xlsx
        expect(result).to include('application/vnd.oasis.opendocument.spreadsheet') # ods

        # Should be comma-separated
        expect(result.count(',')).to eq(5) # 6 items = 5 commas
      end

      it 'formats the result as a comma-separated string' do
        result = test_object.filetypes_to_file_filter(:sheet)
        expect(result).to be_a(String)
        expect(result).to match(/^(\.[a-z]+|application\/[^,]+)(,(\.[a-z]+|application\/[^,]+))*$/)
      end
    end

    context 'when filetype is :scan' do
      it 'returns the correct file filter string with extensions and MIME types' do
        # Expected extensions: jpg, pdf
        result = test_object.filetypes_to_file_filter(:scan)

        # Should include dot-prefixed extensions
        expect(result).to include('.jpg')
        expect(result).to include('.pdf')

        # Should include MIME types
        expect(result).to include('image/jpeg') # jpg
        expect(result).to include('application/pdf') # pdf

        # Should be comma-separated
        expect(result.count(',')).to eq(3) # 4 items = 3 commas
      end
    end

    context 'when filetype is :document' do
      it 'returns the correct file filter string with extensions and MIME types' do
        # Expected extensions: doc, docx, odt
        result = test_object.filetypes_to_file_filter(:document)

        # Should include dot-prefixed extensions
        expect(result).to include('.doc')
        expect(result).to include('.docx')
        expect(result).to include('.odt')

        # Should include MIME types
        expect(result).to include('application/msword') # doc
        expect(result).to include('application/vnd.openxmlformats-officedocument.wordprocessingml.document') # docx
        expect(result).to include('application/vnd.oasis.opendocument.text') # odt

        # Should be comma-separated
        expect(result.count(',')).to eq(5) # 6 items = 5 commas
      end
    end

    context 'when filetype is a string' do
      it 'converts string to symbol and processes correctly' do
        result = test_object.filetypes_to_file_filter('sheet')

        expect(result).to include('.xls')
        expect(result).to include('.xlsx')
        expect(result).to include('.ods')
        expect(result).to include('application/vnd.ms-excel')
      end
    end

    context 'with different input formats' do
      it 'handles symbol input' do
        expect do
          test_object.filetypes_to_file_filter(:sheet)
        end.not_to raise_error
      end

      it 'handles string input' do
        expect do
          test_object.filetypes_to_file_filter('document')
        end.not_to raise_error
      end
    end

    context 'validating output format' do
      it 'does not include duplicate entries' do
        result = test_object.filetypes_to_file_filter(:sheet)
        items = result.split(',')

        expect(items.length).to eq(items.uniq.length)
      end

      it 'includes both extensions and MIME types for each file type' do
        result = test_object.filetypes_to_file_filter(:scan)
        items = result.split(',')

        # Should have extensions (.jpg, .pdf)
        extensions = items.select { |item| item.start_with?('.') }
        expect(extensions.length).to eq(2)

        # Should have MIME types (image/jpeg, application/pdf)
        mime_types = items.select { |item| item.include?('/') }
        expect(mime_types.length).to eq(2)
      end
    end

    context 'edge cases' do
      it 'raises error for empty string filetype' do
        # Empty string is truthy but converts to empty symbol which doesn't exist in FILETYPES
        expect do
          test_object.filetypes_to_file_filter('')
        end.to raise_error(NoMethodError)
      end

      it 'handles false as filetype' do
        expect(test_object.filetypes_to_file_filter(false)).to be_nil
      end

      it 'raises error for blank string' do
        # Blank string is truthy but converts to symbol with spaces which doesn't exist
        expect do
          test_object.filetypes_to_file_filter('   ')
        end.to raise_error(NoMethodError)
      end
    end

    context 'integration with ImpulsaProject constants' do
      it 'uses ImpulsaProject::FILETYPES constant' do
        # Verify the constant exists and has expected structure
        expect(ImpulsaProject::FILETYPES).to be_a(Hash)
        expect(ImpulsaProject::FILETYPES).to have_key(:sheet)
        expect(ImpulsaProject::FILETYPES).to have_key(:scan)
        expect(ImpulsaProject::FILETYPES).to have_key(:document)
      end

      it 'uses ImpulsaProject::EXTENSIONS constant' do
        # Verify the constant exists and has expected structure
        expect(ImpulsaProject::EXTENSIONS).to be_a(Hash)
        expect(ImpulsaProject::EXTENSIONS).to have_key(:pdf)
        expect(ImpulsaProject::EXTENSIONS).to have_key(:jpg)
        expect(ImpulsaProject::EXTENSIONS).to have_key(:doc)
      end

      it 'correctly maps extensions to MIME types for all defined types' do
        ImpulsaProject::FILETYPES.each_key do |filetype|
          result = test_object.filetypes_to_file_filter(filetype)

          # Verify result is not empty
          expect(result).to be_present

          # Verify it contains both extensions and MIME types
          expect(result).to match(/\./)
          expect(result).to match(/\//)
        end
      end
    end

    context 'performance and consistency' do
      it 'returns the same result for multiple calls with the same input' do
        result1 = test_object.filetypes_to_file_filter(:sheet)
        result2 = test_object.filetypes_to_file_filter(:sheet)

        expect(result1).to eq(result2)
      end

      it 'processes all valid filetypes without errors' do
        expect do
          test_object.filetypes_to_file_filter(:sheet)
          test_object.filetypes_to_file_filter(:scan)
          test_object.filetypes_to_file_filter(:document)
        end.not_to raise_error
      end
    end
  end
end
