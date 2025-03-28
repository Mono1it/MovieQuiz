//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Ilya Shcherbakov on 19.03.2025.
//

import Foundation

struct AlertModel {
    //текст заголовка алерта
    let title: String
    //текст сообщения алерта
    let message: String
    //текст для кнопки алерта
    let buttonText: String
    //замыкание без параметров для действия по кнопке алерта
    let completion: () -> Void
}
