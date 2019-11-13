//
//  Extensions.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 25/03/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import RealmSwift

extension UITextField {
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Готово".localizedSafe, style: .done, target: self, action: #selector(doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        inputAccessoryView = doneToolbar
    }
    
    @objc private func doneButtonAction() {
        resignFirstResponder()
    }
}

extension UIApplication {
var statusBarUIView: UIView? {
    if #available(iOS 13.0, *) {
        let tag = 38482
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if let statusBar = keyWindow?.viewWithTag(tag) {
            return statusBar
        } else {
            guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
            let statusBarView = UIView(frame: statusBarFrame)
            statusBarView.tag = tag
            keyWindow?.addSubview(statusBarView)
            return statusBarView
        }
    } else if responds(to: Selector(("statusBar"))) {
        return value(forKey: "statusBar") as? UIView
    } else {
        return nil
    }
  }
}

extension UIViewController {
    func showAlert(_ title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func getStringWithSpace(string: String) -> String {
        let num = string.split(separator: ".")
        
        let numArray = Array(num[0])
        var reversedNumArray = [Character]()
        
        for arrayIndex in stride(from: numArray.count - 1, through: 0, by: -1) {
            reversedNumArray.append(numArray[arrayIndex])
        }
        let len = num[0].count
        var newStr = ""
        for curSymb in 1...len {
            newStr = String(reversedNumArray[curSymb-1]) + newStr
            if((curSymb % 3 == 0) && (curSymb != len)) {
                newStr = " " + newStr
            }
        }
        if(num.count > 1){
            newStr = newStr + "." + "\(num[1])".maxLength(length: 2)
        }
        return newStr
    }
}

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}

extension UITableView {
    func dequeueReusableCell<Cell: UITableViewCell>(_ T: Cell.Type, for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withIdentifier: T.className, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with identifier: " + String(T.className) + " or edit custom class to XIB file")
        }
        return cell
    }
}

extension Realm {
    func safeWrite(_ block: () throws -> Void) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}

extension Double {
    func presentable() -> (first: String, last: String) {
        let int = Int(self)
        var last = ""
        var s = Int(ceil(100 * (self - Double(int))))
        if s < 0 {
            s = -s
        }
        if s < 10 {
            last = "0\(s)"
        } else {
            last = "\(s)"
        }
        return (first: int.formattedWithSeparator, last: last)
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension BinaryInteger {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension TimeInterval {
    func month() -> String {
        let months = [
            "Январь".localizedSafe,
            "Февраль".localizedSafe,
            "Март".localizedSafe,
            "Апрель".localizedSafe,
            "Май".localizedSafe,
            "Июнь".localizedSafe,
            "Июль".localizedSafe,
            "Август".localizedSafe,
            "Сентябрь".localizedSafe,
            "Октябрь".localizedSafe,
            "Ноябрь".localizedSafe,
            "Декабрь".localizedSafe
        ]
        let date = Date(timeIntervalSince1970: self)
        let int = Calendar.current.component(.month, from: date)
        return months[int - 1]
    }
}

extension UISearchBar {

    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    func set(textColor: UIColor) { if let textField = getTextField() { textField.textColor = textColor } }
    func setPlaceholder(textColor: UIColor) { getTextField()?.setPlaceholder(textColor: textColor) }
    func setClearButton(color: UIColor) { getTextField()?.setClearButton(color: color) }

    func setTextField(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = 6
        case .prominent, .default: textField.backgroundColor = color
        @unknown default: break
        }
    }

    func setSearchImage(color: UIColor) {
        guard let imageView = getTextField()?.leftView as? UIImageView else { return }
        imageView.tintColor = color
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
    }
}

private extension UITextField {

    private class Label: UILabel {
        private var _textColor = UIColor.lightGray
        override var textColor: UIColor! {
            set { super.textColor = _textColor }
            get { return _textColor }
        }

        init(label: UILabel, textColor: UIColor = .lightGray) {
            _textColor = textColor
            super.init(frame: label.frame)
            self.text = label.text
            self.font = label.font
        }

        required init?(coder: NSCoder) { super.init(coder: coder) }
    }


    private class ClearButtonImage {
        static private var _image: UIImage?
        static private var semaphore = DispatchSemaphore(value: 1)
        static func getImage(closure: @escaping (UIImage?)->()) {
            DispatchQueue.global(qos: .userInteractive).async {
                semaphore.wait()
                DispatchQueue.main.async {
                    if let image = _image { closure(image); semaphore.signal(); return }
                    guard let window = UIApplication.shared.windows.first else { semaphore.signal(); return }
                    let searchBar = UISearchBar(frame: CGRect(x: 0, y: -200, width: UIScreen.main.bounds.width, height: 44))
                    window.rootViewController?.view.addSubview(searchBar)
                    searchBar.text = "txt"
                    searchBar.layoutIfNeeded()
                    _image = searchBar.getTextField()?.getClearButton()?.image(for: .normal)
                    closure(_image)
                    searchBar.removeFromSuperview()
                    semaphore.signal()
                }
            }
        }
    }

    func setClearButton(color: UIColor) {
        ClearButtonImage.getImage { [weak self] image in
            guard   let image = image,
                let button = self?.getClearButton() else { return }
            button.imageView?.tintColor = color
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }

    var placeholderLabel: UILabel? { return value(forKey: "placeholderLabel") as? UILabel }

    func setPlaceholder(textColor: UIColor) {
        guard let placeholderLabel = placeholderLabel else { return }
        let label = Label(label: placeholderLabel, textColor: textColor)
        setValue(label, forKey: "placeholderLabel")
    }

    func getClearButton() -> UIButton? { return value(forKey: "clearButton") as? UIButton }
}
