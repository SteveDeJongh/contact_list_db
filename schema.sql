CREATE TABLE contacts (
  id serial PRIMARY KEY,
  name text NOT NULL,
  phone integer NOT NULL,
  email text NOT NULL,
  category text NOT NULL
);

--! Sample Data

INSERT INTO contacts (name, phone, email, category)
VALUES ('steve', 1234567890, 'blank@yahoo.com', 'friend'),
       ('John', 1234567890, 'wee@gmail.com', 'work'),
       ('Alfred', 1234567890, 'alft@cbc.ca', 'friend');