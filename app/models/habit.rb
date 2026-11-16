class Habit < ApplicationRecord
  belongs_to :user
  has_many :completions, dependent: :destroy
  def current_streak(today = user.today)
    dates = completions.pluck(:completed_on).to_set
    day = dates.include?(today) ? today : today - 1
    streak = 0
    while dates.include?(day)
      streak += 1
      day -= 1
    end
    streak
  end

  def longest_streak
    longest = 0
    run = 0
    previous = nil
    completions.order(:completed_on).pluck(:completed_on).each do |date|
      run = previous && date == previous + 1 ? run + 1 : 1
      longest = [ longest, run ].max
      previous = date
    end
    longest
  end
end
