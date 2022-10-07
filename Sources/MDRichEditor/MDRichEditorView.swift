import RichEditorView
import WebKit
import UIKit
import Ink

public final class MDRichEditorView: RichEditorView, RichEditorDelegate {
    
    /// By default this variable is true. Any contented pasted to the `MDRichEditorView`  will
    /// contain the style format
    public var canPasteWithFormat: Bool = true {
        didSet {
            webView.canPasteWithFormat = canPasteWithFormat
        }
    }
    
    public var markdownString: String  {
        set {html = MarkdownParser().html(from: newValue)}
    
        get {HTMLParser.asMarkdown(from:contentHTML)}
    }
        
    convenience public init(placeholder: String) {
        self.init(frame: .zero)
        self.placeholder = placeholder
        editingEnabled = true
        delegate = self
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Called when the inner height of the text being displayed changes
    /// Can be used to update the UI
    public final var onHeightDidChange: ((_ height: Int) -> Void)?
    public func richEditor(_ editor: RichEditorView, heightDidChange height: Int) { onHeightDidChange?(height) }
    
    /// Called whenever the content inside the view changes
    public final var onContentDidChange: ((_ content: String) -> Void)?
    public func richEditor(_ editor: RichEditorView, contentDidChange content: String) { onContentDidChange?(content) }
    
    /// Called when the rich editor starts editing
    public final var onEditorDidTakeFocus: ((_ editor: RichEditorView) -> Void)?
    public func richEditorTookFocus(_ editor: RichEditorView) {
        onEditorDidTakeFocus?(editor)
    }
    
    /// Called when the rich editor stops editing or loses focus
    public final var onEditorDidLoseFocus: ((_ editor: RichEditorView) -> Void)?
    public func richEditorLostFocus(_ editor: RichEditorView) {
        onEditorDidLoseFocus?(editor)
    }
    
    /// Called when the RichEditorView has become ready to receive input
    /// More concretely, is called when the internal WKWebView loads for the first time, and contentHTML is set
    public final var onEditorDidLoad: ((_ editor: RichEditorView) -> Void)?
    public func richEditorDidLoad(_ editor: RichEditorView) {
        onEditorDidLoad?(editor)
    }
    
    /// Called when the internal WKWebView begins loading a URL that it does not know how to respond to
    /// For example, if there is an external link, and then the user taps it
    public final var onShouldInteractWith: ((_ url: URL) -> Bool)?
    public func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool {
       return onShouldInteractWith?(url) ?? false
    }
    
    /// Called when custom actions are called by callbacks in the JS
    /// By default, this method is not used unless called by some custom JS that you add
    public final var onHandle: ((_ action: String) -> Void)?
    public func richEditor(_ editor: RichEditorView, handle action: String) {
        onHandle?(action)
    }
    
    public final func richEditorOnPaste(_ editor: RichEditorView, text: String) {
        let formatted = text.replacingOccurrences(of: "\n", with: "")
        runJS("RE.insertHTML('<p>\(formatted)</p>')")
    }
}


extension RichEditorWebView {
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Actions have been constraint to only supported actions by the editor and Markdown format
        let validActions = [
                #selector(UIResponderStandardEditActions.copy(_:)),
                #selector(UIResponderStandardEditActions.paste(_:)),
                #selector(UIResponderStandardEditActions.cut(_:)),
                #selector(UIResponderStandardEditActions.select(_:)),
                #selector(UIResponderStandardEditActions.selectAll(_:)),
                #selector(UIResponderStandardEditActions.toggleItalics(_:)),
                #selector(UIResponderStandardEditActions.toggleBoldface(_:))
            ]
            return validActions.contains(action)
        }
    
}


