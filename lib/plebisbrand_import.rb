# frozen_string_literal: true

class PlebisBrandImport
  # Legacy WP Gravity Forms
  # =======================
  #
  # Importa los contenidos desde un CSV a la aplicación
  # La contraseña es el token enviado por SMS
  #
  # $ rails console staging
  # > require 'plebisbrand_import'
  # > PlebisBrandImport.init('/home/capistrano/juntos.csv')
  #
  # $ bundle exec rake environment resque:work QUEUE=* RAILS_ENV=staging
  #
  #

  def self.convert_document_type(doc_type, doc_number)
    # doctypes:
    # DNI = 1
    # NIE = 2
    # Pasaporte = 3
    if doc_type == 'Pasaporte'
      3
    else
      (doc_number.starts_with?('Z', 'X', 'Y') ? 2 : 1)
    end
  end

  def self.convert_country(country)
    # normalizamos paises usando Carmen
    I18n.locale = :ca # locale sin traducciones para que nos devuelva lo de :en
    country_c = Carmen::Country.named(country)
    return country_c.code unless country_c.nil?

    I18n.locale = :es
    country_c = Carmen::Country.named(country)
    return country if country_c.nil?

    country_c.code
  end

  def self.convert_province(postal_code, country, province)
    # intentamos  convertir por postal_code, si es de españa y el CP corresponde con alguno devolvemos la provincia.
    # si no encuentra la provincia basada en el postal_code + country, devuelve la provincia que ya esta puesta
    # normalizamos provincias
    all_pcs = { '01' => 'VI', '02' => 'AB', '03' => 'A', '04' => 'AL', '05' => 'AV', '06' => 'BA', '07' => 'BI', '08' => 'B',
                '09' => 'BU', '10' => 'CC', '11' => 'CA', '12' => 'CS', '13' => 'CR', '14' => 'CO', '15' => 'C', '16' => 'CU', '17' => 'GI', '18' => 'GR', '19' => 'GU', '20' => 'SS', '21' => 'H', '22' => 'HU', '23' => 'J', '24' => 'LE', '25' => 'L', '26' => 'LO', '27' => 'LU', '28' => 'M', '29' => 'MA', '30' => 'MU', '31' => 'NA', '32' => 'OR', '33' => 'O', '34' => 'P', '35' => 'GC', '36' => 'PO', '37' => 'SA', '38' => 'TF', '39' => 'S', '40' => 'SG', '41' => 'SE', '42' => 'SO', '43' => 'T', '44' => 'TE', '45' => 'TO', '46' => 'V', '47' => 'VA', '48' => 'BI', '49' => 'Z', '50' => 'ZA', '51' => 'CE', '52' => 'ML' }
    return province unless %w[España Spain].include? country

    prov = all_pcs[postal_code[0..1]]
    return province if prov.nil?

    prov
  end

  def self.invalid_record(u, row)
    if u.errors[:email].include? 'Ya estas registrado con tu correo electrónico. Prueba a iniciar sesión o a pedir que te recordemos la contraseña.'
      logger = Logger.new(Rails.root.join('log/users_email.log').to_s)
      logger.info '*' * 10
      logger.info u.errors.messages
      logger.info row
    else
      logger = Logger.new(Rails.root.join('log/users_invalid.log').to_s)
      logger.info '*' * 10
      logger.info u.errors.messages
      logger.info row
      raise "InvalidRecordError - #{u.errors.messages} - #{row}"
    end
  end

  def self.process_row(row)
    now = DateTime.now
    u = User.new
    u.first_name = row[0][1]
    u.last_name = row[1][1]
    u.document_vatid = row[3][1].nil? ? row[4][1] : row[3][1]
    u.document_type = PlebisBrandImport.convert_document_type(row[2][1], u.document_vatid)
    # legacy: al principio no se preguntaba fecha de nacimiento
    unless row[5][1].nil?
      u.born_at = Date.parse row[5][1] # 1943-10-15
    end
    u.email = row[6][1]
    u.phone = row[7][1].sub('+', '00')
    u.sms_confirmation_token = row[8][1]
    u.address = row[9][1]
    # legacy: un usuario puso una carta (literalmente)
    u.town = if row[10][1].length < 250
               row[10][1]
             else
               'A'
             end
    u.postal_code = row[12][1]
    u.province = PlebisBrandImport.convert_province row[12][1], row[13][1], row[11][1]
    u.country = PlebisBrandImport.convert_country row[13][1]
    # legacy: al principio no se preguntaba para recibir la newsletter
    u.wants_newsletter = true if row[16][1] == 1
    u.password = row[8][1]
    u.password_confirmation = row[8][1]
    u.confirmed_at = now
    u.sms_confirmed_at = now
    u.has_legacy_password = true
    u.created_at = row[22][1].to_datetime
    u.old_circle_data = row[15][1].nil? ? row[14][1] : row[15][1]
    u.save
    return if u.valid?

    PlebisBrandImport.invalid_record(u, row)
  end

  def self.init(csv_file)
    File.delete(Rails.root.join('log/users_invalid.log').to_s)
    File.delete(Rails.root.join('log/users_email.log').to_s)
    CSV.foreach(csv_file, headers: true) do |row|
      PlebisBrandImportWorker.perform_async(row)
    end
  end
end
