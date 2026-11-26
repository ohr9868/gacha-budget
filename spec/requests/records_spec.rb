require 'rails_helper'

RSpec.describe "Records", type: :request do
  let(:user) { create(:user) }
  describe "GET /records" do
    it "未ログインならログイン画面にリダイレクトされる" do
      get records_path
      expect(response).to redirect_to(new_user_session_path)
    end
    it "自分の記録だけ表示される" do
      create(:record, series: create(:series, user: user, name: "自分のシリーズ"))
      create(:record, series: create(:series, name: "他人のシリーズ"))
      sign_in user
      get records_path
      expect(response.body).to include("自分のシリーズ")
      expect(response.body).not_to include("他人のシリーズ")
    end
    it "合計金額が表示される" do
      series = create(:series, user: user)
      create(:record, series: series, price_per_play: 300, play_count: 3)
      create(:record, series: series, price_per_play: 100, play_count: 2)
      sign_in user
      get records_path
      expect(response.body).to include("1,100円")
    end
  end

  describe "GET /records/new" do
    it "未ログインならログイン画面にリダイレクトされる" do
      get new_record_path
      expect(response).to redirect_to(new_user_session_path)
    end
    it "ログイン済みなら表示される" do
      sign_in user
      get new_record_path
      expect(response).to have_http_status(:success)
    end
  end
  describe "GET /records/:id/edit" do
    it "未ログインならログイン画面にリダイレクトされる" do
      get edit_record_path(create(:record))
      expect(response).to redirect_to(new_user_session_path)
    end
    it "自分の記録の編集画面に今のシリーズ名が入っている" do
      record = create(:record, series: create(:series, user: user, name: "ねこ"))
      sign_in user
      get edit_record_path(record)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("ねこ")
    end
    it "他人の記録の編集画面は開けない" do
      other_record = create(:record)
      sign_in user
      get edit_record_path(other_record)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /records" do
    let(:valid_params) do
      { record: { series_name: "ねこ", played_date: Date.current, price_per_play: 300, play_count: 3 } }
    end
    it "未ログインならログイン画面にリダイレクトされる" do
      expect { post records_path, params: valid_params }.not_to change(Record, :count)
      expect(response).to redirect_to(new_user_session_path)
    end
    it "記録とシリーズが作成され、一覧に戻る" do
      sign_in user
      expect { post records_path, params: valid_params }.to change(Record, :count).by(1).and change(user.series, :count).by(1)
      expect(response).to redirect_to(records_path)
    end
    it "同名のシリーズがあれば新しく作らない" do
      sign_in user
      user.series.create!(name: "ねこ")
      expect { post records_path, params: valid_params }.to change(Record, :count).by(1).and change(Series, :count).by(0)
    end
    it "シリーズ名が空なら保存されない" do
      sign_in user
      params = valid_params.deep_merge(record: { series_name: "" })
      expect { post records_path, params: params }.not_to change(Record, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
    it "金額が0なら保存されない" do
      sign_in user
      params = valid_params.deep_merge(record: { price_per_play: 0 })
      expect { post records_path, params: params }.not_to change(Record, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /records/:id" do
    let(:series) { create(:series, user: user, name: "ねこ") }
    let(:record) { create(:record, series: series, price_per_play: 300, play_count: 3) }
    it "金額と回数を更新できる" do
      sign_in user
      patch record_path(record), params: { record: { series_name: "ねこ",
        played_date: Date.current, price_per_play: 500, play_count: 2 } }
      expect(record.reload.price_per_play).to eq 500
      expect(response).to redirect_to(records_path)
    end
    it "既存の別シリーズ名に移動できる" do
      sign_in user
      other = create(:series, user: user, name: "いぬ")
      patch record_path(record), params: { record: { series_name: "いぬ",
        played_date: Date.current, price_per_play: 300, play_count: 3 } }
      expect(record.reload.series).to eq other
    end
    it "新しいシリーズ名にすると、シリーズが作られて移る" do
      record
      sign_in user
      expect {
        patch record_path(record), params: {
          record: { series_name: "新シリーズ", played_date: Date.current,
                    price_per_play: 300, play_count: 3 }
        }
      }.to change(user.series, :count).by(1)
      expect(record.reload.series.name).to eq "新シリーズ"
    end
    it "金額が0なら更新されず、編集画面が再表示される" do
      sign_in user
      patch record_path(record), params: {
        record: { series_name: "ねこ", played_date: Date.current,
        price_per_play: 0, play_count: 3 } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(record.reload.price_per_play).to eq 300
    end
    it "シリーズ名が空なら更新されない" do
      sign_in user
      patch record_path(record), params: {
        record: { series_name: "", played_date: Date.current,
        price_per_play: 500, play_count: 3 } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(record.reload.price_per_play).to eq 300
    end
    it "他人の記録は更新できない" do
      other_record = create(:record, price_per_play: 300)
      sign_in user
      patch record_path(other_record), params: {
        record: { series_name: "x", played_date: Date.current,
        price_per_play: 999, play_count: 1 } }
      expect(other_record.reload.price_per_play).to eq 300
    end
  end

  describe "DELETE /records/:id" do
    let!(:record) { create(:record, series: create(:series, user: user)) }
    it "未ログインなら削除されない" do
      expect { delete record_path(record) }.not_to change(Record, :count)
      expect(response).to redirect_to(new_user_session_path)
    end
    it "自分の記録を削除できる" do
      sign_in user
      expect { delete record_path(record) }.to change(Record, :count).by(-1)
      expect(response).to redirect_to(records_path)
    end
    it "他人の記録は削除できない" do
      other_record = create(:record)
      sign_in user
      expect { delete record_path(other_record) }.not_to change(Record, :count)
    end
  end
end
