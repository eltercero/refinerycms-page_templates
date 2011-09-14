module Admin
  class PageTemplatesController < Admin::BaseController

    crudify :page_template,
            :title_attribute => 'name', :xhr_paging => true

    def page_parts
      respond_to do |format|
        format.json do
          template = PageTemplate.find(params[:id])
          @page_parts = template.page_parts.to_json
          render :json => @page_parts
        end
      end
    end
    
  end
end
