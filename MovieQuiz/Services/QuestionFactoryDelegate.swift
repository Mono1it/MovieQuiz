//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ilya Shcherbakov on 18.03.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
