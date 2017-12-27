function highlightTable() {
  var isMouseDown = false,
    isHighlighted;
  $("#our_table td")
    .mousedown(function () {
      isMouseDown = true;
      $(this).toggleClass("record");
      isHighlighted = $(this).hasClass("record");
      return false; // prevent text selection
    })
    .mouseover(function () {
      if (isMouseDown) {
        $(this).toggleClass("record", isHighlighted);
      }
    });

  $(document)
    .mouseup(function () {
      isMouseDown = false;
    });
};

$(document).on("click", "#save_reading", function() {
  if (confirm('Are you sure you wish to save your changes?')) {
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
   if (confirm('Are you sure you wish to save your changes?')) {
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
   if (confirm('Are you sure you wish to save your changes?')) {
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

$(document).on('turbolinks:load', highlightTable);