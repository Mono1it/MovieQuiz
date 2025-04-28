//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Ilya Shcherbakov on 09.04.2025.
//

import Foundation
import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    
    func testGetValueTest() throws {
        // Given
        let array = [1,2,3,4,5,6]

        // When
        let value = array[safe: 3]
   
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 4)
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1,2,3,4,5,6]
     
        // When
        let value = array[safe: 10]
      
        // Then
        XCTAssertNil(value)
    }
}
