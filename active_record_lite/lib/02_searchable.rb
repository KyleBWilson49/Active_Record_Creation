require_relative 'db_connection'
require_relative '01_sql_object'
# require 'byebug'

module Searchable
  def where(params)
    where_line = ""
    values = []
    params.each do |key, val|
      where_line << "#{key} = ? AND "
      values << val
    end
    where_line = where_line.chomp(" AND ")

    results = DBConnection.execute(<<-SQL, values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    results.map do |result|
      self.new(result)
    end
  end
end

class SQLObject
  extend Searchable
end
