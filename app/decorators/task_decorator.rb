class TaskDecorator < Draper::Decorator
  delegate_all

  def today?
    contexts.include?("@today")
  end

  def border_color_class
    "border-blue-300" if today?
  end

  def priority_text_class
    case priority
    when "A"
      "text-red-600"
    when "B"
      "text-orange-600"
    when "C"
      "text-yellow-600"
    end
  end

  def background_class
    if priority_background_class
      priority_background_class
    elsif today?
      "bg-blue-200"
    else
      "bg-white"
    end
  end

  private

  def priority_background_class
    case priority
    when "A"
      "bg-red-200"
    when "B"
      "bg-orange-200"
    when "C"
      "bg-yellow-200"
    end
  end
end
