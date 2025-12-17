# MySQL Cheat Sheet

> Help with SQL commands to interact with a MySQL database

## MySQL Locations

* Mac             */usr/local/mysql/bin*
* Windows         */Program Files/MySQL/MySQL *version*/bin*
* Xampp           */xampp/mysql/bin*

## Drop view

```sql
DROP VIEW [IF EXISTS] view_name;
```

## Convert table to utf8

```sql
ALTER TABLE products CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
```

## Check Database Character Set and Collation

```sql
 SHOW CREATE DATABASE your_database_name;

 # Or if you're already connected to your database:

 SELECT @@character_set_database, @@collation_database;
```

## Check All Databases

```sql
 SELECT
     SCHEMA_NAME as 'Database',
     DEFAULT_CHARACTER_SET_NAME as 'Charset',
     DEFAULT_COLLATION_NAME as 'Collation'
 FROM information_schema.SCHEMATA;
```

## Check Server Default Settings

```sql
 SHOW VARIABLES LIKE 'character_set%';
 SHOW VARIABLES LIKE 'collation%';
```

## Check Specific Tables in Your SugarCRM Database

```sql
 SELECT
     TABLE_SCHEMA as 'Database',
     TABLE_NAME as 'Table',
     TABLE_COLLATION as 'Collation'
 FROM information_schema.TABLES
 WHERE TABLE_SCHEMA = 'your_sugarcrm_database_name'
 ORDER BY TABLE_NAME;
```

## Mysqldump for update db

```sql
mysqldump --login-path=$login_path --add-drop-table $database > $file.sql
```

## Mysqldump for specific table

```sql
mysqldump --lock-all-tables --where="custom_module like '%Tontouta%'" devccincarps fields_meta_data > fields_meta_data.sql
```

## Mysqldump specific table, and replace existing entries

```sql
mysqldump --login-path=$login_path --no-create-info --skip-comments --replace $data_base $table


## Find and kill mysql process

```sql
# revover full list of queries
show full processlist;

kill <process_id>;
```

## Analyse query performance

```sql
# recover timing with miliseconds
EXPLAIN ANALYZE select * from ...

# get index informations
EXPLAIN select * from ...

# exhaustive informations
FLUSH STATUS;select * from ...;SHOW SESSION STATUS LIKE "Handler%";
```

## Export table en csv

To export table to csv file first we need to find directory output :

```sql
SHOW VARIABLES LIKE "secure_file_priv";
```

```bash
+------------------+---------------------------------+
| Variable_name    | Value                           |
+------------------+---------------------------------+
| secure_file_priv | /var/lib/mysql-files/           |
+------------------+---------------------------------+
1 row in set (0.02 sec)
```

Then we have this query :

```sql
SELECT * FROM orders
INTO OUTFILE '/var/lib/mysql-files/orders.csv' 
FIELDS ENCLOSED BY '"' 
TERMINATED BY ',' 
ESCAPED BY '"' 
LINES TERMINATED BY '\r\n';
```

## Subqueries with EXISTS or NOT EXISTS

```sql
SELECT DISTINCT store_type 
FROM stores
WHERE EXISTS (
  SELECT * 
  FROM cities_stores
  WHERE cities_stores.store_type = stores.store_type
);

SELECT DISTINCT store_type 
FROM stores
WHERE NOT EXISTS (
  SELECT * FROM cities_stores
  WHERE cities_stores.store_type = stores.store_type
);
```

## Find duplicate values in one column

```sql
SELECT 
    col, 
    COUNT(col)
FROM
    table_name
GROUP BY col
HAVING COUNT(col) > 1;
```

## Drop table from column

```sql
use icare; 
ALTER TABLE prospections
DROP COLUMN prospection_type;
```

## Truncacte table

```sql
TRUNCATE TABLE `table`;
```

## Get size of db

```sql
SELECT 
    table_schema 'Database Name',
    SUM(data_length + index_length) 'Size in Bytes',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) 'Size in MiB'
FROM information_schema.tables 
WHERE table_schema = 'sakila';
```

## Get size of each table

```sql
SELECT 
    table_name 'Table Name',
    data_length + index_length 'Size in Bytes',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) 'Size in MiB'
FROM information_schema.tables
WHERE table_schema = '$db'
ORDER BY (data_length + index_length) DESC;
```

## Add mysql to your PATH

```bash
# Current Session
export PATH=${PATH}:/usr/local/mysql/bin
# Permanantly
echo 'export PATH="/usr/local/mysql/bin:$PATH"' >> ~/.bash_profile
```

On Windows - <https://www.qualitestgroup.com/resources/knowledge-center/how-to-guide/add-mysql-path-windows/>

## Login

```bash
mysql -u root -p
```

## Transform query to json to use with jq

```bash
mysql --login-path=devilbox -NLs -e "use portail;select json_arrayagg(json_object('id', id, 'email', email, 'roles', roles, 'crm_id', crm_id)) from user limit 2;" | jq
```

## Show Users

```sql
SELECT User, Host FROM mysql.user;
```

## Create User

```sql
CREATE USER 'someuser'@'localhost' IDENTIFIED BY 'somepassword';
```

## Grant All Priveleges On All Databases

```sql
GRANT ALL PRIVILEGES ON * . * TO 'someuser'@'localhost';
FLUSH PRIVILEGES;
```

## Show Grants

```sql
SHOW GRANTS FOR 'someuser'@'localhost';
```

## Remove Grants

```sql
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'someuser'@'localhost';
```

## Change Password

```sql
ALTER USER 'someuser' IDENTIFIED BY new_password;
```

## Delete User

```sql
DROP USER 'someuser'@'localhost';
```

## Exit

```sql
exit;
```

## Show Databases

```sql
SHOW DATABASES
```

## Create Database

```sql
CREATE DATABASE acme;
```

## Delete Database

```sql
DROP DATABASE acme;
```

## Select Database

```sql
USE acme;
```

## Create Table

```sql
CREATE TABLE users(
id INT AUTO_INCREMENT,
   first_name VARCHAR(100),
   last_name VARCHAR(100),
   email VARCHAR(50),
   password VARCHAR(20),
   location VARCHAR(100),
   dept VARCHAR(100),
   is_admin TINYINT(1),
   register_date DATETIME,
   PRIMARY KEY(id)
);
```

## Delete / Drop Table

```sql
DROP TABLE tablename;
```

## Show Tables

```sql
SHOW TABLES;
```

## Describe Tables

```sql
/* Show filds info from a table */
DESCRIBE users;
```

## Insert Row / Record

```sql
INSERT INTO users (first_name, last_name, email, password, location, dept, is_admin, register_date) values ('Brad', 'Traversy', 'brad@gmail.com', '123456','Massachusetts', 'development', 1, now());
```

## Insert Multiple Rows

```sql
INSERT INTO users (first_name, last_name, email, password, location, dept,  is_admin, register_date) values ('Fred', 'Smith', 'fred@gmail.com', '123456', 'New York', 'design', 0, now()), ('Sara', 'Watson', 'sara@gmail.com', '123456', 'New York', 'design', 0, now()),('Will', 'Jackson', 'will@yahoo.com', '123456', 'Rhode Island', 'development', 1, now()),('Paula', 'Johnson', 'paula@yahoo.com', '123456', 'Massachusetts', 'sales', 0, now()),('Tom', 'Spears', 'tom@yahoo.com', '123456', 'Massachusetts', 'sales', 0, now());
```

## Select

```sql
SELECT * FROM users;
SELECT first_name, last_name FROM users;
```

## Pretty Select

```sql
SELECT * FROM users/G;
SELECT first_name, last_name FROM users/G;
```

## Where Clause

```sql
SELECT * FROM users WHERE location='Massachusetts';
SELECT * FROM users WHERE location='Massachusetts' AND dept='sales';
SELECT * FROM users WHERE is_admin = 1;
SELECT * FROM users WHERE is_admin > 0;
```

## Delete Row

```sql
DELETE FROM users WHERE id = 6;
```

## Update Row

```sql
UPDATE users SET email = 'freddy@gmail.com' WHERE id = 2;

```

## Add New Column

```sql
ALTER TABLE users ADD age VARCHAR(3);
```

## Modify Column

```sql
ALTER TABLE users MODIFY COLUMN age INT(3);
```

## Order By (Sort)

```sql
SELECT * FROM users ORDER BY last_name ASC;
SELECT * FROM users ORDER BY last_name DESC;
```

## Concatenate Columns

```sql
SELECT CONCAT(first_name, ' ', last_name) AS 'Name', dept FROM users;

```

## Select Distinct Rows

```sql
SELECT DISTINCT location FROM users;

```

## Between (Select Range)

```sql
SELECT * FROM users WHERE age BETWEEN 20 AND 25;
```

## Like (Searching)

```sql
SELECT * FROM users WHERE dept LIKE 'd%';
SELECT * FROM users WHERE dept LIKE 'dev%';
SELECT * FROM users WHERE dept LIKE '%t';
SELECT * FROM users WHERE dept LIKE '%e%';
```

## Not Like

```sql
SELECT * FROM users WHERE dept NOT LIKE 'd%';
```

## IN

```sql
SELECT * FROM users WHERE dept IN ('design', 'sales');
```

## Create & Remove Index

```sql
CREATE INDEX LIndex On users(location);
DROP INDEX LIndex ON users;
```

## New Table With Foreign Key (Posts)

```sql
CREATE TABLE posts(
id INT AUTO_INCREMENT,
   user_id INT,
   title VARCHAR(100),
   body TEXT,
   publish_date DATETIME DEFAULT CURRENT_TIMESTAMP,
   PRIMARY KEY(id),
   FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## Add Data to Posts Table

```sql
INSERT INTO posts(user_id, title, body) VALUES (1, 'Post One', 'This is post one'),(3, 'Post Two', 'This is post two'),(1, 'Post Three', 'This is post three'),(2, 'Post Four', 'This is post four'),(5, 'Post Five', 'This is post five'),(4, 'Post Six', 'This is post six'),(2, 'Post Seven', 'This is post seven'),(1, 'Post Eight', 'This is post eight'),(3, 'Post Nine', 'This is post none'),(4, 'Post Ten', 'This is post ten');
```

## INNER JOIN

```sql
SELECT
  users.first_name,
  users.last_name,
  posts.title,
  posts.publish_date
FROM users
INNER JOIN posts
ON users.id = posts.user_id
ORDER BY posts.title;
```

## New Table With 2 Foriegn Keys

```sql
CREATE TABLE comments(
 id INT AUTO_INCREMENT,
    post_id INT,
    user_id INT,
    body TEXT,
    publish_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(id),
    FOREIGN KEY(user_id) references users(id),
    FOREIGN KEY(post_id) references posts(id)
);
```

## Add Data to Comments Table

```sql
INSERT INTO comments(post_id, user_id, body) VALUES (1, 3, 'This is comment one'),(2, 1, 'This is comment two'),(5, 3, 'This is comment three'),(2, 4, 'This is comment four'),(1, 2, 'This is comment five'),(3, 1, 'This is comment six'),(3, 2, 'This is comment six'),(5, 4, 'This is comment seven'),(2, 3, 'This is comment seven');
```

## Left Join

```sql
SELECT
comments.body,
posts.title
FROM comments
LEFT JOIN posts ON posts.id = comments.post_id
ORDER BY posts.title;

```

## Join Multiple Tables

```sql
SELECT
comments.body,
posts.title,
users.first_name,
users.last_name
FROM comments
INNER JOIN posts on posts.id = comments.post_id
INNER JOIN users on users.id = comments.user_id
ORDER BY posts.title;

```

## Aggregate Functions

```sql
SELECT COUNT(id) FROM users;
SELECT MAX(age) FROM users;
SELECT MIN(age) FROM users;
SELECT SUM(age) FROM users;
SELECT UCASE(first_name), LCASE(last_name) FROM users;

```

## Group By

```sql
SELECT age, COUNT(age) FROM users GROUP BY age;
SELECT age, COUNT(age) FROM users WHERE age > 20 GROUP BY age;
SELECT age, COUNT(age) FROM users GROUP BY age HAVING count(age) >=2;

```
