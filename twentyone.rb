require 'pry'
class Deck
  SUITS = %w(H S D C)
  VALUES = [2,3,4,5,6,7,8,9,10,'J','Q','K','A']

  attr_reader :all_cards

  def initialize
    @all_cards = SUITS.each_with_object([]) do |suit,array|
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
  attr_reader :hand, :name 
  def initialize(name)
    @hand = []
    @name = name
  end

  def show_hand
    puts "#{name} has"
    self.hand.each do |value, suit|
      puts "The #{value} of #{suit}."
    end
  end



  # cards 
  # hit
  # total value of hand
    # converts value of face cards to numbers 
    # accounts for aces - checks to see if the ace was 11, if it causes player to bust
    # if bust, then ace is valued at 1
  # stay
  # busted? 
end

class Dealer < Participant
  def show_one_card_of_hand
    revealed_card = self.hand[0]
    puts "#{name} has a #{revealed_card[0]} of #{revealed_card[1]} and one hidden card."
  end
  # 17? - check to see if hand total is 17 or less
end

class Player < Participant

end

class Game
  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new 
    @player = Player.new("Tom")
    @dealer = Dealer.new("Jerry")
  end

  def deal_hands 
    2.times {player.hand << deck.deal_one_card}
    2.times {dealer.hand << deck.deal_one_card}
  end

  def play 
    deck.shuffle_cards
    deal_hands
    player.show_hand
    dealer.show_one_card_of_hand
    ask_hit_or_stay
    player_hits 
    player.show_hand
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

  def player_hits
    player.hand << deck.deal_one_card
  end




  # deal hands
  # display player's hands and only one card of dealer hand
  # ask player to hit or stay
  # repeat until player busts or stays
  # reveal dealers full hand
  # dealer hits if hand value is less than 17, stays if 17 and over
  # repeat until dealer busts or is within 17 - 21 range
  # display to player who wins and their winning hand 
end

game = Game.new
game.play 





