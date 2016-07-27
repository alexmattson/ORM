require_relative 'questions_db.rb'

class QuestionLike < QuestionSuper
  attr_accessor :question_id, :user_id

  def self.table
    'question_likes'
  end

  def table
    'question_likes'
  end

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_likes
        JOIN
        users ON user_id = users.id
      WHERE
        question_id = ?
    SQL
    raise "Nobody likes that question" if data.empty?
    data.map{|datum| User.new(datum)}
  end

  def self.total_likes_per_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        COUNT(*) as num_likes
      FROM
        question_likes
      WHERE
        user_id = ?
    SQL
    raise "User's questions suck" if data.empty?
    data[0]["num_likes"]
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*) as num_likes
      FROM
        question_likes
      WHERE
        question_id = ?
    SQL
    raise "Nobody likes that question" if data.empty?
    data[0]["num_likes"]
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_likes
        JOIN
        questions ON question_id = questions.id
      WHERE
        user_id = ?
    SQL
    raise "User does not like any of the questions" if data.empty?
    data.map{|datum| Question.new(datum)}
  end

  def self.most_liked_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        question_id, COUNT(user_id) as likes
      FROM
        question_likes
      GROUP BY
        question_id
      ORDER BY
        likes DESC
      LIMIT
        ?
    SQL
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id, @id)
      UPDATE
        question_likes
      SET
        user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
end
