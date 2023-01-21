//
//  Transaction.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/20/23.
//

import SwiftUI

// MARK: Expense Model with Sample Data
struct Transaction: Identifiable{
    var id: UUID = .init()
    var amountSpent: String
    var product: String
    var productIcon: String
    var spendType: String
}

var transactions: [Transaction] = [
    Transaction(amountSpent: "10", product: "Walk", productIcon: "walk", spendType: "Received"),
    Transaction(amountSpent: "3", product: "Gave Medicine", productIcon: "pills", spendType: "Sent"),
    Transaction(amountSpent: "25", product: "Went to Vet", productIcon: "vet", spendType: "Received"),
    Transaction(amountSpent: "5", product: "Wake Up with Dog", productIcon: "wakeup", spendType: "Sent"),
    Transaction(amountSpent: "15", product: "Went to Park", productIcon: "park", spendType: "Sent"),
    Transaction(amountSpent: "5", product: "Played with Dog", productIcon: "play", spendType: "Received"),
    Transaction(amountSpent: "10", product: "Brushed Hair", productIcon: "comb", spendType: "Received"),
    Transaction(amountSpent: "10", product: "Brushed Teeth", productIcon: "brushedteeth", spendType: "Sent"),
    Transaction(amountSpent: "20", product: "Bath", productIcon: "bath", spendType: "Received"),
    Transaction(amountSpent: "2", product: "Feed Dog", productIcon: "food", spendType: "Received"),
    Transaction(amountSpent: "2", product: "Fill Water", productIcon: "water", spendType: "Sent"),
    Transaction(amountSpent: "12", product: "Late Night Wake Ups", productIcon: "night", spendType: "Received")
]
