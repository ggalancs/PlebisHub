# frozen_string_literal: true

# Diagnostico de solo lectura para el bug de `set_initial_status`.
#
# Entre 2020-11-10 (cuando una migracion cambio el valor por defecto de
# `collaborations.status` de 0 a 2) y 2025-11-30 (commit d4820c38), el callback
# era `after_create :set_initial_status` con un `self.status = 0` que no se
# persistia. Resultado: toda colaboracion creada en esa ventana se quedo con
# status 2 ("Sin confirmar") en vez de 0 ("Sin pago").
#
# Importa porque `has_payment?` es `status.positive?`: una colaboracion con 2
# afirma tener pago sin tenerlo, y de ahi dependen las ramas de `edit` y
# `confirm` del flujo de colaboracion.
#
# Esta tarea NO modifica nada. Solo mide el alcance para poder decidir.
#
#   bundle exec rake plebisbrand:diagnose_collaboration_status
namespace :plebisbrand do
  desc 'Mide cuantas colaboraciones pudieron quedarse con status 2 en vez de 0 (solo lectura)'
  task diagnose_collaboration_status: :environment do
    ventana_inicio = Date.new(2020, 11, 10)
    ventana_fin = Date.new(2025, 11, 30)

    scope = PlebisCollaborations::Collaboration.with_deleted
                                               .where(created_at: ventana_inicio...ventana_fin)

    total = scope.count
    sospechosas = scope.where(status: 2)

    puts "Ventana analizada: #{ventana_inicio} .. #{ventana_fin}"
    puts "Colaboraciones creadas en la ventana: #{total}"
    puts "  con status 2 ('Sin confirmar'): #{sospechosas.count}"
    puts

    puts 'De esas, cuantas parecen no haber tenido pago nunca:'
    sin_ordenes = sospechosas.where.missing(:orders).count
    puts "  sin ninguna orden asociada: #{sin_ordenes}"

    sin_orden_pagada = sospechosas.where(
      'not exists (select 1 from orders o where o.parent_id = collaborations.id ' \
      "and o.parent_type = 'PlebisCollaborations::Collaboration' and o.payed_at is not null)"
    ).count
    puts "  sin ninguna orden cobrada: #{sin_orden_pagada}"
    puts

    puts 'Reparto de estados en la ventana:'
    scope.group(:status).count.sort.each do |status, count|
      nombre = PlebisCollaborations::Collaboration::STATUS.invert[status] || '(desconocido)'
      puts format('  %<status>d %<nombre>-16s %<count>d', status: status, nombre: nombre, count: count)
    end
    puts
    puts 'Fuera de la ventana (para comparar):'
    PlebisCollaborations::Collaboration.with_deleted
                                       .where.not(created_at: ventana_inicio...ventana_fin)
                                       .group(:status).count.sort.each do |status, count|
      nombre = PlebisCollaborations::Collaboration::STATUS.invert[status] || '(desconocido)'
      puts format('  %<status>d %<nombre>-16s %<count>d', status: status, nombre: nombre, count: count)
    end
  end
end
