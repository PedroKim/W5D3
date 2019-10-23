













SELECT

FROM
    users
JOIN
    questions ON questions.user_id = users.id 
JOIN
    quesiton_likes ON question_likes.question_id = questions.id