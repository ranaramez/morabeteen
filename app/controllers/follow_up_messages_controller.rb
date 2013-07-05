class FollowUpMessagesController < ApplicationController
  load_and_authorize_resource :level
  load_and_authorize_resource :follow_up_activity_message, through: :level

  def index
    @messages = @level.follow_up_activity_messages
    @message = params[:message] ? FollowUpActivityMessage.find(params[:message]) : FollowUpActivityMessage.new
  end

  def create
    @message = @level.follow_up_activity_messages.new params[:follow_up_activity_message]
    if @message.save
      redirect_to level_follow_up_messages_path(@level), notice: t('follow_up.created_successfuly')
    else
      redirect_to level_follow_up_messages_path([@level], message: @message), flash: {error: t('follow_up.fail_to_create')}
    end
  end

  def update
    @message = @level.follow_up_activity_messages.find params[:id]
    if @message.update_attributes(params[:follow_up_activity_message])
      redirect_to level_follow_up_messages_path(@level), notice: t('follow_up.updated_successfuly')
    else
      redirect_to level_follow_up_messages_path([@level], message: @message), flash: {error: t('follow_up.fail_to_update')}
    end
  end

  def destroy
    @message = @level.follow_up_activity_messages.find params[:id]
    if @message.destroy
      redirect_to level_follow_up_messages_path(@level), notice: t('follow_up.deleted_successfuly')
    else
      redirect_to level_follow_up_messages_path([@level], message: @message), flash: {error: t('follow_up.fail_to_delete')}
    end
  end

end