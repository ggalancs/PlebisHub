# frozen_string_literal: true

require 'plebisbrand_export'

UNKNOWN = 'Desconocido'
FOREIGN = 'Extranjeros'
NATIVE = 'Españoles'

namespace :plebisbrand do
  desc '[plebisbrand] Dump counters for users attributes'
  task :daily_census, %i[year month day] => :environment do |_t, args|
    args.with_defaults(year: nil, month: nil, day: nil)

    if args.year.nil?
      users = User.confirmed.not_banned
      date = Time.zone.today
    else
      users = User.with_deleted
      date = Date.civil args.year.to_i, args.month.to_i, args.day.to_i
    end

    num_columns = 6
    active_date = date - eval(Rails.application.secrets.users['active_census_range'])

    total = users.count

    progress = RakeProgressbar.new(total + 15)

    spain = Carmen::Country.coded('ES').subregions
    provinces_coded = spain.map(&:code)
    progress.inc

    countries = Carmen::Country.all.to_h do |c|
      [c.name, [0] * num_columns]
    end
    countries[UNKNOWN] = [0] * num_columns
    progress.inc

    autonomies = PlebisBrand::GeoExtra::AUTONOMIES.to_h do |_k, v|
      [v[1], [0] * num_columns]
    end
    autonomies[FOREIGN] = [0] * num_columns
    progress.inc

    provinces = spain.to_h do |p|
      [p.name, [0] * num_columns]
    end
    provinces[UNKNOWN] = [0] * num_columns
    progress.inc

    islands = PlebisBrand::GeoExtra::ISLANDS.to_h do |_k, v|
      [v[1], [0] * num_columns]
    end
    progress.inc

    towns = provinces_coded.map do |p|
      spain.coded(p).subregions.map do |t|
        [t.code, [0] * num_columns]
      end
    end.flatten(1).to_h
    towns[UNKNOWN] = [0] * num_columns
    towns_names = Hash[ *provinces_coded.map do |p|
      spain.coded(p).subregions.map do |t|
        [t.code, t.name]
      end
    end.flatten ]
    towns_names[UNKNOWN] = UNKNOWN
    progress.inc

    postal_codes = Hash.new { |h, k| h[k] = [0] * num_columns }

    users_verified = {}
    users_verified[NATIVE] = [0] * num_columns
    users_verified[FOREIGN] = [0] * num_columns

    progress.inc

    users.find_each do |u|
      if args.year
        u = u.version_at(date)
        next unless u.present? && u.sms_confirmed_at.present? && u.not_banned?
      end

      countries[(countries.include?(u.country_name) ? u.country_name : UNKNOWN)][0] += 1
      if u.country == 'ES'
        autonomies[u.autonomy_name][0] += 1 unless u.autonomy_name.empty?
        provinces[(provinces.include?(u.province_name) ? u.province_name : UNKNOWN)][0] += 1
        towns[(towns.include?(u.town) ? u.town : UNKNOWN)][0] += 1
        islands[u.island_name][0] += 1 unless u.island_name.empty?
        postal_codes[(u.postal_code.match?(/^\d{5}$/) ? u.postal_code : UNKNOWN)][0] += 1
        users_verified[NATIVE][0] += 1 if u.verified?
      else
        autonomies[FOREIGN][0] += 1
        users_verified[FOREIGN][0] += 1 if u.verified?
      end

      if u.current_sign_in_at.present? && u.current_sign_in_at > active_date
        countries[(countries.include?(u.country_name) ? u.country_name : UNKNOWN)][1] += 1
        if u.country == 'ES'
          autonomies[u.autonomy_name][1] += 1 unless u.autonomy_name.empty?
          provinces[(provinces.include?(u.province_name) ? u.province_name : UNKNOWN)][1] += 1
          towns[(towns.include?(u.town) ? u.town : UNKNOWN)][1] += 1
          islands[u.island_name][1] += 1 unless u.island_name.empty?
          postal_codes[(u.postal_code.match?(/^\d{5}$/) ? u.postal_code : UNKNOWN)][1] += 1
          users_verified[NATIVE][1] += 1 if u.verified?
        else
          autonomies[FOREIGN][1] += 1
          users_verified[FOREIGN][1] += 1 if u.verified?
        end
      end

      if u.vote_town
        autonomies[u.vote_autonomy_name][2] += 1 unless u.vote_autonomy_name.empty?
        provinces[(provinces.include?(u.vote_province_name) ? u.vote_province_name : UNKNOWN)][2] += 1
        towns[(towns.include?(u.vote_town) ? u.vote_town : UNKNOWN)][2] += 1
        islands[u.vote_island_name][2] += 1 unless u.vote_island_name.empty?
        users_verified[NATIVE][2] += 1 if u.verified?

        if u.current_sign_in_at.present? && u.current_sign_in_at > active_date
          autonomies[u.vote_autonomy_name][3] += 1 unless u.vote_autonomy_name.empty?
          provinces[(provinces.include?(u.vote_province_name) ? u.vote_province_name : UNKNOWN)][3] += 1
          towns[(towns.include?(u.vote_town) ? u.vote_town : UNKNOWN)][3] += 1
          islands[u.vote_island_name][3] += 1 unless u.vote_island_name.empty?
          users_verified[NATIVE][3] += 1 if u.verified?
        end
      end

      if u.verified?
        autonomies[u.vote_autonomy_name][4] += 1 unless u.vote_autonomy_name.empty?
        provinces[(provinces.include?(u.vote_province_name) ? u.vote_province_name : UNKNOWN)][4] += 1
        towns[(towns.include?(u.vote_town) ? u.vote_town : UNKNOWN)][4] += 1
        islands[u.vote_island_name][4] += 1 unless u.vote_island_name.empty?
        users_verified[NATIVE][4] += 1 if u.verified?
        postal_codes[(u.postal_code.match?(/^\d{5}$/) ? u.postal_code : UNKNOWN)][4] += 1 if u.country == 'ES'

        if u.current_sign_in_at.present? && u.current_sign_in_at > active_date
          autonomies[u.vote_autonomy_name][5] += 1 unless u.vote_autonomy_name.empty?
          provinces[(provinces.include?(u.vote_province_name) ? u.vote_province_name : UNKNOWN)][5] += 1
          towns[(towns.include?(u.vote_town) ? u.vote_town : UNKNOWN)][5] += 1
          islands[u.vote_island_name][5] += 1 unless u.vote_island_name.empty?
          users_verified[NATIVE][5] += 1 if u.verified?
          postal_codes[(u.postal_code.match?(/^\d{5}$/) ? u.postal_code : UNKNOWN)][5] += 1 if u.country == 'ES'
        end
      end

      progress.inc
    end

    suffix = date.strftime
    headers = %w[I IA V VA VV VVA]
    export_raw_data "countries.#{suffix}", countries.sort, headers: ["País | #{suffix}"] + headers,
                                                           folder: 'tmp/census', &:flatten
    progress.inc
    export_raw_data "autonomies.#{suffix}", autonomies.sort, headers: ["Comunidad autonoma | #{suffix}"] + headers,
                                                             folder: 'tmp/census', &:flatten
    progress.inc
    export_raw_data "provinces.#{suffix}", provinces.sort, headers: ["Provincia | #{suffix}"] + headers,
                                                           folder: 'tmp/census', &:flatten
    progress.inc
    export_raw_data "islands.#{suffix}", islands.sort, headers: ["Isla | #{suffix}"] + headers,
                                                       folder: 'tmp/census', &:flatten
    progress.inc
    export_raw_data "towns.#{suffix}", towns.sort, headers: ['Cod Municipio', "Municipio | #{suffix}"] + headers,
                                                   folder: 'tmp/census' do |d|
      [d[0], towns_names[d[0]]] + d[1].flatten
    end
    progress.inc
    export_raw_data "postal_codes.#{suffix}", postal_codes.sort, headers: ["Código postal | #{suffix}"] + headers,
                                                                 folder: 'tmp/census', &:flatten
    progress.inc
    export_raw_data "users_verified.#{suffix}", users_verified.sort,
                    headers: ["Usuarios verificados | #{suffix}"] + headers, folder: 'tmp/census', &:flatten
    progress.finished
  end
end
