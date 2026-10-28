class RecordsController < ApplicationController
  before_action :authenticate_user!
  def new
    @record = Record.new(played_date: Date.current)
    @series_list = current_user.series.order(:name)
  end

  def create
    series_name = params.dig(:record, :series_name)
    series = current_user.series.find_or_create_by(name: series_name) if series_name.present?
    @record = Record.new(record_params)
    @record.series = series
    if series&.persisted? && @record.save
      redirect_to root_path, notice: "記録しました"
    else
      @record.errors.add(:base, "シリーズ名を入力してください") if series_name.blank?
      @series_list = current_user.series.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def record_params
    params.expect(record: [ :played_date, :price_per_play, :play_count ])
  end
end
