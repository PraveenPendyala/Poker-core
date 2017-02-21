//: Poker - noun: a card game played by two or more people who bet on the value of the hands dealt to them.

import UIKit

// ♥️♣️♦️♠️ //

/*
 
 The first challenge for any novice poker player is figuring out how to evaluate any given hand, and understanding how strong it is within the spectrum of all possible hands.

 Your task: write a method that accepts as input an array of 7 arbitrary cards (from a standard 52-card deck) and returns the best 5-card poker hand, as well as the name of that hand


 For example, an input of [8♦ 3♠ 5♦ 8♣ J♦ 3♦ 2♦] should return the output [J♦ 8♦ 5♦ 3♦ 2♦] and "Flush"
 See https://en.wikipedia.org/wiki/List_of_poker_hand_categories for a list and ranking of poker hands
 
 */

public extension Sequence {
  
  /// Categorises elements of self into a dictionary, with the keys given by keyFunc
  
  func categorise<U : Hashable>(keyFunc: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
    var dict: [U:[Iterator.Element]] = [:]
    for el in self {
      let key = keyFunc(el)
      if case nil = dict[key]?.append(el) { dict[key] = [el] }
    }
    return dict
  }
}

let A = 14, K = 13, Q = 12, J = 11

enum Suit {
  case Club
  case Diamond
  case Heart
  case Spade
}

class Card: Hashable, Equatable {
  let rank: Int
  let suit: Suit
  var hashValue: Int { get { return rank.hashValue } }
  
  init(rank: Int, suit: Suit) {
    self.rank = rank
    self.suit = suit
  }
  
  static func ==(lhs: Card, rhs: Card) -> Bool {
    return lhs.rank == rhs.rank
  }
}

let inputCards = [Card.init(rank: J, suit: .Club),
                  Card.init(rank: Q, suit: .Heart),
                  Card.init(rank: 7, suit: .Diamond),
                  Card.init(rank: 6, suit: .Diamond),
                  Card.init(rank: 2, suit: .Club),
                  Card.init(rank: K, suit: .Diamond),
                  Card.init(rank: 3, suit: .Diamond)]

// Get the cards with Highest Count
func getHighestCountCards(cardsDict: [Int: [Card]]) -> Int {
  var highestCountRank  = 0
  var highestCount = 0
  for (rank, cards) in cardsDict {
    if cards.count > highestCount || (cards.count == highestCount && rank > highestCountRank){
      highestCount = cards.count
      highestCountRank = rank
    }
  }
  return highestCountRank
}

// Straight or StraightFlush
func determineIfSequence(cards: [Card], StraightFlush: Bool) -> (String, [Card]){
  var count = 0
  var handName = ""
  var bestCards = [Card]()
  var sortedCards = cards.sorted { $0.rank > $1.rank }
  for i in 1..<sortedCards.count {
    if sortedCards[i-1].rank == sortedCards[i].rank + 1 {
      count = count + 1
      if count == 4 {
        handName = StraightFlush ? "Straight Flush" : "Straight"
        bestCards = Array(sortedCards[i-4..<i+1])
        return (handName, bestCards)
      }
    }
    else {
      count = 0
    }
  }
  return (handName, bestCards)
}

// Complete the Poker Hand with remaining single cards
func fillRemainingHand(sortedCards: [Card], remainigCards: [Int: [Card]], count: Int) -> [Card]{
  var cards = [Card]()
  var remainingCount = count
  for card in sortedCards {
    if (remainigCards[card.rank] != nil) && remainingCount > 0 {
      cards.append(card)
      remainingCount = remainingCount - 1
    }
  }
  return cards
}

// Deduplicated sorted cards
func getDeduplicatedCards(inputCards: [Card]) -> [Card] {
  return Array(Set(inputCards))
}

// get the best 5 Poker Hand
func getBest5PokerHand(inputCards: [Card]) -> (String, [Card]) {
  
  var best5PokerHand = [Card]()
  var bestHandName = ""

  let cardsGroupByRank = inputCards.categorise{ $0.rank }
  let cardsGroupBySuit = inputCards.categorise{ $0.suit }
  let cardsSortedByRank = inputCards.sorted { $0.rank > $1.rank }
  
  // flush or straight flush
  for (_, cards) in cardsGroupBySuit {
    var sortedCards = cards.sorted{ $0.rank > $1.rank }
    if sortedCards.count > 4 {
      (bestHandName, best5PokerHand) = determineIfSequence(cards: sortedCards, StraightFlush: true)
      if bestHandName == "" {
        bestHandName = "Flush"
        best5PokerHand = Array(sortedCards[0..<5])
      }
      break
    }
  }
  
  if bestHandName == "" {
    
    let highestCountRank = getHighestCountCards(cardsDict: cardsGroupByRank)
    best5PokerHand = cardsGroupByRank[highestCountRank]!
    
    var remainingCards = cardsGroupByRank
    remainingCards.removeValue(forKey: highestCountRank)
    
    let deDuplicatedCards = getDeduplicatedCards(inputCards: inputCards)
    
    switch best5PokerHand.count {
    case 4:
      bestHandName = "Four of a kind"
      best5PokerHand.append(contentsOf: fillRemainingHand(sortedCards: cardsSortedByRank,
                                                        remainigCards: remainingCards,
                                                                count: 1))
      break
    case 3:
      let secondHighestCountRank = getHighestCountCards(cardsDict: remainingCards)
      let secondHighestCards = cardsGroupByRank[secondHighestCountRank]!
      if secondHighestCards.count > 1 {
        bestHandName = "Full House"
        best5PokerHand.insert(contentsOf: secondHighestCards[0..<2], at: 3)
      }
      else {
        let (handName, best5) = determineIfSequence(cards: deDuplicatedCards, StraightFlush: false)
        if handName == "" {
          bestHandName = "Three of a kind"
          best5PokerHand.append(contentsOf: fillRemainingHand(sortedCards: cardsSortedByRank,
                                                            remainigCards: remainingCards,
                                                                    count: 2))
        }
        else {
          best5PokerHand = best5
          bestHandName = handName
        }
      }
      break
    case 2:
      let (handName, best5) = determineIfSequence(cards: deDuplicatedCards, StraightFlush: false)
      if bestHandName == "" {
        let secondHighestCountRank = getHighestCountCards(cardsDict: remainingCards)
        let secondHighestCards = cardsGroupByRank[secondHighestCountRank]!
        if secondHighestCards.count > 1 {
          bestHandName = "Two Pair"
        }
        else {
          bestHandName = "One Pair"
        }
        best5PokerHand.append(contentsOf: fillRemainingHand(sortedCards: cardsSortedByRank,
                                                            remainigCards: remainingCards,
                                                            count: 3))
      }
      else {
        bestHandName = handName
        best5PokerHand = best5
      }
      break
    case 1:
      (bestHandName, best5PokerHand) = determineIfSequence(cards: inputCards, StraightFlush: false)
      if bestHandName == "" {
        best5PokerHand = Array(cardsSortedByRank[0..<5])
        bestHandName = "High card"
      }
    default:
      break
    }
  }
  return (bestHandName, best5PokerHand)
}

let (winningHand, winningCards) = getBest5PokerHand(inputCards: inputCards)
print("\(winningHand)")
for card in winningCards {
  print("Rank: \(card.rank), Suit: \(card.suit)")
}


