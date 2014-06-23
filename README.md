
# denormalize_mm

Easily Denormalize fields and associations without writing lots of custom before_validations_

## Examples:

Initializer - config/initializers/mongo_mapper.rb:

      require 'mongo_mapper/denormalization'

Denormalizing a field:

    class Employer
      include MongoMapper::Document

      key :name
    end

    class Employee
      include MongoMapper::Document
      include MongoMapper::Denormalization

      key :employer_name, String

      denormalize_field :employer, :name
      # or:
      # denormalize_field :employer, :name, :target_field => :employer_name
    end

Denormalizing an association:

    class Survey
      include MongoMapper::Document

      has_many :survey_questions
      has_many :survey_responses
    end

    class SurveyQuestion
      include MongoMapper::Document

      belongs_to :survey
    end

    class SurveyResponseOption
      include MongoMapper::Document
      include MongoMapper::Denormalization

      belongs_to :survey
      belongs_to :survey_question

      denormalize_association :survey, :from => :survey_question
    end

