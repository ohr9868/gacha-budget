module ApplicationHelper
  def flash_bg(message_type)
    case message_type.to_sym
      when :notice
        "bg-green-100 text-green-800"
      when :alert
        "bg-red-100 text-red-800"
    else
        "bg-yellow-100"
    end
  end
end
