import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    
    // MARK: - Private Properties
    
    private lazy var alertPresenter = AlertPresenter(self)
    let statisticService: StatisticService = StatisticServiceImplementation()
    private var presenter: MovieQuizPresenter!
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        
        presenter.viewController = self
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
        presenter.questionFactory?.requestNextQuestion()
    }
    
    // MARK: - IB Actions
    
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - AlertPresentorDelegate
    
    func didAlertButtonTouch(alert: UIAlertController?) {
        presenter.restartGame()   //  обнуляем индекс вопроса
    }
    
    // MARK: - Private Methods

    func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз", completion: {})
        alertPresenter.requestAlertPresenter(model: model)
    }
    
    // метод вывода на экран вопроса
    func show(quiz step: QuizStepViewModel) {
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
            presenter.correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor // делаем рамку красной
        }
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            //self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    // метод для показа результатов раунда квиза
    func showResults(quiz result: QuizResultsViewModel) {
        //  создаём модель для AlertPresenter
        let alertModel: AlertModel = AlertModel(title: result.title,
                                                message: result.text,
                                                buttonText: result.buttonText, completion: {})
        alertPresenter.requestAlertPresenter(model: alertModel)
    }
}
