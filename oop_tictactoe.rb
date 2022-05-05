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
    marker == TTTGame.comp_marker
  end
end

class Player
  attr_accessor :score, :marker, :name

  def initialize(marker=nil)
    @marker = marker
    @score = 0
    @name = name
  end
end

class Computer < Player
  attr_reader :board

  def initialize(marker, current_board)
    @board = current_board
    @name = ["Donkey", "Farquad", "Shrek"].sample
    super(marker)
  end

  def under_threat?
    !!off_def_piece("defense")
  end

  def possible_win?
    !!off_def_piece("offense")
  end

  def off_def_piece(strategy)
    Board::WINNING_LINES.each do |line|
      squares = board.squares.values_at(*line)
      if two_consecutive_player_pieces?(squares, strategy)
        line.each { |key| return key if board.squares[key].marker == " " }
      end
    end
    nil
  end

  def place_defensive_piece
    board[off_def_piece("defense")] = (marker)
  end

  def place_offensive_piece
    board[off_def_piece("offense")] = (marker)
  end

  def select_random_square
    board[board.unmarked_keys.sample] = (marker)
  end

  def select_square_five
    board[5] = (marker)
  end

  private

  def two_consecutive_player_pieces?(squares, strategy)
    if strategy == 'offense'
      advantage_of_two_comp_pieces?(squares)
    else
      threat_of_two_human_pieces?(squares)
    end
  end

  def threat_of_two_human_pieces?(squares)
    return false if squares.any?(&:computer_marker?)
    squares.select(&:human_marker?).size == 2
  end

  def advantage_of_two_comp_pieces?(squares)
    return false if squares.any?(&:human_marker?)
    squares.select(&:computer_marker?).size == 2
  end
end

module Displayable
  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts "First to #{TTTGame::POINTS_TO_WIN} wins the game!"
  end

  def ask_for_name
    puts "Please type your name."
    answer = nil
    loop do
      answer = gets.chomp
      break unless answer =~ /[^a-zA-Z]/
      puts "Sorry, that's an invalid input."
    end
    @human.name = answer
  end

  def ask_human_to_pick_marker
    puts "Pick your marker!"
    answer = nil
    loop do
      puts "Type in any single character."
      answer = gets.chomp
      break if answer.size == 1 && !answer.strip.empty?
      puts "Sorry, that's an invalid marker."
    end
    answer
  end

  def ask_who_should_decide_first_mover
    puts ""
    puts "Who should decide who goes first?"
    puts ""
    puts "Type 1 if you want to choose."
    puts "Type 2 to let the computer choose."
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
    if answer == TTTGame::HUMAN_ID
      puts "#{human.name} go first!"
    else
      puts "#{comp.name} the computer goes first!"
    end
    sleep 1.5
  end

  # rubocop:disable Layout/LineLength

  def display_scoreboard
    puts ""
    puts "#{human.name}'s score: #{scoreboard[0].score} | #{comp.name}'s score: #{scoreboard[1].score}"
  end

  def display_board
    puts "#{human.name} is playing #{human.marker}. #{comp.name} is playing #{comp.marker}."
    display_scoreboard
    puts ""
    board.draw
    puts ""
  end

  # rubocop:enable Layout/LineLength

  def display_result
    clear_screen_and_display_board
    case board.winning_marker
    when human.marker
      puts "#{human.name} won!"
    when comp.marker
      puts "#{comp.name} won!"
    else
      puts "It's a tie!"
    end
    sleep 1.2
  end

  def display_goodbye_message
    puts "Thanks for playing. Goodbye!"
  end
end

class TTTGame
  include Displayable
  POINTS_TO_WIN = 5
  HUMAN_ID = 1
  COMPUTER_ID = 2
  attr_reader :board, :human, :comp
  attr_accessor :current_marker, :scoreboard

  def initialize
    @@comp_marker = nil
    @board = Board.new
    @human = Player.new
    @comp = Computer.new(@@comp_marker, @board)
    @first_to_move = nil
    @current_marker = nil
    @scoreboard = [@human, @comp]
  end

  def self.human_marker
    @@human_marker
  end

  def self.comp_marker
    @@comp_marker
  end

  def play
    clear
    display_welcome_message
    ask_for_name
    players_pick_markers
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
      ask_who_goes_first_next_round
      break unless play_again?
      reset
      prepare_next_game_series
    end
  end

  def players_pick_markers
    human_picks_marker
    computer_picks_marker
  end

  def human_picks_marker
    @@human_marker = ask_human_to_pick_marker
    human.marker = @@human_marker
  end

  def computer_picks_marker
    @@comp_marker = if @@human_marker == ("O")
                      "*"
                    else
                      "O"
                    end
    comp.marker = @@comp_marker
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

  def user_answer
    answer = nil
    loop do
      answer = gets.chomp.to_i
      break if [HUMAN_ID, COMPUTER_ID].include?(answer)
      puts "Sorry, that's not a valid answer."
    end
    answer
  end

  def ask_who_goes_first_next_round
    human_decision if scoreboard.all? { |obj| obj.score != POINTS_TO_WIN }
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

  def assign_move_markers_to_answer(answer)
    if answer == HUMAN_ID
      @first_to_move = @@human_marker
    elsif answer == COMPUTER_ID
      @first_to_move = @@comp_marker
    end
    @current_marker = @first_to_move
  end

  def add_point_to_winner
    if board.winning_marker == @@human_marker
      scoreboard[0].score += 1
    elsif board.winning_marker == @@comp_marker
      scoreboard[1].score += 1
    end
  end

  def joinor(keys, delimiter = ", ", word = "or")
    return keys.first if keys.size == 1
    keys[0..-2].join(delimiter).concat(delimiter) + word + " " + keys.last.to_s
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def current_player_moves
    if current_marker == @@human_marker
      human_moves
      @current_marker = @@comp_marker
    elsif current_marker == @@comp_marker
      computer_moves
      @current_marker = @@human_marker
    end
  end

  def human_turn?
    current_marker == @@human_marker
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
    if comp.possible_win?
      comp.place_offensive_piece
    elsif board.square_five_empty?
      comp.select_square_five
    elsif comp.under_threat?
      comp.place_defensive_piece
    else
      comp.select_random_square
    end
  end

  def play_again?
    return true unless scoreboard.any? { |obj| obj.score == POINTS_TO_WIN }
    answer = nil
    loop do
      puts "Would you like to play again? (yes/no)"
      answer = gets.chomp.downcase
      break if %w(y n yes no).include? answer
      puts "Sorry, that's not a valid answer."
    end
    answer == "y" || answer == "yes"
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
