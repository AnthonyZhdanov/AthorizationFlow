//
//  HintTextView.swift
//  Example
//
//  Created by Beloizerov on 22.02.18.
//  Copyright © 2018 Anton Zhdanov. All rights reserved.
//

import UIKit

@IBDesignable
open class HintTextView: UITextView {
    
    // MARK: - Initialize
    
    private func baseInit() {
        _textContainerInset = super.textContainerInset
        updateTextContainerInset()
        updatePlaceholder()
        addTextDidChangeObserver()
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        baseInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        baseInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIView
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        setupCorrectInsets()
        if layer.needsLayout() { contentOffset = .zero }
        setAnimation(turnOn: false, block: layoutPlaceholder)
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        placeholder = "Placeholder"
    }
    
    // MARK: - UITextView
    
    open override var text: String! {
        didSet {
            guard isTitle == text.isEmpty else { return }
            updatePlaceholder(animated: false)
        }
    }
    
    open override var font: UIFont? {
        didSet { setPlaceholderFont() }
    }
    
    open override var textAlignment: NSTextAlignment {
        didSet { placeholderLayer.alignmentMode = placeholderAlignment }
    }
    
    private var placeholderAlignment: String {
        switch textAlignment {
        case .center: return kCAAlignmentCenter
        case .justified: return kCAAlignmentJustified
        case .left: return kCAAlignmentLeft
        case .natural: return kCAAlignmentNatural
        case .right: return kCAAlignmentRight
        }
    }
    
    private var _textContainerInset: UIEdgeInsets?
    
    open override var textContainerInset: UIEdgeInsets {
        get {
            return _textContainerInset ?? super.textContainerInset
        }
        set {
            guard newValue != _textContainerInset else { return }
            _textContainerInset = newValue
            updateTextContainerInset()
        }
    }
    
    private func updateTextContainerInset(disableAnimation: Bool = false) {
        var inset = textContainerInset
        if havePlaceholder, reservePlaceForTitle || !text.isEmpty {
            inset.top += titleFont.lineHeight + titleBottomInset
        }
        guard super.textContainerInset != inset else { return }
        super.textContainerInset = inset
        isScrollEnabled && !reservePlaceForTitle
            ? sizeToFit()
            : invalidateIntrinsicContentSize()
        if disableAnimation { setAnimation(turnOn: false, block: layoutIfNeeded) }
    }
    
    // MARK: - TextDidChange Notification
    
    private func addTextDidChangeObserver() {
        let name = NSNotification.Name.UITextViewTextDidChange
        let selector = #selector(textDidChange)
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: self)
    }
    
    @objc private func textDidChange() {
        guard isTitle == text.isEmpty else { return }
        updatePlaceholder(animated: true)
    }
    
    // MARK: - Placeholder
    
    @IBInspectable open var reservePlaceForTitle: Bool = true {
        didSet {
            guard reservePlaceForTitle != oldValue else { return }
            updateTextContainerInset(disableAnimation: true)
        }
    }
    
    @IBInspectable open var placeholder: String? {
        get {
            return placeholderLayer.string as? String
        }
        set {
            guard newValue != placeholder else { return }
            let hadPlaceholder = havePlaceholder
            placeholderLayer.string = newValue
            guard hadPlaceholder != havePlaceholder else { return }
            updatePlaceholder()
        }
    }
    
    private lazy var placeholderLayer: CATextLayer = {
        let placeholder = CATextLayer()
        placeholder.contentsScale = UIScreen.main.scale
        placeholder.truncationMode = kCATruncationEnd
        layer.addSublayer(placeholder)
        return placeholder
    }()
    
    private var havePlaceholder: Bool {
        return placeholder?.isEmpty == false
    }
    
    // MARK: - Placeholder update
    
    private var isTitle = false
    
    private func updatePlaceholder() {
        placeholderLayer.isHidden = !havePlaceholder
        isTitle = !text.isEmpty && havePlaceholder
        updateTextContainerInset()
        guard havePlaceholder else { return }
        setPlaceholderFont()
        setPlaceholderColor()
        layoutPlaceholder()
    }
    
    // MARK: - Placeholder animation
    
    open var placeholderAnimationDuration: Double?
    
    private func updatePlaceholder(animated: Bool) {
        let animation = animated && !CATransaction.disableActions()
        setAnimation(turnOn: animation) {
            if animation, let customDuration = placeholderAnimationDuration {
                CATransaction.setAnimationDuration(customDuration)
            }
            updatePlaceholder()
            if !animation { placeholderLayer.displayIfNeeded() }
        }
    }
    
    private func setAnimation(turnOn: Bool, block: (() -> ())) {
        CATransaction.begin()
        CATransaction.setDisableActions(!turnOn)
        block()
        CATransaction.commit()
    }
    
    // MARK: - Placeholder rect
    
    @IBInspectable open var titleBottomInset: CGFloat = 8 {
        didSet {
            guard titleBottomInset != oldValue else { return }
            updateTextContainerInset(disableAnimation: true)
        }
    }
    
    private func layoutPlaceholder() {
        let inset = isTitle ? textContainerInset : super.textContainerInset
        let x = textContainer.lineFragmentPadding + inset.left
        let y = isTitle ? inset.top + contentOffset.y : inset.top
        let height = max(titleFont.lineHeight, placeholderFont.lineHeight)
        let size = CGSize(width: textContainer.size.width, height: height)
        let origin = CGPoint(x: x, y: y)
        placeholderLayer.frame = CGRect(origin: origin, size: size)
        updatePlaceholderMask()
    }
    
    // MARK: - Placeholder fonts
    
    @IBInspectable open var titleFontSize: CGFloat = 12 {
        didSet {
            guard titleFontSize != oldValue else { return }
            setPlaceholderFont()
            updateTextContainerInset(disableAnimation: true)
        }
    }
    
    private var titleFont: UIFont {
        return UIFont(descriptor: placeholderFont.fontDescriptor, size: titleFontSize)
    }
    
    private var placeholderFont: UIFont {
        return font ?? .systemFont(ofSize: UIFont.systemFontSize)
    }
    
    private func setPlaceholderFont() {
        placeholderLayer.font = placeholderFont.fontName as CFTypeRef
        let font = isTitle ? titleFont : placeholderFont
        placeholderLayer.fontSize = font.pointSize
    }
    
    // MARK: - Placeholder Colors
    
    @IBInspectable open var placeholderColor: UIColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1) {
        didSet { if !isTitle { setPlaceholderColor() } }
    }
    
    @IBInspectable open var titleColor: UIColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1) {
        didSet { if isTitle { setPlaceholderColor() } }
    }
    
    private func setPlaceholderColor() {
        let color = isTitle ? titleColor : placeholderColor
        placeholderLayer.foregroundColor = color.cgColor
    }
    
    // MARK: - Placeholder mask
    
    private func updatePlaceholderMask() {
        guard isTitle, isScrollEnabled, bounds.height < contentSize.height else {
            scrollIndicatorInsets.top = 0
            return subviews.forEach { view in view.layer.mask = nil }
        }
        var minY = placeholderLayer.frame.maxY
        minY += max(0, titleBottomInset - textContainerInset.top)
        scrollIndicatorInsets.top = minY - contentOffset.y
        for (index, view) in subviews.enumerated() {
            if (minY - view.frame.minY < titleBottomInset) ||
                (index == 0 && view.frame.minY >= minY ) {
                view.layer.mask = nil
                continue
            }
            var rect = view.frame
            rect.size.height = minY - view.frame.minY
            let path = CGMutablePath()
            path.addRect(view.convert(rect, from: self))
            path.addRect(view.bounds)
            let mask = CAShapeLayer()
            mask.fillRule = kCAFillRuleEvenOdd
            mask.path = path
            view.layer.mask = mask
        }
    }
    
    // MARK: - Update insets
    private func setupCorrectInsets() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
    
}
