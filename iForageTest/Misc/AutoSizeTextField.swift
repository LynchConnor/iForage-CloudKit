//
//  AutosizeTextField.swift
//  iForage
//
//  Created by Connor A Lynch on 04/11/2021.
//

import Foundation
import SwiftUI

struct AutoSizeTextField: UIViewRepresentable {
    
    @Binding var text: String
    let hint: String
    @Binding var containerHeight: CGFloat
    
    var onEnd: () -> ()
    
    func makeUIView(context: Context) -> UITextView {
        
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = UIColor(Color.black)
        textView.font = .systemFont(ofSize: 19)
        textView.delegate = context.coordinator
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(context.coordinator.closeKeyboard))
        
        toolbar.barStyle = .default
        
        toolbar.items = [spacer, doneButton]
        
        toolbar.sizeToFit()
        
        textView.inputAccessoryView = toolbar
        
        return textView
        
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.text = text
        DispatchQueue.main.async {
            if containerHeight == 0 {
                containerHeight = uiView.contentSize.height
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        let parent: AutoSizeTextField
        
        init(_ parent: AutoSizeTextField){
            self.parent = parent
        }
        
        @objc func closeKeyboard(){
            parent.onEnd()
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.hint {
                textView.text = ""
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == "" {
                textView.text = parent.hint
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.containerHeight = textView.contentSize.height
        }
        
    }
}

struct AutoSizeTextField_Previews: PreviewProvider {
    static var previews: some View {
        AutoSizeTextField(text: .constant("howdy"), hint: "howdy", containerHeight: .constant(200), onEnd: {
            
        } //
        )
    }
}

