require 'pry'
class Board
  attr_reader :squares

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength

  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def []=(num, marker)
    @squares[num].marker = marker
  end

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "
  attr_accessor :marker

  def initialize
    @marker = INITIAL_MARKER
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def human_marker?
    marker == TTTGame::HUMAN_MARKER
  end

  def computer_marker?
    marker == TTTGame::COMPUTER_MARKER
  end
end

class Player
  attr_reader :marker
  attr_accessor :score

  def initialize(marker)
    @marker = marker
    @score = 0
  end
end

class Computer < Player
  attr_reader :board

  def initialize(marker, current_board)
    @board = current_board
    super(marker)
  end

  def under_threat?
    !!defensive_piece
  end

  def defensive_piece
    Board::WINNING_LINES.each do |line|
      squares = board.squares.values_at(*line)
      if two_consecutive_human_markers?(squares)
        line.each { |key| return key if board.squares[key].marker == " " }
      end
    end
    nil
  end

  private

  def two_consecutive_human_markers?(squares)
    return false if squares.any?(&:computer_marker?)
    markers = squares.select(&:human_marker?).collect(&:marker)
    markers.size == 2
  end
end

class TTTGame
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  FIRST_TO_MOVE = HUMAN_MARKER
  POINTS_TO_WIN = 5
  attr_reader :board, :human, :computer
  attr_accessor :current_marker, :scoreboard

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Computer.new(COMPUTER_MARKER, @board)
    @current_marker = FIRST_TO_MOVE
    @scoreboard = [@human, @computer]
  end

  def play
    clear
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  def main_game
    loop do
      display_board
      player_move
      add_point_to_winner
      display_result
      break unless play_again?
      reset
      reset_scoreboard if scoreboard.any? { |obj| obj.score == POINTS_TO_WIN }
    end
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts "First to #{POINTS_TO_WIN} wins the game!"
  end

  def display_scoreboard
    puts "Score | You: #{scoreboard[0].score} | Comp: #{scoreboard[1].score}"
  end

  def display_goodbye_message
    puts "Thanks for playing. Goodbye!"
  end

  def display_board
    puts "You are #{human.marker}. Computer is #{computer.marker}."
    display_scoreboard
    puts ""
    board.draw
    puts ""
  end

  def add_point_to_winner
    if board.winning_marker == HUMAN_MARKER
      scoreboard[0].score += 1
    elsif board.winning_marker == COMPUTER_MARKER
      scoreboard[1].score += 1
    end
  end

  def current_player_moves
    if current_marker == HUMAN_MARKER
      human_moves
      self.current_marker = COMPUTER_MARKER
    else
      computer_moves
      self.current_marker = HUMAN_MARKER
    end
  end

  def human_turn?
    current_marker == HUMAN_MARKER
  end

  def joinor(keys, delimiter = ", ", word = "or")
    return keys.first if keys.size == 1
    keys[0..-2].join(delimiter).concat(delimiter) + word + " " + keys.last.to_s
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys)})"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry that's not a valid choice."
    end
    board[square] = (human.marker)
  end

  def computer_moves
    if computer.under_threat?
      board[computer.defensive_piece] = (computer.marker)
    else
      board[board.unmarked_keys.sample] = (computer.marker)
    end
  end

  def display_result
    clear_screen_and_display_board
    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
    sleep 1.2
  end

  def play_again?
    return true unless scoreboard.any? { |obj| obj.score == POINTS_TO_WIN }
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, that's not a valid answer."
    end
    answer == "y"
  end

  def clear
    system "clear"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def reset
    board.reset
    self.current_marker = FIRST_TO_MOVE
    clear
  end

  def reset_scoreboard
    scoreboard.each { |obj| obj.score = 0 }
  end
end

game = TTTGame.new
game.play
