class Dog
  attr_accessor :name, :breed
  attr_reader :id

  #abtraction attempts
  def self.table_name
    "#{self.to_s.downcase}s"
  end

  def self.reify_from_row(row)
    self.new.tap do |d|
      d.id  = row[0]
      d.name = row[1]
      d.breed = row[2]
    end
  end
  #----------------------------------------------------
  #standard methods/sql
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS #{self.table_name} (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE #{self.table_name}"
    DB[:conn].execute(sql)
  end

  def save #create dog in db, check for duplicates, and assign an ID
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO #{self.class.table_name} (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.class.table_name}")[0][0]
    end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM #{self.table_name} WHERE id = ?
    SQL
    DB[:conn].execute(sql, id).first
  end


end
