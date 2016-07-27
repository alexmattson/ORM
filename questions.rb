require_relative 'questions_db.rb'

class Question < QuestionSuper
  attr_accessor :title, :body, :author_id

  def self.table
    'questions'
  end

  def table
    'questions'
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def self.num_comments_per_user_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        COUNT(*) as num_likes
      FROM
        questions
      WHERE
        author_id = ?
    SQL
    raise "User has no comments" if data.empty?
    data[0]["num_likes"]
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, author_id = ?
      WHERE
        id = ?
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def author
    User.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question(@id)
  end

  def followers
    QuestionFollow.followers_for_question(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end
end
