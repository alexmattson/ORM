require_relative 'questions_db.rb'

class Reply < QuestionSuper
  attr_accessor :reply, :question_id, :parent_id, :user_id

  def self.table
    'replies'
  end

  def table
    'replies'
  end

  def initialize(options)
    @id = options['id']
    @reply = options['reply']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @reply, @question_id, @parent_id, @user_id, @id)
      UPDATE
        replies
      SET
        reply = ?, question_id = ?, parent_id = ?, user_id = ?
      WHERE
        id = ?
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    raise 'This reply has no parent' unless @parent_id
    Reply.find_by_id(@parent_id)
  end

  def child_replies
    Reply.find_by_parent(@id)
  end
end
