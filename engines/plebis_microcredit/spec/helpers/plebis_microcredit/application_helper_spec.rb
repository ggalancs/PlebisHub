# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlebisMicrocredit::ApplicationHelper, type: :helper do
  describe '#method_missing' do
    context 'with route helper methods ending in _path' do
      it 'delegates to main_app when main_app responds to the method' do
        allow(helper.main_app).to receive(:respond_to?).with(:users_path).and_return(true)
        allow(helper.main_app).to receive(:users_path).and_return('/users')

        result = helper.users_path
        expect(result).to eq('/users')
      end

      it 'delegates with arguments' do
        allow(helper.main_app).to receive(:respond_to?).with(:user_path).and_return(true)
        allow(helper.main_app).to receive(:user_path).with(123).and_return('/users/123')

        result = helper.user_path(123)
        expect(result).to eq('/users/123')
      end

      it 'delegates with multiple arguments' do
        allow(helper.main_app).to receive(:respond_to?).with(:edit_user_path).and_return(true)
        allow(helper.main_app).to receive(:edit_user_path).with(123, foo: 'bar').and_return('/users/123/edit?foo=bar')

        result = helper.edit_user_path(123, foo: 'bar')
        expect(result).to eq('/users/123/edit?foo=bar')
      end

      it 'delegates with keyword arguments' do
        allow(helper.main_app).to receive(:respond_to?).with(:search_path).and_return(true)
        allow(helper.main_app).to receive(:search_path).with(query: 'test').and_return('/search?query=test')

        result = helper.search_path(query: 'test')
        expect(result).to eq('/search?query=test')
      end

      it 'delegates with block' do
        allow(helper.main_app).to receive(:respond_to?).with(:custom_path).and_return(true)
        block_result = nil
        allow(helper.main_app).to receive(:custom_path) do |&block|
          block_result = block.call if block
          '/custom'
        end

        result = helper.custom_path { 'block_executed' }
        expect(result).to eq('/custom')
        expect(block_result).to eq('block_executed')
      end
    end

    context 'with route helper methods ending in _url' do
      it 'delegates to main_app when main_app responds to the method' do
        allow(helper.main_app).to receive(:respond_to?).with(:users_url).and_return(true)
        allow(helper.main_app).to receive(:users_url).and_return('http://example.com/users')

        result = helper.users_url
        expect(result).to eq('http://example.com/users')
      end

      it 'delegates with arguments' do
        allow(helper.main_app).to receive(:respond_to?).with(:user_url).and_return(true)
        allow(helper.main_app).to receive(:user_url).with(456).and_return('http://example.com/users/456')

        result = helper.user_url(456)
        expect(result).to eq('http://example.com/users/456')
      end

      it 'delegates with options hash' do
        allow(helper.main_app).to receive(:respond_to?).with(:posts_url).and_return(true)
        allow(helper.main_app).to receive(:posts_url).with(host: 'test.com').and_return('http://test.com/posts')

        result = helper.posts_url(host: 'test.com')
        expect(result).to eq('http://test.com/posts')
      end
    end

    context 'when main_app does not respond to the method' do
      it 'raises NoMethodError for unknown _path method' do
        allow(helper.main_app).to receive(:respond_to?).with(:unknown_route_path).and_return(false)

        expect { helper.unknown_route_path }.to raise_error(NoMethodError)
      end

      it 'raises NoMethodError for unknown _url method' do
        allow(helper.main_app).to receive(:respond_to?).with(:unknown_route_url).and_return(false)

        expect { helper.unknown_route_url }.to raise_error(NoMethodError)
      end
    end

    context 'with methods not ending in _path or _url' do
      it 'raises NoMethodError' do
        expect { helper.nonexistent_method }.to raise_error(NoMethodError)
      end

      it 'raises NoMethodError even if main_app has the method' do
        allow(helper.main_app).to receive(:respond_to?).with(:some_method).and_return(true)

        expect { helper.some_method }.to raise_error(NoMethodError)
      end

      it 'does not delegate regular methods' do
        expect { helper.regular_helper_method }.to raise_error(NoMethodError)
      end
    end

    context 'with real main_app routes' do
      it 'can access root_path' do
        result = helper.root_path
        expect(result).to be_a(String)
        expect(result).to eq('/')
      end

      it 'can access root_url' do
        result = helper.root_url
        expect(result).to be_a(String)
        expect(result).to include('http')
      end

      it 'can access new_collaboration_path' do
        result = helper.new_collaboration_path
        expect(result).to be_a(String)
      end

      it 'handles paths with parameters' do
        # This tests the actual delegation to main_app
        expect { helper.root_path(locale: 'es') }.not_to raise_error
      end
    end

    context 'edge cases' do
      it 'handles methods with underscores before _path' do
        allow(helper.main_app).to receive(:respond_to?).with(:some_long_route_name_path).and_return(true)
        allow(helper.main_app).to receive(:some_long_route_name_path).and_return('/some/long/route')

        result = helper.some_long_route_name_path
        expect(result).to eq('/some/long/route')
      end

      it 'handles methods with numbers' do
        allow(helper.main_app).to receive(:respond_to?).with(:api_v1_users_path).and_return(true)
        allow(helper.main_app).to receive(:api_v1_users_path).and_return('/api/v1/users')

        result = helper.api_v1_users_path
        expect(result).to eq('/api/v1/users')
      end

      it 'preserves nil arguments' do
        allow(helper.main_app).to receive(:respond_to?).with(:user_path).and_return(true)
        allow(helper.main_app).to receive(:user_path).with(nil).and_return('/users')

        result = helper.user_path(nil)
        expect(result).to eq('/users')
      end

      it 'preserves empty hash arguments' do
        allow(helper.main_app).to receive(:respond_to?).with(:users_path).and_return(true)
        allow(helper.main_app).to receive(:users_path).with({}).and_return('/users')

        result = helper.users_path({})
        expect(result).to eq('/users')
      end
    end
  end

  describe '#respond_to_missing?' do
    context 'with methods ending in _path' do
      it 'returns true when main_app responds to the method' do
        allow(helper.main_app).to receive(:respond_to?).with(:users_path).and_return(true)

        expect(helper.respond_to?(:users_path)).to be true
      end

      it 'returns false when main_app does not respond to the method' do
        allow(helper.main_app).to receive(:respond_to?).with(:unknown_path).and_return(false)

        expect(helper.respond_to?(:unknown_path)).to be false
      end

      it 'works with respond_to? check' do
        allow(helper.main_app).to receive(:respond_to?).with(:posts_path).and_return(true)

        expect(helper).to respond_to(:posts_path)
      end
    end

    context 'with methods ending in _url' do
      it 'returns true when main_app responds to the method' do
        allow(helper.main_app).to receive(:respond_to?).with(:users_url).and_return(true)

        expect(helper.respond_to?(:users_url)).to be true
      end

      it 'returns false when main_app does not respond to the method' do
        allow(helper.main_app).to receive(:respond_to?).with(:unknown_url).and_return(false)

        expect(helper.respond_to?(:unknown_url)).to be false
      end

      it 'works with respond_to? check' do
        allow(helper.main_app).to receive(:respond_to?).with(:posts_url).and_return(true)

        expect(helper).to respond_to(:posts_url)
      end
    end

    context 'with methods not ending in _path or _url' do
      it 'returns false for regular methods' do
        expect(helper.respond_to?(:some_random_method)).to be false
      end

      it 'returns false even if main_app has the method' do
        allow(helper.main_app).to receive(:respond_to?).with(:some_method).and_return(true)

        expect(helper.respond_to?(:some_method)).to be false
      end
    end

    context 'with include_private parameter' do
      it 'respects include_private flag' do
        allow(helper.main_app).to receive(:respond_to?).with(:users_path).and_return(true)

        expect(helper.respond_to?(:users_path, false)).to be true
        expect(helper.respond_to?(:users_path, true)).to be true
      end

      it 'delegates include_private to super when not a route helper' do
        expect(helper.respond_to?(:nonexistent, true)).to be false
      end
    end

    context 'with real routes' do
      it 'responds to root_path' do
        expect(helper).to respond_to(:root_path)
      end

      it 'responds to root_url' do
        expect(helper).to respond_to(:root_url)
      end

      it 'does not respond to nonexistent routes' do
        expect(helper).not_to respond_to(:definitely_nonexistent_route_path)
      end
    end
  end

  describe 'module structure' do
    it 'is a module' do
      expect(PlebisMicrocredit::ApplicationHelper).to be_a(Module)
    end

    it 'defines method_missing' do
      expect(PlebisMicrocredit::ApplicationHelper.instance_methods(false)).to include(:method_missing)
    end

    it 'defines respond_to_missing?' do
      expect(PlebisMicrocredit::ApplicationHelper.instance_methods(false)).to include(:respond_to_missing?)
    end

    it 'is in the correct namespace' do
      expect(PlebisMicrocredit::ApplicationHelper.name).to eq('PlebisMicrocredit::ApplicationHelper')
    end
  end

  describe 'integration with view context' do
    it 'has access to main_app' do
      expect(helper).to respond_to(:main_app)
      expect(helper.main_app).to be_present
    end

    it 'can be included in a view context' do
      expect(helper.class.ancestors).to include(PlebisMicrocredit::ApplicationHelper)
    end

    it 'works alongside other helper methods' do
      expect(helper).to respond_to(:content_tag)
      expect(helper).to respond_to(:link_to)
    end
  end

  describe 'practical usage scenarios' do
    it 'allows engine views to use main app routes' do
      # This simulates the actual use case from the comment in the file
      path = helper.root_path
      expect(path).to be_a(String)
    end

    it 'enables collaboration routes from microcredit engine' do
      result = helper.new_collaboration_path
      expect(result).to be_a(String)
      expect(result).to include('collaboration')
    end

    it 'supports polymorphic route helpers' do
      allow(helper.main_app).to receive(:respond_to?).with(:polymorphic_path).and_return(true)
      allow(helper.main_app).to receive(:polymorphic_path).with(:user).and_return('/users')

      result = helper.polymorphic_path(:user)
      expect(result).to eq('/users')
    end
  end

  describe 'performance and safety' do
    it 'does not break existing helper functionality' do
      # Ensure standard Rails helpers still work
      expect { helper.content_tag(:div, 'test') }.not_to raise_error
      expect { helper.link_to('Test', '/') }.not_to raise_error
    end

    it 'handles multiple sequential calls' do
      allow(helper.main_app).to receive(:respond_to?).with(:users_path).and_return(true)
      allow(helper.main_app).to receive(:users_path).and_return('/users')

      expect(helper.users_path).to eq('/users')
      expect(helper.users_path).to eq('/users')
      expect(helper.users_path).to eq('/users')
    end

    it 'handles different route helpers in sequence' do
      result1 = helper.root_path
      result2 = helper.new_collaboration_path

      expect(result1).to be_a(String)
      expect(result2).to be_a(String)
      expect(result1).not_to eq(result2)
    end
  end
end
