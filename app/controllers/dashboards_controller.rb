class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    month = Date.current.beginning_of_month
    @month = month
    @budget = current_user.budgets.find_by(month: month)
    @spent = current_user.records.where(played_date: month.all_month).sum("price_per_play * play_count")
    @remaining = @budget.amount - @spent if @budget
  end
end
