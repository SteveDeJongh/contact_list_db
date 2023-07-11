require "pg"
require "pry"

class Databasepersistence
  def initialize()
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "contact_list")
          end
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def exists?(name)
    sql = <<~SQL
    SELECT name FROM contacts;
    SQL

    result = query(sql)
    result.any? { |tuple| tuple["name"] == name }
  end

  def add_contact(new_contact)
    sql = <<~SQL
    INSERT INTO contacts (name, phone, email, category)
    VALUES ($1, $2, $3, $4)
    SQL
    query(sql, new_contact[:name], new_contact[:phone], new_contact[:email], new_contact[:category])
  end

  def get_contacts
    sql = <<~SQL
    SELECT * FROM contacts;
    SQL

    result = query(sql)

    result.map do |tuple|
      tuple_to_list_hash(tuple)
    end
  end

  def delete_contact(name)
    sql = <<~SQL
    DELETE FROM contacts WHERE name = $1
    SQL
    query(sql, name)
  end

  private

  def tuple_to_list_hash(tuple)
    { id: tuple["id"],
      name: tuple["name"],
      phone: tuple["phone"],
      email: tuple["email"],
      category: tuple["category"]
    }
  end
end