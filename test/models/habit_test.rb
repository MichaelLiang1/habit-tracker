require "test_helper"

class HabitTest < ActiveSupport::TestCase
  setup do
    @habit = users(:one).habits.create!(name: "Test habit")
    @today = Date.new(2026, 11, 16)
  end

  def complete(*days)
    days.each { |d| @habit.completions.create!(completed_on: d) }
  end

  test "current streak is zero with no completions" do
    assert_equal 0, @habit.current_streak(@today)
  end

  test "current streak counts consecutive days ending today" do
    complete(@today, @today - 1, @today - 2)
    assert_equal 3, @habit.current_streak(@today)
  end

  test "streak stays alive if only yesterday is done" do
    complete(@today - 1, @today - 2)
    assert_equal 2, @habit.current_streak(@today)
  end

  test "a gap breaks the current streak" do
    complete(@today, @today - 2)
    assert_equal 1, @habit.current_streak(@today)
  end

  test "current streak is zero if last completion was two days ago" do
    complete(@today - 2)
    assert_equal 0, @habit.current_streak(@today)
  end

  test "longest streak finds the best run" do
    complete(@today - 10, @today - 9, @today - 8, @today - 1, @today)
    assert_equal 3, @habit.longest_streak
  end
end
