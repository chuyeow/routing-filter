require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'RoutingFilter', 'url recognition' do
  include RoutingFilterHelpers

  before :each do
    setup_environment :locale, :pagination
  end

  it 'recognizes the path /de/sections/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1', @section_params.update(:locale => 'de')
  end

  it 'recognizes the path /sections/1/pages/1 and sets the :page param' do
    should_recognize_path '/sections/1/pages/1', @section_params.update(:page => 1)
  end

  it 'recognizes the path /de/sections/1/pages/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1/pages/1', @section_params.update(:locale => 'de', :page => 1)
  end

  it 'recognizes the path /sections/1/articles/1 and sets the :locale param' do
    should_recognize_path '/sections/1/articles/1', @article_params
  end

  it 'recognizes the path /de/sections/1/articles/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1/articles/1', @article_params.update(:locale => 'de')
  end

  it 'recognizes the path /de/sections/1/articles/1/pages/1 and sets the :locale param' do
    should_recognize_path '/de/sections/1/articles/1/pages/1', @article_params.update(:locale => 'de', :page => 1)
  end

  it 'recognizes the path /sections/1 and does not set a :locale param' do
    should_recognize_path '/sections/1', @section_params
  end

  it 'recognizes the path /sections/1 and does not set a :page param' do
    should_recognize_path '/sections/1', @section_params
  end

  # Test that routing errors are thrown for invalid locales
  it 'does not recognizes the path /aa/sections/1 and does not set a :locale param' do
    begin
      should_recognize_path '/aa/sections/1', @section_params.update(:locale => 'aa')
      false
    rescue ActionController::RoutingError
      true
    end
  end

  it 'recognizes the path /en-US/sections/1 and sets a :locale param' do
    should_recognize_path '/en-US/sections/1', @section_params.update(:locale => 'en-US')
  end

  it 'recognizes the path /sections/1/articles/1 and does not set a :locale param' do
    should_recognize_path '/sections/1/articles/1', @article_params
  end

  it 'recognizes the path /sections/1/articles/1 and does not set a :page param' do
    should_recognize_path '/sections/1/articles/1', @article_params
  end

  it 'invalid locale: does not recognize the path /aa/sections/1/articles/1 and does not set a :locale param' do
    lambda { @set.recognize_path('/aa/sections/1/articles/1', {}) }.should raise_error(ActionController::RoutingError)
  end

  it 'recognizes the path /en-US/sections/1/articles/1 and sets a :locale param' do
    should_recognize_path '/en-US/sections/1/articles/1', @article_params.update(:locale => 'en-US')
  end

  it 'recognizes the path /en-us/sections/1/articles/1 and sets a :locale param' do
    orig_value = RoutingFilter::Locale.case_insensitive_locales
    RoutingFilter::Locale.case_insensitive_locales = true

    should_recognize_path '/en-us/sections/1/articles/1', @article_params.update(:locale => 'en-us')

    RoutingFilter::Locale.case_insensitive_locales = orig_value
  end

  it 'does not recognize the path /en-us/sections/1 if RoutingFilter::Locale.case_insensitive_locales is false' do
    lambda { @set.recognize_path('/en-us/sections/1/', {}) }.should raise_error(ActionController::RoutingError)
  end
end

describe 'RoutingFilter', 'url recognition with relative_url_root set' do
  include RoutingFilterHelpers

  before :each do
    @orig_relative_url_root = ActionController::Base.relative_url_root
    ActionController::Base.relative_url_root = '/anime'

    setup_environment :locale
  end

  after :each do
    ActionController::Base.relative_url_root = @orig_relative_url_root
  end

  it 'recognizes the path /anime/sections/1/articles/1' do
    should_recognize_path '/anime/sections/1/articles/1', @article_params
  end

  it 'recognizes the path /sections/1/articles/1' do
    should_recognize_path '/sections/1/articles/1', @article_params
  end

  it 'recognizes the path /en-US/anime/sections/1/articles/1' do
    should_recognize_path '/en-US/anime/sections/1/articles/1', @article_params.update(:locale => 'en-US')
  end
end