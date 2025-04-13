import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    private let generator = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: - Private Properties
    
    private lazy var alertPresenter = AlertPresenter(self)
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
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
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }

    func resetBorder() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func impact() {
        self.generator.impactOccurred()
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
