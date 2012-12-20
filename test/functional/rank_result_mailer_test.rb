require 'test_helper'

class RankResultMailerTest < ActionMailer::TestCase
  test "rank_result" do
    mail = RankResultMailer.rank_result
    assert_equal "Rank result", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
