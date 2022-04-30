require 'pry'
class Deck
  SUITS = %w(H S D C)
  VALUES = [2,3,4,5,6,7,8,9,10,'J','Q','K','A']

  attr_reader :deck

  def initialize

    @deck = SUITS.each_with_object([]) do |suit,array|
      VALUES.each do |value|
        array << [value, suit]
      end
    end.shuffle

  end
end

deck = Deck.new 
p deck.new_deck





# ----------
class Participant
  # cards 
  # hit
  # total value of hand
  # stay
  # busted? 
end

class Dealer < Participant
  # 17? - check to see if hand total is 17 or less
end

class Player < Participant
  
end

class Deck
  # create the deck 
  # shuffle the deck
  # converts value of face cards to numbers 
    # accounts for aces - checks to see if the ace was 11, if it causes player to bust
    # if bust, then ace is valued at 1
  # deal - deal to both dealer and participant
end

class Game 
  # deal hands
  # display hands to player (only one card of dealer hand)
  # ask player to hit or stay
  # repeat until player busts or stays
  # reveal dealers full hand
  # dealer hits if hand value is less than 17, stays if 17 and over
  # repeat until dealer busts or is within 17 - 21 range
  # display to player who wins and their winning hand 
end