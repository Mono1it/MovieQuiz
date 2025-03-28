//
//  GameResultModel.swift
//  MovieQuiz
//
//  Created by Ilya Shcherbakov on 24.03.2025.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        if total <= 0 {
            return false
        } else if another.total <= 0 {
            return true
        } else {
            return Double(correct) / Double(total) > Double(another.correct) / Double(another.total)
        }
    }
}
