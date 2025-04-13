//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Ilya Shcherbakov on 13.04.2025.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func disableButtons()
    func enableButtons()
    func resetBorder()
    func impact()
    func showResults(quiz result: QuizResultsViewModel)
}
