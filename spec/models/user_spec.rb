require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションチェック' do
    it '設定したすべてのバリデーションが機能しているか' do
      user = build(:user)
      expect(user).to be_valid
    end
    it 'メールアドレスが空白の場合エラーになるか' do
      user_without_email = build(:user, email: '')
      expect(user_without_email).to be_invalid
    end
    it 'メールアドレスが重複の場合エラーになるか' do
      user = create(:user)
      user_duplicated_email = build(:user, email: user.email)
      expect(user_duplicated_email).to be_invalid
    end
    it 'メールアドレスに＠がない場合エラーになるか' do
      user_without_atsign = build(:user, email: 'aaaaaaa')
      expect(user_without_atsign).to be_invalid
    end
    it 'パスワードが空白の場合エラーになるか' do
      user_without_password = build(:user, password: "", password_confirmation: '')
      expect(user_without_password).to be_invalid
    end
    it '確認用パスワードとパスワードが一致しない場合エラーになるか' do
      user_password_mismatch = build(:user, password_confirmation: 'mismatch')
      expect(user_password_mismatch).to be_invalid
    end
    it 'パスワードの文字数が規定(5文字以下)より短い場合エラーになるか' do
      user_password_short = build(:user, password: 'short', password_confirmation: 'short')
      expect(user_password_short).to be_invalid
    end
  end
  # pending "add some examples to (or delete) #{__FILE__}"
end
