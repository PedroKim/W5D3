PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    body TEXT NOT NULL,
    question_id  INTEGER NOT NULL,
    user_id  INTEGER NOT NULL,
    reply_id  INTEGER,
    
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(question_id) REFERENCES questions(id),
    FOREIGN KEY(reply_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(question_id) REFERENCES questions(id)
);

INSERT INTO
    users (fname, lname)
VALUES
    ('Peter', 'Kim'),
    ('Korrey', 'Shin');

INSERT INTO
    questions (title, body, user_id)
VALUES
    ('What is your favorite color?', 'Please tell me your favorite color.', (SELECT id FROM users WHERE fname = 'Peter')),
    ('What is 1 + 1?', 'I''ve been working on this and I need help. What is the answer to 1 + 1?', (SELECT id FROM users WHERE fname = 'Korrey' AND lname = 'Shin')),
    ('What is bigger, 5 or 9?', 'I''ve been working on this and I need help. What is the answer to this question?', (SELECT id FROM users WHERE fname = 'Korrey' AND lname = 'Shin'));

INSERT INTO
    replies (body, question_id, user_id, reply_id)
VALUES
    ('I think it''s 2.', (SELECT id FROM questions WHERE title = 'What is 1 + 1?'), (SELECT id FROM users WHERE fname = 'Peter'), NULL),
    ('Mine is blue', (SELECT id FROM questions WHERE title = 'What is your favorite color?'), (SELECT id FROM users WHERE fname = 'Korrey'), NULL);
    
INSERT INTO
    replies (body, question_id, user_id, reply_id)
VALUES    
    ('Interesting. Mine is green.', (SELECT id FROM questions WHERE title = 'What is your favorite color?'), (SELECT id FROM users WHERE fname = 'Peter'), (SELECT id FROM replies WHERE body = 'Mine is blue'));

INSERT INTO
    question_likes (user_id, question_id)
VALUES
    ((SELECT id FROM users WHERE fname = 'Peter'), (SELECT id FROM questions WHERE title = 'What is 1 + 1?')),
    ((SELECT id FROM users WHERE fname = 'Korrey'), (SELECT id FROM questions WHERE title = 'What is 1 + 1?'));

INSERT INTO
    question_follows (user_id, question_id)
VALUES
    ((SELECT id FROM users WHERE fname = 'Peter'), (SELECT id FROM questions WHERE title = 'What is 1 + 1?')),
    ((SELECT id FROM users WHERE fname = 'Korrey'), (SELECT id FROM questions WHERE title = 'What is 1 + 1?')),
    ((SELECT id FROM users WHERE fname = 'Korrey'), (SELECT id FROM questions WHERE title = 'What is your favorite color?'));