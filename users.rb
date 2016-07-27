require_relative 'questions_db.rb'

class User < QuestionSuper
  attr_accessor :fname, :lname

  def self.table
    'users'
  end

  def table
    'users'
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def authored_questions
    Question.find_by_author(@id)
  end

  def authored_replies
    Reply.find_by_user(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    total_likes = QuestionLike.total_likes_per_user_id(@id)
    num_comments = Question.num_comments_per_user_id(@id)
    total_likes / num_comments
  end
end
