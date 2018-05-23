require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create(attributes)
    new_dog = Dog.new(attributes)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL

    result = DB[:conn].execute(sql, id)
    id = result[0][0]
    name = result[0][1]
    breed = result[0][2]
    Dog.new(name: name, breed: breed, id: id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL

    result = DB[:conn].execute(sql, name)
    id = result[0][0]
    name = result[0][1]
    breed = result[0][2]
    Dog.new(breed: breed, name: name, id: id)


  end

  def self.find_or_create_by(name: name, breed: breed)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    AND breed = ?
    SQL

    result = DB[:conn].execute(sql, name, breed)

    if result.empty?
       create(name: name, breed: breed)
    else
      id = result[0][0]
      name = result[0][1]
      breed = result[0][2]
      Dog.new(id: id, name: name, breed: breed)
    end
  end

  def self.new_from_db(dog_row)
    id = dog_row[0]
    name = dog_row[1]
    breed = dog_row[2]
    Dog.new(breed: breed, id: id, name: name)
  end


  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, @name, @breed, @id)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, @name, @breed)
    #DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
#    binding.pry
  end
end
