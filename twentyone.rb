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

# ----------
class Participant
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
    when "A" then ace_to_value(face)
    else face
    end
    # returns a number
  end

  def ace_to_value
    if @total_hand_value + 11 > 21
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
    @total_hand_value > 21
  end
end

class Dealer < Participant
  DEALER_TOTAL_MINIMUM = 17

  def show_one_card_of_hand
    revealed_card = hand[0]
    puts "#{name} has a #{revealed_card[0]} of #{revealed_card[1]} and one hidden card."
  end

  def hand_total_below_minimum?
    total_hand_value < DEALER_TOTAL_MINIMUM
  end
end

class Player < Participant
end

class Game
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
    player_sequence
    dealer_sequence
    determine_winner
  end

  def game_setup
    deck.shuffle_cards
    deal_two_cards_to_all_players
    player.show_cards_in_hand
    player.calculate_hand_value
    dealer.calculate_hand_value
    player.display_hand_total
    dealer.show_one_card_of_hand
  end

  def hit
    deck.deal_one_card
  end

  def player_busted?
    @player_busted
  end

  def dealer_busted?
    @dealer_busted
  end

  def player_sequence
    loop do
      answer = ask_hit_or_stay
      break if answer == "s" || answer == "stay"
      if answer == "h" || answer == "hit"
        player.hand << hit # give player card
        player.show_cards_in_hand
        player.calculate_hand_value # calculate new total
        player.display_hand_total # display total value
        if player.bust?
          @player_busted = true
          break
          # sorry you lose with a hand over 21 - break out of game to the end
        end
      end
      # loops back to ask_hit_or_stay
    end
  end

  def dealer_sequence
    return if player_busted?
    dealer.show_cards_in_hand
    dealer.display_hand_total
    loop do
      if dealer.bust?
        @dealer_busted = true
        puts "dealer busted with a hand of #{dealer.total_hand_value}!"
        break
      elsif dealer.hand_total_below_minimum?
        dealer.hand << hit
        dealer.show_cards_in_hand
        dealer.calculate_hand_value
      else
        puts "Dealer stays with a final hand is a value of #{dealer.total_hand_value}."
        break
      end
    end
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
