require 'spec_helper'

describe PageTemplate do

  def reset_page_template(options = {})
    @valid_attributes = {
      :id => 1,
      :name => "RSpec is great for testing too"
    }

    @page_template.destroy! if @page_template
    @page_template = PageTemplate.create!(@valid_attributes.update(options))
  end

  before(:each) do
    reset_page_template
  end

  context "validations" do
    
    it "rejects empty name" do
      PageTemplate.new(@valid_attributes.merge(:name => "")).should_not be_valid
    end

    it "rejects non unique name" do
      # as one gets created before each spec by reset_page_template
      PageTemplate.new(@valid_attributes).should_not be_valid
    end
    
  end

end