require 'test_helper'
require 'plebisbrand_import'

class PlebisBrandImportTest < ActiveSupport::TestCase

#  test "should #init work" do
#    skip("TODO")
#    csv_file = "#{Rails.root}/test/lib/juntos_test.csv"
#    PlebisBrandImport.init(csv_file)
#    # User.difference N
#    User.count
#  end

  # DOCUMENT: Pasaporte NIE DNI 

  test "should #convert_document_type work" do
    assert_equal 1, PlebisBrandImport.convert_document_type("DNI / NIE", "N888888")
    assert_equal 2, PlebisBrandImport.convert_document_type("DNI / NIE", "X888888")
    assert_equal 3, PlebisBrandImport.convert_document_type("Pasaporte", "D888888")
  end

#  test "should #invalid_record work" do
#    skip("TODO")
#    #PlebisBrandImport.invalid_record(logger)
#  end
#
#  test "should #process_row work" do
#    skip("TODO")
#    #PlebisBrandImport.process_row(logger)
#  end

  test "should #convert_province work" do
    assert_equal PlebisBrandImport.convert_province("28002", "España", "Madrid"), "M"
    assert_equal PlebisBrandImport.convert_province("48002", "Spain", "Bilbao"), "BI"
    assert_equal PlebisBrandImport.convert_province("48002", "España", "Bilbao"), "BI" 
    assert_equal PlebisBrandImport.convert_province("48002", "bla", "Tanganika"), "Tanganika"
  end
  
  test "should #convert_country work" do
    assert_equal PlebisBrandImport.convert_country("Alemania"), "DE"
    assert_equal PlebisBrandImport.convert_country("Francia"), "FR"
    assert_equal PlebisBrandImport.convert_country("Irlanda"), "IE"
    assert_equal PlebisBrandImport.convert_country("Brasil"), "BR"
    assert_equal PlebisBrandImport.convert_country("Noruega"), "NO"
    assert_equal PlebisBrandImport.convert_country("España"), "ES"
    assert_equal PlebisBrandImport.convert_country("Bélgica"), "BE"
    assert_equal PlebisBrandImport.convert_country("Invalid"), "Invalid"
  end
  
end
