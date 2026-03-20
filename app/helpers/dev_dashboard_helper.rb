module DevDashboardHelper
  def render_status_badge(status)
    case status
    when :done
      content_tag(:span, "Done", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-900/50 text-green-300")
    when :partial
      content_tag(:span, "Partial", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-900/50 text-yellow-300")
    when :deferred
      content_tag(:span, "Deferred", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-700 text-gray-400")
    when :not_started
      content_tag(:span, "Not Started", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-900/50 text-red-400")
    else
      content_tag(:span, status.to_s.titleize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-700 text-gray-400")
    end
  end
end
