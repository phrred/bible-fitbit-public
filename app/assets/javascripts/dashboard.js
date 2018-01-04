$(document).on("click", "#reset_book", function() {
  var book = $("#book_dropdown1").val()
   if (confirm('Are you sure you wish to reset your reading progress for: ' + book + " ?")) {
    $.ajax({
     url: "resetBook",
     type: "POST",
     data: {'book': $('#book_dropdown1').val()},
     dataType: "json",
     success: function(data) {
      location.reload();
       }
     });
   }
});

$(document).on("click", "#reset_bible", function() {
   if (confirm('Are you sure you wish to reset your reading progress in the whole bible?')) {
     $.ajax({
     url: "resetBible",
     type: "POST",
     data: {},
     dataType: "json",
     success: function(data) {
      location.reload();
       }
     });
   }
});