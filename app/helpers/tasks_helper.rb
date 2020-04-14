module TasksHelper
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

  def priority_background_class(task)
    case task.priority
    when 'A'
      'bg-red-200'
    when 'B'
      'bg-orange-200'
    when 'C'
      'bg-yellow-200'
    else
      'bg-white'
    end
  end
end
