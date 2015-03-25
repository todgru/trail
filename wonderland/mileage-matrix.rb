require 'csv'
require 'pry'

# Create a mileage matrix for the 93 mile Wonderland Trail loop.
# 
# @todo clean up.
# 
class WonderLoop

  def initialize
    @matrix = Hash.new

    @mileage = csv

    # setup empty matrix hash
    @mileage.each do |row|
      @matrix[row[:from]] = Hash.new
      @mileage.each do |r|
        @matrix[row[:from]][r[:from]] = ""
      end
    end
    create
    write_to_csv
    puts 'done'
  end

  # Write new CSV data to matrix.csv
  #
  def write_to_csv
    column_names = @matrix.keys
    CSV.open("matrix.csv", "wb") do |c|
      c << column_names.insert(0, "")
      @matrix.each do |hash|
        c << hash[1].values.insert(0, hash[0])
      end
    end
  end

  # read CSV data
  #
  def csv
    m = Array.new
    CSV.foreach("mileage.csv", :headers => true, :header_converters => :symbol, :converters => :all).collect do |row|
      m << Hash[row.collect { |c,r| [c,r] }] 
    end
    m
  end

  # Create matrix of distance between a given point and anything other point in the loop.
  #
  # { "start" -> { "stop1" => 12, "stop2" => 22 }
  #   ...
  # }
  def create
    @matrix.each do |start|
      @matrix[start[0]].each do |fin|
        @matrix[start[0]][fin[0]] = miles(start[0], fin[0]).round(2)
      end
    end
  end

  # Find the the mileage between two points of the circle.
  #
  def miles(start_from, finish) 
    return 0 if start_from == finish
    discards = Array.new
    distance = 0
    skip = 0
    n = 0

    # "next if" until we get to the first occurence of ":from == start_from"
    # each of the :from's that we skipped, add them to the discard pile. we may need them.
    @mileage.each do |row|
      break if start_from == row[:from]
      skip += 1
      discards << row
    end

    # skip the n first items that we discarded, then start adding
    # Start adding the distances together
    # until we get to ":to == finish", if it exists, else..
    @mileage.each do |row|
      n += 1
      next if skip >= n 
      distance = distance + row[:distance]
      return distance if finish == row[:to]
    end

    # ...if its not found, start adding distances from the discard pile
    #
    # Start adding the distances from the discard pile
    # until we get to ":to == fin"
    # if its not found, return zero
    # if its found, return current sum
    discards.each do |row|
      distance = distance + row[:distance]
      return distance if finish == row[:to]
    end
    distance
  end

  # Test mileage, represents hash read from CSV
  #
  def test_mileage
    [
      { :from => "first", :to => "second", :distance => 2 },
      { :from => "second", :to => "third", :distance => 4 },
      { :from => "third", :to => "fourth", :distance => 3 },
      { :from => "fourth", :to => "first", :distance => 1 }
    ]
  end

end

WonderLoop.new
