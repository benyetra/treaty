//
//  TransactionType.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/20/23.
//

import SwiftUI

// MARK: Expense Model with Sample Data
struct TransactionType: Identifiable{
    var id: UUID = .init()
    var amountSpent: Int
    var product: String
    var productIcon: String
}

var types: [TransactionType] = [
    TransactionType(amountSpent: 10, product: "Walk", productIcon: "walk"),
    TransactionType(amountSpent: 3, product: "Gave Medicine", productIcon: "pills"),
    TransactionType(amountSpent: 25, product: "Went to Vet", productIcon: "vet"),
    TransactionType(amountSpent: 5, product: "Wake Up with Dog", productIcon: "wakeup"),
    TransactionType(amountSpent: 15, product: "Went to Park", productIcon: "park"),
    TransactionType(amountSpent: 5, product: "Played with Dog", productIcon: "play"),
    TransactionType(amountSpent: 10, product: "Brushed Hair", productIcon: "comb"),
    TransactionType(amountSpent: 10, product: "Brushed Teeth", productIcon: "brushedteeth"),
    TransactionType(amountSpent: 20, product: "Bath", productIcon: "bath"),
    TransactionType(amountSpent: 2, product: "Feed Dog", productIcon: "food"),
    TransactionType(amountSpent: 2, product: "Fill Water", productIcon: "water"),
    TransactionType(amountSpent: 12, product: "Late Night Wake Ups", productIcon: "night")
]
