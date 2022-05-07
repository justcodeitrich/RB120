require 'pry'

module Printable
  def press_any_key
    puts "Press any key to continue."
    gets.chomp
  end

  def clear
    system('clear')
  end

  def print_player_draws_card(drawn_card, player)
    puts "#{player.name} draws a #{drawn_card.first} of #{drawn_card.last}."
  end

  def print_dealers_turn
    puts "Dealer's turn!"
  end

  def print_dealer_hand_reveal
    hidden_card = dealer.hand.last
    puts "#{dealer.name} flips over the hidden card: A #{hidden_card.first} of #{hidden_card.last}!"
  end

  def print_dealer_stays
    puts "#{dealer.name} stays with a total value of #{dealer.total_hand_value}."
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

  def print_one_of_dealers_cards
    revealed_card = dealer.hand[0]
    puts "#{dealer.name} has a #{revealed_card[0]} of #{revealed_card[1]} and one hidden card."
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
  attr_accessor :name

  def initialize(name)
    @hand = []
    @name = name + " the dealer"
    @total_hand_value = 0
  end

  def calculate_hand_value
    @total_hand_value = 0
    hand.each do |cards|
      @total_hand_value += card_to_value(cards)
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
  HIT = ['hit', 'h']
  STAY = ['stay', 's']
  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new(" ")
    @dealer = Dealer.new(["Tom", "Jerry", "Roe"].sample)
    @player_busted = false
    @dealer_busted = false
  end

  def play
    player.name = ask_for_name
    game_setup
    player_full_sequence
    dealer_full_sequence
    determine_winner
  end

  def game_setup
    clear
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

  def ask_hit_or_stay
    answer = nil
    loop do
      print_hit_or_stay
      answer = gets.chomp
      break if %w(h hit s stay).include?(answer)
      print_invalid_answer
    end
    answer
  end

  def hit
    deck.deal_one_card
  end

  def player_busted?(player)
    if player.total_hand_value > Player::HAND_VALUE_LIMIT
      @player_busted = true
    else
      false
    end
  end

  def player_busted?
    if player.total_hand_value > Player::HAND_VALUE_LIMIT
      @player_busted = true
    else
      false
    end
  end

  def dealer_busted?
    if dealer.total_hand_value > Player::HAND_VALUE_LIMIT
      @dealer_busted = true
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
        break if player_busted?
      end
    end
  end

  def player_hit_sequence
    player.hand << hit
    hit_message(player)
    print_cards_in_hand(player)
    player.calculate_hand_value
    print_hand_total(player)
  end

  def dealer_full_sequence
    return if player_busted?
    print_dealers_turn
    print_dealer_hand_reveal
    dealer_play_loop
  end

  def dealer_play_loop
    loop do
      return if dealer_busted?
      if dealer.hand_total_below_minimum?
        dealer_hit_sequence
      else
        print_dealer_stays
        break
      end
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
    answer
  end

  def hit_message(player)
    drawn_card = player.hand.last
    print_player_draws_card(drawn_card, player)
    press_any_key
    clear
  end

  def dealer_reveals_hand
    print_cards_in_hand(dealer)
    print_hand_total(dealer)
  end

  def dealer_hit_sequence
    dealer.hand << hit
    hit_message(dealer)
    print_cards_in_hand(dealer)
    dealer.calculate_hand_value
  end

  def determine_winner
    return print_busted(player) if player_busted?
    return print_busted(dealer) if dealer_busted?
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
