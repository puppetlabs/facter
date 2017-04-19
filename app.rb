require 'gettext-setup'

class TranslationTools
  include FastGettext::Translation
  GettextSetup.initialize(File.absolute_path('locales', File.dirname(__FILE__)))
  before do
    FastGettext.locale = GettextSetup.negotiate_locale(env["HTTP_ACCEPT_LANGUAGE"])
  end
end
