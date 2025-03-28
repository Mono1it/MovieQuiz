//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Ilya Shcherbakov on 19.03.2025.
//

import Foundation
import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didAlertButtonTouch(alert: UIAlertController?)
}
