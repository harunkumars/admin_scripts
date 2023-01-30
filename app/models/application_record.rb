class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  connects_to database: { writing: Rails.env.to_sym, reading: Rails.env.to_sym }
end
