require "sqlite3"

# Open a database
db = SQLite3::Database.new "test.db"

# Create a database
rows = db.execute "create table numbers (\nname varchar(30),\nval int\n);\n"

# Execute a few inserts
{
  "one" => 1,
  "two" => 2,
}.each do |pair|
  db.execute "insert into numbers values ( ?, ? )", pair
end

