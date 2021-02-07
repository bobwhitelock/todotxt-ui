module Context
  class << self
    def from(string)
      "@#{string.downcase}"
    end

    def for_current_day
      current_day = Date.today.strftime("%A")
      from(current_day)
    end
  end

  TODAY = "@today"
  TOMORROW = "@tomorrow"
  YESTERDAY = "@yesterday"
  DAILY_CONTEXTS = Date::DAYNAMES.map { |day| from(day) }
  AUTOCOMPLETE_CONTEXTS = [TODAY, TOMORROW, *DAILY_CONTEXTS]
end
