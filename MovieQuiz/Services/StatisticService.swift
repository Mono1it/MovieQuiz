//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Ilya Shcherbakov on 24.03.2025.
//

import Foundation

protocol StatisticService{
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct: Int, total: Int)
}
