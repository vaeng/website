class User::ResetCache
  include Mandate

  initialize_with :user, :key

  def call
    # Some of these queries are really slow
    # so we don't want to wrap them in a pesimistic lock.
    # As user-data has an optimistic lock, it's not necessary either

    # Don't call user.update! here
    user.data.update!(cache:)
    cache
  rescue ActiveRecord::StaleObjectError
    user.reload
    retry
  end

  private
  memoize
  def cache
    user.cache.tap do |c|
      c[key.to_s] = send("value_for_#{key}")
    end
  end

  def value_for_has_unrevealed_testimonials? = user.mentor_testimonials.unrevealed.exists?
  def value_for_has_unrevealed_badges? = user.acquired_badges.unrevealed.exists?
  def value_for_has_unseen_reputation_tokens? = user.reputation_tokens.unseen.exists?
  def value_for_num_solutions_mentored = user.mentor_discussions.finished_for_mentor.count
  def value_for_num_testimonials = user.mentor_testimonials.published.count
  def value_for_mentor_satisfaction_percentage = Mentor::CalculateSatisfactionPercentage.(user)

  # This one is sloooooow!
  def value_for_num_students_mentored
    user.mentor_discussions.joins(:solution).distinct.count(:user_id)
  end
end
