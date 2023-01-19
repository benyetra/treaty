//
//  BarterView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI

struct BarterView: View {
    @ObservedObject var credentials = UserCredentials()
    @AppStorage("user_name") var userName: String = ""

    var body: some View {
        if userName.isEmpty {
            UserNameView().environmentObject(credentials)
        } else {
            Text("Hello World")
        }
    }
}

struct BarterView_Previews: PreviewProvider {
    static var previews: some View {
        BarterView()
    }
}
