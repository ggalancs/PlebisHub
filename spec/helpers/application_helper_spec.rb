# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#semantic_form_with' do
    let(:model) { double('model') }

    before do
      allow(helper).to receive(:semantic_form_for).and_return('<form></form>'.html_safe)
    end

    it 'delegates to semantic_form_for with model parameter' do
      helper.semantic_form_with(model: model) {}
      expect(helper).to have_received(:semantic_form_for).with(model)
    end

    it 'converts model parameter to record for semantic_form_for' do
      result = helper.semantic_form_with(model: model) {}
      expect(result).to be_present
    end

    it 'converts scope parameter to as option' do
      helper.semantic_form_with(model: model, scope: :custom_scope) {}
      expect(helper).to have_received(:semantic_form_for).with(model, { as: :custom_scope })
    end

    it 'passes url option through' do
      url = '/custom/url'
      helper.semantic_form_with(model: model, url: url) {}
      expect(helper).to have_received(:semantic_form_for).with(model, { url: url })
    end

    it 'passes through additional options' do
      helper.semantic_form_with(model: model, html: { class: 'custom' }, method: :post) {}
      expect(helper).to have_received(:semantic_form_for)
        .with(model, { html: { class: 'custom' }, method: :post })
    end

    it 'combines url, scope, and other options' do
      helper.semantic_form_with(
        model: model,
        url: '/path',
        scope: :item,
        html: { id: 'form' }
      ) {}
      expect(helper).to have_received(:semantic_form_for)
        .with(model, { url: '/path', as: :item, html: { id: 'form' } })
    end

    it 'works with nil model' do
      result = helper.semantic_form_with(model: nil) {}
      expect(result).to be_present
    end

    it 'passes block to semantic_form_for' do
      block = proc { 'form content' }
      result = helper.semantic_form_with(model: model, &block)
      expect(result).to be_present
    end

    it 'handles url being nil' do
      helper.semantic_form_with(model: model, url: nil) {}
      expect(helper).to have_received(:semantic_form_for).with(model)
    end

    it 'handles scope being nil' do
      helper.semantic_form_with(model: model, scope: nil) {}
      expect(helper).to have_received(:semantic_form_for).with(model)
    end
  end

  describe '#nav_menu_link_to' do
    let(:name) { 'Home' }
    let(:icon) { 'home' }
    let(:url) { '/home' }

    before do
      allow(helper).to receive(:fa_icon).with(icon).and_return('<i class="fa fa-home"></i>'.html_safe)
      allow(helper).to receive(:content_tag).with(:span, name).and_return('<span>Home</span>'.html_safe)
      allow(helper).to receive(:link_to).and_return('<a href="/home">Link</a>'.html_safe)
    end

    context 'when current page matches one of the URLs' do
      it 'adds active class when first URL matches' do
        allow(helper).to receive(:current_page?).with('/home').and_return(true)
        allow(helper).to receive(:current_page?).with('/dashboard').and_return(false)

        result = helper.nav_menu_link_to(name, icon, url, ['/home', '/dashboard'])
        expect(result).to be_present

        expect(helper).to have_received(:link_to).with(
          anything,
          url,
          hash_including(class: ' active')
        )
      end

      it 'adds active class when second URL matches' do
        allow(helper).to receive(:current_page?).with('/home').and_return(false)
        allow(helper).to receive(:current_page?).with('/dashboard').and_return(true)

        result = helper.nav_menu_link_to(name, icon, url, ['/home', '/dashboard'])
        expect(result).to be_present

        expect(helper).to have_received(:link_to).with(
          anything,
          url,
          hash_including(class: ' active')
        )
      end
    end

    context 'when current page does not match any URL' do
      it 'does not add active class' do
        allow(helper).to receive(:current_page?).with('/home').and_return(false)
        allow(helper).to receive(:current_page?).with('/dashboard').and_return(false)

        result = helper.nav_menu_link_to(name, icon, url, ['/home', '/dashboard'])
        expect(result).to be_present

        expect(helper).to have_received(:link_to).with(
          anything,
          url,
          hash_including(class: '')
        )
      end
    end

    it 'preserves existing CSS classes when not active' do
      allow(helper).to receive(:current_page?).and_return(false)

      result = helper.nav_menu_link_to(name, icon, url, [], { class: 'custom-class' })
      expect(result).to be_present

      expect(helper).to have_received(:link_to).with(
          anything,
          url,
          hash_including(class: 'custom-class')
      )
    end

    it 'combines existing classes with active class' do
      allow(helper).to receive(:current_page?).with('/home').and_return(true)

      result = helper.nav_menu_link_to(name, icon, url, ['/home'], { class: 'custom-class' })
      expect(result).to be_present

      expect(helper).to have_received(:link_to).with(
        anything,
        url,
        hash_including(class: 'custom-class active')
      )
    end

    it 'creates proper link content with icon and span' do
      allow(helper).to receive(:current_page?).and_return(false)
      icon_html = '<i class="fa fa-home"></i>'.html_safe
      span_html = '<span>Home</span>'.html_safe

      result = helper.nav_menu_link_to(name, icon, url, [])
      expect(result).to be_present

      expect(helper).to have_received(:fa_icon).with(icon)
      expect(helper).to have_received(:content_tag).with(:span, name)
      expect(helper).to have_received(:link_to).with(icon_html + span_html, url, anything)
    end

    it 'handles nil html_options by creating empty class' do
      allow(helper).to receive(:current_page?).and_return(false)

      result = helper.nav_menu_link_to(name, icon, url, [])
      expect(result).to be_present

      expect(helper).to have_received(:link_to).with(
        anything,
        url,
        hash_including(class: '')
      )
    end
  end

  describe '#new_notifications_class' do
    it 'returns empty string' do
      expect(helper.new_notifications_class).to eq('')
    end
  end

  describe '#current_lang?' do
    before do
      I18n.locale = :es
    end

    it 'returns true when locale matches' do
      expect(helper.current_lang?(:es)).to be true
    end

    it 'returns true when locale matches string' do
      expect(helper.current_lang?('es')).to be true
    end

    it 'returns false when locale does not match' do
      expect(helper.current_lang?(:en)).to be false
    end

    it 'is case insensitive' do
      expect(helper.current_lang?(:ES)).to be true
      expect(helper.current_lang?('ES')).to be true
    end

    it 'handles different locale' do
      I18n.locale = :en
      expect(helper.current_lang?(:en)).to be true
      expect(helper.current_lang?(:es)).to be false
    end
  end

  describe '#current_lang_class' do
    before do
      I18n.locale = :es
    end

    context 'when language matches current locale' do
      it 'returns "active"' do
        result = helper.current_lang_class(:es)
        expect(result).to eq('active')
      end

      it 'returns "active" for symbol' do
        result = helper.current_lang_class(:es)
        expect(result).to eq('active')
      end

      it 'returns "active" for string' do
        result = helper.current_lang_class('es')
        expect(result).to eq('active')
      end
    end

    context 'when language does not match current locale' do
      it 'returns empty string' do
        result = helper.current_lang_class(:en)
        expect(result).to eq('')
      end

      it 'returns empty string for different language' do
        result = helper.current_lang_class('en')
        expect(result).to eq('')
      end
    end

    it 'is case insensitive' do
      expect(helper.current_lang_class(:ES)).to eq('active')
      expect(helper.current_lang_class('ES')).to eq('active')
    end
  end

  describe '#info_box' do
    before do
      allow(helper).to receive(:render).and_return('<div>Info</div>'.html_safe)
      allow(helper).to receive(:with_output_buffer).and_yield.and_return('test content')
    end

    it 'renders the info partial with content' do
      result = helper.info_box { 'test content' }
      expect(result).to be_present

      expect(helper).to have_received(:with_output_buffer)
      expect(helper).to have_received(:render).with(
        partial: 'application/info',
        locals: { content: 'test content' }
      )
    end

    it 'captures block content' do
      captured = 'Block content'
      allow(helper).to receive(:with_output_buffer).and_yield.and_return(captured)

      result = helper.info_box { 'Block content' }
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/info',
        locals: { content: captured }
      )
    end
  end

  describe '#alert_box' do
    before do
      allow(helper).to receive(:render).and_return('<div>Alert</div>'.html_safe)
      allow(helper).to receive(:with_output_buffer).and_yield.and_return('content')
    end

    it 'calls render_flash with application/alert partial' do
      title = 'Warning'
      close_text = 'Close'

      result = helper.alert_box(title, close_text) { 'content' }
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/alert',
        locals: { title: title, content: 'content', close_text: close_text }
      )
    end

    it 'uses empty string as default close_text' do
      title = 'Warning'

      result = helper.alert_box(title) { 'content' }
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/alert',
        locals: { title: title, content: 'content', close_text: '' }
      )
    end

    it 'passes block to render_flash' do
      result = helper.alert_box('Title') { 'block content' }
      expect(result).to be_present
    end
  end

  describe '#error_box' do
    before do
      allow(helper).to receive(:render).and_return('<div>Error</div>'.html_safe)
      allow(helper).to receive(:with_output_buffer).and_yield.and_return('content')
    end

    it 'calls render_flash with application/error partial' do
      title = 'Error'
      close_text = 'Dismiss'

      result = helper.error_box(title, close_text) { 'content' }
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/error',
        locals: { title: title, content: 'content', close_text: close_text }
      )
    end

    it 'uses empty string as default close_text' do
      title = 'Error'

      result = helper.error_box(title) { 'content' }
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/error',
        locals: { title: title, content: 'content', close_text: '' }
      )
    end

    it 'passes block to render_flash' do
      result = helper.error_box('Title') { 'error content' }
      expect(result).to be_present
    end
  end

  describe '#render_flash' do
    before do
      allow(helper).to receive(:render).and_return('<div>Flash</div>'.html_safe)
      allow(helper).to receive(:with_output_buffer).and_yield.and_return('test content')
    end

    it 'renders partial with title, content, and close_text' do
      partial_name = 'application/custom'
      title = 'Title'
      close_text = 'Close'

      result = helper.render_flash(partial_name, title, close_text) { 'test content' }
      expect(result).to be_present

      expect(helper).to have_received(:with_output_buffer)
      expect(helper).to have_received(:render).with(
        partial: partial_name,
        locals: { title: title, content: 'test content', close_text: close_text }
      )
    end

    it 'uses empty string as default close_text' do
      partial_name = 'application/custom'
      title = 'Title'

      result = helper.render_flash(partial_name, title) { 'content' }
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: partial_name,
        locals: { title: title, content: 'test content', close_text: '' }
      )
    end

    it 'captures block content' do
      captured_content = 'Captured from block'
      allow(helper).to receive(:with_output_buffer).and_yield.and_return(captured_content)

      result = helper.render_flash('application/test', 'Test') { captured_content }
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/test',
        locals: { title: 'Test', content: captured_content, close_text: '' }
      )
    end
  end

  describe '#field_notice_box' do
    before do
      allow(helper).to receive(:render).and_return('<div>Notice</div>'.html_safe)
    end

    it 'renders the form_field_notice partial' do
      result = helper.field_notice_box
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/form_field_notice'
      )
    end
  end

  describe '#errors_in_form' do
    let(:resource) { double('resource') }

    before do
      allow(helper).to receive(:render).and_return('<div>Errors</div>'.html_safe)
    end

    it 'renders the errors_in_form partial with resource' do
      result = helper.errors_in_form(resource)
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/errors_in_form',
        locals: { resource: resource }
      )
    end

    it 'passes different resources correctly' do
      resource1 = double('resource1')
      resource2 = double('resource2')

      helper.errors_in_form(resource1)
      expect(helper).to have_received(:render).with(
        partial: 'application/errors_in_form',
        locals: { resource: resource1 }
      )

      helper.errors_in_form(resource2)
      expect(helper).to have_received(:render).with(
        partial: 'application/errors_in_form',
        locals: { resource: resource2 }
      )
    end
  end

  describe '#steps_nav' do
    before do
      allow(helper).to receive(:render).and_return('<div>Steps</div>'.html_safe)
    end

    it 'renders steps_nav partial with current_step and three steps' do
      steps = ['Step One', 'Step Two', 'Step Three']
      current_step = 2

      result = helper.steps_nav(current_step, *steps)
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/steps_nav',
        locals: {
          first_step: 'Step One',
          second_step: 'Step Two',
          third_step: 'Step Three',
          steps_text: steps,
          current_step: 2
        }
      )
    end

    it 'handles first step as current' do
      steps = ['Alpha', 'Beta', 'Gamma']

      result = helper.steps_nav(1, *steps)
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/steps_nav',
        locals: {
          first_step: 'Alpha',
          second_step: 'Beta',
          third_step: 'Gamma',
          steps_text: steps,
          current_step: 1
        }
      )
    end

    it 'handles last step as current' do
      steps = ['Start', 'Middle', 'End']

      result = helper.steps_nav(3, *steps)
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/steps_nav',
        locals: {
          first_step: 'Start',
          second_step: 'Middle',
          third_step: 'End',
          steps_text: steps,
          current_step: 3
        }
      )
    end

    it 'passes steps_text array to partial' do
      steps = ['A', 'B', 'C']

      result = helper.steps_nav(1, *steps)
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/steps_nav',
        locals: hash_including(steps_text: steps)
      )
    end

    it 'extracts individual steps from array' do
      steps = ['X', 'Y', 'Z']

      result = helper.steps_nav(2, *steps)
      expect(result).to be_present

      expect(helper).to have_received(:render).with(
        partial: 'application/steps_nav',
        locals: hash_including(
          first_step: 'X',
          second_step: 'Y',
          third_step: 'Z'
        )
      )
    end
  end

  describe '#body_class' do
    context 'when user is not signed in and on login page' do
      it 'returns class starting with "logged-out"' do
        result = helper.body_class(false, 'sessions', 'new')
        expect(result).to start_with('logged-out')
      end

      it 'includes controller and action classes' do
        result = helper.body_class(false, 'sessions', 'new')
        expect(result).to include('controller-sessions')
        expect(result).to include('action-new')
      end
    end

    context 'when user is signed in' do
      it 'returns class starting with "signed-in"' do
        result = helper.body_class(true, 'sessions', 'new')
        expect(result).to start_with('signed-in')
      end

      it 'returns "signed-in" for any controller' do
        result = helper.body_class(true, 'posts', 'index')
        expect(result).to start_with('signed-in')
      end

      it 'returns "signed-in" for any action' do
        result = helper.body_class(true, 'users', 'edit')
        expect(result).to start_with('signed-in')
      end
    end

    context 'when user is not signed in but not on login page' do
      it 'returns "logged-out" for different controller' do
        result = helper.body_class(false, 'registrations', 'new')
        expect(result).to start_with('logged-out')
      end

      it 'returns "logged-out" for different action' do
        result = helper.body_class(false, 'sessions', 'create')
        expect(result).to start_with('logged-out')
      end

      it 'returns "logged-out" for different controller and action' do
        result = helper.body_class(false, 'pages', 'show')
        expect(result).to start_with('logged-out')
      end
    end

    context 'edge cases' do
      it 'handles nil signed_in as falsy' do
        result = helper.body_class(nil, 'sessions', 'new')
        expect(result).to start_with('logged-out')
      end

      it 'handles empty strings' do
        result = helper.body_class(false, '', '')
        expect(result).to eq('logged-out')
      end

      it 'handles nil controller and action' do
        result = helper.body_class(false, nil, nil)
        expect(result).to eq('logged-out')
      end
    end
  end
end
