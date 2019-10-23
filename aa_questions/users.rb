require_relative 'questions_db_connection'
require_relative 'questions'
require_relative 'replies'

class User
    attr_accessor :id, :fname, :lname

    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
        data.map { |datum| User.new(datum) }
    end

    def self.find_by_name(fname, lname)
        user = QuestionsDBConnection.instance.execute(<<-SQL, fname, lname)
            SELECT 
                *
            FROM
                users
            WHERE
                fname = ? AND lname = ?
        SQL

        raise "User #{fname} #{lname} not in database" if user.length == 0

        User.new(user.first)
    end
    
    def self.find_by_id(id)
        user = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT 
                *
            FROM
                users
            WHERE
                id = ?  
        SQL

        raise "ID #{id} not in database" if user.length == 0

        User.new(user.first)
    end
    
    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def authored_questions
        questions = Question.find_by_author_id(self.id)
    end

    def authored_replies
        replies = Reply.find_by_user_id(self.id)
    end

    def liked_questions
        questions = QuestionLike.liked_questions_for_user_id(self.id)
    end
end