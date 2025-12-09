# frozen_string_literal: true

class PlebisBrandImportCollaborations
  def self.log_to_file(filename, text)
    File.open(filename, 'a') { |f| f.write(text) }
  end

  def self.process_row(row)
    params = { document_vatid: row['DNI / NIE'].strip.upcase,
               full_name: row['Apellidos'] ? "#{row['Nombre']} #{row['Apellidos']}" : row['Nombre'],
               email: row['Email'],
               ccc_1: row['Entidad'],
               ccc_2: row['Oficina'],
               ccc_3: row['DC'],
               ccc_4: row['Cuenta'],
               iban_1: row['IBAN'],
               iban_2: row['BIC/SWIFT'],
               payment_type: row['Método de pago'],
               amount: row['Total'].to_i * 100.0,
               frequency: row['Frecuencia de pago'], #  1 3 12
               created_at: DateTime.parse(row['Creado']),
               row: row }

    create_collaboration(params)
  end

  def self.create_collaboration(params)
    #  si el usuario tiene el mismo correo en colabora y participa...
    if User.exists?(email: params[:email])
      user = User.find_by email: params[:email]
      #  ... y si tambien tiene el mismo documento, lo damos de alta
      if user.document_vatid == params[:document_vatid]
        c = Collaboration.new
        c.user = user
        c.amount = params[:amount]
        c.frequency = params[:frequency]
        c.created_at = params[:created_at]
        case params[:payment_type]
        when 'Suscripción con Tarjeta de Crédito/Débito'
          c.payment_type = 1
        when 'Domiciliación en cuenta bancaria (CCC)'
          c.payment_type = 2
          c.ccc_entity = params[:ccc_1]
          c.ccc_office = params[:ccc_2]
          c.ccc_dc = params[:ccc_3]
          c.ccc_account = params[:ccc_4]
        when 'Domiciliación en cuenta extranjera (IBAN)'
          # If Spanish IBAN without BIC, convert to CCC first
          if params[:iban_1].present? && params[:iban_2].blank? && params[:iban_1].to_s.start_with?('ES')
            params[:ccc_1] = params[:iban_1][4..7]
            params[:ccc_2] = params[:iban_1][8..11]
            params[:ccc_3] = params[:iban_1][12..13]
            params[:ccc_4] = params[:iban_1][14..23]
            params[:iban_1] = nil
            params[:payment_type] = 'Domiciliación en cuenta bancaria (CCC)'
            return create_collaboration(params)
          end
          c.payment_type = 3
          c.iban_account = params[:iban_1]
          c.iban_bic = params[:iban_2]
        else
          log_to_file Rails.root.join('log/collaboration/not_payment_type.txt').to_s, params[:row]
        end
        # Skip validations for import - data comes from already-validated external system
        # (terms_of_service, minimal_year_old, CCC control digit, etc. aren't applicable for imports)
        c.terms_of_service = '1'
        c.minimal_year_old = '1'
        c.skip_queries_validations = true

        # For imports, skip all validations since data is pre-validated
        if c.save(validate: false)
          log_to_file Rails.root.join('log/collaboration/valid.txt').to_s, params[:row]
        # Keep the IBAN-to-CCC conversion logic for Spanish IBANs without BIC
        elsif params[:iban_1].present? && params[:iban_2].blank? && params[:iban_1].to_s.start_with?('ES')
          #  en caso de que tenga un iban_account pero no un iban_bic ...
          #  ... y la cuenta bancaria sea española
          if params[:iban_1].starts_with? 'ES'
            #  convertimos de IBAN a CCC
            params[:ccc_1] = params[:iban_1][4..7]
            params[:ccc_2] = params[:iban_1][8..11]
            params[:ccc_3] = params[:iban_1][12..13]
            params[:ccc_4] = params[:iban_1][14..23]
            params[:iban_1] = nil
            params[:payment_type] = 'Domiciliación en cuenta bancaria (CCC)'
            create_collaboration(params)
          else
            log_to_file Rails.root.join('log/collaboration/valid_not_bic.txt').to_s, params[:row].to_s
          end
        else
          log_to_file Rails.root.join('log/collaboration/not_valid.txt').to_s,
                      "#{params[:row]};#{c.errors.messages}"
        end
      elsif user.full_name.downcase == params[:full_name].downcase
        #  si concuerda el correo pero no el documento, comprobamos si su nombre es el mismo en colabora y participa
        params[:document_vatid] = user.document_vatid
        create_collaboration(params)
      #  en ese caso lo guardamos con el documento de participa
      else
        log_to_file Rails.root.join('log/collaboration/not_document.txt').to_s, params[:row]
      end
    elsif User.exists?(document_vatid: params[:document_vatid])
      # en cambio, si no concuerda el email pero si hay alguno documento
      user = User.find_by document_vatid: params[:document_vatid]
      #  comprobamos si su nombre es el mismo en colabora y participa
      if user.full_name.downcase == params[:full_name].downcase
        #  en ese caso lo guardamos con el email de participa
        params[:email] = user.email
        create_collaboration(params)
      else
        log_to_file Rails.root.join('log/collaboration/not_email.txt').to_s, params[:row]
      end
    else
      #  por ultimo, usuarios de los que no tenemos ni el email ni el documento en participa
      log_to_file Rails.root.join('log/collaboration/not_participation.txt').to_s, params[:row]
    end
  end

  def self.init(csv_file)
    CSV.foreach(csv_file, headers: true) do |row|
      process_row row
    rescue StandardError
      log_to_file Rails.root.join('log/collaboration/exception.txt').to_s, row
    end
  end
end
