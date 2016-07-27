require 'byebug'

class QuestionSuper

  def self.find_by_id(id)
    table = self.table
    query = "SELECT  * FROM " + table + " WHERE id = " + id.to_s
    data = QuestionsDatabase.instance.execute(query)
    raise "ID not found" if data.empty?
    data
  end

  def self.all
    data = QuestionsDatabase.instance.execute('SELECT * FROM ' + self.table )
    data.map {|datum| self.new(datum)}
  end

  def self.where(options)
    if options.is_a?(Hash)
      args = []
      options.each {|key, val| args << "#{key.sanitize} = #{val.sanitize}"}
      args = args.join(", ")
      query = "SELECT * FROM #{self.table} WHERE #{args}"
      QuestionsDatabase.instance.execute(query)
    else
      query = "SELECT * FROM #{self.table} WHERE #{options}"
      QuestionsDatabase.instance.execute(query)
    end
  end

  def self.method_missing(method_name, *args)
    method_name = method_name.to_s
    if method_name.start_with?("find_by_")
      text = method_name[("find_by_".length)..-1]
      methods = text.split("_and_")

      options = Hash.new
      (0...args.count).each {|i| options[methods[i]] = args[i]}
      self.where(options)
    else
      super
    end
  end

  def save
    raise "#{self} already in database" if @id
    self_iv = self.instance_variables
    self_iv.map!{|variable| variable.to_s[1..-1]}
    self_iv.delete('id')
    self_iv_string = self_iv.join(", ")
    values = self_iv.map{|iv| self.send(iv).sanitize}
    query = "INSERT INTO #{table} (#{self_iv_string}) VALUES (#{values.join(", ")})"
    QuestionsDatabase.instance.execute(query)
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

end

class String
   def sanitize
     self.gsub(/[^[:alnum:]]+/, '_')
   end
 end
