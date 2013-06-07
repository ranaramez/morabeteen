module ApplicationHelper
  def flash_messages
    echo = ''

    %w(success notice alert).each do |error|
      echo << %Q{
        <div class="alert #{flash_to_alert(error)}">
          <b>#{flash[error.to_sym]}</b>
        </div>
      } if flash[error.to_sym]
    end

    echo.html_safe
  end

  def notification_item(notification)
    need = notification.subject_type.constantize.find(notification.subject_id)
    need_thumb = need.selected_image.payload.notification_thumb.url
    %Q{<li>
        <a href="#{need_path(need)}">
          <div class="columns">
          <img alt="Notification_thumb" src="#{need_thumb}">
        </div>
        <div class="text clearfix">
          #{notification.notification_type.humanize}
        </div>
        </a>
      </li>}.html_safe
  end

  def custom_bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      type = :success if type == :notice
      type = :warning    if type == :alert
      type = :error   if type == :error
      type = :info   if type == :info
      unless type == :info
        text = "<script>toastr.options = {'positionClass': 'toast-bottom-right'};toastr.#{type}('#{message}')</script>"
      else
        text = "<script>toastr.options = {'positionClass': 'toast-bottom-full-width'};toastr.#{type}('#{message}')</script>"
      end
      flash_messages << text.html_safe if message
    end
    flash_messages.join("\n").html_safe
  end

end
