# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActiveAdmin::Views::Footer, type: :view do
  describe '#build' do
    let(:footer) { ActiveAdmin::Views::Footer.new(Arbre::Context.new) }

    before do
      footer.build
    end

    it 'creates a footer element with id' do
      expect(footer.id).to eq('footer')
    end

    it 'has right-aligned text style' do
      expect(footer.attributes['style']).to include('text-align: right')
    end

    it 'contains a link to the privacy manual' do
      html = footer.to_s
      expect(html).to include('Manual de uso de datos de carácter personal')
    end

    it 'has the correct link URL' do
      html = footer.to_s
      expect(html).to include('/pdf/PLEBISBRAND_LOPD_-_MANUAL_DE_USUARIO_DE_BASES_DE_DATOS_DE_PLEBISBRAND_v.2014.09.10.pdf')
    end

    it 'opens link in new tab' do
      html = footer.to_s
      expect(html).to include('target="_blank"')
    end

    it 'has noopener rel attribute for security' do
      html = footer.to_s
      expect(html).to include('rel="noopener"')
    end

    it 'wraps content in a div' do
      html = footer.to_s
      expect(html).to match(/<div[^>]*>.*<\/div>/m)
    end

    it 'uses small tag for text' do
      html = footer.to_s
      expect(html).to match(/<small[^>]*>.*<\/small>/m)
    end
  end

  describe 'rendering in admin layout' do
    it 'is part of ActiveAdmin::Views module' do
      expect(ActiveAdmin::Views::Footer).to be < ActiveAdmin::Views::Component
    end

    it 'inherits from Component' do
      expect(ActiveAdmin::Views::Footer.superclass).to eq(ActiveAdmin::Views::Component)
    end
  end

  describe 'accessibility' do
    let(:footer) { ActiveAdmin::Views::Footer.new(Arbre::Context.new) }

    before do
      footer.build
    end

    it 'provides a clickable link' do
      html = footer.to_s
      expect(html).to match(/<a[^>]+href=/)
    end

    it 'has descriptive link text' do
      html = footer.to_s
      expect(html).to include('Manual de uso de datos')
    end
  end
end
