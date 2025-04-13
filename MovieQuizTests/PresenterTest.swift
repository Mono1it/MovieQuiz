//
//  PresenterTest.swift
//  MovieQuizTests
//
//  Created by Ilya Shcherbakov on 13.04.2025.
//

import Foundation
import UIKit

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func impact() {
        
    }
    
    func disableButtons() {
        
    }
    
    func enableButtons() {
        
    }
    
    func resetBorder() {
        
    }
    
    
    func showResults(quiz result: MovieQuiz.QuizResultsViewModel) {
        
    }
    
    func show(quiz step: QuizStepViewModel) {
    
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
    
    }
    
    func showLoadingIndicator() {
    
    }
    
    func hideLoadingIndicator() {
    
    }
    
    func showNetworkError(message: String) {
    
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
