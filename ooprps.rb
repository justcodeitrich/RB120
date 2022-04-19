module Displayable
  private

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
    sleep(2)
    human.points += 1
    system("clear")
  end

  def display_comp_wins
    puts "#{comp.name} won!"
    sleep(2)
    comp.points += 1
    system("clear")
  end

  def display_move_history
    puts "#{human.name}'s previous moves: #{human.move_history.join(', ')}"
    puts "#{comp.name}'s previous moves: #{comp.move_history.join(', ')}"
  end

  def display_tie
    puts "It's a tie!"
    sleep(1.5)
    system("clear")
  end

  def display_choices
    puts "#{human.name} chose #{human.move}."
    sleep(1)
    puts "#{comp.name} chose #{comp.move}."
    sleep(1)
  end

  def display_points
    puts "#{human.name}:#{human.points} | #{comp.name}:#{comp.points}"
  end

  def display_winner
    display_choices
    if human.move.value == comp.move.value
      display_tie
    elsif human.move > comp.move
      display_human_wins
    else
      display_comp_wins
    end
  end
end

class Move
  include Comparable
  attr_accessor :value

  VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard']
  def initialize(value)
    self.value = value
  end

  def scissors?
    value == 'scissors'
  end

  def rock?
    value == 'rock'
  end

  def paper?
    value == 'paper'
  end

  def spock?
    value == 'spock'
  end

  def lizard?
    value == "lizard"
  end

  def tie?(other_move)
    value == other_move
  end

  def to_s
    @value
  end

  protected

  def <=>(other_move)
    return 1 if rock_wins?(other_move) ||
                paper_wins?(other_move) ||
                scissors_wins?(other_move) ||
                spock_wins?(other_move) ||
                lizard_wins?(other_move)
    -1
  end

  def rock_wins?(other_move)
    (rock? && (other_move.scissors? || other_move.lizard?))
  end

  def paper_wins?(other_move)
    (paper? && (other_move.rock? || other_move.spock?))
  end

  def scissors_wins?(other_move)
    (scissors? && (other_move.paper? || other_move.lizard?))
  end

  def spock_wins?(other_move)
    (spock? && (other_move.rock? || other_move.scissors?))
  end

  def lizard_wins?(other_move)
    (lizard? && (other_move.paper? || other_move.spock?))
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

  private

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
  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, spock, or lizard:"
      choice = gets.chomp
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice"
    end

    self.move = choice_to_new_obj(choice)
    move_history << choice
  end

  private

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
end

class Comp < Player
  def comp_personalities
    case name
    when 'R2D2' then ['rock', 'rock', 'rock', 'paper', 'spock'].sample
    when 'CHAPPIER' then ['lizard', 'lizard', 'rock', 'paper', 'spock'].sample
    when 'WALL-E' then ['rock', 'paper', 'scissors', 'lizard', 'spock'].sample
    when 'The Iron Giant' then 'scissors'
    end
  end

  def choose
    choice = comp_personalities
    self.move = choice_to_new_obj(choice)
    move_history << choice
  end

  private

  def set_name
    self.name = ['R2D2', 'CHAPPIER', 'WALL-E', 'The Iron Giant'].sample
  end
end

class RPSGame
  private

  include Displayable

  attr_accessor :human, :comp

  def initialize
    @human = Human.new
    @comp = Comp.new
  end

  def reset_game
    human.points = 0
    comp.points = 0
    human.move_history = []
    comp.move_history = []
    comp.name = ['R2D2', 'CHAPPIER', 'WALL-E', 'The Iron Giant'].sample
  end

  def announce_winner
    if human.points.eql?(10)
      display_human_wins
    else
      display_comp_wins
    end
  end

  def play_again?
    return true unless point_check
    announce_winner
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
    human.points.eql?(10) || comp.points.eql?(10)
  end

  public

  def play
    display_welcome_message
    loop do
      human.choose
      comp.choose
      display_winner
      display_move_history
      display_points
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
