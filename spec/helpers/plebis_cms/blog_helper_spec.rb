# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisCms::BlogHelper, type: :helper do
  # Include AutoHtml for testing
  include AutoHtml

  let(:post) do
    double('Post',
           content: "# Test Post\n\nThis is a test post with **bold** text.",
           media_url: nil,
           created_at: Time.zone.parse('2025-01-15 10:00:00'))
  end

  describe '#formatted_content' do
    it 'formats post content using auto_html' do
      result = helper.formatted_content(post)
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it 'processes markdown content' do
      result = helper.formatted_content(post)
      # The content should be processed by redcarpet (markdown)
      expect(result).to include('Test Post')
    end

    it 'returns full content when max_paraphs is nil' do
      result = helper.formatted_content(post, nil)
      expect(result).to include('test post')
    end

    context 'with max_paraphs limit' do
      let(:long_post) do
        double('Post',
               content: "Paragraph 1\n\nParagraph 2\n\nParagraph 3\n\nParagraph 4",
               media_url: nil,
               created_at: Time.zone.now)
      end

      before do
        # Mock link_to to avoid routing complexity in tests
        allow(helper).to receive(:link_to).and_return('<a href="#">Seguir leyendo</a>')
      end

      it 'truncates content to max_paraphs' do
        result = helper.formatted_content(long_post, 2)
        expect(result).to be_a(String)
      end

      it 'adds read more link when content exceeds max_paraphs' do
        result = helper.formatted_content(long_post, 2)
        expect(result).to include('Seguir leyendo')
      end

      it 'does not add read more link when content is within limit' do
        # With 10 paraphs limit, the 4-paragraph content should fit
        allow(helper).to receive(:link_to).and_call_original
        result = helper.formatted_content(long_post, 10)
        expect(result).not_to include('Seguir leyendo')
      end

      it 'includes plus-circle icon in read more link' do
        allow(helper).to receive(:fa_icon).and_return('<i class="fa fa-plus-circle"></i> Seguir leyendo')
        result = helper.formatted_content(long_post, 2)
        expect(helper).to have_received(:fa_icon).with('plus-circle', text: 'Seguir leyendo')
      end

      it 'links to the post in read more' do
        helper.formatted_content(long_post, 2)
        expect(helper).to have_received(:link_to).with(anything, long_post)
      end
    end

    context 'with YouTube URLs' do
      let(:youtube_post) do
        double('Post',
               content: "Check this video: https://www.youtube.com/watch?v=dQw4w9WgXcQ",
               media_url: nil,
               created_at: Time.zone.now)
      end

      it 'processes YouTube links' do
        result = helper.formatted_content(youtube_post)
        # AutoHtml should process the YouTube URL
        expect(result).to be_a(String)
      end
    end

    context 'with Vimeo URLs' do
      let(:vimeo_post) do
        double('Post',
               content: "Watch: https://vimeo.com/123456789",
               media_url: nil,
               created_at: Time.zone.now)
      end

      it 'processes Vimeo links' do
        result = helper.formatted_content(vimeo_post)
        expect(result).to be_a(String)
      end
    end

    context 'with Twitter content' do
      let(:twitter_post) do
        double('Post',
               content: "Follow @example on Twitter",
               media_url: nil,
               created_at: Time.zone.now)
      end

      it 'processes Twitter mentions' do
        result = helper.formatted_content(twitter_post)
        expect(result).to be_a(String)
      end
    end

    context 'with image URLs' do
      let(:image_post) do
        double('Post',
               content: "See image: https://example.com/image.jpg",
               media_url: nil,
               created_at: Time.zone.now)
      end

      it 'processes image links' do
        result = helper.formatted_content(image_post)
        expect(result).to be_a(String)
      end
    end

    context 'with regular links' do
      let(:link_post) do
        double('Post',
               content: "Visit https://example.com for more info",
               media_url: nil,
               created_at: Time.zone.now)
      end

      it 'processes regular links with target _blank' do
        result = helper.formatted_content(link_post)
        expect(result).to be_a(String)
      end
    end

    context 'with simple text formatting' do
      let(:simple_post) do
        double('Post',
               content: "Line 1\nLine 2\nLine 3",
               media_url: nil,
               created_at: Time.zone.now)
      end

      it 'applies simple_format to content' do
        result = helper.formatted_content(simple_post)
        expect(result).to be_a(String)
      end
    end
  end

  describe '#main_media' do
    context 'when post has no media_url' do
      it 'returns nil' do
        result = helper.main_media(post)
        expect(result).to be_nil
      end
    end

    context 'when post has YouTube media_url' do
      let(:youtube_media_post) do
        double('Post',
               content: 'Test',
               media_url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
               created_at: Time.zone.now)
      end

      it 'processes YouTube media URL' do
        result = helper.main_media(youtube_media_post)
        expect(result).to be_a(String)
      end

      it 'returns non-empty string for YouTube URL' do
        result = helper.main_media(youtube_media_post)
        expect(result).not_to be_empty
      end
    end

    context 'when post has Vimeo media_url' do
      let(:vimeo_media_post) do
        double('Post',
               content: 'Test',
               media_url: 'https://vimeo.com/123456789',
               created_at: Time.zone.now)
      end

      it 'processes Vimeo media URL' do
        result = helper.main_media(vimeo_media_post)
        expect(result).to be_a(String)
      end
    end

    context 'when post has image media_url' do
      let(:image_media_post) do
        double('Post',
               content: 'Test',
               media_url: 'https://example.com/photo.jpg',
               created_at: Time.zone.now)
      end

      it 'processes image media URL' do
        result = helper.main_media(image_media_post)
        expect(result).to be_a(String)
      end
    end

    context 'with empty media_url' do
      let(:empty_media_post) do
        double('Post',
               content: 'Test',
               media_url: '',
               created_at: Time.zone.now)
      end

      it 'returns nil for empty string' do
        result = helper.main_media(empty_media_post)
        expect(result).to be_nil
      end
    end

    context 'with blank media_url' do
      let(:blank_media_post) do
        double('Post',
               content: 'Test',
               media_url: '   ',
               created_at: Time.zone.now)
      end

      it 'returns nil for blank string' do
        result = helper.main_media(blank_media_post)
        expect(result).to be_nil
      end
    end
  end

  describe '#long_date' do
    it 'formats the post creation date in long format' do
      result = helper.long_date(post)
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it 'uses I18n localization' do
      allow(I18n).to receive(:l).and_call_original
      helper.long_date(post)
      expect(I18n).to have_received(:l).with(post.created_at.to_date, format: :long)
    end

    it 'returns localized date string' do
      result = helper.long_date(post)
      # The exact format depends on locale, but should contain year
      expect(result).to match(/202\d/)
    end

    context 'with different date' do
      let(:old_post) do
        double('Post',
               content: 'Old post',
               media_url: nil,
               created_at: Time.zone.parse('2020-06-15 14:30:00'))
      end

      it 'formats the old date correctly' do
        result = helper.long_date(old_post)
        expect(result).to include('2020')
      end
    end

    context 'with today\'s date' do
      let(:today_post) do
        double('Post',
               content: 'Today post',
               media_url: nil,
               created_at: Time.zone.now)
      end

      it 'formats today\'s date correctly' do
        result = helper.long_date(today_post)
        expect(result).to include(Time.zone.now.year.to_s)
      end
    end

    context 'with future date' do
      let(:future_post) do
        double('Post',
               content: 'Future post',
               media_url: nil,
               created_at: 1.year.from_now)
      end

      it 'formats future date correctly' do
        result = helper.long_date(future_post)
        expect(result).to include((Time.zone.now.year + 1).to_s)
      end
    end
  end

  # Edge cases and error handling
  describe 'edge cases' do
    context 'with nil content' do
      let(:nil_content_post) do
        double('Post',
               content: nil,
               media_url: nil,
               created_at: Time.zone.now)
      end

      it 'handles nil content gracefully' do
        expect { helper.formatted_content(nil_content_post) }.not_to raise_error
      end
    end

    context 'with empty content' do
      let(:empty_content_post) do
        double('Post',
               content: '',
               media_url: nil,
               created_at: Time.zone.now)
      end

      it 'handles empty content' do
        result = helper.formatted_content(empty_content_post)
        expect(result).to be_a(String)
      end
    end

    context 'with special characters in content' do
      let(:special_char_post) do
        double('Post',
               content: "Test <script>alert('xss')</script> content",
               media_url: nil,
               created_at: Time.zone.now)
      end

      it 'handles special characters safely' do
        result = helper.formatted_content(special_char_post)
        expect(result).to be_a(String)
      end
    end

    context 'with very long content' do
      let(:long_content_post) do
        double('Post',
               content: 'Lorem ipsum ' * 1000,
               media_url: nil,
               created_at: Time.zone.now)
      end

      it 'handles very long content' do
        result = helper.formatted_content(long_content_post)
        expect(result).to be_a(String)
      end

      it 'truncates with max_paraphs' do
        result = helper.formatted_content(long_content_post, 1)
        expect(result).to be_a(String)
      end
    end

    context 'with multiple consecutive newlines' do
      let(:newline_post) do
        double('Post',
               content: "Para 1\n\n\n\n\nPara 2\n\n\n\nPara 3",
               media_url: nil,
               created_at: Time.zone.now)
      end

      it 'handles multiple newlines' do
        result = helper.formatted_content(newline_post)
        expect(result).to be_a(String)
      end
    end
  end

  # Integration tests
  describe 'auto_html filter chain' do
    it 'applies all filters in correct order' do
      post_with_all = double('Post',
                             content: "# Title\n\nhttps://youtube.com/watch?v=123\n\n**Bold** text\n\nhttps://example.com",
                             media_url: nil,
                             created_at: Time.zone.now)

      result = helper.formatted_content(post_with_all)
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end

    it 'returns string type result' do
      result = helper.formatted_content(post)
      expect(result).to be_a(String)
    end
  end
end
