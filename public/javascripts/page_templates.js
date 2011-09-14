jQuery(document).ready(function($) {
  $('#page_page_template_path').change(function(){
    
    var id = $("option:selected", this).val().replace("/","%2F");
    
    jQuery.getJSON(
      '/refinery/page_templates/' + id + '/page_parts.json', // TODO: store URL in page_options?
      function(data){

        add_part_in_sequence(0, data, function(){
          var allowed_part_titles = $.map(data, function(part){ return part.title; });
          page_options.tabs.children("ul").children("li").each( function(index) {
            var tab_title = $('a', this).html();
            console.debug(index + " : " + $.trim($.wymeditors(index).html()));
            if (($.inArray(tab_title, allowed_part_titles) == -1) &&
                (!$.trim($.wymeditors(index).html()))) {
                  console.debug("Removing " + index);
                  $.ajax({
                    url: page_options.del_part_url + '/' + $('#page_parts_attributes_' + index + '_id').val(),
                    type: 'DELETE'
                  });
                  page_options.tabs.tabs('remove', index);
                  $('#page_parts_attributes_' + index + '_id').remove();
                  // $('#submit_continue_button').remove();
            }
          });
        });
      });
  });
});

function add_part_in_sequence(part_index, parts_array, callback) {
  var part = parts_array[part_index];
  var tab_title = part.title.toLowerCase().replace(" ", "_");
  if ($('#page_part_' + tab_title).size() === 0) {
  $.get(
    page_options.new_part_url,
    {
      title: part.title,
      part_index: $('#new_page_part_index').val(),
      body: ''
    }, function(data, status) {
      $('#submit_continue_button').remove();
      // Add a new tab for the new content section.
      $('#page_part_editors').append(data);
      page_options.tabs.tabs('add', '#page_part_new_' + $('#new_page_part_index').val(), part.title);
      page_options.tabs.tabs('select', $('#new_page_part_index').val());

      // hook into wymeditor to instruct it to select this new tab again once it has loaded.
      WYMeditor.onload_functions.push(function() {
        page_options.tabs.tabs('select', $('#new_page_part_index').val());
      });

      // turn the new textarea into a wymeditor.
      $('#page_part_new_' + $('#new_page_part_index').val()).appendTo('#page_part_editors')
      WYMeditor.init();

      // Wipe the title and increment the index counter by one.
      $('#new_page_part_index').val(parseInt($('#new_page_part_index').val(), 10) + 1);
      $('#new_page_part_title').val('');

      page_options.tabs.find('> ul li a').corner('top 5px');
      if (part_index < parts_array.length-1) {
        part_index++;
        add_part_in_sequence(part_index, parts_array, callback);
      } else {
        callback();
      }
    });
  } else {
    callback();
  }
}
