class MobileController < ApplicationController
	skip_before_action :verify_user, only: [:show]
	skip_before_action :verify_oath_user, only: [:show]
end
