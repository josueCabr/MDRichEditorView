import UIKit
import MDRichEditor

class EditorViewController: UIViewController {
    let editorView = MDRichEditorView(placeholder: "Type your note")
    var prevText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalSafeAreaInsets = .init(top: 6, left: 12, bottom: 0, right: 12)
        editorView.webView.scrollView.keyboardDismissMode = .interactive
        editorView.canPasteWithFormat = false
        view.addSubview(editorView)
        let sa = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            editorView.topAnchor.constraint(equalTo: sa.topAnchor),
            editorView.leadingAnchor.constraint(equalTo: sa.leadingAnchor),
            editorView.trailingAnchor.constraint(equalTo: sa.trailingAnchor),
            editorView.bottomAnchor.constraint(equalTo: sa.bottomAnchor)
        ])

//        let markdownDoc =
        
//        **Title**
//
//        Another paragraph. Now this has a list
//
//        1. tem
//        2. Item
//
//
//        ***Italic text bold***
//
//        - This is the first list item.
//        - Here's the second list item.
//        - Done
//        - Done
//        - Done
//
//
//        I need to add another paragraph below the second list item.
//
//        - And here's the third list item.

//        """
        let markdownDoc = "1. FWEFWEF\n2. Wexcwefwefwe\n\nCwewedwed\n\n* Wefwef e\n* E Wefwefwe\n* ScreedFeed WEFWE\n\n\n"

        editorView.markdownString = markdownDoc
        
        editorView.onContentDidChange = {[weak self] content in
            // This is meant to act as a text cap
            if content.count > 1000 {
                self?.editorView.html = self?.prevText ?? ""
            } else {
                self?.prevText = content
            }
        }
        
        editorView.onEditorDidLoseFocus = {[weak self] editor in
            self?.convertToMarckDown(html:editor.html)
        }
    
    }
    
    func convertToMarckDown(html: String) {
        let markdown = editorView.markdownString
        editorView.markdownString = markdown
        print("\n\nMARKDOWN\n\n", markdown)
    }
}
