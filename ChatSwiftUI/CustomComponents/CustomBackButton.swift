//
//  CustomBackButton.swift
//  ChatSwiftUI
//
//  Created by Tzy on 05.06.2022.
//

import SwiftUI

struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "chevron.left")
        }
    }
}
