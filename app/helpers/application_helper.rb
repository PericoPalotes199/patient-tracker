module ApplicationHelper
  def conditional_fixed_footer
    if !current_user ||
    (controller_name == 'encounters' && action_name == 'show') ||
    (controller_name == 'users' && action_name == 'index' && !policy(@users).index?) ||
    (controller_name == 'users' && action_name == 'show')
      'fixed_footer'
    end
  end
end
