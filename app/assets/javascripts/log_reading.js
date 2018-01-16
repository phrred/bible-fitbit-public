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
  var chapters_highlighted = []
     $('.record > .chapterNumber').each(function() {
      chapters_highlighted.push($(this).html().trim())
     })
  if (confirm('Are you sure you wish to save chapters: '+ chapters_highlighted + '?')) {
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

$(document).on('turbolinks:load', highlightTable);