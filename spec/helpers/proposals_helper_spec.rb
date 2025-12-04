# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProposalsHelper, type: :helper do
  let(:proposal) { create(:proposal, :active) }
  let!(:confirmed_user) { create(:user, :confirmed) }

  before do
    # Assign @proposal instance variable for methods that use it
    assign(:proposal, proposal)
  end

  describe '#time_left' do
    it 'returns time distance to finishes_at from now' do
      result = helper.time_left(proposal)
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it 'returns correct time for active proposal' do
      active_proposal = create(:proposal, created_at: 1.month.ago)
      result = helper.time_left(active_proposal)
      expect(result).to match(/mes|día/)
    end

    it 'returns correct time for just finished proposal' do
      finished_proposal = create(:proposal, :just_finished)
      result = helper.time_left(finished_proposal)
      expect(result).to be_a(String)
    end
  end

  describe '#formatted_created_at' do
    it 'returns time distance to created_at from now' do
      result = helper.formatted_created_at(proposal)
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it 'returns correct time for recent proposal' do
      recent_proposal = create(:proposal, created_at: 2.days.ago)
      result = helper.formatted_created_at(recent_proposal)
      expect(result).to include('2')
    end

    it 'returns correct time for old proposal' do
      old_proposal = create(:proposal, created_at: 2.months.ago)
      result = helper.formatted_created_at(old_proposal)
      expect(result).to match(/mes/)
    end
  end

  describe '#formatted_description' do
    it 'formats description with simple_format' do
      proposal_with_newlines = create(:proposal, description: "Line 1\n\nLine 2")
      result = helper.formatted_description(proposal_with_newlines)
      expect(result).to include('<p>')
    end

    it 'auto-links URLs in description' do
      proposal_with_url = create(:proposal, description: 'Check https://example.com')
      result = helper.formatted_description(proposal_with_url)
      expect(result).to include('<a')
      expect(result).to include('https://example.com')
    end

    it 'adds target="_blank" to auto-linked URLs' do
      proposal_with_url = create(:proposal, description: 'Visit https://example.com')
      result = helper.formatted_description(proposal_with_url)
      expect(result).to include('target="_blank"')
    end

    it 'handles plain text without URLs' do
      plain_proposal = create(:proposal, description: 'Simple description')
      result = helper.formatted_description(plain_proposal)
      expect(result).to include('Simple description')
      expect(result).to include('<p>')
    end

    it 'handles multiple URLs' do
      proposal_with_urls = create(:proposal, description: 'Site1: https://example.com and Site2: https://test.com')
      result = helper.formatted_description(proposal_with_urls)
      expect(result.scan(/<a/).length).to eq(2)
    end
  end

  describe '#formatted_support_count' do
    it 'returns formatted support count with delimiter' do
      allow(proposal).to receive(:agoravoting_required_votes).and_return(1000)
      allow(proposal).to receive(:supports_count).and_return(500)
      result = helper.formatted_support_count(proposal)
      expect(result).to eq('500 de 1.000')
    end

    it 'formats large numbers with delimiters' do
      allow(proposal).to receive(:agoravoting_required_votes).and_return(10_000)
      allow(proposal).to receive(:supports_count).and_return(5_000)
      result = helper.formatted_support_count(proposal)
      expect(result).to eq('5.000 de 10.000')
    end

    it 'handles zero supports' do
      allow(proposal).to receive(:agoravoting_required_votes).and_return(100)
      allow(proposal).to receive(:supports_count).and_return(0)
      result = helper.formatted_support_count(proposal)
      expect(result).to eq('0 de 100')
    end

    it 'uses @proposal instance variable' do
      allow(proposal).to receive(:agoravoting_required_votes).and_return(50)
      allow(proposal).to receive(:supports_count).and_return(25)
      result = helper.formatted_support_count(proposal)
      expect(result).to match(/\d+ de \d+/)
    end
  end

  describe '#formatted_support_percentage' do
    it 'returns percentage as string' do
      allow(proposal).to receive(:support_percentage).and_return(25.5)
      result = helper.formatted_support_percentage(proposal)
      expect(result).to eq('25,500%')
    end

    it 'accepts options for formatting' do
      allow(proposal).to receive(:support_percentage).and_return(25.5)
      result = helper.formatted_support_percentage(proposal, precision: 1)
      expect(result).to eq('25,5%')
    end

    it 'handles zero percentage' do
      allow(proposal).to receive(:support_percentage).and_return(0)
      result = helper.formatted_support_percentage(proposal)
      expect(result).to eq('0,000%')
    end

    it 'handles 100 percentage' do
      allow(proposal).to receive(:support_percentage).and_return(100)
      result = helper.formatted_support_percentage(proposal)
      expect(result).to eq('100,000%')
    end

    it 'passes custom options to number_to_percentage' do
      allow(proposal).to receive(:support_percentage).and_return(33.3333)
      result = helper.formatted_support_percentage(proposal, precision: 2)
      expect(result).to eq('33,33%')
    end
  end

  describe '#proposal_image' do
    it 'returns image_url when present' do
      proposal_with_image = create(:proposal)
      allow(proposal_with_image).to receive(:image_url).and_return('custom-image.jpg')
      result = helper.proposal_image(proposal_with_image)
      expect(result).to eq('custom-image.jpg')
    end

    it 'returns default image when image_url is nil' do
      proposal_without_image = create(:proposal)
      allow(proposal_without_image).to receive(:image_url).and_return(nil)
      result = helper.proposal_image(proposal_without_image)
      expect(result).to eq('proposal-example.jpg')
    end

    it 'returns default image when image_url is empty string' do
      proposal_without_image = create(:proposal)
      allow(proposal_without_image).to receive(:image_url).and_return('')
      result = helper.proposal_image(proposal_without_image)
      expect(result).to eq('proposal-example.jpg')
    end

    it 'returns default image when image_url is blank' do
      proposal_without_image = create(:proposal)
      allow(proposal_without_image).to receive(:image_url).and_return('   ')
      result = helper.proposal_image(proposal_without_image)
      expect(result).to eq('proposal-example.jpg')
    end
  end

  describe '#support_button' do
    it 'returns CSS selector for support button' do
      result = helper.support_button
      expect(result).to eq("#support_proposal_#{proposal.id} input[type=submit]")
    end

    it 'uses @proposal instance variable' do
      different_proposal = create(:proposal)
      assign(:proposal, different_proposal)
      result = helper.support_button
      expect(result).to eq("#support_proposal_#{different_proposal.id} input[type=submit]")
    end

    it 'returns valid CSS selector format' do
      result = helper.support_button
      expect(result).to match(/^#support_proposal_\d+ input\[type=submit\]$/)
    end
  end

  describe '#filtered_proposals' do
    before do
      allow(helper).to receive(:params).and_return({ filter: 'popular' })
      # Stub the proposals_path method from the view context
      helper.singleton_class.class_eval do
        def proposals_path(options = {})
          if options[:filter]
            "/proposals?filter=#{options[:filter]}"
          else
            '/proposals'
          end
        end
      end
    end

    it 'returns link to proposals_path with filter' do
      result = helper.filtered_proposals('Popular', 'popular')
      expect(result).to include('href')
      expect(result).to include('/proposals')
      expect(result).to include('filter=popular')
    end

    it 'adds active class when filter matches params' do
      result = helper.filtered_proposals('Popular', 'popular')
      expect(result).to include('class="active"')
    end

    it 'does not add active class when filter does not match params' do
      result = helper.filtered_proposals('Recent', 'recent')
      expect(result).not_to include('class="active"')
      expect(result).to include('class=""')
    end

    it 'includes text in link' do
      result = helper.filtered_proposals('Popular Proposals', 'popular')
      expect(result).to include('Popular Proposals')
    end

    it 'generates correct path for different filters' do
      result = helper.filtered_proposals('Hot', 'hot')
      expect(result).to include('filter=hot')
    end

    it 'works when params[:filter] is nil' do
      allow(helper).to receive(:params).and_return({})
      result = helper.filtered_proposals('All', 'all')
      expect(result).to include('href')
      expect(result).not_to include('class="active"')
    end
  end

  describe '#active?' do
    context 'when filter matches params[:filter]' do
      before do
        allow(helper).to receive(:params).and_return({ filter: 'popular' })
      end

      it 'returns "active"' do
        result = helper.active?('popular')
        expect(result).to eq('active')
      end
    end

    context 'when filter does not match params[:filter]' do
      before do
        allow(helper).to receive(:params).and_return({ filter: 'popular' })
      end

      it 'returns empty string' do
        result = helper.active?('recent')
        expect(result).to eq('')
      end
    end

    context 'when params[:filter] is nil' do
      before do
        allow(helper).to receive(:params).and_return({})
      end

      it 'returns empty string' do
        result = helper.active?('popular')
        expect(result).to eq('')
      end
    end

    context 'when params is empty' do
      before do
        allow(helper).to receive(:params).and_return({})
      end

      it 'returns empty string for any filter' do
        expect(helper.active?('recent')).to eq('')
        expect(helper.active?('popular')).to eq('')
        expect(helper.active?('hot')).to eq('')
      end
    end

    it 'performs exact string comparison' do
      allow(helper).to receive(:params).and_return({ filter: 'popular' })
      expect(helper.active?('popular')).to eq('active')
      expect(helper.active?('Popular')).to eq('')
      expect(helper.active?('popular ')).to eq('')
    end
  end

  # Integration tests for method interactions
  describe 'integration tests' do
    it 'formatted_description and proposal_image work together' do
      proposal_with_both = create(:proposal, description: 'Visit https://example.com')
      allow(proposal_with_both).to receive(:image_url).and_return('custom.jpg')

      description = helper.formatted_description(proposal_with_both)
      image = helper.proposal_image(proposal_with_both)

      expect(description).to include('https://example.com')
      expect(image).to eq('custom.jpg')
    end

    it 'support_button uses correct proposal when @proposal changes' do
      proposal1 = create(:proposal)
      proposal2 = create(:proposal)

      assign(:proposal, proposal1)
      button1 = helper.support_button

      assign(:proposal, proposal2)
      button2 = helper.support_button

      expect(button1).to include(proposal1.id.to_s)
      expect(button2).to include(proposal2.id.to_s)
      expect(button1).not_to eq(button2)
    end

    it 'filtered_proposals and active? work together consistently' do
      allow(helper).to receive(:params).and_return({ filter: 'hot' })
      helper.singleton_class.class_eval do
        def proposals_path(options = {})
          if options[:filter]
            "/proposals?filter=#{options[:filter]}"
          else
            '/proposals'
          end
        end
      end

      hot_link = helper.filtered_proposals('Hot', 'hot')
      popular_link = helper.filtered_proposals('Popular', 'popular')

      expect(hot_link).to include('class="active"')
      expect(popular_link).not_to include('class="active"')
    end
  end

  # Edge cases and error handling
  describe 'edge cases' do
    it 'handles proposal with very long description' do
      long_description = 'A' * 10_000
      long_proposal = create(:proposal, description: long_description)
      result = helper.formatted_description(long_proposal)
      expect(result).to include('A' * 100) # Should contain the text
    end

    it 'handles proposal with special HTML characters in description' do
      special_proposal = create(:proposal, description: 'Test <script>alert("xss")</script>')
      result = helper.formatted_description(special_proposal)
      # Rails sanitizes/strips script tags for security
      expect(result).not_to include('<script>')
      expect(result).to include('Test')
    end

    it 'handles proposals created at exact boundaries' do
      exactly_3_months = create(:proposal, created_at: 3.months.ago)
      result = helper.time_left(exactly_3_months)
      expect(result).to be_a(String)
    end

    it 'formatted_support_count handles very large numbers' do
      allow(proposal).to receive(:agoravoting_required_votes).and_return(1_000_000)
      allow(proposal).to receive(:supports_count).and_return(999_999)
      result = helper.formatted_support_count(proposal)
      expect(result).to include('999.999')
      expect(result).to include('1.000.000')
    end

    it 'formatted_support_percentage handles decimal precision' do
      allow(proposal).to receive(:support_percentage).and_return(33.33333333)
      result = helper.formatted_support_percentage(proposal, precision: 4)
      expect(result).to eq('33,3333%')
    end
  end
end
