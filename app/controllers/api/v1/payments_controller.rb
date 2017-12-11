class Api::V1::PaymentsController < Api::V1::BaseController
  before_action :check_user
  before_action :get_customer, only: [:billing_information, :invoices, :create, :remove, :edit, :update]
  
  def billing_information
    credit_card = @customer.sources&.first
    if credit_card
      render json: {credit_card: BillingsQuery.single(credit_card)}, status: 200
    else
      render json: {error: "Please add credit card"}, status: 404
    end
  end

  def invoices
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    invoices = params[:starting_after].present? ? @customer.invoices(limit: per_page, starting_after: params[:starting_after]) : @customer.invoices(limit: per_page)
    render json: InvoicesQuery.list(invoices, per_page), status: 200
  end

  def create
    begin
      response = Stripe::Token.create(card: get_params.to_h)
      if response
        credit_card = @customer.sources.create(card: response.id)
        render json: {credit_card: BillingsQuery.single(credit_card)}, status: 200
      end
    rescue Stripe::InvalidRequestError, Stripe::AuthenticationError, Stripe::APIConnectionError, Stripe::StripeError => e
      render json: {error: e.message}, status: 500
    end
  end

  def update
    credit_card = @customer.sources.first 
    credit_card.name = get_params["name"]
    credit_card.address_line1 = get_params["address_line1"]
    credit_card.address_line2 = get_params["address_line2"]
    credit_card.address_country = get_params["address_country"]
    credit_card.address_city = get_params["address_city"]
    credit_card.address_state = get_params["address_state"]
    credit_card.address_zip = get_params["address_zip"]
    begin
      if credit_card.save
        render json: {credit_card: BillingsQuery.single(credit_card)}, status: 200
      end
    rescue Stripe::InvalidRequestError, Stripe::AuthenticationError, Stripe::APIConnectionError, Stripe::StripeError => e
      render json: {error: e.message}, status: 500
    end
  end

  def destroy
    @customer.sources.first.delete
    render json: {notice: "Remove Successfully"}, status: 500
  end

  private
  def get_customer
    if current_user.customer_id.nil?
      @customer = Stripe::Customer.create(email: current_user.email) 
      current_user.update(customer_id: @customer.id)
    else
      @customer = Stripe::Customer.retrieve(current_user.customer_id)
    end
  end

  def check_user
    if current_user.staff?
      render json: {error: "This function only use for User"}, status: 500
    end
  end

  def get_params
    params.require(:card).permit(:number, :exp_month, :exp_year, :cvc, :name, :address_line1, :address_line2, :address_country, :address_city, :address_state, :address_zip)
  end
end