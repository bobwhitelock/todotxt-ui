module Context
  def self.from(string)
    "@#{string.downcase}"
  end

  TODAY = "@today"
  TOMORROW = "@tomorrow"
  DAILY_CONTEXTS = Date::DAYNAMES.map { |day| from(day) }
  SPECIAL_CONTEXTS = [TODAY, TOMORROW, *DAILY_CONTEXTS]
end
