# frozen_string_literal: true

require 'English'
module PlebisCollaborations
  class Order < ApplicationRecord
    include Rails.application.routes.url_helpers

    acts_as_paranoid
    has_paper_trail

    belongs_to :parent, -> { with_deleted }, polymorphic: true
    belongs_to :collaboration, lambda {
      with_deleted.joins(:order).where(orders: { parent_type: 'PlebisCollaborations::Collaboration' })
    }, foreign_key: 'parent_id', class_name: 'PlebisCollaborations::Collaboration'
    belongs_to :user, -> { with_deleted }, class_name: '::User'

    attr_accessor :raw_xml

    validates :payment_type, :amount, :payable_at, presence: true

    STATUS = { 'Nueva' => 0, 'Sin confirmar' => 1, 'OK' => 2, 'Alerta' => 3, 'Error' => 4, 'Devuelta' => 5 }.freeze
    PAYMENT_TYPES = {
      'Suscripción con Tarjeta de Crédito/Débito' => 1,
      'Domiciliación en cuenta bancaria (formato CCC)' => 2,
      'Domiciliación en cuenta bancaria (formato IBAN)' => 3
    }.freeze

    PARENT_CLASSES = {
      PlebisCollaborations::Collaboration => 'C'
    }.freeze

    REDSYS_SERVER_TIME_ZONE = ActiveSupport::TimeZone.new('Madrid')

    scope :created, -> { where(deleted_at: nil) }
    scope :by_date, lambda { |date_start, date_end|
      created.where(payable_at: date_start.beginning_of_month..date_end.end_of_month)
    }
    scope :credit_cards, -> { created.where(payment_type: 1) }
    scope :banks, -> { created.where.not(payment_type: 1) }
    scope :to_be_paid, -> { created.where(status: [0, 1]) }
    scope :to_be_charged, -> { created.where(status: 0) }
    scope :charging, -> { created.where(status: 1) }
    scope :paid, -> { created.where(status: [2, 3]).where.not(payed_at: nil) }
    scope :warnings, -> { created.where(status: 3) }
    scope :errors, -> { created.where(status: 4) }
    scope :returned, -> { created.where(status: 5) }
    scope :deleted, -> { only_deleted }

    scope :full_view, -> { with_deleted.includes(:user) }

    after_initialize do |o|
      o.status = 0 if o.status.nil?
    end

    def is_payable?
      status < 2
    end

    def is_chargeable?
      status.zero?
    end

    def is_paid?
      !payed_at.nil? and [2, 3].include? status
    end

    def has_warnings?
      status == 3
    end

    def has_errors?
      status == 4
    end

    def was_returned?
      status == 5
    end

    def status_name
      STATUS.invert[status]
    end

    def payment_type_name
      PAYMENT_TYPES.invert[payment_type]
    end

    def is_credit_card?
      payment_type == 1
    end

    def is_bank?
      payment_type != 1
    end

    def is_bank_national?
      is_bank? and !is_bank_international?
    end

    def is_bank_international?
      has_iban_account? and !payment_identifier.start_with?('ES')
    end

    def has_ccc_account?
      payment_type == 2
    end

    def has_iban_account?
      payment_type == 3
    end

    def error_message
      return redsys_text_status if payment_type == 1

      bank_text_status
    end

    def self.parent_from_order_id(order_id)
      PARENT_CLASSES.invert[order_id[7]].find(order_id[0..7].to_i)
    end

    def self.payment_day
      Rails.application.secrets.orders['payment_day'].to_i
    end

    def self.by_month_count(date)
      by_date(date, date).count
    end

    def self.by_month_amount(date)
      by_date(date, date).sum(:amount) / 100.0
    end

    def admin_permalink
      admin_order_path(self)
    end

    #### BANK PAYMENTS ####

    # USAMOS order_id
    # def receipt
    # TODO order receipt
    # Es el identificador del cargo a todos los efectos y no se ha de repetir en la remesa y en las remesas sucesivas. Es un nº correlativo
    # end

    def due_code
      # CÓDIGO DE ADEUDO  Se pondra FRST cuando sea el primer cargo desde la fecha de alta, y RCUR en los siguientes sucesivos
      # TODO codigo de adeudo
      first ? 'FRST' : 'RCUR'
    end

    def url_source
      # URL FUENTE  "Este campo no se si existira en el nuevo entorno. Si no es asi poner por defecto https://plebisbrand.info/participa/colaboraciones/colabora/
      # TODO url_source
      new_collaboration_url
    end

    # USAMOS reference
    # def concept
    # COMPROBACIÓN  Es el texto que aparecefrá en el recibo. Sera "Colaboracion "mes x"
    # TODO comprobación / concepto
    #  "Colaboración mes de XXXX"
    # end

    def mark_as_charging
      self.status = 1
    end

    def mark_as_paid!(date)
      self.status = 2
      self.payed_at = date
      save
      return unless parent

      parent.payment_processed! self
    end

    def processed!(code = nil)
      error_codes = %w[AC01 AC04 AC06 SL01]
      self.payment_response = code if code
      self.status = 5
      self.status = 4 if code && error_codes.include?(code.strip.upcase)
      if save
        if parent && !parent.deleted?
          reason = SEPA_RETURNED_REASONS[payment_response]
          if reason
            parent.processed_order! reason[:error], reason[:warn], (status == 4)
          else
            parent.processed_order!
          end
        end
        true
      else
        false
      end
    end

    def self.mark_bank_orders_as_charged!(date = Time.zone.today)
      PlebisCollaborations::Order.banks.by_date(date, date).to_be_charged.update_all(status: 1)
    end

    def self.mark_bank_orders_as_paid!(date = Time.zone.today)
      PlebisCollaborations::Collaboration.update_paid_unconfirmed_bank_collaborations(PlebisCollaborations::Order.banks.by_date(
        date, date
      ).charging)
      PlebisCollaborations::Order.banks.by_date(date, date).charging.update_all(status: 2, payed_at: date)
    end

    SEPA_RETURNED_REASONS = {
      'AC01' => { error: true, warn: true, text: 'El IBAN o BIN son incorrectos.' },
      'AC04' => { error: true, text: 'La cuenta ha sido cerrada.' },
      'AC06' => { error: true, text: 'Cuenta bloqueada.' },
      'AC13' => { error: true, warn: true, text: 'Cuenta de cliente no apta para operaciones entre comercios.' },
      'AG01' => { error: true, text: 'Cuenta de ahorro, no admite recibos.' },
      'AG02' => { error: false, warn: true, text: 'Código de pago incorrecto (ejemplo: RCUR sin FRST previo).' },
      'AM04' => { error: false, text: 'Fondos insuficientes.' },
      'AM05' => { error: false, warn: true, text: 'Orden duplicada (ID repetido o dos operaciones FRST).' },
      'BE01' => { error: true, text: 'El nombre dado no coincide con el titular de la cuenta.' },
      'BE05' => { error: false, text: 'Creditor Identifier incorrecto.' },
      'FF01' => { error: false, warn: true, text: 'Código de transacción incorrecto o formato de fichero inválido.' },
      'FF05' => { error: false, warn: true, text: "Tipo de 'Direct Debit' incorrecto." },
      'MD01' => { error: false, text: 'Transacción no autorizada.' },
      'MD02' => { error: false, text: 'Información del cliente incompleta o incorrecta.' },
      'MD06' => { error: false, text: 'El cliente reclama no haber autorizado esta orden (hasta 8 semanas de plazo).' },
      'MD07' => { error: true, text: 'El titular de la cuenta ha muerto.' },
      'MS02' => { error: false, text: 'El cliente ha devuelto esta orden.' },
      'MS03' => { error: false, text: 'Razón no especificada por el banco.' },
      'RC01' => { error: true, warn: true, text: 'El código BIC provisto es incorrecto.' },
      'RR01' => { error: true, warn: true,
                  text: 'La identificación del titular de la cuenta requerida legalmente es insuficiente o inexistente.' },
      'RR02' => { error: true, warn: true,
                  text: 'El nombre o la dirección del cliente requerida legalmente es insuficiente o inexistente.' },
      'RR03' => { error: false, warn: true,
                  text: 'El nombre o la dirección del cliente requerida legalmente es insuficiente o inexistente.' },
      'RR04' => { error: true, warn: true, text: 'Motivos legales. Contactar al banco para más información.' },
      'SL01' => { error: true,
                  text: 'Cobro bloqueado a entidad por lista negra o ausencia en lista de cobros autorizados.' }
    }.freeze

    def bank_text_status
      case status
      when 4
        'Error'
      when 5
        if payment_response
          if SEPA_RETURNED_REASONS[payment_response]
            "#{payment_response}: #{SEPA_RETURNED_REASONS[payment_response][:text]}"
          else
            payment_response.to_s
          end
        else
          'Orden devuelta'
        end
      else
        ''
      end
    end

    #### REDSYS CC PAYMENTS ####

    def redsys_secret(key)
      Rails.application.secrets.redsys[key]
    end

    def redsys_expiration
      # Credit card is valid until the last day of expiration month
      return unless redsys_response && first

      DateTime.strptime(redsys_response['Ds_ExpiryDate'],
                        '%y%m') + 1.month - 1.second
    end

    def redsys_order_id
      @redsys_order_id ||=
        if redsys_response && first
          redsys_response['Ds_Order']
        elsif persisted?
          id.to_s.rjust(12, '0')
        else
          parent.id.to_s.rjust(7, '0') + PARENT_CLASSES[parent.class] + Time.now.to_i.to_s(36)[-4..]
        end
    end

    def redsys_post_url
      redsys_secret 'post_url'
    end

    def redsys_merchant_url
      if first
        orders_callback_redsys_url(protocol: Rails.env.development? ? :http : :https,
                                   redsys_order_id: redsys_order_id, user_id: user_id, parent_id: parent.id)
      else
        ''
      end
    end

    def redsys_merchant_request_signature
      _sign(redsys_order_id, redsys_merchant_params)
    end

    def redsys_merchant_response_signature
      request_start = raw_xml.index '<Request'
      request_end = raw_xml.index '</Request>', request_start if request_start
      msg = raw_xml[request_start..(request_end + 9)] if request_start && request_end
      _sign(redsys_order_id, msg)
    end

    def redsys_logger
      @@redsys_logger ||= Logger.new(Rails.root.join('log/redsys.log').to_s)
    end

    def redsys_response
      @redsys_response ||= payment_response.nil? ? nil : JSON.parse(payment_response)
    end

    def redsys_parse_response!(params, xml = nil)
      redsys_logger.info('*' * 40)
      redsys_logger.info('Redsys: New payment')
      redsys_logger.info("User: #{user_id} - #{parent.class}: #{parent.id}")
      redsys_logger.info("Data: #{attributes.inspect}")
      redsys_logger.info("Params: #{params}")
      redsys_logger.info("XML: #{xml}")
      self.payment_response = params.to_json
      self.raw_xml = xml

      if params['Ds_Response'].to_i < 100
        self.payed_at = Time.zone.now
        begin
          payment_date = REDSYS_SERVER_TIME_ZONE.parse "#{params['Fecha'] or params['Ds_Date']} #{params['Hora'] or params['Ds_Hour']}"
          redsys_logger.info("Validation data: #{payment_date}, #{Time.zone.now}, #{params['user_id']}, #{user_id}, #{params['Ds_Signature']}, #{redsys_merchant_response_signature}")
          if ((payment_date - 1.hour) < Time.zone.now) && (Time.zone.now < (payment_date + 1.hour)) && (params['Ds_Signature'] == redsys_merchant_response_signature) # and params["user_id"].to_i == self.user_id
            redsys_logger.info('Status: OK')
            self.status = 2
          else
            redsys_logger.info('Status: OK, but with warnings ')
            self.status = 3
          end
          self.payment_identifier = params['Ds_Merchant_Identifier']
        rescue StandardError
          redsys_logger.info('Status: OK, but with errors on response processing.')
          redsys_logger.info("Error: #{$ERROR_INFO.message}")
          redsys_logger.info("Backtrace: #{$ERROR_INFO.backtrace}")
          self.status = 3
        end
      else
        redsys_logger.info('Status: KO - ERROR')
        self.status = 4
      end
      save

      return unless parent

      parent.payment_processed! self
    end

    def redsys_raw_params
      extra = if first
                {
                  'Ds_Merchant_Identifier' => redsys_secret('identifier'),
                  'Ds_Merchant_UrlOK' => parent.ok_url,
                  'Ds_Merchant_UrlKO' => parent.ko_url
                }
              else
                {
                  'Ds_Merchant_Identifier' => payment_identifier,
                  'Ds_Merchant_DirectPayment' => 'true'
                }
              end

      {
        'Ds_Merchant_Amount' => amount.to_s,
        'Ds_Merchant_Currency' => redsys_secret('currency'),
        'Ds_Merchant_MerchantCode' => redsys_secret('code'),
        'Ds_Merchant_MerchantName' => redsys_secret('name'),
        'Ds_Merchant_Terminal' => redsys_secret('terminal'),
        'Ds_Merchant_TransactionType' => redsys_secret('transaction_type'),
        'Ds_Merchant_PayMethods' => redsys_secret('payment_methods'),
        'Ds_Merchant_MerchantData' => user_id.to_s,
        'Ds_Merchant_MerchantURL' => redsys_merchant_url,
        'Ds_Merchant_Order' => redsys_order_id
      }.merge(extra).transform_keys(&:upcase)
    end

    def redsys_merchant_params
      Base64.strict_encode64(redsys_raw_params.to_json)
    end

    def redsys_params
      {
        'Ds_SignatureVersion' => 'HMAC_SHA256_V1',
        'Ds_MerchantParameters' => redsys_merchant_params,
        'Ds_Signature' => redsys_merchant_request_signature
      }
    end

    def redsys_send_request
      uri = URI redsys_post_url

      http = Net::HTTP.new uri.host, uri.port
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        # http.ssl_options = OpenSSL::SSL::OP_NO_SSLv2 + OpenSSL::SSL::OP_NO_SSLv3 + OpenSSL::SSL::OP_NO_COMPRESSION
        http.ssl_version = :TLSv1_2
      end

      save
      response = http.post(uri, URI.encode_www_form(redsys_params))
      info = response.body.scan(/<!--\W*(\w*)\W*-->/).flatten
      self.payment_response = info.to_json
      if info[0] == 'RSisReciboOK'
        self.payed_at = Time.zone.now
        self.status = 2
      else
        self.status = 4
      end
      save

      return unless parent

      parent.payment_processed! self
    end

    def redsys_text_status
      case status
      when 5
        'Orden devuelta'
      else
        code = if redsys_response
                 if first
                   redsys_response['Ds_Response']
                 else
                   redsys_response[-1]
                 end
               end

        if code
          code = code.to_i if code.is_a?(String) && (!code.start_with? 'SIS')
          # Given a status code, returns the status message
          message = case code
                    when 'SIS0298'  then 'El comercio no permite realizar operaciones de Tarjeta en Archivo.'
                    when 'SIS0319'  then 'El comercio no pertenece al grupo especificado en Ds_Merchant_Group.'
                    when 'SIS0321'  then 'La referencia indicada en Ds_Merchant_Identifier no está asociada al comercio.'
                    when 'SIS0322'  then 'Error de formato en Ds_Merchant_Group.'
                    when 'SIS0325'  then 'Se ha pedido no mostrar pantallas pero no se ha enviado ninguna referencia de tarjeta.'
                    when 0..99      then 'Transacción autorizada para pagos y preautorizaciones'
                    when 900        then 'Transacción autorizada para devoluciones y confirmaciones'
                    when 101        then 'Tarjeta caducada'
                    when 102        then 'Tarjeta en excepción transitoria o bajo sospecha de fraude'
                    when 104, 9104  then 'Operación no permitida para esa tarjeta o terminal'
                    when 116        then 'Disponible insuficiente'
                    when 118        then 'Tarjeta no registrada'
                    when 129        then 'Código de seguridad (CVV2/CVC2) incorrecto'
                    when 180        then 'Tarjeta ajena al servicio'
                    when 184        then 'Error en la autenticación del titular'
                    when 190        then 'Denegación sin especificar Motivo'
                    when 191        then 'Fecha de caducidad errónea'
                    when 202        then 'Tarjeta en excepción transitoria o bajo sospecha de fraude con retirada de tarjeta'
                    when 912, 9912  then 'Emisor no disponible'
                    else
                      'Transacción denegada'
                    end
          "#{code}: #{message}"
        else
          'Transacción no procesada'
        end
      end
    end

    def redsys_callback_response
      response = "<Response Ds_Version='0.0'><Ds_Response_Merchant>#{is_paid? ? 'OK' : 'KO'}</Ds_Response_Merchant></Response>"
      signature = _sign(redsys_order_id, response)

      soap = []
      soap << <<~EOL
        <?xml version='1.0' encoding='UTF-8'?>
        <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <SOAP-ENV:Body>
        <ns1:procesaNotificacionSIS xmlns:ns1="InotificacionSIS" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
        <return xsi:type="xsd:string">
      EOL
      soap[-1].rstrip!
      soap << CGI.escapeHTML("<Message>#{response}<Signature>#{signature}</Signature></Message>")
      soap << "</return>\n</ns1:procesaNotificacionSIS>\n</SOAP-ENV:Body>\n</SOAP-ENV:Envelope>"

      soap.join
    end

    def generate_target_territory
      return '' unless parent&.get_user

      parent.get_user
      type_order = if island_code
                     'I'
                   elsif town_code
                     'M'
                   else
                     autonomy_code ? 'A' : 'E'
                   end
      circle = VoteCircle.find(vote_circle_id) if vote_circle_id.present?
      has_active_circle = circle.present? && !circle.interno?
      type_order = 'E' if has_active_circle && circle.exterior?
      type_order = 'A' if has_active_circle && circle.comarcal?
      case type_order
      when 'I'
        text = 'Isla '
        text += has_active_circle && circle.island_code.present? ? circle.island_name : parent.get_vote_island_name
      when 'M'
        text = 'Municipal '
        text += has_active_circle && circle.town.present? ? circle.town_name : parent.get_vote_town_name
      when 'A'
        text = 'Autonómico '
        text += has_active_circle && circle.autonomy_code.present? ? circle.autonomy_name : parent.get_vote_autonomy_name
      else
        text = 'Estatal'
      end
      text.html_safe
    end

    private

    def _sign(key, data)
      des3 = OpenSSL::Cipher.new('des-ede3-cbc')
      des3.encrypt
      des3.key = Base64.strict_decode64(redsys_secret('secret_key'))
      des3.iv = "\0" * 8
      des3.padding = 0

      _key = key
      _key += "\0" until (_key.bytesize % 8).zero?
      key = des3.update(_key) + des3.final
      digest = OpenSSL::Digest.new('sha256')
      Base64.strict_encode64(OpenSSL::HMAC.digest(digest, key, data))
    end
  end
end
