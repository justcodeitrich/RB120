class Move
  VALUES = ['rock', 'paper', 'scissors','spock','lizard']
  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def spock?
    @value == 'spock'
  end

  def lizard?
    @value == "lizard"
  end

  def >(other_move)
    (rock? && other_move.scissors? || other_move.lizard?) ||
      (paper? && other_move.rock? || other_move.spock?) ||
      (scissors? && other_move.paper? || other_move.lizard?) || 
      (spock? && other_move.rock? || other_move.scissors?) || 
      (lizard? && other_move.paper? || other_move.spock?)
  end

  def <(other_move)
    (rock? && other_move.paper? || other_move.spock?) ||
      (paper? && other_move.scissors? || other_move.lizard?) ||
      (scissors? && other_move.rock? || other_move.spock?) || 
      (spock? && other_move.lizard? || other_move.paper?) ||
      (lizard? && other_move.rock? || other_move.scissors)
  end

  def to_s
    @value
  end

end

class Player
  attr_accessor :move, :name, :points
  def initialize
    @points = 0
    set_name
  end
end

class Human < Player
  def set_name
    system("clear")
    n = ""
    loop do
      puts "What is your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, spock, or lizard:"
      choice = gets.chomp
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice"
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'CHAPPIER'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

module Displayable 
  def display_welcome_message
    system("clear")
    puts "Welcome to Rock, Paper, Scissors, Spock, Lizard!"
    sleep(1)
    puts "First to 10 points wins!"
  end

  def display_goodbye_message
    puts "Thanks for playing!"
  end

  def display_human_wins
    puts "#{human.name} won!"
    human.points += 1
  end

  def display_computer_wins
    puts "#{computer.name} won!"
    computer.points += 1
  end

  def display_winner
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
    
    if human.move > computer.move
      display_human_wins
    elsif human.move < computer.move
      display_computer_wins
    else
      puts "It's a tie!"
    end
  end

  def display_points
    puts "#{human.name}:#{human.points} | #{computer.name}:#{computer.points}"
  end
end

class RPSGame
  include Displayable
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def reset_points
    human.points = 0
    computer.points = 0
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include? answer.downcase
      puts "Sorry, must y or n."
    end
    reset_points if answer == 'y'
  end

  def point_check
    human.points.eql?(10) || computer.points.eql?(10)
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_winner
      display_points
      if point_check
        break unless play_again?
      end
    end
    display_goodbye_message
  end
end

RPSGame.new.play

=begin
problem: adding lizard and spock
scissors - beats paper and lizard
paper - beats rock and spock
rock - beats lizard and scissors
lizard - beats paper and spock 
spock - beats rock and scissors

- change display prompt asking to pick an option
- add lizard and spock to the > and < 
=end
