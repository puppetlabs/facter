# frozen_string_literal: true

class LoggerHelper
  class << self
    def determine_callers_name(sender_self)
      class_name = case sender_self
                   when String
                     sender_self
                   when Class
                     sender_self.name
                   when Module
                     sender_self.name
                   else # when class is singleton
                     sender_self.class.name
                   end
      class_name
    end
  end
end
