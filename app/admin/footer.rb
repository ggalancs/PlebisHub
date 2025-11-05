module ActiveAdmin
  module Views
    class Footer < Component

      def build
        super :id => "footer"                                                    
        super :style => "text-align: right;"                                     

        div do                                                                   
          small do
            link_to "Manual de uso de datos de carácter personal", "/pdf/PLEBISBRAND_LOPD_-_MANUAL_DE_USUARIO_DE_BASES_DE_DATOS_DE_PLEBISBRAND_v.2014.09.10.pdf", target: "_blank"
          end
        end
      end

    end
  end
end
