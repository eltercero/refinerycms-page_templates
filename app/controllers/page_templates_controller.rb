class PageTemplatesController < ApplicationController

  before_filter :find_all_page_templates
  before_filter :find_page

  def index
    # you can use meta fields from your model instead (e.g. browser_title)
    # by swapping @page for @page_template in the line below:
    present(@page)
  end

  def show
    @page_template = PageTemplate.find(params[:id])

    # you can use meta fields from your model instead (e.g. browser_title)
    # by swapping @page for @page_template in the line below:
    present(@page)
  end

protected

  def find_all_page_templates
    @page_templates = PageTemplate.order('position ASC')
  end

  def find_page
    @page = Page.where(:link_url => "/page_templates").first
  end

end
