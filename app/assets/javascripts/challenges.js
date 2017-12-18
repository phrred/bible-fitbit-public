$("#current_challenge_table").html("<%= escape_javascript(render partial: 'current_challenge_table', locals: {current_challenges: @current_challenges} )%>");
$("#comparison_chart").html("<%= escape_javascript(render partial: 'comparison_chart')%>");
$(document).on("click", "#compareButton", function() {
   $.ajax({
   url: "comparison_values",
   type: "POST",
   data: {"group1" : $('#group1 :selected').text(), 'group2': $("#group2 :selected").text()},
   dataType: "json",
   success: function(data) {
    // location.reload();
     }
   });
});