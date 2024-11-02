//
//  DraggablePopover.swift
//  DraggablePopover
//
//  Created by iurii iaremenko on 10.09.2022.
//

import Combine
import SwiftUI

public extension View {
    /// Adds a draggable popover to the view that sticks to the corners of the parent view, similar to Picture-in-Picture (PiP) behavior in iOS.
     ///
     /// The popover can be dragged around by the user and will snap to the nearest corner when released. Tapping outside the popover can trigger an optional action.
     ///
     /// - Parameters:
     ///   - isPresented: A binding to a Boolean value that determines whether the popover is presented.
     ///   - alignment: A binding to the `Alignment` that specifies the popover's position within the parent view.
     ///   - outsideTapped: An optional closure that is called when the area outside the popover is tapped.
     ///   - content: A view builder that creates the content of the popover.
     ///
     /// - Returns: A view that conditionally presents the draggable popover when `isPresented` is `true`.
     ///
     /// - Note: The popover will automatically adjust its position when the keyboard appears to avoid being obscured.
     ///
     /// - Example:
     ///   ```swift
     ///   struct ContentView: View {
     ///       @State private var isPopoverPresented = true
     ///       @State private var popoverAlignment = Alignment.topLeading
     ///
     ///       var body: some View {
     ///           Color.red
     ///               .popoverDraggable(
     ///                   isPresented: $isPopoverPresented,
     ///                   alignment: $popoverAlignment,
     ///                   outsideTapped: { print("Outside tapped") }
     ///               ) {
     ///                   Text("Popover Content")
     ///                       .padding()
     ///                       .background(Color.white)
     ///                       .cornerRadius(8)
     ///               }
     ///       }
     ///   }
     ///   ```
    @ViewBuilder
    func popoverDraggable<Content: View>(
        isPresented: Binding<Bool>,
        alignment: Binding<Alignment>,
        outsideTapped: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        if isPresented.wrappedValue {
            self.modifier(
                PopoverDraggableView(
                    alignment: alignment,
                    outsideTapped: outsideTapped,
                    popoverContent: content
                )
            )
        } else {
            self
        }
    }
}

public struct PopoverDraggableView<PopoverContent>: ViewModifier where PopoverContent: View {
    @Binding private var alignment: Alignment
    @State private var isDragging = false
    @State private var offset = CGSize.zero
    @State private var lastTimestamp: Date?
    private let dragThreshold: CGFloat = 40

    private let popoverContent: () -> PopoverContent
    private let outsideTappedAction: (() -> Void)?

    public init(
        alignment: Binding<Alignment>,
        outsideTapped: (() -> Void)? = nil,
        @ViewBuilder popoverContent: @escaping () -> PopoverContent
    ) {
        self.outsideTappedAction = outsideTapped
        self.popoverContent = popoverContent
        self._alignment = alignment
    }

    public func body(content: Content) -> some View {
        content.overlay(
            ZStack(alignment: alignment) {
                Color.clear
                    .highPriorityGesture(outsideViewGesture, including: .gesture)
                popoverContent()
                    .offset(x: isDragging ? offset.width : 0, y: isDragging ? offset.height : 0)
                    .gesture(drag)
            }
            .onReceive(keyboardWillShow) { _ in
                withAnimation {
                    self.alignment = .init(horizontal: self.alignment.horizontal, vertical: .top)
                }
            }
        )
    }
}

private extension PopoverDraggableView {
    // Used to shift up popover when keyboard 
    private var keyboardWillShow: AnyPublisher<Void, Never> {
        NotificationCenter.Publisher(
            center: .default,
            name: UIResponder.keyboardWillShowNotification
        )
        .receive(on: RunLoop.main)
        .map { _ in () }
        .eraseToAnyPublisher()
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                // we drop first `onChanged` event, because it may be caused by popoverContent gesture.
                guard let lastTimestamp = lastTimestamp, gesture.time.timeIntervalSince(lastTimestamp) < 0.3 else {
                    lastTimestamp = gesture.time
                    return
                }

                offset = gesture.translation
                self.isDragging = true
                self.lastTimestamp = gesture.time
            }
            .onEnded { gesture in
                offset = gesture.translation

                let verticalAlignment: VerticalAlignment
                if offset.height > dragThreshold {
                    verticalAlignment = .bottom
                } else if offset.height < -dragThreshold {
                    verticalAlignment = .top
                } else {
                    verticalAlignment = alignment.vertical
                }

                let horizontalAlignment: HorizontalAlignment
                if offset.width > dragThreshold {
                    horizontalAlignment = .trailing
                } else if offset.width < -dragThreshold {
                    horizontalAlignment = .leading
                } else {
                    horizontalAlignment = alignment.horizontal
                }

                withAnimation {
                    self.isDragging = false
                    self.alignment = .init(
                        horizontal: horizontalAlignment,
                        vertical: verticalAlignment
                    )
                }
            }
    }

    private var outsideViewGesture: some Gesture {
        SimultaneousGesture(
            TapGesture().onEnded { outsideTappedAction?() },
            DragGesture().onChanged { _ in outsideTappedAction?() }
        )
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var alignment = Alignment(horizontal: .leading, vertical: .top)

    Color.red
        .popoverDraggable(
            isPresented: .constant(true),
            alignment: $alignment,
            outsideTapped: { }
        ) {
            RoundedRectangle(cornerSize: .init(width: 10, height: 10))
                .fill(Color.green)
                .frame(width: 300, height: 200)
                .padding()
        }
}
