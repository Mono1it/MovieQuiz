//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Ilya Shcherbakov on 25.03.2025.
//

import Foundation

final class StatisticServiceImplementation: StatisticService {
    
    private let defaults = UserDefaults.standard
    
    private var correctAnswers: Int {
        get {
            return defaults.integer(forKey: Keys.totalCorrect.rawValue)
        }
        set{
            defaults.set(newValue, forKey: Keys.totalCorrect.rawValue)
        }
    }
    
    var gamesCount: Int{
        get {
            return defaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            defaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get{
            let correct = defaults.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = defaults.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = defaults.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set{
            defaults.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            defaults.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            defaults.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            let totalGames: Int = gamesCount
            let totalCorrect: Int = correctAnswers
            if totalGames > 0 {
                return Double(totalCorrect)/Double(10 * totalGames) * 100
            } else {
                return 0
            }
        }
    }
    
    private enum Keys: String {
        case bestGameCorrect
        case bestGameTotal
        case gamesCount
        case bestGameDate
        case totalCorrect
    }
    
    func store(correct: Int, total: Int) {
        let currentGame = GameResult(correct: correct, total: total, date: Date())
        if currentGame.isBetterThan(bestGame) {
            bestGame = currentGame
        }
        gamesCount += 1
        correctAnswers += correct
    }
}
