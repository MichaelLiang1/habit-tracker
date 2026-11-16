class CompletionsController < ApplicationController
  before_action :set_habit

  def create
    @habit.completions.find_or_create_by(completed_on: Current.user.today)
    redirect_to habits_path, status: :see_other
  end

  def destroy
    @habit.completions.find(params[:id]).destroy
    redirect_to habits_path, status: :see_other
  end

  private

  def set_habit
    @habit = Current.user.habits.find(params[:habit_id])
  end
end
