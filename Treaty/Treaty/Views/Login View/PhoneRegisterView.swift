//
//  PhoneRegisterView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI

struct PhoneRegisterView: View {
    @StateObject var loginModel: LoginViewModel = .init()
    var body: some View {
        // MARK: Custom TextField
        CustomTextField(hint: "+1 6505551234", text: $loginModel.mobileNo)
            .disabled(loginModel.showOTPField)
            .opacity(loginModel.showOTPField ? 0.4 : 1)
            .overlay(alignment: .trailing, content: {
                Button("Change"){
                    withAnimation(.easeInOut){
                        loginModel.showOTPField = false
                        loginModel.otpCode = ""
                        loginModel.CLIENT_CODE = ""
                    }
                }
                .font(.caption)
                .foregroundColor(.indigo)
                .opacity(loginModel.showOTPField ? 1 : 0)
                .padding(.trailing,15)
            })
            .padding(.top,50)
        
        CustomTextField(hint: "OTP Code", text: $loginModel.otpCode)
            .disabled(!loginModel.showOTPField)
            .opacity(!loginModel.showOTPField ? 0.4 : 1)
            .padding(.top,20)
        
        Button(action: loginModel.showOTPField ? loginModel.verifyOTPCode : loginModel.getOTPCode) {
            HStack(spacing: 15){
                Text(loginModel.showOTPField ? "Verify Code" : "Get Code")
                    .fontWeight(.semibold)
                    .contentTransition(.identity)
                
                Image(systemName: "line.diagonal.arrow")
                    .font(.title3)
                    .rotationEffect(.init(degrees: 45))
            }
            .foregroundColor(.black)
            .padding(.horizontal,25)
            .padding(.vertical)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.black.opacity(0.05))
            }
        }
        .padding(.top,30)    }
}

struct PhoneRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneRegisterView()
    }
}
