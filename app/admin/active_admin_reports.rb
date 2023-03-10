ActiveAdmin.register ActiveAdminReport do

  permit_params :name, :description, :ruby_script

  action_item :execute, only: :show do
    link_to 'Execute Ruby Script', execute_admin_active_admin_report_path(resource)
  end
  member_action :execute do
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Last-Modified'] = Time.now.httpdate
    response.stream.write "Streaming Started: \n"

    custom_puts = proc { |arg| response.stream.write "#{arg}\n" }

    mod = Module.new do
      define_method :puts do |*args|
        args.each{ |arg| custom_puts[arg] }
        nil
      end
    end

    klass = Class.new do
      extend mod
      include mod
    end

    begin
      ActiveRecord::Base.connected_to(role: :reading) do
        klass.class_eval(resource.ruby_script)
        @out = ">>>> The Script returned: #{klass.new.perform}"
      end
    rescue => e
      @out = ">>>> The Script failed: #{e}"
    end

  ensure
    response.stream.write "#{@out}\n"
    response.stream.write "Streaming Ended. You may now close the tab.\n"
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
