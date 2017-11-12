class Api::V1::TestsController < Api::V1::BaseController
  def show
    render :json => { test_message: 'Hi! this is test message'}, status: 200
  end
end
