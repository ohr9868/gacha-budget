require 'rails_helper'

RSpec.describe Record, type: :model do
  describe 'Recordのバリデーションチェック' do
    it '全て正しく入力されていたら有効' do
      expect(build(:record)).to be_valid
    end
    it 'シリーズが無い場合エラーになるか' do
      expect(build(:record, series: nil)).to be_invalid
    end
    it '日付が無い場合エラーになるか' do
      expect(build(:record, played_date: nil)).to be_invalid
    end
    it '1回の金額が無い場合エラーになるか' do
      expect(build(:record, price_per_play: nil)).to be_invalid
    end
    it '1回の金額が0以下の場合エラーになるか' do
      expect(build(:record, price_per_play: 0)).to be_invalid
    end
    it '1回の金額が小数点の場合エラーになるか' do
      expect(build(:record, price_per_play: 200.5)).to be_invalid
    end
    it '回数が無い場合エラーになるか' do
      expect(build(:record, play_count: nil)).to be_invalid
    end
    it '回数が0以下の場合エラーになるか' do
      expect(build(:record, play_count: 0)).to be_invalid
    end
    it '回数が小数点の場合エラーになるか' do
      expect(build(:record, play_count: 1.5)).to be_invalid
    end
  end
  describe '合計金額のチェック' do
    it '1回の金額 × 回数が正常に動作するか' do
      record = build(:record, price_per_play: 300, play_count: 3)
      expect(record.total_price).to eq 900
    end
  end
  # pending "add some examples to (or delete) #{__FILE__}"
end
