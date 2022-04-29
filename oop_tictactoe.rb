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

  def square_five_empty?
    squares[5].marker == " "
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
    marker == TTTGame.human_marker
  end

  def computer_marker?
    marker == TTTGame::COMPUTER_MARKER
  end
end

class Player
  attr_accessor :score, :marker

  def initialize(marker=nil)
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

  def possible_win?
    !!offensive_piece
  end

  def offensive_piece
    Board::WINNING_LINES.each do |line|
      squares = board.squares.values_at(*line)
      if two_consecutive_comp_pieces?(squares)
        line.each { |key| return key if board.squares[key].marker == " " }
      end
    end
    nil
  end

  def defensive_piece
    Board::WINNING_LINES.each do |line|
      squares = board.squares.values_at(*line)
      if two_consecutive_human_pieces?(squares)
        line.each { |key| return key if board.squares[key].marker == " " }
      end
    end
    nil
  end

  def place_defensive_piece
    board[defensive_piece] = (marker)
  end

  def place_offensive_piece
    board[offensive_piece] = (marker)
  end

  def select_random_square
    board[board.unmarked_keys.sample] = (marker)
  end

  def select_square_five
    board[5] = (marker)
  end

  private

  def two_consecutive_human_pieces?(squares)
    return false if squares.any?(&:computer_marker?)
    markers = squares.select(&:human_marker?).collect(&:marker)
    markers.size == 2
  end

  def two_consecutive_comp_pieces?(squares)
    return false if squares.any?(&:human_marker?)
    markers = squares.select(&:computer_marker?).collect(&:marker)
    markers.size == 2
  end
end

class TTTGame
  COMPUTER_MARKER = "O"
  POINTS_TO_WIN = 5
  HUMAN_ID = 1
  COMPUTER_ID = 2
  attr_reader :board, :human, :computer
  attr_accessor :current_marker, :scoreboard

  def initialize
    @board = Board.new
    @human = Player.new()
    @computer = Computer.new(COMPUTER_MARKER, @board)
    @first_to_move = nil
    @current_marker = nil
    @scoreboard = [@human, @computer]
  end

  def self.human_marker
    @@human_marker
  end

  def self.human_marker=(value)
    @@human_marker = value
  end

  def play
    clear
    display_welcome_message
    human_picks_marker
    determine_who_goes_first
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
      prepare_next_game_series
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

  def ask_human_to_pick_marker
    puts "Pick your marker!"
    answer = nil
    loop do
      puts "Type in any single character."
      answer = gets.chomp
      break if answer.size == 1
      puts "Sorry, that's an invalid marker."
    end
    answer
  end

  def human_picks_marker
    TTTGame.human_marker = ask_human_to_pick_marker
    human.marker = TTTGame.human_marker
  end

  def ask_who_goes_first
    puts ""
    puts "Who should go first?"
    puts ""
    puts "Type 1 if you want to go first."
    puts "Type 2 to let the computer go first."
  end

  def display_who_goes_first(answer)
    clear
    if answer == HUMAN_ID
      puts "You go first!"
    else
      puts "Computer goes first!"
    end
    sleep 1.5
  end

  def assign_move_markers_to_answer(answer)
    if answer == HUMAN_ID
      @first_to_move = TTTGame.human_marker
    elsif answer == COMPUTER_ID
      @first_to_move = COMPUTER_MARKER
    end
    @current_marker = @first_to_move
  end

  def ask_who_should_decide_first_mover
    puts ""
    puts "Who should decide who goes first?"
    puts ""
    puts "Type 1 if you want to choose."
    puts "Type 2 to let the computer choose."
  end

  def user_answer
    answer = nil
    loop do
      answer = gets.chomp.to_i
      break if [HUMAN_ID, COMPUTER_ID].include?(answer)
      puts "Sorry, that's not a valid answer."
    end
    answer
  end

  def determine_who_goes_first
    ask_who_should_decide_first_mover
    decision_maker = user_answer
    if decision_maker == HUMAN_ID
      human_decision
    elsif decision_maker == COMPUTER_ID
      computer_decision
    end
  end

  def human_decision
    ask_who_goes_first
    human_choice = user_answer
    assign_move_markers_to_answer(human_choice)
    display_who_goes_first(human_choice)
  end

  def computer_decision
    comp_choice = [HUMAN_ID, COMPUTER_ID].sample
    assign_move_markers_to_answer(comp_choice)
    display_who_goes_first(comp_choice)
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
    if board.winning_marker == TTTGame.human_marker
      scoreboard[0].score += 1
    elsif board.winning_marker == COMPUTER_MARKER
      scoreboard[1].score += 1
    end
  end

  def current_player_moves
    if current_marker == TTTGame.human_marker
      human_moves
      @current_marker = COMPUTER_MARKER
    elsif current_marker == COMPUTER_MARKER
      computer_moves
      @current_marker = TTTGame.human_marker
    end
  end

  def human_turn?
    current_marker == TTTGame.human_marker
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
    if computer.possible_win?
      computer.place_offensive_piece
    elsif board.square_five_empty?
      computer.select_square_five
    elsif computer.under_threat?
      computer.place_defensive_piece
    else
      computer.select_random_square
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
    @current_marker = @first_to_move
    board.reset
    clear
  end

  def reset_scoreboard
    scoreboard.each { |obj| obj.score = 0 }
  end

  def prepare_next_game_series
    return unless scoreboard.any? { |obj| obj.score == POINTS_TO_WIN }
    reset_scoreboard
    determine_who_goes_first
  end
end

game = TTTGame.new
game.play
