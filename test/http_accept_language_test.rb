$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'http_accept_language'
require 'test/unit'

class MockedCgiRequest
  include HttpAcceptLanguage
  def env
    @env ||= {'HTTP_ACCEPT_LANGUAGE' => 'en-us,en-gb;q=0.8,en;q=0.6'}
  end
end

class HttpAcceptLanguageTest < Test::Unit::TestCase
  def test_should_return_empty_array
    request.env['HTTP_ACCEPT_LANGUAGE'] = nil
    assert_equal [], request.user_preferred_languages
  end

  def test_should_properly_split
    assert_equal %w{en-US en-GB en}, request.user_preferred_languages
  end

  def test_should_ignore_jambled_header
    request.env['HTTP_ACCEPT_LANGUAGE'] = 'odkhjf89fioma098jq .,.,'
    assert_equal [], request.user_preferred_languages
  end

  def test_should_find_first_available_language
    assert_equal 'en-GB', request.preferred_language_from(%w{en en-GB})
  end

  def test_should_find_first_compatible_language
    assert_equal 'en-hk', request.compatible_language_from(%w{en-hk})
    assert_equal 'en', request.compatible_language_from(%w{en})
  end

  def test_should_find_first_compatible_from_user_preferred
    request.env['HTTP_ACCEPT_LANGUAGE'] = 'en-us,de-de'
    assert_equal 'en', request.compatible_language_from(%w{de en})
  end

  def test_should_accept_symbols_as_available_languages
    request.env['HTTP_ACCEPT_LANGUAGE'] = 'en-us'
    assert_equal :"en-HK", request.compatible_language_from([:"en-HK"])
  end

  def test_should_find_most_compatible_language_from_user_preferred
    request.env['HTTP_ACCEPT_LANGUAGE'] = 'ja,en-gb,en-us,fr-fr'
    assert_equal "ja-JP", request.language_region_compatible_from(%w{en-UK en-US ja-JP})
  end

  def test_should_sanitize_available_language_names
    assert_equal ["en-UK", "en-US", "ja-JP", "pt-BR"], request.sanitize_available_locales(%w{en_UK-x3 en-US-x1 ja_JP-x2 pt-BR-x5})
  end

  private
  def request
    @request ||= MockedCgiRequest.new
  end
end
