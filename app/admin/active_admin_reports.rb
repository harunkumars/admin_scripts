ActiveAdmin.register ActiveAdminReport do

  permit_params :name, :description, :ruby_script

  action_item :execute, only: :show do
    link_to 'Execute Ruby Script', execute_admin_active_admin_report_path(resource)
  end
  member_action :execute do
    response.headers['Content-Type'] = 'text/event-stream'

    custom_puts = proc { |arg| response.stream.write "#{arg}\n" }

    klass = Class.new do
      custom_puts

      define_method :puts do |*args|
        args.each{ |arg| custom_puts[arg] }
        nil
      end
    end

    klass.class_eval(resource.ruby_script)
    response.stream.write klass.new.perform
  ensure
    response.stream.close
  end

  index do
    id_column
    column :name
    column :description
    column :created_at
    column :updated_at
    actions
  end

  show do
    code do
      div(style: 'white-space: pre') do
        resource.ruby_script
      end
    end
  end
  sidebar('Info', only: :show) do
    attributes_table do
      rows :name, :description, :created_at, :updated_at
    end
  end

  controller do
    include ActionController::Live
  end
end
