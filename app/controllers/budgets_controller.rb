class BudgetsController < ApplicationController
    before_action :authenticate_user!

    def new
        @budget = current_user.budgets.new(month: Date.current.beginning_of_month)
    end

    def create
        @budget = current_user.budgets.new(budget_params)
        if @budget.save
            redirect_to budgets_path, notice: "予算を設定しました"
        else
            render :new, status: :unprocessable_entity
        end
    end

    private
    def budget_params
        params.expect(budget: [ :month, :amount ])
    end
end
