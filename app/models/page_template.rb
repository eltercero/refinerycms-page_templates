require 'template_existence_validator'
class PageTemplate < ActiveRecord::Base

  set_primary_key 'path'
  
  acts_as_indexed :fields => [:name, :description, :path]

  validates :path, :presence => true, :uniqueness => true, :template_existence => true
  validates :name, :presence => true
  serialize :page_parts
  has_many :pages, :foreign_key => :page_template_path
  
  def template_name
    path.split("/").last
  end

  def group
    "pages/#{path.sub(template_name, "")}"
  end

  def self.options_for_select(page, automatic_text=null)
    groups = PageTemplate.all.group_by(&:group).sort
    groups.map!{|k,v| OpenStruct.new({:group => k, :children => v}) }

    options = automatic_text ? "<option>#{automatic_text}</option>" : ""
    options << ActionController::Base.helpers.option_groups_from_collection_for_select(
      groups, :children, :group, :path, :template_name, 
      page.page_template ? page.page_template.path : ""
    )
  end
  
end
