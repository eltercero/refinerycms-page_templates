require 'validators/template_existence_validator'
class PageTemplate < ActiveRecord::Base

  set_primary_key 'path'
  
  acts_as_indexed :fields => [:name, :description, :path]

  validates :path, :presence => true, :uniqueness => true, :template_existence => true
  serialize :page_parts
  has_many :pages, :foreign_key => :page_template_path

  def manually_assigned_pages
    pages.where(:lock_page_template => true)
  end
  def auto_assigned_pages
    pages.where(:lock_page_template => false)
  end

  def label_for_select
    path.split("/").last
  end
  def group_for_select
    "pages/#{path.sub(label_for_select, "")}"
  end

  def self.options_for_select(page, blank_text=nil)
    groups = PageTemplate.all.group_by(&:group_for_select).sort
    groups.map!{|k,v| OpenStruct.new({:group_for_select => k, :children => v}) }

    options = blank_text ? "<option value=''>#{blank_text}</option>" : ""
    options << ActionController::Base.helpers.option_groups_from_collection_for_select(
      groups, :children, :group_for_select, :path, :label_for_select, 
      page.page_template_path
    )
  end
  
end
