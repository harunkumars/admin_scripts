ActiveAdmin.register ActiveAdminReport do

  permit_params :name, :description, :ruby_script

  action_item :execute, only: :show do
    link_to 'Execute Ruby Script', execute_admin_active_admin_report_path(resource)
  end
  member_action :execute do
    class TempClass

    end
    TempClass.class_eval(resource.ruby_script)
    render plain: TempClass.new.perform
  end
end
