class RecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_record, only: %i[edit update]
  def index
    @records = current_user.records.includes(:series).order(played_date: :desc, id: :desc)
    @all_records_price = @records.sum("price_per_play * play_count")
  end

  def new
    @record = Record.new(played_date: Date.current)
    @series_list = current_user.series.order(:name)
  end

  def create
    series = find_or_create_series
    @record = Record.new(record_params)
    @record.series = series
    if series&.persisted? && @record.save
      redirect_to records_path, notice: "記録しました"
    else
      @record.errors.add(:base, "シリーズ名を入力してください") if series_name.blank?
      @series_list = current_user.series.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @series_list = current_user.series.order(:name)
  end

  def update
    series = find_or_create_series
    @record.assign_attributes(record_params)
    @record.series = series
    if series&.persisted? && @record.save
      redirect_to records_path, notice: "記録しました"
    else
      @record.errors.add(:base, "シリーズ名を入力してください") if series_name.blank?
      @series_list = current_user.series.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  private
  def set_record
    @record = current_user.record.find(params[:id])
  end

  def series_name
    params.dig(:record, :series_name)
  end

  def find_or_create_series
    current_user.series.find_or_create_by(name: series_name) if series_name.present?
  end

  def record_params
    params.expect(record: [ :played_date, :price_per_play, :play_count ])
  end
end
