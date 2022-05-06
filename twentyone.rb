require 'pry'
class Deck
  SUITS = %w(H S D C)
  VALUES = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A']

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
  attr_reader :hand, :name, :total_hand_value

  def initialize(name)
    @hand = []
    @name = name
    @total_hand_value = 0
  end

  def calculate_hand_value
    @total_hand_value = 0
    hand.each do |cards|
      @total_hand_value += card_to_value(cards)
    end
  end

  def display_hand_total
    puts "#{name}'s cards total to #{@total_hand_value} "
  end

  def card_to_value(card)
    face = card.first
    case face
    when "J" then 10
    when "Q" then 10
    when "K" then 10
    when "A" then ace_to_value
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

  def show_cards_in_hand
    puts "#{name} has"
    hand.each do |value, suit|
      puts "The #{value} of #{suit}."
    end
  end

  def bust?
    @total_hand_value > HAND_VALUE_LIMIT
  end
end

class Dealer < Player
  DEALER_TOTAL_MINIMUM = 17

  def show_one_card_of_hand
    revealed_card = hand[0]
    puts "#{name} has a #{revealed_card[0]} of #{revealed_card[1]} and one hidden card."
  end

  def hand_total_below_minimum?
    total_hand_value < DEALER_TOTAL_MINIMUM
  end
end

class Game
  HIT = ['hit', 'h']
  STAY = ['stay', 's']
  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new("Player")
    @dealer = Dealer.new("Dealer")
    @player_busted = false
    @dealer_busted = false
  end

  def deal_two_cards_to_all_players
    2.times do
      player.hand << hit
      dealer.hand << hit
    end
  end

  def play
    game_setup
    player_full_sequence
    dealer_full_sequence
    determine_winner
  end

  def game_setup
    deck.shuffle_cards
    deal_two_cards_to_all_players
    player.calculate_hand_value
    dealer.calculate_hand_value
    player.show_cards_in_hand
    player.display_hand_total
    dealer.show_one_card_of_hand
  end

  def hit
    deck.deal_one_card
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
        hit_sequence
        break if player_busted?
      end
    end
  end

  def hit_sequence
    player.hand << hit
    player.show_cards_in_hand
    player.calculate_hand_value
    player.display_hand_total
  end

  def dealer_full_sequence
    return if player_busted?
    dealer_reveals_hand
    loop do
      return puts "Dealer busted with a hand of #{dealer.total_hand_value}!" if dealer_busted?
      if dealer.hand_total_below_minimum?
        dealer_hit_sequence
      else
        dealer_stays_message
        break
      end
    end
  end

  def dealer_stays_message 
    puts "Dealer stays with a total value of #{dealer.total_hand_value}."
  end

  def dealer_reveals_hand
    dealer.show_cards_in_hand
    dealer.display_hand_total
  end

  def dealer_hit_sequence
    dealer.hand << hit
    dealer.show_cards_in_hand
    dealer.calculate_hand_value
  end

  def ask_hit_or_stay
    answer = nil
    loop do
      puts "Would you like to hit or stay? Type: (h)it or (s)tay"
      answer = gets.chomp
      break if %w(h hit s stay).include?(answer)
      puts "Sorry, that's not a valid answer."
    end
    answer
  end

  def determine_winner
    return puts "Sorry you busted! You lose" if player_busted?
    return puts "Dealer busted! You win!" if dealer_busted?
    if player.total_hand_value == dealer.total_hand_value
      puts "It's a tie!"
    elsif player.total_hand_value > dealer.total_hand_value
      puts "Player wins!"
    else
      puts "Dealer wins!"
    end
  end
end

game = Game.new
game.play
