class TemplateExistenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)  
    template_path = "#{RAILS_ROOT}/app/views/pages/#{value}.html"
    unless File.file?("#{template_path}.haml") || File.file?("#{template_path}.erb")
      record.errors[attribute] << (options[:message] || "#{value}.html.haml or #{value}.html.erb couldn't be found beneath #{value}.yml")
    end
  end
end