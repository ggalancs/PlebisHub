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

  describe 'content and styling' do
    let(:footer) { ActiveAdmin::Views::Footer.new(Arbre::Context.new) }

    before do
      footer.build
    end

    it 'has both id and style attributes' do
      expect(footer.id).to eq('footer')
      expect(footer.attributes['style']).to be_present
    end

    it 'contains a div wrapper' do
      expect(footer.children.any? { |child| child.is_a?(Arbre::HTML::Div) }).to be true
    end

    it 'wraps link in small tag' do
      html = footer.to_s
      expect(html).to match(/<small>.*<a.*<\/a>.*<\/small>/m)
    end

    it 'has complete structure: footer > div > small > a' do
      html = footer.to_s
      expect(html).to match(/<footer[^>]*id="footer"[^>]*>.*<div[^>]*>.*<small[^>]*>.*<a[^>]*>.*<\/a>.*<\/small>.*<\/div>.*<\/footer>/m)
    end

    it 'link points to PDF document' do
      html = footer.to_s
      expect(html).to include('.pdf')
    end

    it 'link is within /pdf/ directory' do
      html = footer.to_s
      expect(html).to include('/pdf/')
    end

    it 'document name contains PLEBISBRAND' do
      html = footer.to_s
      expect(html).to include('PLEBISBRAND')
    end

    it 'document name contains LOPD' do
      html = footer.to_s
      expect(html).to include('LOPD')
    end

    it 'style attribute contains text-align' do
      expect(footer.attributes['style']).to include('text-align')
    end

    it 'style attribute contains right alignment' do
      expect(footer.attributes['style']).to include('right')
    end
  end

  describe 'build method behavior' do
    let(:footer) { ActiveAdmin::Views::Footer.new(Arbre::Context.new) }

    it 'can be called multiple times without error' do
      expect { footer.build }.not_to raise_error
      expect { footer.build }.not_to raise_error
    end

    it 'creates non-empty HTML' do
      footer.build
      expect(footer.to_s).not_to be_empty
    end

    it 'calls super with id parameter' do
      expect(footer).to receive(:super).with(id: 'footer').and_call_original
      footer.build
    end

    it 'calls super with style parameter' do
      allow(footer).to receive(:super).with(id: 'footer').and_call_original
      expect(footer).to receive(:super).with(style: 'text-align: right;')
      footer.build
    end
  end

  describe 'link attributes' do
    let(:footer) { ActiveAdmin::Views::Footer.new(Arbre::Context.new) }

    before do
      footer.build
    end

    it 'uses target=_blank for external navigation' do
      html = footer.to_s
      expect(html).to include('target="_blank"')
    end

    it 'includes rel=noopener for security' do
      html = footer.to_s
      expect(html).to include('rel="noopener"')
    end

    it 'has href attribute' do
      html = footer.to_s
      expect(html).to match(/href=["'][^"']+["']/)
    end

    it 'link text is in Spanish' do
      html = footer.to_s
      expect(html).to include('Manual de uso')
      expect(html).to include('datos de carácter personal')
    end

    it 'complete link text matches expected' do
      html = footer.to_s
      expect(html).to include('Manual de uso de datos de carácter personal')
    end
  end

  describe 'HTML structure validation' do
    let(:footer) { ActiveAdmin::Views::Footer.new(Arbre::Context.new) }

    before do
      footer.build
    end

    it 'produces valid HTML tags' do
      html = footer.to_s
      expect(html).to match(/<footer[^>]*>/)
      expect(html).to match(/<\/footer>/)
    end

    it 'div tags are properly closed' do
      html = footer.to_s
      div_opens = html.scan(/<div[^>]*>/).count
      div_closes = html.scan(/<\/div>/).count
      expect(div_opens).to eq(div_closes)
    end

    it 'small tags are properly closed' do
      html = footer.to_s
      small_opens = html.scan(/<small[^>]*>/).count
      small_closes = html.scan(/<\/small>/).count
      expect(small_opens).to eq(small_closes)
    end

    it 'anchor tags are properly closed' do
      html = footer.to_s
      a_opens = html.scan(/<a[^>]*>/).count
      a_closes = html.scan(/<\/a>/).count
      expect(a_opens).to eq(a_closes)
    end
  end

  describe 'integration with ActiveAdmin' do
    it 'is in the correct namespace' do
      expect(ActiveAdmin::Views::Footer.name).to eq('ActiveAdmin::Views::Footer')
    end

    it 'can be instantiated with Arbre context' do
      context = Arbre::Context.new
      expect { ActiveAdmin::Views::Footer.new(context) }.not_to raise_error
    end

    it 'responds to build method' do
      footer = ActiveAdmin::Views::Footer.new(Arbre::Context.new)
      expect(footer).to respond_to(:build)
    end

    it 'responds to to_s for rendering' do
      footer = ActiveAdmin::Views::Footer.new(Arbre::Context.new)
      footer.build
      expect(footer).to respond_to(:to_s)
    end
  end
end
