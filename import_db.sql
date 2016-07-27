DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT,
  body TEXT,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  reply TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(parent_id) REFERENCES replies(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY(question_id) REFERENCES questions(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ("Alex", "Mattson"),
  ("Zhe", "Wang");

INSERT INTO
  questions (title, body, author_id)
VALUES
  ("WHAT THE??", "I don't get it", (SELECT id FROM users WHERE lname = 'Mattson')),
  ("HOW IS YOUR NIGHT?", "HOW WAS IT", (SELECT id FROM users WHERE lname = 'Wang'));

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE lname = 'Mattson'), (SELECT id FROM questions WHERE title = 'HOW IS YOUR NIGHT?')),
  ((SELECT id FROM users WHERE lname = 'Wang'), (SELECT id FROM questions WHERE title = 'WHAT THE??'));

INSERT INTO
  replies (reply, question_id, user_id, parent_id)
VALUES
  ('Good question',
   (SELECT id FROM questions WHERE title = 'HOW IS YOUR NIGHT?'),
   (SELECT id FROM users WHERE lname = 'Mattson'),
   null
  ),
  ('I got nothing',
   (SELECT id FROM questions WHERE title = 'WHAT THE??'),
   (SELECT id FROM users WHERE lname = 'Wang'),
   null
 );

 INSERT INTO
   replies (reply, question_id, user_id, parent_id)
 VALUES
   ('Good reply',
    (SELECT id FROM questions WHERE title = 'HOW IS YOUR NIGHT?'),
    (SELECT id FROM users WHERE lname = 'Wang'),
    (SELECT id FROM replies WHERE reply = 'Good question')
  );


INSERT INTO
  question_likes (question_id, user_id)
VALUES
((SELECT id FROM questions WHERE title = 'HOW IS YOUR NIGHT?'), (SELECT id FROM users WHERE lname = 'Mattson')),
((SELECT id FROM questions WHERE title = 'WHAT THE??'), (SELECT id FROM users WHERE lname = 'Wang'));
