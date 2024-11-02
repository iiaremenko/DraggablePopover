//
//  ContentView.swift
//  DraggablePopover
//
//  Created by iurii iaremenko on 02.11.2024.
//

import SwiftUI

struct ContentView: View {
    @State var isPresented: Bool = true
    @State var popoverAlignment = Alignment(horizontal: .leading, vertical: .top)

    var body: some View {
        // Test if only isPresented changed, bit not @identity
//        let _ = Self._printChanges()

        VStack {
            Toggle("Show Popover", isOn: $isPresented)
                .padding([.horizontal, .top], 20)

            Color.green
                .opacity(0.3)
                .popoverDraggable(isPresented: $isPresented, alignment: $popoverAlignment) {
                    popoverView
                }
        }
        .ignoresSafeArea()

    }

    var popoverView: some View {
        ZStack {
            Color.black
                .cornerRadius(20)

            VStack {
                Spacer()
                PlayerControlsView()
                    .padding(.bottom)
            }
        }
        .frame(width: 450, height: 250)
        .padding()
    }
}

#Preview {
    ContentView()
}
