Given /^I have no page_templates$/ do
  PageTemplate.delete_all
end

Given /^I (only )?have page_templates titled "?([^\"]*)"?$/ do |only, titles|
  PageTemplate.delete_all if only
  titles.split(', ').each do |title|
    PageTemplate.create(:name => title)
  end
end

Then /^I should have ([0-9]+) page_templates?$/ do |count|
  PageTemplate.count.should == count.to_i
end
