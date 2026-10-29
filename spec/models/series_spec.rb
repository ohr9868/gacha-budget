require 'rails_helper'

RSpec.describe Series, type: :model do
  describe 'Seriesのバリデーションチェック' do
    it '名前があれば有効' do
      series = build(:series)
      expect(series).to be_valid
    end
    it '名前が空白の場合エラーになるか' do
      series_without = build(:series, name: '')
      expect(series_without).to be_invalid
    end
    it '名前が31文字以上の場合エラーになるか' do
      series_31over = build(:series, name: 'a' * 31)
      expect(series_31over).to be_invalid
    end
    it '同じユーザで同じシリーズ名の場合エラーになるか' do
      user = create(:user)
      create(:series, user: user, name: 'ねこ')
      user_duplicated_series = build(:series, user: user, name: 'ねこ')
      expect(user_duplicated_series).to be_invalid
    end
    it '別のユーザで同じシリーズ名の場合は有効' do
      create(:series, name: 'ねこ')
      user_series = build(:series, name: 'ねこ')
      expect(user_series).to be_valid
    end
  end
  describe '削除のバリデーションチェック' do
    it '記録がないと削除できる' do
      series = create(:series)
      expect { series.destroy }.to change(Series, :count).by(-1)
    end
    it '記録があると削除できない' do
      series = create(:series)
      create(:record, series: series)
      expect { series.destroy }.not_to change(Series, :count)
    end
  end
  #pending "add some examples to (or delete) #{__FILE__}"
end
