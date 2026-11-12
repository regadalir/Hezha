import UIKit

// MARK: - Style

private enum Style {
    static let background = UIColor(white: 0.10, alpha: 1)
    static let key = UIColor(white: 0.26, alpha: 1)
    static let keyPressed = UIColor(white: 0.42, alpha: 1)
    static let text = UIColor.white
    static let hint = UIColor(white: 0.85, alpha: 1)
    static let brand = "© Hazhir Hezha"
}

// MARK: - Key button

final class KeyButton: UIButton {
    var output = ""
    var longOutput: String?
    var isPlain = false { didSet { refresh() } }
    let hintLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 7
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.9
        layer.shadowRadius = 0
        setTitleColor(Style.text, for: .normal)
        tintColor = Style.text
        hintLabel.font = .systemFont(ofSize: 11, weight: .medium)
        hintLabel.textColor = Style.hint
        addSubview(hintLabel)
        refresh()
    }

    required init?(coder: NSCoder) { fatalError() }

    override var isHighlighted: Bool { didSet { refresh() } }

    private func refresh() {
        if isPlain {
            backgroundColor = isHighlighted ? Style.keyPressed : .clear
            layer.shadowOpacity = 0
        } else {
            backgroundColor = isHighlighted ? Style.keyPressed : Style.key
            layer.shadowOpacity = 0.9
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        hintLabel.frame = CGRect(x: 6, y: 2, width: 18, height: 14)
    }
}

// MARK: - Space key with "⎵" mark + brand text

final class SpaceButton: UIButton {
    private let mark = CAShapeLayer()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        mark.strokeColor = UIColor.white.cgColor
        mark.fillColor = UIColor.clear.cgColor
        mark.lineWidth = 1.5
        layer.addSublayer(mark)
        label.text = Style.brand
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        addSubview(label)
        layer.cornerRadius = 7
    }

    required init?(coder: NSCoder) { fatalError() }

    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? Style.keyPressed : .clear }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let w: CGFloat = 40, y = bounds.midY - 10
        let x0 = bounds.midX - w / 2
        let p = UIBezierPath()
        p.move(to: CGPoint(x: x0, y: y - 5))
        p.addLine(to: CGPoint(x: x0, y: y))
        p.addLine(to: CGPoint(x: x0 + w, y: y))
        p.addLine(to: CGPoint(x: x0 + w, y: y - 5))
        mark.path = p.cgPath
        label.frame = CGRect(x: 4, y: y + 4, width: bounds.width - 8, height: 22)
    }
}

// MARK: - Keyboard

final class KeyboardViewController: UIInputViewController {

    private enum Page { case letters, numbers, symbols }

    // Exact visual order (left → right) of the reference layout.
    private let letterRows: [[String]] = [
        ["ق", "ڤ", "ف", "غ", "ع", "ھ", "ە", "ت", "ح", "خ"],
        ["ش", "س", "ی", "ێ", "ل", "ڵ", "ا", "ن", "ج", "چ"],
        ["ب", "ز", "ر", "ڕ", "د", "وو", "و", "ۆ", "ک", "گ"],
        ["ئ", "پ", "ژ", "م", "؟", "،", "."],
    ]
    private let topDigits = ["١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩", "٠"]

    private let numberRows: [[String]] = [
        ["١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩", "٠"],
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["-", "/", ":", "؛", "(", ")", "«", "»", "@", "\""],
        [".", "،", "؟", "!", "'", "٪", "+"],
    ]

    private let symbolRows: [[String]] = [
        ["\u{064E}", "\u{064F}", "\u{0650}", "\u{064B}", "\u{064C}", "\u{064D}", "\u{0651}", "\u{0652}", "ـ", "\u{0670}"],
        ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        ["_", "\\", "|", "~", "<", ">", "$", "€", "£", "•"],
        [".", "،", "؟", "!", "'", "…", "&"],
    ]

    private var page: Page = .letters
    private var rows: [[(view: UIView, units: CGFloat)]] = []
    private var deleteTimer: Timer?
    private var heightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Style.background
        let c = view.heightAnchor.constraint(equalToConstant: 290)
        c.priority = UILayoutPriority(999)
        c.isActive = true
        heightConstraint = c
        rebuild()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let s = UIScreen.main.bounds.size
        heightConstraint?.constant = s.width > s.height ? 210 : 290
    }

    // MARK: Building

    private func rebuild() {
        rows.flatMap { $0 }.forEach { $0.view.removeFromSuperview() }
        rows = []

        let source: [[String]]
        switch page {
        case .letters: source = letterRows
        case .numbers: source = numberRows
        case .symbols: source = symbolRows
        }

        for (r, keys) in source.enumerated() {
            var row: [(view: UIView, units: CGFloat)] = []
            if r == 3 {
                // ⟷ = zero-width non-joiner (نیوەفاسیلە)
                let zwnj = iconKey("arrow.left.and.right", plain: true)
                zwnj.output = "\u{200C}"
                zwnj.addTarget(self, action: #selector(charTapped(_:)), for: .touchUpInside)
                row.append((zwnj, 1))
            }
            for (i, k) in keys.enumerated() {
                let hint = (page == .letters && r == 0) ? topDigits[i] : nil
                row.append((charKey(k, hint: hint), 1))
            }
            if r == 3 {
                let del = iconKey("delete.right", plain: true)
                del.addTarget(self, action: #selector(deleteDown), for: .touchDown)
                del.addTarget(self, action: #selector(deleteUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
                row.append((del, 2))
            }
            rows.append(row)
        }

        // Bottom row: globe · numbers · space · symbols · return
        let globe = iconKey("globe", plain: true)
        globe.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)

        let numKey = textKey(page == .numbers ? "ابپ" : "½")
        numKey.addTarget(self, action: #selector(numbersTapped), for: .touchUpInside)

        let space = SpaceButton()
        space.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)

        let symKey = textKey(page == .symbols ? "ابپ" : "!؟")
        symKey.addTarget(self, action: #selector(symbolsTapped), for: .touchUpInside)

        let ret = iconKey("arrow.left", plain: true)
        ret.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)

        rows.append([(globe, 1.5), (numKey, 1.5), (space, 4), (symKey, 1.5), (ret, 1.5)])

        rows.flatMap { $0 }.forEach { view.addSubview($0.view) }
        view.setNeedsLayout()
    }

    private func charKey(_ s: String, hint: String?) -> KeyButton {
        let b = KeyButton()
        b.output = s
        // Show combining marks on a tatweel so they are visible.
        let isMark = s.unicodeScalars.first?.properties.generalCategory == .nonspacingMark
        b.setTitle(isMark ? "ـ" + s : s, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: s.count > 1 ? 20 : 27)
        if let hint = hint {
            b.hintLabel.text = hint
            b.longOutput = hint
            let lp = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
            lp.minimumPressDuration = 0.35
            b.addGestureRecognizer(lp)
        }
        b.addTarget(self, action: #selector(charTapped(_:)), for: .touchUpInside)
        return b
    }

    private func iconKey(_ symbol: String, plain: Bool) -> KeyButton {
        let b = KeyButton()
        b.isPlain = plain
        let cfg = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        b.setImage(UIImage(systemName: symbol, withConfiguration: cfg), for: .normal)
        return b
    }

    private func textKey(_ title: String) -> KeyButton {
        let b = KeyButton()
        b.isPlain = true
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 21, weight: .semibold)
        return b
    }

    // MARK: Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let W = view.bounds.width, H = view.bounds.height
        guard W > 0, H > 0, !rows.isEmpty else { return }
        let side: CGFloat = 3, gapX: CGFloat = 5, gapY: CGFloat = 9, top: CGFloat = 8, bottom: CGFloat = 4
        let n = CGFloat(rows.count)
        let rowH = (H - top - bottom - gapY * (n - 1)) / n
        let unit = (W - 2 * side + gapX) / 10
        for (r, row) in rows.enumerated() {
            let total = row.reduce(0) { $0 + $1.units }
            var x = side + (10 - total) * unit / 2
            let y = top + CGFloat(r) * (rowH + gapY)
            for k in row {
                k.view.frame = CGRect(x: x, y: y, width: k.units * unit - gapX, height: rowH)
                x += k.units * unit
            }
        }
    }

    // MARK: Actions

    @objc private func charTapped(_ sender: KeyButton) {
        textDocumentProxy.insertText(sender.output)
    }

    @objc private func longPressed(_ g: UILongPressGestureRecognizer) {
        guard g.state == .began, let b = g.view as? KeyButton, let out = b.longOutput else { return }
        textDocumentProxy.insertText(out)
    }

    @objc private func spaceTapped() { textDocumentProxy.insertText(" ") }
    @objc private func returnTapped() { textDocumentProxy.insertText("\n") }

    @objc private func numbersTapped() {
        page = page == .numbers ? .letters : .numbers
        rebuild()
    }

    @objc private func symbolsTapped() {
        page = page == .symbols ? .letters : .symbols
        rebuild()
    }

    @objc private func deleteDown() {
        textDocumentProxy.deleteBackward()
        deleteTimer?.invalidate()
        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false) { [weak self] _ in
            self?.deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { _ in
                self?.textDocumentProxy.deleteBackward()
            }
        }
    }

    @objc private func deleteUp() {
        deleteTimer?.invalidate()
        deleteTimer = nil
    }
}
