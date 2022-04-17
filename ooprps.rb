class Move
  attr_accessor :value

  VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard']
  def initialize(value)
    self.value = value
  end

  def scissors?
    self.value == 'scissors'
  end

  def rock?
    self.value == 'rock'
  end

  def paper?
    self.value == 'paper'
  end

  def spock?
    self.value == 'spock'
  end

  def lizard?
    self.value == "lizard"
  end

  def >(other_move)
    (rock? && (other_move.scissors? || other_move.lizard?)) ||
      (paper? && (other_move.rock? || other_move.spock?)) ||
      (scissors? && (other_move.paper? || other_move.lizard?)) ||
      (spock? && (other_move.rock? || other_move.scissors?)) ||
      (lizard? && (other_move.paper? || other_move.spock?))
  end

  def <(other_move)
    (rock? && (other_move.paper? || other_move.spock?)) ||
      (paper? && (other_move.scissors? || other_move.lizard?)) ||
      (scissors? && (other_move.rock? || other_move.spock?)) ||
      (spock? && (other_move.lizard? || other_move.paper?)) ||
      (lizard? && (other_move.rock? || other_move.scissors?))
  end

  def to_s
    @value
  end
end

class Rock < Move
  def initialize(value)
    super(value)
  end
end

class Paper < Move
  def initialize(value)
    super(value)
  end
end

class Scissors < Move
  def initialize(value)
    super(value)
  end
end

class Lizard < Move
  def initialize(value)
    super(value)
  end
end

class Spock < Move
  def initialize(value)
    super(value)
  end
end

class Player
  attr_accessor :move, :name, :points, :move_history

  def initialize
    @points = 0
    @move_history = []
    set_name
  end

  def choice_to_new_obj(choice)
    case choice
    when "rock" then Rock.new('rock')
    when "paper" then Paper.new('paper')
    when "scissors" then Scissors.new('scissors')
    when "spock" then Spock.new('spock')
    when "lizard" then Lizard.new('lizard')
    end
  end
end

class Human < Player
  def set_name
    # system("clear")
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

    self.move = choice_to_new_obj(choice)
    self.move_history << choice
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'CHAPPIER', 'WALL-E', 'The Iron Giant'].sample
  end

  def computer_personalities
    case self.name
    when 'R2D2' then ['rock', 'rock', 'rock', 'paper', 'spock'].sample
    when 'CHAPPIER' then ['lizard', 'lizard', 'rock', 'paper', 'spock'].sample
    when 'WALL-E' then 'scissors'
    when 'The Iron Giant' then ['rock', 'paper', 'scissors', 'lizard', 'spock'].sample
    end
  end

  def choose
    choice = computer_personalities
    self.move = choice_to_new_obj(choice)
    self.move_history << choice
  end
end

module Displayable
  def display_welcome_message
    # system("clear")
    puts "Welcome to Rock, Paper, Scissors, Spock, Lizard!"
    # sleep(1)
    puts "First to 10 points wins!"
  end

  def display_goodbye_message
    puts "Thanks for playing!"
  end

  def display_human_wins
    puts "#{human.name} won!"
    # sleep(1.5)
    human.points += 1
    # system("clear")
  end

  def display_computer_wins
    puts "#{computer.name} won!"
    # sleep(1.5)
    computer.points += 1
    # system("clear")
  end

  def display_move_history
    puts "#{human.name}'s previous moves: #{human.move_history.join(', ')}"
    puts "#{computer.name}'s previous moves: #{computer.move_history.join(' , ')}"
  end

  def display_tie
    puts "It's a tie!"
    # sleep(1.5)
    # system("clear")
  end

  def display_winner
    puts "#{human.name} chose #{human.move}."
    # sleep(1)
    puts "#{computer.name} chose #{computer.move}."
    # sleep(1)
    if human.move > computer.move
      display_human_wins
    elsif human.move < computer.move
      display_computer_wins
    else
      display_tie
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

  def reset_game
    human.points = 0
    computer.points = 0
    human.move_history = []
    computer.move_history = []
    computer.name = ['R2D2', 'CHAPPIER', 'WALL-E', 'The Iron Giant'].sample
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include? answer.downcase
      puts "Sorry, must y or n."
    end
    reset_game if answer == 'y'
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
      display_move_history
      display_points
      if point_check
        break unless play_again?
      end
    end
    display_goodbye_message
  end
end

RPSGame.new.play
