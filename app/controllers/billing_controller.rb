class BillingController < ApplicationController
  before_action :get_customer, only: [:index, :create, :remove, :edit, :update]
  def index
    @billing = @customer.sources.first
    @invoices = @customer.invoices
  end

  def new
  end

  def edit
    @credit_card = @customer.sources.first    
  end

  def create
    begin
      response = Stripe::Token.create(card: get_params.to_h)
      if response
        @customer.sources.create(card: response.id)
        Stripe::Subscription.create(:customer => @customer.id, :plan => STRIPE_PLAINNING)
        redirect_to billing_index_path, notice: "Create Successfully"
      end
    rescue Stripe::InvalidRequestError, 
       Stripe::AuthenticationError,
       Stripe::APIConnectionError,
       Stripe::StripeError => e
       redirect_to new_billing_path, notice: e.message
    end
  end

  def update
    @credit_card = @customer.sources.first 
    @credit_card.name = get_params["name"]
    @credit_card.address_line1 = get_params["address_line1"]
    @credit_card.address_line2 = get_params["address_line2"]
    @credit_card.address_country = get_params["address_country"]
    @credit_card.address_city = get_params["address_city"]
    @credit_card.address_state = get_params["address_state"]
    @credit_card.address_zip = get_params["address_zip"]
    begin
      if @credit_card.save
        redirect_to billing_index_path, notice: "Update Successfully"
      end
    rescue Stripe::InvalidRequestError, 
       Stripe::AuthenticationError,
       Stripe::APIConnectionError,
       Stripe::StripeError => e
       redirect_to edit_billing_index_path, notice: e.message
    end
  end

  def remove
    @customer.sources.first.delete
    redirect_to billing_index_path, notice: "Remove Successfully"
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

  def get_params
    params.require(:card).permit(:number, :exp_month, :exp_year, :cvc, :name, :address_line1, :address_line2, :address_country, :address_city, :address_state, :address_zip)
  end
end
