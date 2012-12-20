class RankResultMailer < ActionMailer::Base
  default from: "from@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.rank_result_mailer.rank_result.subject
  #
  def rank_result
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
