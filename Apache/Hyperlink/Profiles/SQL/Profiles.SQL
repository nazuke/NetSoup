# This SQL script builds the Profiles database.

# pcookie is the key into the user's profile

# dcookie is a key into the Downloads Registration database

DROP   DATABASE profiles;
CREATE DATABASE profiles;
CREATE TABLE    profiles.cookies ( id      INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
                                   pcookie CHAR(32),
                                   dcookie CHAR(32),
                                   urls    TEXT );
