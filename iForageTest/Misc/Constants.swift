//
//  Constants.swift
//  iForageTest
//
//  Created by Connor A Lynch on 25/11/2021.
//
import SwiftUI
import Foundation

enum RecordType {
    static let post = "Posts"
}

extension View {

    /// Fix the SwiftUI bug for onAppear twice in subviews
    /// - Parameters:
    ///   - perform: perform the action when appear
    func onFirstAppear(perform: @escaping () -> Void) -> some View {
        let kAppearAction = "appear_action"
        let queue = OperationQueue.main
        let delayOperation = BlockOperation {
            Thread.sleep(forTimeInterval: 0.001)
        }
        let appearOperation = BlockOperation {
            perform()
        }
        appearOperation.name = kAppearAction
        appearOperation.addDependency(delayOperation)
        return onAppear {
            if !delayOperation.isFinished, !delayOperation.isExecuting {
                queue.addOperation(delayOperation)
            }
            if !appearOperation.isFinished, !appearOperation.isExecuting {
                queue.addOperation(appearOperation)
            }
        }
        .onDisappear {
            queue.operations
                .first { $0.name == kAppearAction }?
                .cancel()
        }
    }
}


struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

//MARK:- StrechingHeader
struct StretchingHeader<Content: View>: View {
    let height: CGFloat
    let content: () -> Content
    
    var body: some View {
        GeometryReader { geo in
            content()
                .frame(width: geo.size.width, height: self.getHeightForHeaderImage(geo))
                .clipped()
                .offset(x: 0, y: self.getOffsetForHeaderImage(geo))
        }
        .frame(height: height)
    }
    
    private func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
        geometry.frame(in: .global).minY
    }
    
    // 2
    private func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        
        // Image was pulled down
        if offset > 0 {
            return -offset
        }
        else if offset > 0 {
            return offset
        }
        
        
        return 0
    }
    
    private func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
        let offset = getScrollOffset(geometry)
        let imageHeight = geometry.size.height

        if offset > 0 {
            return imageHeight + offset
        }

        return imageHeight
    }
}
