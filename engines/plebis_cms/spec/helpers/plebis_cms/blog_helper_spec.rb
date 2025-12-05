# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisCms::BlogHelper, type: :helper do
  let(:post) { create(:post, content: "First paragraph\nSecond paragraph\nThird paragraph") }

  before do
    I18n.locale = :es
  end

  describe '#formatted_content' do
    context 'without max_paraphs limit' do
      it 'returns formatted HTML content' do
        result = helper.formatted_content(post)
        expect(result).to be_present
        expect(result).to be_html_safe
      end

      it 'includes all paragraphs when no limit specified' do
        result = helper.formatted_content(post)
        expect(result).to include('First paragraph')
        expect(result).to include('Second paragraph')
        expect(result).to include('Third paragraph')
      end

      it 'processes content with auto_html filters' do
        result = helper.formatted_content(post)
        expect(result).to be_a(String)
        expect(result).to be_html_safe
      end

      it 'does not include read more link' do
        result = helper.formatted_content(post)
        expect(result).not_to include('Seguir leyendo')
      end

      it 'returns sum of processed content' do
        result = helper.formatted_content(post)
        expect(result).to be_a(String)
      end
    end

    context 'with max_paraphs limit' do
      context 'when content has more paragraphs than limit' do
        let(:post) { create(:post, content: "Para 1\nPara 2\nPara 3\nPara 4\nPara 5") }

        it 'limits content to specified number of paragraphs' do
          result = helper.formatted_content(post, 2)
          expect(result).to include('Para 1')
          expect(result).to include('Para 2')
        end

        it 'includes read more link when content is truncated' do
          allow(helper).to receive(:link_to).and_call_original
          result = helper.formatted_content(post, 2)
          expect(helper).to have_received(:link_to)
        end

        it 'generates read more link with correct text' do
          result = helper.formatted_content(post, 2)
          expect(result).to include('Seguir leyendo')
        end

        it 'generates read more link pointing to post' do
          allow(helper).to receive(:link_to).and_call_original
          helper.formatted_content(post, 2)
          expect(helper).to have_received(:link_to).with(anything, post)
        end

        it 'wraps read more link in paragraph tag' do
          allow(helper).to receive(:content_tag).and_call_original
          helper.formatted_content(post, 2)
          expect(helper).to have_received(:content_tag).with(:p, anything)
        end

        it 'does not include paragraphs beyond limit' do
          result = helper.formatted_content(post, 2)
          expect(result).not_to include('Para 3')
          expect(result).not_to include('Para 4')
          expect(result).not_to include('Para 5')
        end
      end

      context 'when content has fewer paragraphs than limit' do
        let(:post) { create(:post, content: "Only one\nOnly two") }

        it 'includes all content' do
          result = helper.formatted_content(post, 5)
          expect(result).to include('Only one')
          expect(result).to include('Only two')
        end

        it 'does not include read more link' do
          result = helper.formatted_content(post, 5)
          expect(result).not_to include('Seguir leyendo')
        end

        it 'returns all paragraphs when under limit' do
          result = helper.formatted_content(post, 10)
          expect(result).to be_present
        end
      end

      context 'when content has exactly max_paraphs paragraphs' do
        let(:post) { create(:post, content: "First\nSecond\nThird") }

        it 'includes all paragraphs' do
          result = helper.formatted_content(post, 3)
          expect(result).to include('First')
          expect(result).to include('Second')
          expect(result).to include('Third')
        end

        it 'does not include read more link' do
          result = helper.formatted_content(post, 3)
          expect(result).not_to include('Seguir leyendo')
        end
      end

      context 'with different paragraph counts' do
        it 'limits to 1 paragraph' do
          post = create(:post, content: "A\nB\nC\nD")
          result = helper.formatted_content(post, 1)
          expect(result).to include('Seguir leyendo')
        end

        it 'limits to 3 paragraphs' do
          post = create(:post, content: "A\nB\nC\nD\nE")
          result = helper.formatted_content(post, 3)
          expect(result).to include('Seguir leyendo')
        end

        it 'handles 0 max_paraphs by showing read more immediately' do
          result = helper.formatted_content(post, 0)
          expect(result).to include('Seguir leyendo')
        end
      end
    end

    context 'with special content' do
      it 'handles empty content' do
        post = create(:post, content: '')
        result = helper.formatted_content(post)
        expect(result).to be_a(String)
      end

      it 'handles single line content' do
        post = create(:post, content: 'Single line')
        result = helper.formatted_content(post)
        expect(result).to include('Single line')
      end

      it 'handles content with only newlines' do
        post = create(:post, content: "\n\n\n")
        result = helper.formatted_content(post)
        expect(result).to be_a(String)
      end

      it 'processes YouTube links' do
        post = create(:post, content: 'https://www.youtube.com/watch?v=test')
        result = helper.formatted_content(post)
        expect(result).to be_present
      end

      it 'processes Vimeo links' do
        post = create(:post, content: 'https://vimeo.com/12345')
        result = helper.formatted_content(post)
        expect(result).to be_present
      end

      it 'processes image URLs' do
        post = create(:post, content: 'https://example.com/image.jpg')
        result = helper.formatted_content(post)
        expect(result).to be_present
      end

      it 'processes regular links with target blank' do
        post = create(:post, content: 'https://example.com')
        result = helper.formatted_content(post)
        expect(result).to be_present
      end

      it 'processes markdown content' do
        post = create(:post, content: '# Header\n**Bold text**')
        result = helper.formatted_content(post)
        expect(result).to be_present
      end

      it 'processes Twitter content' do
        post = create(:post, content: '@username')
        result = helper.formatted_content(post)
        expect(result).to be_present
      end
    end

    context 'edge cases' do
      it 'handles nil max_paraphs' do
        result = helper.formatted_content(post, nil)
        expect(result).to be_present
      end

      it 'handles negative max_paraphs' do
        result = helper.formatted_content(post, -1)
        expect(result).to be_present
      end

      it 'returns html_safe string' do
        result = helper.formatted_content(post)
        expect(result.html_safe?).to be true
      end
    end
  end

  describe '#main_media' do
    context 'when post has media_url' do
      it 'returns processed YouTube video' do
        post = create(:post)
        post.media_url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
        result = helper.main_media(post)
        expect(result).to be_present
      end

      it 'returns processed Vimeo video' do
        post = create(:post)
        post.media_url = 'https://vimeo.com/123456'
        result = helper.main_media(post)
        expect(result).to be_present
      end

      it 'returns processed image URL' do
        post = create(:post)
        post.media_url = 'https://example.com/photo.png'
        result = helper.main_media(post)
        expect(result).to be_present
      end

      it 'processes media with auto_html' do
        post = create(:post)
        post.media_url = 'https://www.youtube.com/watch?v=test'
        result = helper.main_media(post)
        expect(result).to be_a(String)
      end

      it 'handles various image formats' do
        %w[jpg jpeg png gif].each do |format|
          post = create(:post)
          post.media_url = "https://example.com/image.#{format}"
          result = helper.main_media(post)
          expect(result).to be_present
        end
      end
    end

    context 'when post has no media_url' do
      it 'returns nil' do
        post = create(:post)
        post.media_url = nil
        result = helper.main_media(post)
        expect(result).to be_nil
      end

      it 'returns nil for empty string' do
        post = create(:post)
        post.media_url = ''
        result = helper.main_media(post)
        expect(result).to be_nil
      end

      it 'returns nil for blank string' do
        post = create(:post)
        post.media_url = '   '
        result = helper.main_media(post)
        expect(result).to be_nil
      end
    end

    context 'edge cases' do
      it 'handles invalid URLs gracefully' do
        post = create(:post)
        post.media_url = 'not a url'
        result = helper.main_media(post)
        expect(result).to be_present
      end

      it 'handles special characters in URL' do
        post = create(:post)
        post.media_url = 'https://example.com/media?id=123&param=value'
        result = helper.main_media(post)
        expect(result).to be_present
      end
    end
  end

  describe '#long_date' do
    it 'formats date in long format' do
      post = create(:post)
      post.created_at = Time.zone.parse('2023-05-15 10:30:00')
      result = helper.long_date(post)
      expect(result).to be_a(String)
      expect(result).to be_present
    end

    it 'uses I18n localization' do
      post = create(:post)
      post.created_at = Time.zone.parse('2023-05-15 10:30:00')
      expect(I18n).to receive(:l).with(post.created_at.to_date, format: :long).and_call_original
      helper.long_date(post)
    end

    it 'converts datetime to date' do
      post = create(:post)
      datetime = Time.zone.parse('2023-05-15 14:30:00')
      post.created_at = datetime
      result = helper.long_date(post)
      expect(result).to be_present
    end

    it 'formats different dates correctly' do
      dates = [
        Time.zone.parse('2020-01-01'),
        Time.zone.parse('2023-06-15'),
        Time.zone.parse('2024-12-25')
      ]

      dates.each do |date|
        post = create(:post)
        post.created_at = date
        result = helper.long_date(post)
        expect(result).to be_a(String)
        expect(result).to be_present
      end
    end

    it 'uses long format' do
      post = create(:post)
      post.created_at = Time.zone.parse('2023-05-15')
      result = helper.long_date(post)
      # In Spanish locale, should be something like "15 de mayo de 2023"
      expect(result).to match(/\d+.*\d{4}/)
    end

    it 'respects current locale' do
      post = create(:post)
      post.created_at = Time.zone.parse('2023-05-15')

      I18n.with_locale(:es) do
        result_es = helper.long_date(post)
        expect(result_es).to be_present
      end

      I18n.with_locale(:en) do
        result_en = helper.long_date(post)
        expect(result_en).to be_present
      end
    end

    context 'edge cases' do
      it 'handles today date' do
        post = create(:post)
        post.created_at = Time.zone.now
        result = helper.long_date(post)
        expect(result).to be_present
      end

      it 'handles past dates' do
        post = create(:post)
        post.created_at = 10.years.ago
        result = helper.long_date(post)
        expect(result).to be_present
      end

      it 'handles recent dates' do
        post = create(:post)
        post.created_at = 1.day.ago
        result = helper.long_date(post)
        expect(result).to be_present
      end
    end
  end

  describe 'module structure' do
    it 'includes AutoHtml module' do
      expect(PlebisCms::BlogHelper.included_modules).to include(AutoHtml)
    end

    it 'is a module' do
      expect(PlebisCms::BlogHelper).to be_a(Module)
    end

    it 'defines formatted_content method' do
      expect(PlebisCms::BlogHelper.instance_methods).to include(:formatted_content)
    end

    it 'defines main_media method' do
      expect(PlebisCms::BlogHelper.instance_methods).to include(:main_media)
    end

    it 'defines long_date method' do
      expect(PlebisCms::BlogHelper.instance_methods).to include(:long_date)
    end
  end

  describe 'integration with Rails helpers' do
    it 'can access content_tag' do
      expect(helper).to respond_to(:content_tag)
    end

    it 'can access link_to' do
      expect(helper).to respond_to(:link_to)
    end

    it 'can access fa_icon' do
      expect(helper).to respond_to(:fa_icon)
    end
  end
end
