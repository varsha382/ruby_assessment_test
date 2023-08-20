class User < ApplicationRecord

  # Define Enum for Kind
	enum :kind, { student: 0, teacher: 1, student_teacher: 2}

  # Define some associations
	has_many :user_enrollments, class_name: :Enrollment
	has_many :teachers, through: :user_enrollments do
    def favorites
      where("enrollments.favorite=true")
    end
  end
	has_many :programs, through: :user_enrollments
	has_many :teacher_enrollments, class_name: :Enrollment, foreign_key: :teacher_id

  # Define some scope
	scope :exclude, -> (id) { where.not(id: id) }
	scope :filter_by_programs, -> (program_ids) {
		joins(:user_enrollments).
		where(user_enrollments:
			{ program_id: program_ids }
		)
	}

  # Define Validation
	validate :validate_kind, :kind_changed?

	def self.classmates(user)
		User.
			filter_by_programs(user.programs.ids).
			exclude(user.id).
			distinct
	end

  private
	def validate_kind
		if kind_change == ["teacher", "student"] && teacher_enrollments.any?
			errors.add(:kind, 'can not be student because is teaching in at least one program')
    elsif kind_change == ["student", "teacher"] && user_enrollments.any?
      errors.add(:kind, 'can not be teacher because is studying in at least one program')
		end
	end
end
