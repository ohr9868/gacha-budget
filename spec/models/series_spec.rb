require 'rails_helper'

RSpec.describe Series, type: :model do
  describe 'Seriesのバリデーションチェック' do
    it '名前があれば有効' do
      expect(build(:series)).to be_valid
    end
    it '名前が空白の場合エラーになるか' do
      expect(build(:series, name: "")).to be_invalid
    end
    it '名前が31文字以上の場合エラーになるか' do
      expect(build(:series, name: "a" * 31)).to be_invalid
    end
    it '同じユーザで同じシリーズ名の場合エラーになるか' do
      user = create(:user)
      create(:series, user: user, name: "ねこ")
      expect(build(:series, user: user, name: "ねこ")).to be_invalid
    end
    it '別のユーザで同じシリーズ名の場合は有効' do
      create(:series, name: "ねこ")
      expect(build(:series, name: "ねこ")).to be_valid
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
  # pending "add some examples to (or delete) #{__FILE__}"
end
