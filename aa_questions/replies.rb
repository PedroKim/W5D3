require_relative 'questions_db_connection'
require_relative 'users'
require_relative 'questions'

class Reply
    attr_accessor :id, :body, :question_id, :user_id, :reply_id
    
    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM replies")
        data.map { |datum| Reply.new(datum) }
    end
    
    def self.find_by_id(id)
        reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                replies
            WHERE
                id = ?
        SQL

        raise "ID #{id} not in database" if reply.length == 0
        
        Reply.new(reply.first)
    end

    def self.find_by_user_id(user_id)
        replies = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
                replies
            WHERE
                user_id = ?
        SQL

        raise "ID #{user_id} not in database" if replies.length == 0
    
        replies.map { |reply| Reply.new(reply) }
    end

    def self.find_by_question_id(question_id)
        replies = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                replies
            WHERE
                question_id = ?
        SQL

        raise "ID #{question_id} not in database" if replies.length == 0
    
        replies.map { |reply| Reply.new(reply) }
    end
    
    def initialize(options)
        @id = options['id']
        @body = options['body']
        @question_id = options['question_id']
        @user_id = options['user_id']
        @reply_id = options['reply_id']
    end

    def author
        author = User.find_by_id(self.user_id)
    end

    def question
        question = Question.find_by_id(self.question_id)
    end

    def parent_reply
        reply = Reply.find_by_id(self.reply_id)
    end

    def child_replies
        replies = QuestionsDBConnection.instance.execute(<<-SQL, self.id)
            SELECT
                *
            FROM
                replies
            WHERE
                reply_id = ?
        SQL
        replies.map {|reply| Reply.new(reply)}
    end
end
