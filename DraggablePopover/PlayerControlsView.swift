//
//  PlayerControlsView.swift
//  DraggablePopover
//
//  Created by iurii iaremenko on 02.11.2024.
//

import Foundation
import SwiftUI

// Mock view to show controls
struct PlayerControlsView: View {
    var body: some View {
        HStack(spacing: 50) {
            Button(action: {
                // Action for backward button
            }) {
                Image(systemName: "backward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .padding()
                    .background(Circle().fill(Color.gray.opacity(0.2)))
            }

            Button(action: {
                // Action for pause button
            }) {
                Image(systemName: "pause.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                    .padding()
                    .background(Circle().fill(Color.gray.opacity(0.2)))
            }

            Button(action: {
                // Action for forward button
            }) {
                Image(systemName: "forward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .padding()
                    .background(Circle().fill(Color.gray.opacity(0.2)))
            }
        }
        .accentColor(.white)
    }
}
