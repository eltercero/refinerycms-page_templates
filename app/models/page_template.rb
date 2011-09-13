require 'template_existence_validator'
class PageTemplate < ActiveRecord::Base

  set_primary_key 'path'
  
  acts_as_indexed :fields => [:name, :description, :path]

  validates :path, :presence => true, :uniqueness => true, :template_existence => true
  validates :name, :presence => true
  serialize :page_parts
  has_many :pages, :foreign_key => :page_template_path

end
