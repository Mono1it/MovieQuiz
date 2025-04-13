//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ilya Shcherbakov on 13.04.2025.
//
import UIKit
import Foundation

final class MovieQuizPresenter {
    // MARK: - Properties
    private var currentQuestionIndex: Int = .zero
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    private let generator = UIImpactFeedbackGenerator(style: .heavy) // Генератор тактильной отдачи
    
    // MARK: - IB Actions
    
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    func yesButtonClicked() {
        self.generator.impactOccurred() // Вибрация
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    func noButtonClicked() {
        self.generator.impactOccurred() // Вибрация
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    // MARK: - Methods
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
}
