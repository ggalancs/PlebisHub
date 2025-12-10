# frozen_string_literal: true

module ActiveAdmin
  module Views
    class Footer < Component
      # ActiveAdmin 3.x: Accept optional argument from ActiveAdmin framework
      def build(*)
        super(id: 'footer', style: 'text-align: right;')

        within(self) do
          div do
            small do
              # Use Arbre's 'a' method instead of link_to for compatibility
              a href: '/pdf/PLEBISBRAND_LOPD_-_MANUAL_DE_USUARIO_DE_BASES_DE_DATOS_DE_PLEBISBRAND_v.2014.09.10.pdf',
                target: '_blank',
                rel: 'noopener' do
                text_node 'Manual de uso de datos de carácter personal'
              end
            end
          end
        end
      end
    end
  end
end
