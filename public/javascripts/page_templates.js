jQuery(document).ready(function($) {
  $('#page_page_template_path').change(function(){
    var id = $("option:selected", this).val();
    if (id != null && id != "")  {
      $('#page_lock_page_template').val(true);
      $('#page_template_auto_selection').hide();
      $('#page_template_manual_selection').show();
    } else {
      $('#page_lock_page_template').val(false);
      $('#page_template_manual_selection').hide();
      $('#page_template_auto_selection').show();
    }
    $("#submit_continue_button").remove();
  });
});