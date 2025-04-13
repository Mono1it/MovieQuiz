import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    // MARK: - Private Properties
    
    // переменная со счётчиком правильных ответов
    private var correctAnswers: Int = .zero
    private lazy var alertPresenter = AlertPresenter(self)
    private let statisticService: StatisticService = StatisticServiceImplementation()

    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private let generator = UIImpactFeedbackGenerator(style: .heavy) // Генератор тактильной отдачи
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - IB Actions
    
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        // проверка, что вопрос не nil
        currentQuestion = question
        // конвертируем вопрос во вью модель
        let quizStepViewModel = presenter.convert(model: question)
        // показываем вопрос на экране
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: quizStepViewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator() // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - AlertPresentorDelegate
    
    func didAlertButtonTouch(alert: UIAlertController?) {
        presenter.resetQuestionIndex()   //  обнуляем индекс вопроса
        self.correctAnswers = 0 //  обнуляем счётчик правильных ответов
        self.imageView.layer.borderColor = UIColor.clear.cgColor // делаем границу прозрачной
        guard let questionFactory = self.questionFactory else { return }
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    // MARK: - Private Methods

    private func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз", completion: {})
        alertPresenter.requestAlertPresenter(model: model)
    }
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
//    private func convert(model: QuizQuestion) -> QuizStepViewModel {
//        let questionStep = QuizStepViewModel(
//            image: UIImage(data: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
//        return questionStep
//    }
    
    // приватный метод вывода на экран вопроса
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // метод, который меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
        // метод красит рамку
        yesButton.isEnabled = false
        noButton.isEnabled = false
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor // делаем рамку зелёной
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor // делаем рамку красной
        }
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // логика перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            // идём в состояние "Результат квиза"
            let result = QuizResultsViewModel(title: "Этот раунд окончен!", text: """
                                              Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                                              Количество сыграный квизов: \(statisticService.gamesCount)
                                              Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                                              Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                                              """, buttonText: "Сыграть ещё раз")
            showResults(quiz: result)
        } else {
            presenter.switchToNextQuestion()
            // идём в состояние "Вопрос показан"
            imageView.layer.borderColor = UIColor.clear.cgColor
            
            guard let questionFactory = self.questionFactory else { return }
            questionFactory.requestNextQuestion()
        }
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    // метод для показа результатов раунда квиза
    private func showResults(quiz result: QuizResultsViewModel) {
        //  создаём модель для AlertPresenter
        let alertModel: AlertModel = AlertModel(title: result.title,
                                                message: result.text,
                                                buttonText: result.buttonText, completion: {})
        alertPresenter.requestAlertPresenter(model: alertModel)
    }
}
