module Context
  def self.from(string)
    "@#{string.downcase}"
  end

  TODAY = "@today"
  TOMORROW = "@tomorrow"
  YESTERDAY = "@yesterday"
  DAILY_CONTEXTS = Date::DAYNAMES.map { |day| from(day) }
  AUTOCOMPLETE_CONTEXTS = [TODAY, TOMORROW, *DAILY_CONTEXTS]
end
