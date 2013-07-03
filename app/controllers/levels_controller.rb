class LevelsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def update
    if @level.update_attributes params[:level]
      msg = @level.default ? t('level.assigned_default', level: @level.name) : t('level.un_assigned_default', level: @level.name) 
      redirect_to schedules_path, notice: msg
    else
      redirect_to schedules_path, error: t('level.cant_assigned_default') 
    end
  end
end