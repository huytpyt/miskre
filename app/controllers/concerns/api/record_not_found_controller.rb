module Api::RecordNotFoundController
  def handle_not_found
    render json: { error: 'Not found' }, status: 404
  end
end
