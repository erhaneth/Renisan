import UIKit

class KeyboardViewController: UIInputViewController {

    // 1. The Brain
    var predictionEngine: PredictionEngine?
    
    // 2. UI Elements
    var suggestionBar: UIStackView!
    var suggestionButtons: [UIButton] = []
    var mainStackView: UIStackView!
    
    // 3. State Management
    enum KeyboardMode {
        case letters
        case numbers
    }
    var currentMode: KeyboardMode = .letters
    var isUppercase: Bool = false
    
    // 4. Layout Definitions
    // LOWERCASE (Standard)
    let keysLower = [
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "ê", "û"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l", "ş", "î"],
        ["z", "x", "c", "v", "b", "n", "m", "ç"]
    ]
    
    // NUMBERS & SYMBOLS (Mapped to match the letter grid size roughly)
    let keysNumbers = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "/"],
        ["@", "#", "$", "&", "(", ")", "'", "\"", ":", ";", "!"],
        ["%", "*", "+", "=", "?", ",", ".", "_"]
    ]
    
    // 5. Colors
    let colorBackground = UIColor(red: 226/255, green: 228/255, blue: 231/255, alpha: 1.0)  // Matches iOS keyboard background
    let colorKeyNormal = UIColor.white
    let colorKeyDark = UIColor(red: 172/255, green: 177/255, blue: 185/255, alpha: 1.0)
    let colorKeyShadow = UIColor(red: 136/255, green: 138/255, blue: 142/255, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Brain
        DispatchQueue.global(qos: .userInitiated).async {
            self.predictionEngine = PredictionEngine()
        }
        
        view.backgroundColor = colorBackground
        
        setupSuggestionBar()
        // Initial Layout
        updateKeyboardLayout()
    }
    
    // MARK: - 1. Suggestion Bar
    func setupSuggestionBar() {
        suggestionBar = UIStackView()
        suggestionBar.axis = .horizontal
        suggestionBar.distribution = .fillEqually
        suggestionBar.spacing = 1
        suggestionBar.translatesAutoresizingMaskIntoConstraints = false
        suggestionBar.backgroundColor = colorBackground
        
        for _ in 0..<3 {
            let btn = UIButton(type: .system)
            btn.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
            btn.setTitleColor(.black, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            btn.isHidden = true
            btn.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
            suggestionButtons.append(btn)
            suggestionBar.addArrangedSubview(btn)
        }
        
        view.addSubview(suggestionBar)
        
        NSLayoutConstraint.activate([
            suggestionBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            suggestionBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            suggestionBar.topAnchor.constraint(equalTo: view.topAnchor),
            suggestionBar.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    // MARK: - 2. Layout Engine (Redraws keys based on state)
    func updateKeyboardLayout() {
        // 1. Remove old layout if it exists
        mainStackView?.removeFromSuperview()
        
        // 2. Determine which keys to show
        var currentKeys: [[String]]
        
        if currentMode == .numbers {
            currentKeys = keysNumbers
        } else {
            // If Uppercase, map everything to uppercase
            if isUppercase {
                currentKeys = keysLower.map { row in row.map { $0.uppercased() } }
            } else {
                currentKeys = keysLower
            }
        }
        
        // 3. Build Stack
        mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 12
        mainStackView.distribution = .fillEqually
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // --- ROWS 1, 2, 3 ---
        for (rowIndex, rowKeys) in currentKeys.enumerated() {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 6
            rowStack.distribution = .fillEqually
            
            // Row 3 Special Logic (Shift/Back)
            if rowIndex == 2 {
                // LEFT SIDE FUNCTION KEY
                if currentMode == .letters {
                    // Show SHIFT
                    let shiftTitle = isUppercase ? "⬆" : "⇧" // Filled arrow if active
                    let shiftBtn = createKeyButton(title: shiftTitle, isFunctionKey: true)
                    // Highlight shift if active
                    if isUppercase {
                        shiftBtn.backgroundColor = .white
                        shiftBtn.setTitleColor(.black, for: .normal)
                    }
                    shiftBtn.addTarget(self, action: #selector(shiftTapped), for: .touchUpInside)
                    rowStack.addArrangedSubview(shiftBtn)
                } else {
                    // Show SYMBOLS Toggle (Simplified: Just a placeholder or specific symbol logic)
                    // For now, we keep it aligned with letters, maybe add a specific symbol key later
                    // Let's put a placeholder spacer to keep alignment or more symbols
                    let spacer = createKeyButton(title: "#+=", isFunctionKey: true)
                     // (Action not implemented for brevity, acts as spacer)
                    rowStack.addArrangedSubview(spacer)
                }
                
                // CENTER KEYS
                for key in rowKeys {
                    let keyBtn = createKeyButton(title: key, isFunctionKey: false)
                    rowStack.addArrangedSubview(keyBtn)
                }
                
                // RIGHT SIDE: Backspace
                let backspaceBtn = createKeyButton(title: "⌫", isFunctionKey: true)
                backspaceBtn.removeTarget(nil, action: nil, for: .allEvents)
                backspaceBtn.addTarget(self, action: #selector(backspaceTapped), for: .touchUpInside)
                rowStack.addArrangedSubview(backspaceBtn)
                
                mainStackView.addArrangedSubview(rowStack)
            } else {
                // Standard Rows 1 & 2
                for key in rowKeys {
                    let keyBtn = createKeyButton(title: key, isFunctionKey: false)
                    rowStack.addArrangedSubview(keyBtn)
                }
                mainStackView.addArrangedSubview(rowStack)
            }
        }
        
        // --- ROW 4 (Bottom) ---
        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.spacing = 6
        bottomRow.distribution = .fillProportionally
        
        // 123 / ABC Button
        let modeTitle = (currentMode == .letters) ? "123" : "ABC"
        let modeBtn = createKeyButton(title: modeTitle, isFunctionKey: true)
        modeBtn.widthAnchor.constraint(equalToConstant: 90).isActive = true
        modeBtn.addTarget(self, action: #selector(modeTapped), for: .touchUpInside)
        
        // Dot Key (with autocorrect)
        let dotBtn = createKeyButton(title: ".", isFunctionKey: false)
        dotBtn.removeTarget(nil, action: nil, for: .allEvents)
        dotBtn.addTarget(self, action: #selector(punctuationTapped(_:)), for: .touchUpInside)
        dotBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Space
        let spaceBtn = createKeyButton(title: "Navber", isFunctionKey: false)
        spaceBtn.addTarget(self, action: #selector(spaceTapped), for: .touchUpInside)
        
        // Return
        let returnBtn = createKeyButton(title: "⏎", isFunctionKey: true)
        returnBtn.widthAnchor.constraint(equalToConstant: 90).isActive = true
        returnBtn.addTarget(self, action: #selector(returnTapped), for: .touchUpInside)

        bottomRow.addArrangedSubview(modeBtn)
        bottomRow.addArrangedSubview(dotBtn)
        bottomRow.addArrangedSubview(spaceBtn)
        bottomRow.addArrangedSubview(returnBtn)
        
        mainStackView.addArrangedSubview(bottomRow)
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 3),
            mainStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -3),
            mainStackView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor, constant: 8),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
    }
    
    // MARK: - 3. Styling Engine
    func createKeyButton(title: String, isFunctionKey: Bool) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = isFunctionKey ? colorKeyDark : colorKeyNormal
        btn.setTitleColor(.black, for: .normal)
        btn.layer.shadowColor = colorKeyShadow.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        btn.layer.shadowOpacity = 1.0
        btn.layer.shadowRadius = 0.0
        btn.layer.masksToBounds = false
        btn.layer.cornerRadius = 5.0
        
        if title.count > 1 {
             btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        } else {
             btn.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .light)
        }

        // Auto-add action for standard keys
        if !["⌫", "Navber", "⏎", "123", "ABC", "⇧", "⬆", "#+="].contains(title) {
            btn.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
        }
        return btn
    }
    
    // MARK: - Actions
    
    @objc func shiftTapped() {
        isUppercase.toggle()
        updateKeyboardLayout() // Re-draw keys
    }
    
    @objc func modeTapped() {
        if currentMode == .letters {
            currentMode = .numbers
        } else {
            currentMode = .letters
        }
        updateKeyboardLayout() // Re-draw keys
    }
    
    @objc func keyPressed(_ sender: UIButton) {
        guard let letter = sender.title(for: .normal) else { return }
        textDocumentProxy.insertText(letter)
        UIDevice.current.playInputClick()
        
        // Auto-lowercase after typing a letter (standard behavior)
        if isUppercase {
            isUppercase = false
            updateKeyboardLayout()
        }
    }
    
    @objc func spaceTapped() {
        performAutocorrect()
        textDocumentProxy.insertText(" ")
    }
    
    @objc func backspaceTapped() { textDocumentProxy.deleteBackward() }
    
    @objc func returnTapped() {
        performAutocorrect()
        textDocumentProxy.insertText("\n")
    }
    
    // MARK: - Autocorrect Logic
    
    /// Performs autocorrect on the current word before inserting space/punctuation
    func performAutocorrect() {
        guard let engine = predictionEngine else { return }
        
        // Get the current word being typed
        guard let currentWord = getCurrentWord(), !currentWord.isEmpty else { return }
        
        // Check if we have a correction
        if let correction = engine.getCorrection(for: currentWord) {
            // Delete the misspelled word
            for _ in 0..<currentWord.count {
                textDocumentProxy.deleteBackward()
            }
            // Insert the corrected word
            textDocumentProxy.insertText(correction)
            
            print("✨ Autocorrected: '\(currentWord)' → '\(correction)'")
        }
    }
    
    /// Gets the current word being typed (before cursor)
    func getCurrentWord() -> String? {
        guard let context = textDocumentProxy.documentContextBeforeInput else { return nil }
        
        // Find the last word (text after last space/newline)
        let trimmed = context.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return nil }
        
        // Split by whitespace and get the last word
        let words = trimmed.components(separatedBy: .whitespacesAndNewlines)
        return words.last
    }
    
    /// Handler for punctuation keys (autocorrect before inserting)
    @objc func punctuationTapped(_ sender: UIButton) {
        guard let punctuation = sender.title(for: .normal) else { return }
        performAutocorrect()
        textDocumentProxy.insertText(punctuation)
        UIDevice.current.playInputClick()
    }

    @objc func suggestionTapped(_ sender: UIButton) {
        guard let word = sender.title(for: .normal) else { return }
        let proxy = self.textDocumentProxy
        proxy.insertText(word + " ")
    }
    
    // MARK: - Prediction Logic
    override func textDidChange(_ textInput: UITextInput?) {
        updatePredictions()
    }
    
    override func selectionWillChange(_ textInput: UITextInput?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.updatePredictions()
        }
    }
    
    func updatePredictions() {
        let proxy = self.textDocumentProxy
        guard let context = proxy.documentContextBeforeInput else {
            updateButtons(with: [])
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            guard let engine = self.predictionEngine else { return }
            let suggestions = engine.getSuggestions(for: context)
            DispatchQueue.main.async {
                self.updateButtons(with: suggestions)
            }
        }
    }
    
    func updateButtons(with words: [String]) {
        if words.isEmpty {
            for btn in suggestionButtons { btn.isHidden = true }
            return
        }
        for (index, btn) in suggestionButtons.enumerated() {
            if index < words.count {
                btn.setTitle(words[index], for: .normal)
                btn.isHidden = false
            } else {
                btn.isHidden = true
            }
        }
    }
}
