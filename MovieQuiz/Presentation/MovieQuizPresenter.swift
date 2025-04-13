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
    private var currentQuestionIndex: Int = .zero
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    //private let statisticService: StatisticService = StatisticServiceImplementation()
    private let generator = UIImpactFeedbackGenerator(style: .heavy) // Генератор тактильной отдачи
    var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewController) {
            self.viewController = viewController
            
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
        self.generator.impactOccurred() // Вибрация
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
        }
    
    // MARK: - Iternal Methods
    
    // логика перехода в один из сценариев
    func showNextQuestionOrResults() {
        guard let viewController = viewController else { return }
        if self.isLastQuestion() {
            viewController.statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            // идём в состояние "Результат квиза"
            let result = QuizResultsViewModel(title: "Этот раунд окончен!", text: """
                                              Ваш результат: \(correctAnswers)/\(self.questionsAmount)
                                              Количество сыграный квизов: \(viewController.statisticService.gamesCount)
                                              Рекорд: \(viewController.statisticService.bestGame.correct)/\(viewController.statisticService.bestGame.total) (\(viewController.statisticService.bestGame.date.dateTimeString))
                                              Средняя точность: \(String(format: "%.2f", viewController.statisticService.totalAccuracy))%
                                              """, buttonText: "Сыграть ещё раз")
            viewController.showResults(quiz: result)
        } else {
            self.switchToNextQuestion()
            // идём в состояние "Вопрос показан"
            viewController.imageView.layer.borderColor = UIColor.clear.cgColor
            questionFactory?.requestNextQuestion()
        }
        viewController.yesButton.isEnabled = true
        viewController.noButton.isEnabled = true
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0 //  обнуляем счётчик правильных ответов
        viewController?.imageView.layer.borderColor = UIColor.clear.cgColor // делаем границу прозрачной
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
