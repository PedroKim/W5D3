require_relative 'questions_db_connection'
require_relative 'users'
require_relative 'replies'

class Question
    attr_accessor :id, :title, :body, :user_id
    
    def self.all
        data = QuestionsDBConnection.instance.execute("SELECT * FROM questions")
        data.map { |datum| Question.new(datum) }
    end
    
    def self.find_by_id(id)
        question = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                questions
            WHERE
                id = ?
        SQL

        raise "ID #{id} not in database" if question.length == 0
        
        Question.new(question.first)
    end

    def self.find_by_author_id(user_id)
        questions = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
                questions
            WHERE
                user_id = ?
        SQL

        raise "ID #{user_id} not in database" if questions.length == 0
    
        questions.map { |question| Question.new(question) }
    end

    def self.most_followed(n)
        questions = QuestionFollow.most_followed_questions(n)
    end

    def self.most_liked(n)
        questions = QuestionLike.most_liked_questions(n)
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end

    def author
        author = User.find_by_id(self.user_id)
    end

    def replies
        replies = Reply.find_by_question_id(self.id)
    end

    def followers
        followers = QuestionFollow.followers_for_question_id(self.id)
    end

    def likers
        likers = QuestionLike.likers_for_question_id(self.id)
    end

    def num_likes
        num_likes = QuestionLike.num_likes_for_question_id(self.id)
    end
end

class QuestionFollow

    def self.followers_for_question_id(question_id)
        followers = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
            SELECT
                users.*
            FROM
                question_follows
            JOIN
                users ON users.id = question_follows.user_id
            WHERE
                question_follows.question_id = ?
        SQL

        followers.map {|follower| User.new(follower)}
    end

    def self.followed_questions_for_user_id(user_id)
        questions = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
            SELECT
                questions.*
            FROM
                question_follows
            JOIN
                questions ON questions.id = question_follows.question_id
            WHERE
                question_follows.user_id = ?
        SQL
        
        questions.map {|question| Question.new(question)}
    end

    def self.most_followed_questions(n)
        # Fetches the n most followed questions.   --- n = 1, what is 1 + 1
        # Fetch the question with n followers
        questions = QuestionsDBConnection.instance.execute(<<-SQL, n)
            SELECT
                questions.* -- => id, title, body, user ID
            FROM
                question_follows 
            JOIN
                questions ON questions.id = question_follows.question_id
            GROUP BY
                questions.id -- 
            ORDER BY
                COUNT(questions.id) DESC
            LIMIT
                ?
        SQL
        
        questions.map {|question| Question.new(question)}
    end
end

class QuestionLike
    def self.likers_for_question_id(question_id)
        users = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
            SELECT
                users.*
            FROM
                question_likes
            JOIN
                users ON users.id = question_likes.user_id
            WHERE
                question_likes.question_id = ?
        SQL

        users.map {|user| User.new(user)}
    end

    def self.num_likes_for_question_id(question_id)
        likes = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
            SELECT
                COUNT(question_likes.question_id) AS like_count
            FROM
                question_likes
            WHERE
                question_likes.question_id = ?
        SQL

        likes.first['like_count']
    end

    def self.liked_questions_for_user_id(user_id)
        questions = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
            SELECT
                questions.*
            FROM
                question_likes
            JOIN 
                questions ON questions.id = question_likes.question_id
            WHERE
                question_likes.user_id = ?
        SQL
        questions.map {|question| Question.new(question)}
    end

    def self.most_liked_questions(n)
        questions = QuestionsDBConnection.instance.execute(<<-SQL, n)
            SELECT
                questions.*
            FROM
                question_likes
            JOIN
                questions ON questions.id = question_likes.question_id
            GROUP BY
                question_likes.question_id
            ORDER BY
                COUNT(question_likes.question_id) DESC
            LIMIT
                ?
        SQL

        questions.map {|question| Question.new(question)}
    end
end