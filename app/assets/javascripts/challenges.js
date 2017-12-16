$("#current_challenge_table").html("<%= escape_javascript(render partial: 'current_challenge_table', locals: {current_challenges: @current_challenges} )%>");
