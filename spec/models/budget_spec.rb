require 'rails_helper'

RSpec.describe Budget, type: :model do
  describe 'Budgetのバリデーションチェック' do
    it '全て正しく入力されていたら有効' do
      expect(build(:budget)).to be_valid
    end
    it '月がなければ無効' do
      expect(build(:budget, month: nil)).to be_invalid
    end
    it '金額がなければ無効' do
      expect(build(:budget, amount: nil)).to be_invalid
    end
    it "金額が0なら有効" do
      expect(build(:budget, amount: 0)).to be_valid
    end
    it "金額がマイナスなら無効" do
      expect(build(:budget, amount: -1)).to be_invalid
    end
    it "金額が小数なら無効" do
      expect(build(:budget, amount: 1000.5)).to be_invalid
    end
    it "ユーザーがなければ無効" do
      expect(build(:budget, user: nil)).to be_invalid
    end
    it "同じユーザーで同じ月なら無効" do
      user = create(:user)
      create(:budget, user: user, month: Date.new(2026, 11, 1))
      expect(build(:budget, user: user, month: Date.new(2026, 11, 1))).to be_invalid
    end
    it "別のユーザーなら同じ月でも有効" do
      create(:budget, month: Date.new(2026, 11, 1))
      expect(build(:budget, month: Date.new(2026, 11, 1))).to be_valid
    end
  end
  describe "month=（月初日への統一）" do
    it "日付を渡すと月初日になる" do
      expect(build(:budget, month: Date.new(2026, 11, 15)).month).to eq Date.new(2026, 11, 1)
    end
    it "YYYY-MM 形式の文字列でも月初日になる" do
      expect(build(:budget, month: "2026-11").month).to eq Date.new(2026, 11, 1)
    end
    it "同じ月の別の日でも、重複として無効になる" do
      user = create(:user)
      create(:budget, user: user, month: Date.new(2026, 11, 1))
      expect(build(:budget, user: user, month: Date.new(2026, 11, 20))).to be_invalid
    end
  end
  #  pending "add some examples to (or delete) #{__FILE__}"
end
