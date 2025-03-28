//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Ilya Shcherbakov on 16.03.2025.
//
import UIKit
import Foundation

struct QuizStepViewModel {
    // картинка с афишей фильма с типом UIImage
    let image: UIImage
    // вопрос о рейтинге квиза
    let question: String
    // строка с порядковым номером этого вопроса (ex. "1/10")
    let questionNumber: String
}
