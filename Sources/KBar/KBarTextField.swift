/**
 *  MacEditorTextView
 *  Copyright (c) Thiago Holanda 2020-2021
 *  https://twitter.com/tholanda
 *
 *  MIT license
 */

import Combine
import SwiftUI

internal protocol KBarTextFieldDelegate {
	func onCommit()

	func selectPreviousItem()
	func selectNextItem()
}

internal struct KBarTextField: NSViewRepresentable {
	@Binding var text: String
	@Binding var isFocused : Bool
	
	var config : KBar.Config

	var delegate : KBarTextFieldDelegate

	func makeCoordinator() -> Coordinator {
		let coordinator = Coordinator(self)

		return coordinator
	}

	@State private var isSetup = false

	func makeNSView(context: Context) -> KBarTextFieldView {
		let textView = KBarTextFieldView(
			text: text,
			isEditable: true,
			font: .systemFont(ofSize: 20),
			focusOnInit: true,
			kbarConfig: config
		)
		textView.delegate = context.coordinator

		return textView
	}

	func updateNSView(_ view: KBarTextFieldView, context: Context) {
		view.text = text

		if isFocused {
			view.window?.makeFirstResponder(view)
		} else {
			view.resignFirstResponder()
		}
	}
}

// MARK: - Coordinator

internal extension KBarTextField {

	class Coordinator: NSObject, NSTextViewDelegate {
		var parent: KBarTextField
		// var selectedRanges: [NSValue] = []

		init(_ parent: KBarTextField) {
			self.parent = parent
		}

		func textDidBeginEditing(_ notification: Notification) {
			guard let textView = notification.object as? MyKBarTextFieldView else {
				return
			}

			self.parent.text = textView.string
		}

		func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
			if commandSelector == #selector(NSResponder.moveUp) {
				self.parent.delegate.selectPreviousItem()
				return true
			}
			if commandSelector == #selector(NSResponder.moveDown(_:)) {
				self.parent.delegate.selectNextItem()
				return true
			}
			if commandSelector == #selector(NSResponder.insertNewline(_:)) {

				self.parent.delegate.onCommit()

				return true
			}
			if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
				if textView.string.isEmpty {
					withAnimation {
						self.parent.isFocused = false
					}
				} else {
					textView.string = ""
					self.parent.text = ""
				}
				
				return true
			}
			return false
		}

		func textDidChange(_ notification: Notification) {
			guard let textView = notification.object as? MyKBarTextFieldView else {
				return
			}

			self.parent.text = textView.string
		}

		func textDidEndEditing(_ notification: Notification) {
			guard let textView = notification.object as? MyKBarTextFieldView else {
				return
			}

			self.parent.text = textView.string
		}
	}
}

// MARK: - CustomTextView

internal final class KBarTextFieldView: NSView {
	private var isEditable: Bool
	private var font: NSFont? = .systemFont(ofSize: 20)
	
	var kbarConfig : KBar.Config

	var focusOnInit = false

	weak var delegate: NSTextViewDelegate?

	var text: String {
		didSet {
			textView.string = text
		}
	}

	var selectedRanges: [NSValue] = [] {
		didSet {
			guard selectedRanges.count > 0 else {
				return
			}

			textView.selectedRanges = selectedRanges
		}
	}

	private lazy var scrollView: NSScrollView = {
		let scrollView = NSScrollView()
		scrollView.drawsBackground = false
		scrollView.borderType = .noBorder
		scrollView.hasVerticalScroller = false
		scrollView.hasHorizontalRuler = true
		scrollView.autoresizingMask = [.width, .height]
		scrollView.translatesAutoresizingMaskIntoConstraints = false

		return scrollView
	}()

	override func becomeFirstResponder() -> Bool {
		self.window?.makeFirstResponder(textView)
		return true
	}

	private lazy var textView: MyKBarTextFieldView = {
		let contentSize = scrollView.contentSize
		let textStorage = NSTextStorage()


		let layoutManager = NSLayoutManager()
		textStorage.addLayoutManager(layoutManager)


		let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
		textContainer.widthTracksTextView = true
		textContainer.containerSize = NSSize(
			width: contentSize.width,
			height: CGFloat.greatestFiniteMagnitude
		)

		layoutManager.addTextContainer(textContainer)

		let placeholder = NSMutableAttributedString(string: kbarConfig.placeholderText)
		let attributes : [NSAttributedString.Key : Any] = [
			NSAttributedString.Key.font: self.font as Any,
			NSAttributedString.Key.foregroundColor: NSColor.placeholderTextColor
		]
		placeholder.addAttributes(attributes, range: NSRange(location: 0, length: placeholder.length))

		let textView                     = MyKBarTextFieldView(frame: .zero, textContainer: textContainer)
		textView.autoresizingMask        = .width
		textView.placeholderAttributedString = placeholder
		textView.backgroundColor         = .red
		textView.delegate                = self.delegate
		textView.drawsBackground         = false
		textView.font                    = self.font
		textView.isEditable              = self.isEditable
		textView.isHorizontallyResizable = false
		textView.isVerticallyResizable   = true
		textView.maxSize                 = NSSize(width: CGFloat.greatestFiniteMagnitude, height: 30)
//		textView.minSize                 = NSSize(width: 0, height: 40)
		textView.textColor               = NSColor.labelColor
		textView.allowsUndo              = true
		textView.textContainerInset = .init(width: -4, height: 4)
		textView.isRichText = false
		textView.isSelectable = true
		//		textView.insertionPointColor = NSColor(Color.appPrimary)
		//		textView.selectedTextAttributes = [ .backgroundColor : NSColor(Color.appPrimary) ]

		return textView
	}()

	// MARK: - Init
	init(text: String, isEditable: Bool, font: NSFont?, focusOnInit: Bool = false, kbarConfig: KBar.Config = .init()) {
		self.font       = font
		self.isEditable = isEditable
		self.text       = text
		self.focusOnInit = focusOnInit
		self.kbarConfig = kbarConfig

		super.init(frame: .zero)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Life cycle

	override func viewWillDraw() {
		super.viewWillDraw()

		setupScrollViewConstraints()
		setupTextView()
	}

	func setupScrollViewConstraints() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false

		addSubview(scrollView)

		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: topAnchor),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
		])
	}

	func setupTextView() {
		scrollView.documentView = textView

		if focusOnInit {
			textView.window?.makeFirstResponder(textView)
		}
	}
}

internal  class MyKBarTextFieldView: NSTextView {
	@objc var placeholderAttributedString: NSAttributedString?

//	override func becomeFirstResponder() -> Bool {
//		let textView = window?.fieldEditor(true, for: nil) as? NSTextView
//		onFocusChange(true)
//		return super.becomeFirstResponder()
//	}
	//	var caretSize: CGFloat = 3
	//
	//	open override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn flag: Bool) {
	//		var rect = rect
	//		rect.size.width = caretSize
	//		super.drawInsertionPoint(in: rect, color: color, turnedOn: flag)
	//	}
	//
	//	open override func setNeedsDisplay(_ rect: NSRect, avoidAdditionalLayout flag: Bool) {
	//		var rect = rect
	//		let width = rect.size.width + caretSize - 1
	//		rect.size.width = max(rect.size.width, width) // Updated 2022-08-29
	//		super.setNeedsDisplay(rect, avoidAdditionalLayout: flag)
	//	}
}
