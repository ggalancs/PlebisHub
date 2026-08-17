# frozen_string_literal: true

# Herramienta de analisis y migracion para el bug historico de
# `Collaboration#set_initial_status`.
#
# CONTEXTO
# --------
# `STATUS = { 'Sin pago' => 0, 'Error' => 1, 'Sin confirmar' => 2, 'OK' => 3,
#             'Alerta' => 4, 'Migracion' => 9 }`
#
# `has_payment?` es `status.positive?`, asi que 0 significa "todavia no hay pago"
# y 2 significa "el callback de pago volvio OK, pendiente de confirmar" (lo pone
# `set_active!` desde la accion OK del controlador).
#
# El callback `set_initial_status` siempre quiso poner 0, pero durante anos fue
# un `after_create` con una asignacion que no se persistia, de modo que mandaba
# el valor por defecto de la columna:
#
#   * hasta 2020-11-10 el defecto era 0  -> coincidia con la intencion, sin dano
#   * la migracion 20201110125929 lo cambio a 2 -> toda colaboracion nueva nacio
#     como "Sin confirmar" sin haber pagado nada
#   * el 2025-11-30 (commit d4820c38) paso a `before_create` y volvio a persistir 0
#
# El efecto es visible: con estado 2 una colaboracion recurrente recien creada
# entra en `confirm`, ese metodo ve `has_payment?` true y redirige a `edit`, asi
# que el usuario NUNCA llega a la pantalla de pago.
#
# USO
# ---
#   bundle exec rake plebisbrand:collaboration_status:analyze
#   bundle exec rake plebisbrand:collaboration_status:migrate               # simulacro
#   bundle exec rake plebisbrand:collaboration_status:migrate CONFIRM=SI    # aplica
#
# Opciones de `migrate`:
#   SCOPE=sin_ordenes   (por defecto) solo las que no tienen ninguna orden
#   SCOPE=sin_cobros    ademas, las que tienen ordenes pero ninguna cobrada
#
# Ver docs/MIGRACION_PARTICIPA_A_PLEBISHUB.md
# Ventana en la que el defecto de columna (2) mandaba sobre la intencion del
# modelo (0), porque set_initial_status era un after_create que no persistia.
VENTANA_INICIO = Date.new(2020, 11, 10)
VENTANA_FIN = Date.new(2025, 11, 30)
SIN_ORDEN_COBRADA = <<~SQL.squish
  not exists (
    select 1 from orders o
    where o.parent_id = collaborations.id
      and o.parent_type = 'PlebisCollaborations::Collaboration'
      and o.payed_at is not null
  )
SQL

namespace :plebisbrand do
  namespace :collaboration_status do
    def afectadas
      PlebisCollaborations::Collaboration.with_deleted
                                         .where(created_at: VENTANA_INICIO...VENTANA_FIN)
                                         .where(status: 2)
    end

    def grupos
      base = afectadas
      sin_ordenes = base.where.missing(:orders)
      sin_cobros = base.where(SIN_ORDEN_COBRADA).where.not(id: sin_ordenes.select(:id))
      con_cobros = base.where.not(id: sin_ordenes.select(:id)).where.not(id: sin_cobros.select(:id))
      { sin_ordenes: sin_ordenes, sin_cobros: sin_cobros, con_cobros: con_cobros }
    end

    def reparto(titulo, scope)
      puts titulo
      datos = scope.group(:status).count
      if datos.none?
        puts '  (ninguna)'
      else
        datos.sort.each do |status, count|
          nombre = PlebisCollaborations::Collaboration::STATUS.invert[status] || '(desconocido)'
          puts format('  %<status>d  %<nombre>-14s %<count>6d', status: status, nombre: nombre, count: count)
        end
      end
      puts
    end

    desc 'Analiza (solo lectura) cuantas colaboraciones pudieron quedarse en estado 2 por el bug'
    task analyze: :environment do
      puts "Ventana afectada: #{VENTANA_INICIO} .. #{VENTANA_FIN}"
      puts

      total_ventana = PlebisCollaborations::Collaboration.with_deleted
                                                         .where(created_at: VENTANA_INICIO...VENTANA_FIN).count
      puts "Colaboraciones creadas en la ventana: #{total_ventana}"
      puts "  de ellas en estado 2 ('Sin confirmar'): #{afectadas.count}"
      puts

      g = grupos
      puts 'Reparto de las de estado 2 por evidencia de haber entrado al flujo de pago:'
      puts format('  A) sin ninguna orden .................. %6d   <- casi seguro el bug', g[:sin_ordenes].count)
      puts format('  B) con ordenes pero ninguna cobrada ... %6d   <- probable, revisar', g[:sin_cobros].count)
      puts format('  C) con alguna orden cobrada ........... %6d   <- NO tocar', g[:con_cobros].count)
      puts

      reparto('Reparto de estados dentro de la ventana:',
              PlebisCollaborations::Collaboration.with_deleted.where(created_at: VENTANA_INICIO...VENTANA_FIN))
      reparto('Reparto de estados fuera de la ventana (referencia):',
              PlebisCollaborations::Collaboration.with_deleted.where.not(created_at: VENTANA_INICIO...VENTANA_FIN))

      if afectadas.none?
        puts 'No hay nada que migrar en esta instalacion.'
      else
        puts 'Para simular el cambio:  bundle exec rake plebisbrand:collaboration_status:migrate'
      end
    end

    desc 'Corrige el estado 2 -> 0 de las afectadas. Simulacro salvo CONFIRM=SI'
    task migrate: :environment do
      scope_name = (ENV['SCOPE'] || 'sin_ordenes').to_sym
      unless %i[sin_ordenes sin_cobros].include?(scope_name)
        abort "SCOPE no valido: #{scope_name}. Usa sin_ordenes o sin_cobros."
      end

      g = grupos
      objetivo = scope_name == :sin_ordenes ? g[:sin_ordenes] : g[:sin_ordenes].or(g[:sin_cobros])
      total = objetivo.count

      puts "Ventana: #{VENTANA_INICIO} .. #{VENTANA_FIN}"
      puts "Criterio: #{scope_name}"
      puts "Colaboraciones que se pondrian a 0 ('Sin pago'): #{total}"
      puts "Quedarian intactas por tener alguna orden cobrada: #{g[:con_cobros].count}"
      puts

      if total.zero?
        puts 'Nada que hacer.'
        next
      end

      puts 'Muestra (hasta 10):'
      objetivo.limit(10).each do |c|
        puts format('  id=%<id>-8d usuario=%<user>-8s creada=%<fecha>s ordenes=%<ordenes>d',
                    id: c.id, user: c.user_id || '-', fecha: c.created_at.to_date, ordenes: c.orders.count)
      end
      puts

      if ENV['CONFIRM'] != 'SI'
        puts 'SIMULACRO: no se ha modificado nada.'
        puts 'Para aplicarlo de verdad, repite el comando con CONFIRM=SI'
        next
      end

      ids = objetivo.pluck(:id)
      actualizadas = 0
      PlebisCollaborations::Collaboration.transaction do
        # update_all: es una correccion de datos, no debe disparar callbacks ni
        # validaciones del modelo.
        actualizadas = PlebisCollaborations::Collaboration.with_deleted.where(id: ids).update_all(status: 0)
      end

      puts "Hecho. Colaboraciones actualizadas: #{actualizadas}"
      puts "Registra este cambio: ids afectados guardados en #{Rails.root.join('tmp/collaboration_status_migrated.txt')}"
      Rails.root.join('tmp/collaboration_status_migrated.txt').write(ids.join("\n"))
    end
  end
end
