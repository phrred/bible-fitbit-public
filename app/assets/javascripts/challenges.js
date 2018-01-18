/**
 * Display tooltips when hovering over students' names in the gradebook view
 */
challenge_info_popup = function() {
    fadeTime = 100
    $(".challenge_invite").hover(function() {
        $(this).find(".tooltip_content").fadeIn(fadeTime).css("display", "block");
    }, function() {
        $(this).find(".tooltip_content").fadeOut(fadeTime, function() {$(this).css("marginLeft", "");});
    });
}

$(document).on('turbolinks:load', challenge_info_popup);