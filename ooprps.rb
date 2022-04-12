class Move
  VALUES = ['rock', 'paper', 'scissors']
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

  def >(other_move)
    rock? && other_move.scissors? ||
      paper? && other_move.rock? ||
      scissors? && other_move.paper?
  end

  def <(other_move)
    rock? && other_move.paper? ||
      paper? && other_move.scissors? ||
      scissors? && other_move.rock?
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
      puts "Please choose rock, paper, or scissors:"
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

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    system("clear")
    puts "Welcome to Rock, Paper, Scissors!"
    sleep(1.5)
    puts "First to 10 points wins!"
  end

  def display_goodbye_message
    puts "Thanks for playing!"
  end

  def human_wins
    puts "#{human.name} won!"
    human.points += 1
  end

  def computer_wins
    puts "#{computer.name} won!"
    computer.points += 1
  end

  def display_winner
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
    if human.move > computer.move
      human_wins
    elsif human.move < computer.move
      computer_wins
    else
      puts "It's a tie!"
    end
  end

  def display_points
    puts "#{human.name}:#{human.points} | #{computer.name}:#{computer.points}"
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
      display_choices
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
problem: adding a score system
 done - prompting message the first to 10 points wins to player
 done - incrementing the score for each game depending on who wins
 done - displaying score count at end of each round
 done - exiting when first to score 10 points wins (checking for 10 on each round)
 done - reset score to 0 if player wants to play again

- instead of a new class - build on top of the play loop

Write a description of the problem and extract major nouns and verbs.
Make an initial guess at organizing the verbs and nouns into methods and classes/modules, then do a spike to explore the problem with temporary code.
When you have a better idea of the problem, model your thoughts into CRC cards.
=end
