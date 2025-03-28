//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Ilya Shcherbakov on 19.03.2025.
//

import Foundation
import UIKit

final class AlertPresenter: AlertPresenterProtocol{

    weak var viewController: (UIViewController&AlertPresenterDelegate)?
    
    init(_ viewController: UIViewController&AlertPresenterDelegate) {
        self.viewController = viewController
    }
    
    func requestAlertPresenter(model: AlertModel?) {
        guard let model else { return }
        let alert = UIAlertController(title: model.title, // заголовок всплывающего окна
                                      message: model.message, // текст во всплывающем окне
                                      preferredStyle: .alert)
        // настраиваем кнопку действия для начала новой игры
        let action = UIAlertAction(title: model.buttonText, style: .default) {[weak self]_ in
            self?.viewController?.didAlertButtonTouch(alert: alert)
        }
        // добавляем в алерт кнопку
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}
