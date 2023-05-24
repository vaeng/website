class Mentor::UpdateStats
  include Mandate

  queue_as :default

  initialize_with :mentor, update_num_solutions_mentored: false, update_satisfaction_rating: false

  def call
    Mentor::UpdateNumSolutionsMentored.(mentor) if update_num_solutions_mentored
    Mentor::UpdateSatisfactionPercentage.(mentor) if update_satisfaction_rating
    User::UpdateMentorRoles.defer(mentor)
  end
end
