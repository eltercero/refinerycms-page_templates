if defined?(User)
  User.all.each do |user|
    if user.plugins.where(:name => 'page_templates').blank?
      user.plugins.create(:name => 'page_templates',
                          :position => (user.plugins.maximum(:position) || -1) +1)
    end
  end
end