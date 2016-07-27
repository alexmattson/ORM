require_relative 'questions_db.rb'

class QuestionFollow < QuestionSuper
  attr_accessor :user_id, :question_id

  def self.table
    'question_follows'
  end

  def table
    'question_follows'
  end

  def self.followers_for_question(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        users.*
      FROM
        question_follows
        JOIN
          users ON user_id = users.id
      WHERE
        question_id = ?
    SQL
    raise "That question has no following" if data.empty?
    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows
        JOIN
        questions ON questions.id = question_id
      WHERE
        user_id = ?
    SQL
    raise "That user has not followed any questions" if data.empty?
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        question_id, COUNT(user_id) as followers
      FROM
        question_follows
      GROUP BY
        question_id
      ORDER BY
        followers DESC
      LIMIT
        ?
    SQL
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id, @id)
      UPDATE
        question_follows
      SET
        user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
end
