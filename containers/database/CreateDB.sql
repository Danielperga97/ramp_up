CREATE TABLE movies (
    title character varying(255) NOT NULL,
    release character varying (24) NOT NULL,
    score integer,
    reviewer character varying(70) NOT NULL,
    publication character varying(70) NOT NULL
);

INSERT INTO movies (title,release,score,reviewer,publication) VALUES ('Suicide Squad','2016',8,'Robert Smith','The Daily Reviewer');