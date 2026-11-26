require 'rails_helper'

RSpec.describe "Budgets", type: :request do
  let(:user) { create(:user) }
  describe "GET /budgets/new" do
    it "未ログインならログイン画面にリダイレクトされる" do
      get new_budget_path
      expect(response).to redirect_to(new_user_session_path)
    end
    it "ログイン済みなら表示される" do
      sign_in user
      get new_budget_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /budgets" do
    let(:valid_params) { { budget: { month: "2026-11", amount: 10_000 } } }
    it "未ログインならログイン画面にリダイレクトされ、作成されない" do
      expect { post budgets_path, params: valid_params }.not_to change(Budget, :count)
      expect(response).to redirect_to(new_user_session_path)
    end
    it "予算を作成し、ダッシュボードに戻る" do
      sign_in user
      expect {
        post budgets_path, params: { budget: { month: "2026-11", amount: 10_000 } }
      }.to change(user.budgets, :count).by(1)
      expect(response).to redirect_to(dashboard_path)
    end
    it "月が月初日で保存される" do
      sign_in user
      post budgets_path, params: { budget: { month: "2026-11", amount: 10_000 } }
      expect(user.budgets.last.month).to eq Date.new(2026, 11, 1)
    end
    it "同じ月の予算は作れない" do
      sign_in user
      create(:budget, user: user, month: Date.new(2026, 11, 1))
      expect {
        post budgets_path, params: { budget: { month: "2026-11", amount: 5_000 } }
      }.not_to change(Budget, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
    it "金額がマイナスなら作れない" do
      sign_in user
      params = { budget: { month: "2026-11", amount: -100 } }
      expect { post budgets_path, params: params }.not_to change(Budget, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /budgets/:id/edit" do
    it "自分の予算の編集画面を表示できる" do
      budget = create(:budget, user: user)
      sign_in user
      get edit_budget_path(budget)
      expect(response).to have_http_status(:success)
    end
    it "他人の予算の編集画面は開けない" do
      other_budget = create(:budget)
      sign_in user
      get edit_budget_path(other_budget)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /budgets/:id" do
    let!(:budget) { create(:budget, user: user, amount: 10_000) }
    it "未ログインなら更新されない" do
      patch budget_path(budget), params: { budget: { month: "2026-11", amount: 99_000 } }
      expect(budget.reload.amount).to eq 10_000
      expect(response).to redirect_to(new_user_session_path)
    end
    it "自分の予算を更新でき、ダッシュボードに戻る" do
      sign_in user
      patch budget_path(budget), params: { budget: { month: "2026-11", amount: 20_000 } }
      expect(budget.reload.amount).to eq 20_000
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "DELETE /budgets/:id" do
    let!(:budget) { create(:budget, user: user) }
    it "未ログインなら削除されない" do
      expect { delete budget_path(budget) }.not_to change(Budget, :count)
      expect(response).to redirect_to(new_user_session_path)
    end
    it "自分の予算を削除でき、ダッシュボードに戻る" do
      sign_in user
      expect { delete budget_path(budget) }.to change(Budget, :count).by(-1)
      expect(response).to redirect_to(dashboard_path)
    end
    it "他人の予算は削除できない" do
      other_budget = create(:budget)
      expect { delete budget_path(other_budget) }.not_to change(Budget, :count)
    end
  end
end
