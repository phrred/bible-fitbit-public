$(function () {
  var isMouseDown = false,
    isHighlighted;
  $("#our_table td")
    .mousedown(function () {
      isMouseDown = true;
      $(this).toggleClass("highlighted");
      isHighlighted = $(this).hasClass("highlighted");
      return false; // prevent text selection
    })
    .mouseover(function () {
      if (isMouseDown) {
        $(this).toggleClass("highlighted", isHighlighted);
      }
    });

  $(document)
    .mouseup(function () {
      isMouseDown = false;
    });
<<<<<<< Updated upstream
});
=======
});

$(document).on("click", "#save_reading", function() {
  if (confirm('Are you sure ?')) {
     var chapters_highlighted = []
     $('.record').each(function() {
      chapters_highlighted.push($(this).html().trim())
     })
     $.ajax({
     url: "update",
     type: "POST",
     data: {"date" : $('#date_input').val(), 'record': chapters_highlighted, 'book': $('#book_dropdown').val()},
     dataType: "json",
     success: function(data) {
      location.reload();
       }
     });
   }
});

$(document).on("click", "#reset_book", function() {
   if (confirm('Are you sure ?')) {
    $.ajax({
     url: "resetBook",
     type: "POST",
     data: {'book': $('#book_dropdown').val()},
     dataType: "json",
     success: function(data) {
      location.reload();
       }
     });
   }
});

$(document).on("click", "#reset_bible", function() {
   if (confirm('Are you sure ?')) {
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

// $(document).on("change", "#book_dropdown", function() {
//   $.ajax({
//      url: "search",
//      type: "POST",
//      data: {'book': $('#book_dropdown').val()},
//      dataType: "json",
//      success: function(data) {
//       //do nothing
//        }
//      });
// });

>>>>>>> Stashed changes
