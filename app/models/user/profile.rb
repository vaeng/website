class User::Profile < ApplicationRecord
  MIN_REPUTATION = 5

  extend Mandate::Memoize

  belongs_to :user

  delegate :to_param, to: :user

  memoize
  def solutions_tab? = num_solutions_published > 3

  memoize
  def testimonials_tab? = num_testimonials.positive?

  memoize
  def contributions_tab?
    user.reputation_tokens.where(category: %i[building authoring maintaining misc]).exists?
  end

  memoize
  def badges_tab? = user.revealed_badges.exists?

  memoize
  def num_solutions_published = user.solutions.published.count

  memoize
  def num_testimonials = user.mentor_testimonials.published.count
end
