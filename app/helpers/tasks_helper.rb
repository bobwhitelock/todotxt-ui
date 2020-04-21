module TasksHelper
  def border_color_class(task)
    if task.contexts.include?('@today')
      'border-blue-300'
    end
  end

  def priority_text_class(task)
    case task.priority
    when 'A'
      'text-red-600'
    when 'B'
      'text-orange-600'
    when 'C'
      'text-yellow-600'
    end
  end

  def background_class(task)
    priority_class = priority_background_class(task)
    if priority_class
      priority_class
    elsif task.contexts.include?('@today')
      'bg-blue-200'
    else
      'bg-white'
    end
  end

  private

  def priority_background_class(task)
    case task.priority
    when 'A'
      'bg-red-200'
    when 'B'
      'bg-orange-200'
    when 'C'
      'bg-yellow-200'
    end
  end
end
