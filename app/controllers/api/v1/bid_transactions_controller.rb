class Api::V1::BidTransactionsController < Api::V1::BaseController
	before_action :supplier_authentication
	before_action :set_transaction, only: [:update, :destroy, :show]
  def create
  	unless params[:time].is_a? Integer
  		render json: {bid_transaction: nil, errors: "Time must be integer"}, status: 200
  		return
  	end
  	time_spend = Date.today + params[:time].days
  	bid = BidTransaction.new(supplier_id: current_resource.supplier.id, time: time_spend, product_need_id: params[:product_need_id], cost: params[:cost], status: "pending")
  	if bid.save
  		render json: {bid_transaction: BidTransactionsQuery.single(bid), errors: nil}, status: 200
  	else
  		render json: {bid_transaction: nil, errors: bid.errors}, status: 200
  	end
  end

  def update
  	unless params[:time].is_a? Integer
  		render json: {bid_transaction: nil, errors: "Time must be integer"}, status: 200
  		return
  	end
  	time_spend = Date.today + params[:time].days
  	@transaction.time = time_spend
  	@transaction.cost = params[:cost]
  	if @transaction.save
  		render json: {bid_transaction: BidTransactionsQuery.single(@transaction), errors: nil}, status: 200
  	else
  		render json: {bid_transaction: nil, errors: @transaction.errors}, status: 200
  	end
  end

  def show
    render json: {bid_transaction: BidTransactionsQuery.single(@transaction), errors: nil}, status: 200
  end

  def index
    transaction_list = current_resource.supplier.bid_transactions
    page = params[:page]
    per_page = params[:per_page]
    search = params[:search]
    render json: BidTransactionsQuery.list(transaction_list, page, per_page, search), status: 200
  end

  def destroy
  	@transaction.destroy
  	head :no_content
  end

  private
  def set_transaction
  	@transaction = BidTransaction.find_by_id(params[:id])
  	unless @transaction
  		render json: {bid_transaction: nil, errors: "Not found"}, status: 200
  		return
  	end
  end
  def supplier_authentication
    unless current_resource.is_supplier? && current_resource.supplier.present?
      render json: {status: false, message: "Permission denied"}, status: 550
    end
  end
end