//
//  AuthService.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/19/23.
//

import FirebaseAuth

class AuthService {
    static func createUser(credentials: UserCredentials, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
}
