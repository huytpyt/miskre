class NationsController < ApplicationController
  before_action :set_nation, only: [:destroy]
  before_action :authorization

  def index
    @nations = Nation.all
  end

  def new
    @nation = Nation.new
  end

  def create
    nation_name = params[:name]
    code = ISO3166::Country.find_by_name(nation_name).last["alpha2"]
    @nation = Nation.new(name: nation_name, code: code)
    if @nation.save
      redirect_to nations_path, notice: 'Nation was successfully created.' 
    else
      render :new
    end
  end

  def destroy
    @nation.destroy
    respond_to do |format|
      format.html { redirect_to nations_url, notice: 'Nation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def sync_shipping
    ShippingService.sync_shipping
    redirect_to nations_path
  end

  private

    def authorization
      unless current_user.staff?
        redirect_to root_path
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_nation
      @nation = Nation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
end
