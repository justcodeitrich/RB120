require 'pry'

RULES = <<HEREDOC

Rules:

  Player rules:
    Player
      - To win, your total card value needs to beat the dealer's total card value without going over 21.
      - If your total card value goes over 21 then that is a bust and you lose the game.

    Dealer
      - The dealer must continue to hit until his total card value is at least 17 or above.
      - The dealer wins by having a greater total card value than your total card value.

  Card Values:
    2,3,4,5,6,7,8,9, and 10 cards have the same value as the number on the card.
    Jack, Queen, and King each have a value of 10.
    Ace cards can be a 1 or 11. 
    - An Ace's value is 1 if adding an Ace valued at 11 to your current total would cause you to bust.

  Gameplay:
    - First you and the dealer are dealt two cards each.  
    - Look at your cards and decide if you want to hit or stay.
      - Hit - you will draw one extra card and add it to your hand.
        - You can continue to hit until you feel you have a total hand value that can win.
      - Stay - you do not draw any cards and it is the dealer's turn.

  Remember if you draw a card that causes your hand to go over 21, dealer wins!

  Good luck! Have fun!

HEREDOC

module Printable
  def press_any_key
    puts "Press any key to continue."
    gets.chomp
  end

  def clear
    system('clear')
  end

  def wait
    sleep(1.5)
  end

  def print_player_draws_card(drawn_card, player)
    puts "#{player.name} draws a #{drawn_card.first} of #{drawn_card.last}."
  end

  def print_welcome_message
    puts "Welcome to Twenty One!"
  end

  def print_game_rules
    puts RULES
    press_any_key
    clear
  end

  def print_dealers_turn
    puts "Dealer's turn!"
  end

  def print_ask_user_name
    puts "What is your name?"
  end

  def print_hit_or_stay
    puts "Would you like to hit or stay? Type: (h)it or (s)tay"
  end

  def print_invalid_answer
    puts "Sorry, that's not a valid answer."
  end

  def print_winner(player=nil)
    if player.nil?
      puts "It's a tie!"
    else
      puts "#{player.name} wins!"
    end
  end

  def print_busted(player)
    puts "#{player.name} went over #{Player::HAND_VALUE_LIMIT} and busted!"
  end

  def print_hand_total(player)
    puts "#{player.name}'s cards total to #{player.total_hand_value} "
  end

  def print_cards_in_hand(player)
    puts "#{player.name} has"
    player.hand.each do |value, suit|
      puts "#{value} of #{suit}"
    end
  end

  # rubocop:disable Layout/LineLength
  def print_one_of_dealers_cards
    revealed_card = dealer.hand[0]
    puts "#{dealer.name} has a #{revealed_card[0]} of #{revealed_card[1]} and one hidden card."
  end

  def print_dealer_hand_reveal
    hidden_card = dealer.hand.last
    puts "#{dealer.name} flips over the hidden card: A #{hidden_card.first} of #{hidden_card.last}!"
  end

  def print_dealer_stays
    puts "#{dealer.name} stays with a total value of #{dealer.total_hand_value}."
  end
  # rubocop:enable Layout/LineLength
end

class Deck
  SUITS = %w(Hearts Spades Diamonds Clubs)
  VALUES = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'Jack', 'Queen', 'King', 'Ace']

  attr_reader :all_cards

  def initialize
    @all_cards = SUITS.each_with_object([]) do |suit, array|
      VALUES.each do |value|
        array << [value, suit]
      end
    end
  end

  def shuffle_cards
    all_cards.shuffle!
  end

  def deal_one_card
    all_cards.pop
  end
end

class Player
  HAND_VALUE_LIMIT = 21
  attr_reader :hand, :total_hand_value
  attr_accessor :name, :busted

  def initialize(name)
    @hand = []
    @name = name + " the dealer"
    @total_hand_value = 0
    @busted = false
  end

  def calculate_hand_value
    @total_hand_value = 0
    aces = hand.select { |card| card.first == "Ace" }
    hand.each do |card_with_suit|
      next if card_with_suit[0] == "Ace"
      @total_hand_value += card_to_value(card_with_suit)
    end
    aces.each do |ace|
      @total_hand_value += card_to_value(ace)
    end
  end

  def card_to_value(card)
    face = card.first
    case face
    when "Jack" then 10
    when "Queen" then 10
    when "King" then 10
    when "Ace" then ace_to_value
    else face
    end
  end

  def ace_to_value
    if @total_hand_value + 11 > HAND_VALUE_LIMIT
      1
    else
      11
    end
  end

  def bust?
    @total_hand_value > HAND_VALUE_LIMIT
  end
end

class Dealer < Player
  DEALER_TOTAL_MINIMUM = 17

  def hand_total_below_minimum?
    total_hand_value < DEALER_TOTAL_MINIMUM
  end
end

class Game
  include Printable
  HIT = ['h', 'hit']
  STAY = ['s', 'stay']

  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new(" ")
    @dealer = Dealer.new(["Tom", "Jerry", "Roe"].sample)
  end

  def play
    prepare_player
    game_setup
    player_full_sequence
    dealer_full_sequence
    determine_winner
  end

  def prepare_player
    clear
    ask_for_name
    clear
    print_welcome_message
    print_game_rules
  end

  def game_setup
    deck.shuffle_cards
    deal_two_cards_to_all_players
    player.calculate_hand_value
    dealer.calculate_hand_value
    print_cards_in_hand(player)
    print_hand_total(player)
    print_one_of_dealers_cards
  end

  def deal_two_cards_to_all_players
    2.times do
      player.hand << hit
      dealer.hand << hit
    end
  end

  def ask_for_name
    print_ask_user_name
    answer = nil
    loop do
      answer = gets.chomp
      break if answer.downcase =~ /[a-zA-Z]/
      print_invalid_answer
    end
    player.name = answer
  end

  def ask_hit_or_stay
    answer = nil
    loop do
      print_hit_or_stay
      answer = gets.chomp
      break if (HIT + STAY).include?(answer)
      print_invalid_answer
    end
    answer
  end

  def hit
    deck.deal_one_card
  end

  def player_busted?(player)
    if player.total_hand_value > Player::HAND_VALUE_LIMIT
      player.busted = true
    else
      false
    end
  end

  def player_full_sequence
    loop do
      answer = ask_hit_or_stay
      break if STAY.include?(answer)
      if HIT.include?(answer)
        player_hit_sequence
        break if player_busted?(player)
      end
    end
  end

  def player_hit_sequence
    player.hand << hit
    print_player_draws_card(player.hand.last, player)
    print_cards_in_hand(player)
    player.calculate_hand_value
    print_hand_total(player)
  end

  def dealer_full_sequence
    return if player_busted?(player)
    print_dealers_turn
    print_dealer_hand_reveal
    print_cards_in_hand(dealer)
    dealer_play_loop
  end

  def dealer_play_loop
    loop do
      return if player_busted?(dealer)
      if dealer.hand_total_below_minimum?
        dealer_hit_sequence
      else
        print_dealer_stays
        break
      end
    end
  end

  def dealer_reveals_hand
    print_cards_in_hand(dealer)
    print_hand_total(dealer)
  end

  def dealer_hit_sequence
    dealer.hand << hit
    print_player_draws_card(dealer.hand.last, dealer)
    print_cards_in_hand(dealer)
    dealer.calculate_hand_value
  end

  def determine_winner
    return print_busted(player) if player_busted?(player)
    return print_busted(dealer) if player_busted?(dealer)
    compare_hands_print_winner
  end

  def compare_hands_print_winner
    if player.total_hand_value == dealer.total_hand_value
      print_winner
    elsif player.total_hand_value > dealer.total_hand_value
      print_winner(player)
    else
      print_winner(dealer)
    end
  end
end

game = Game.new
game.play
