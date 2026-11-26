class BudgetsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_budget, only: %i[edit update destroy]

    def new
        @budget = current_user.budgets.new(month: Date.current.beginning_of_month)
    end

    def create
        @budget = current_user.budgets.new(budget_params)
        if @budget.save
            redirect_to dashboard_path, notice: "予算を設定しました"
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit; end

    def update
        if @budget.update(budget_params)
            redirect_to dashboard_path, notice: "予算を更新しました"
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @budget.destroy!
        redirect_to dashboard_path, notice: "予算を削除しました", status: :see_other
    end

    private
    def set_budget
    @budget = current_user.budgets.find(params[:id])
    end

    def budget_params
        params.expect(budget: [ :month, :amount ])
    end
end
