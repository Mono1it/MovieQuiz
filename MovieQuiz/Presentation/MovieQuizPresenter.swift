//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ilya Shcherbakov on 13.04.2025.
//
import UIKit
import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Properties
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceImplementation!
    
    private var correctAnswers: Int = .zero
    private var currentQuestionIndex: Int = .zero
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Initializer
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - IB Actions
    
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        // проверка, что вопрос не nil
        currentQuestion = question
        // конвертируем вопрос во вью модель
        let quizStepViewModel = convert(model: question)
        // показываем вопрос на экране
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: quizStepViewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator() // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        viewController?.impact() // Вибрация
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    // MARK: - Iternal Methods
    
    // метод, который меняет цвет рамки
    func proceedWithAnswer(isCorrect: Bool) {
        viewController?.disableButtons()
        if isCorrect {
            viewController?.highlightImageBorder(isCorrectAnswer: isCorrect) // делаем рамку зелёной
            correctAnswers += 1
        } else {
            viewController?.highlightImageBorder(isCorrectAnswer: isCorrect) // делаем рамку красной
        }
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    // логика перехода в один из сценариев
    private func proceedToNextQuestionOrResults() {
        guard let viewController = viewController else { return }
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            // идём в состояние "Результат квиза"
            let result = QuizResultsViewModel(title: "Этот раунд окончен!", text: """
                                              Ваш результат: \(correctAnswers)/\(self.questionsAmount)
                                              Количество сыграный квизов: \(statisticService.gamesCount)
                                              Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                                              Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                                              """, buttonText: "Сыграть ещё раз")
            viewController.showResults(quiz: result)
        } else {
            self.switchToNextQuestion()
            // идём в состояние "Вопрос показан"
            viewController.resetBorder()
            questionFactory?.requestNextQuestion()
        }
        viewController.enableButtons()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0 //  обнуляем счётчик правильных ответов
        viewController?.resetBorder() // делаем границу прозрачной
        guard let questionFactory = self.questionFactory else { return }
        viewController?.showLoadingIndicator()
        questionFactory.loadData()
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
