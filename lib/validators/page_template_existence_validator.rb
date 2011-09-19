class PageTemplateExistenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)  
    existing_templates = [Rails.root, Refinery::Plugins.registered.pathnames].flatten.uniq.map{|p| p.join('app', 'views', 'pages', '**', '*html*')}.map(&:to_s).map{ |p| Dir[p] }.select{|p| p.count > 0}.flatten.map{|f| f.to_s.sub(/.*\/app\/views\/pages\//, '')}.map{ |f| f.split(".").first }
    unless existing_templates.include?(value)
      record.errors[attribute] << (options[:message] || "#{value}.html.haml or #{value}.html.erb couldn't be found next to #{value}.yml")
    end
  end
end