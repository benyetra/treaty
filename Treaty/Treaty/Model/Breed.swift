//
//  Breed.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/19/23.
//

import SwiftUI

struct Breed: Decodable {
    let id: Int
    let name: String
    let temperament: String?
    let origin: String?
    let lifeSpan: String?
    let weight: Weight?
    let height: Height?
    let bredFor: String?
    let breedGroup: String?
    let image: Image?
    
    struct Weight: Decodable {
        let imperial: String
        let metric: String
    }
    
    struct Height: Decodable {
        let imperial: String
        let metric: String
    }
    
    struct Image: Decodable {
        let url: URL
    }
}

