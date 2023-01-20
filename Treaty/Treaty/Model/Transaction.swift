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
    Transaction(amountSpent: "$128", product: "Amazon", productIcon: "Amazon", spendType: "Groceries"),
    Transaction(amountSpent: "$18", product: "Youtube", productIcon: "Youtube", spendType: "Streaming"),
    Transaction(amountSpent: "$10", product: "Dribbble", productIcon: "Dribbble", spendType: "Membership"),
    Transaction(amountSpent: "$28", product: "Apple", productIcon: "Apple", spendType: "Apple Pay"),
    Transaction(amountSpent: "$9", product: "Patreon", productIcon: "Patreon", spendType: "Membership"),
    Transaction(amountSpent: "$100", product: "Instagram", productIcon: "Instagram", spendType: "Ad Publish"),
    Transaction(amountSpent: "$55", product: "Netflix", productIcon: "Netflix", spendType: "Movies"),
    Transaction(amountSpent: "$348", product: "Photoshop", productIcon: "Photoshop", spendType: "Editing"),
    Transaction(amountSpent: "$99", product: "Figma", productIcon: "Figma", spendType: "Pro Member"),
]
