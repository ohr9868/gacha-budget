require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  let(:user) { create(:user) }
  describe "GET /dashboard" do
    it "未ログインならログイン画面にリダイレクトされる" do
      get dashboard_path
      expect(response).to redirect_to(new_user_session_path)
     end
    it "予算がなければ「未設定」と表示される" do
      sign_in user
      get dashboard_path
      expect(response.body).to include("今月の予算は未設定です")
    end
    it "予算がなければ「未設定」と表示される" do
      sign_in user
      create(:budget, user: user, amount: 10_000)
      series = create(:series, user: user)
      create(:record, series: series, played_date: Date.current,
        price_per_play: 300, play_count: 3)
      get dashboard_path
      expect(response.body).to include("10,000円")
      expect(response.body).to include("900円")
      expect(response.body).to include("9,100円")
    end
    it "先月の記録は合計に含まれない" do
      sign_in user
      create(:budget, user: user, amount: 10_000)
      series = create(:series, user: user)
      create(:record, series: series, played_date: Date.current.prev_month,
        price_per_play: 777, play_count: 1)
      get dashboard_path
      expect(response.body).not_to include("777円")
      expect(response.body).to include("10,000円")
    end
    it "他人の予算・記録は反映されない" do
      sign_in user
      create(:budget, amount: 999)
      create(:record, played_date: Date.current, price_per_play: 123, play_count: 1)
      get dashboard_path
      expect(response.body).not_to include("999円")
      expect(response.body).not_to include("123円")
      expect(response.body).to include("今月の予算は未設定です")
    end
  end
end
