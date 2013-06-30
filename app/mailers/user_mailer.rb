# encoding: utf-8
class UserMailer < ActionMailer::Base
  include SendGrid
  default from: 'مرابطين <no-reply@moravids.com>'
  sendgrid_category    :use_subject_lines

  def schedule_started(users, schedule)
    @users = users
    @schedule = schedule
    sendgrid_recipients users.map(&:email).flatten
    mail to: "users@moravids", subject: "جدول متابعة جديد"
  end
end
