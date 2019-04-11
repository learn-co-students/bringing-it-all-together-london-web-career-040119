class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?);
    SQL
    dog_data = DB[:conn].execute(sql, name, breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs;')[0][0]
    self
  end

  def self.create(name:, breed:)
    dog = new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1;
    SQL
    dog_data = DB[:conn].execute(sql, id)[0]
    new_from_db(dog_data)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1;
    SQL
    dog_data = DB[:conn].execute(sql, name, breed)[0]

    if dog_data
      dog = new_from_db(dog_data)
    else
      dog = new(name: name, breed: breed)
      dog.save
    end
    dog
  end

  def self.new_from_db(row)
    new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1;
    SQL
    dog_data = DB[:conn].execute(sql, name)[0]
    new_from_db(dog_data)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL
    DB[:conn].execute(sql, name, breed, id)
    self
  end
end
