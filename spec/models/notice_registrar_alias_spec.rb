# frozen_string_literal: true

require 'rails_helper'

# Test the NoticeRegistrar alias class specifically
# This ensures the alias file app/models/notice_registrar.rb is covered
RSpec.describe NoticeRegistrar, type: :model do
  it 'is defined as a class' do
    expect(defined?(NoticeRegistrar)).to eq('constant')
    expect(NoticeRegistrar).to be_a(Class)
  end

  it 'is the same class as PlebisCms::NoticeRegistrar' do
    expect(NoticeRegistrar).to eq(PlebisCms::NoticeRegistrar)
  end

  it 'inherits from PlebisCms::NoticeRegistrar' do
    expect(NoticeRegistrar.superclass).to eq(PlebisCms::NoticeRegistrar.superclass)
    expect(NoticeRegistrar < PlebisCms::NoticeRegistrar.superclass).to be true
  end

  it 'can create instances' do
    instance = NoticeRegistrar.new
    expect(instance).to be_a(NoticeRegistrar)
    expect(instance).to be_a(PlebisCms::NoticeRegistrar)
  end

  it 'responds to the same methods as PlebisCms::NoticeRegistrar' do
    expect(NoticeRegistrar.public_instance_methods).to eq(PlebisCms::NoticeRegistrar.public_instance_methods)
  end

  it 'has the same class methods as PlebisCms::NoticeRegistrar' do
    expect(NoticeRegistrar.public_methods).to eq(PlebisCms::NoticeRegistrar.public_methods)
  end
end
