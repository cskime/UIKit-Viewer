//
//  DisplayView.swift
//  UIKitViewer
//
//  Created by cskim on 2020/02/05.
//  Copyright © 2020 cskim. All rights reserved.
//

import UIKit
import SnapKit
import Then

class DisplayView: UIView {
    
    private var previewObject = UIView()
    private let valueDisplay = UILabel().then {
        $0.font = .systemFont(ofSize: 20)
    }
    private var previewType: UIKitObject = .view
    
    // MARK: Initialize
    
    init(objectType: UIKitObject) {
        super.init(frame: .zero)
        self.previewType = objectType
        self.setupUI()
        self.addObserverForControl()
    }
    
    private func setupUI() {
        self.setupAttributes()
        self.setupObject()
    }
    
    private func setupAttributes() {
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        self.clipsToBounds = true
    }
    
    private func setupObject() {
        self.previewObject = self.previewType.makeInstance() ?? UIView()
        self.addSubview(self.previewObject)
        self.previewObject.snp.makeConstraints {
            $0.center.equalToSuperview()
            
            switch self.previewType {
            case .label, .textField:
                $0.width.equalToSuperview().dividedBy(2)
            case .slider:
                $0.width.equalToSuperview().dividedBy(1.5)
            case .imageView, .view:
                $0.size.equalToSuperview().multipliedBy(0.7)
            case .tableView, .collectionView:
                $0.size.equalToSuperview().multipliedBy(0.9)
            default:
                return
            }
        }
        
        self.setupAdditionalAttributes()
    }
    
    private func setupAdditionalAttributes() {
        switch self.previewType {
        case .switch:
            self.previewObject.isUserInteractionEnabled = false
        case .textField:
            guard let textField = self.previewObject as? UITextField else { return }
            textField.delegate = self
            self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        case .tableView:
            guard let tableView = self.previewObject as? UITableView else { return }
            tableView.dataSource = self
            tableView.delegate = self
        case .collectionView:
            guard let collectionView = self.previewObject as? UICollectionView else { return }
            collectionView.register(PreviewCollectionViewCell.self)
            collectionView.register(PreviewCollectionHeaderView.self, kind: .header)
            collectionView.register(PreviewCollectionFooterView.self, kind: .footer)
            collectionView.dataSource = self
            collectionView.delegate = self
        case .stepper:
            guard let stepper = self.previewObject as? UIStepper else { return }
            stepper.addTarget(self, action: #selector(stepperChanged(_:)), for: .valueChanged)
            self.setupValueMonitor(value: stepper.value.description)
        case .slider:
            guard let slider = self.previewObject as? UISlider else { return }
            slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
            self.setupValueMonitor(value: slider.value.description)
        case .pageControl:
            self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        case .datePicker:
            self.previewObject.transform = .init(scaleX: 0.8, y: 0.8)
        default:
            return
        }
    }
    
    private func setupValueMonitor(value: String) {
        self.addSubview(self.valueDisplay)
        self.valueDisplay.text = value
        self.valueDisplay.snp.makeConstraints {
            $0.centerX.equalTo(self.previewObject)
            $0.bottom.equalTo(self.previewObject.snp.top).offset(-8)
        }
    }
    
    // MARK: Actions
    
    @objc private func stepperChanged(_ sender: UIStepper) {
        self.valueDisplay.text = String(format: "%.1f", sender.value)
    }
    
    @objc private func sliderChanged(_ sender: UISlider) {
        self.valueDisplay.text = String(format: "%.1f", sender.value)
    }
    
    // MARK: Notification
    
    private func addObserverForControl() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(responseForControl(_:)),
                                               name: ControlCell.requestDisplayedObjectNotification,
                                               object: nil)
    }
    
    private func removeObserverForControl() {
        NotificationCenter.default.removeObserver(self,
                                                  name: ControlCell.requestDisplayedObjectNotification,
                                                  object: nil)
    }
    
    @objc private func responseForControl(_ noti: Notification) {
        guard let object = noti.object as? UIKitObject else { return }
        NotificationCenter.default.post(name: object.responseDisplayedObjectNotification,
                                        object: self.previewObject)
        self.removeObserverForControl()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

// MARK:- TextField Interfaces

extension DisplayView {
    
    func configure(text: String, for property: String, of object: UIKitObject) {
        let property = property.components(separatedBy: ".").last!
        
        switch object {
        case .button:       self.configureButton(title: text, for: property)
        case .label:        self.configureLabel(text: text, for: property)
        case .textField:    self.configureTextField(text: text, for: property)
        default: return
        }
    }
    
    private func configureButton(title: String, for property: String) {
        guard let button = self.previewObject as? UIButton else { return }
        
        switch property {
        case "setTitle":
            button.setTitle(title, for: .normal)
        default:
            return
        }
    }
    
    private func configureLabel(text: String, for property: String) {
        guard let label = self.previewObject as? UILabel else { return }
        
        switch property {
        case "text":
            label.text = text
        default:
            return
        }
    }
    
    private func configureTextField(text: String, for property: String) {
        guard let textField = self.previewObject as? UITextField else { return }
        
        switch property {
        case "text":
            textField.text = text
        case "placeholder":
            textField.placeholder = text
        default:
            return
        }
    }
}

// MARK:- Palette Interfaces

extension DisplayView {
    
    func configure(color: UIColor?, for property: String, of object: UIKitObject) {
        let property = property.components(separatedBy: ".").last!
        
        switch object {
        case .view:             self.configureView(color: color, for: property)
        case .button:           self.configureButton(color: color, for: property)
        case .label:            self.configureLabel(color: color, for: property)
        case .switch:           self.configureSwitch(color: color, for: property)
        case .slider:           self.configureSlider(color: color, for: property)
        case .textField:        self.configureTextField(color: color, for: property)
        case .tableView:        self.configureTableView(color: color, for: property)
        case .pageControl:      self.configurePageControl(color: color, for: property)
        case .activityIndicatorView:
            self.configureActivityIndicator(color: color, for: property)
        default:
            return
        }
    }
    
    private func configureActivityIndicator(color: UIColor?, for property: String) {
        guard let activityIndicator = self.previewObject as? UIActivityIndicatorView else { return }
        
        switch property {
        case "color":
            activityIndicator.color = color
        default:
            return
        }
    }
    
    private func configureSlider(color: UIColor?, for property: String) {
        guard let slider = self.previewObject as? UISlider else { return }
        
        switch property {
        case "thumbTintColor":                slider.thumbTintColor = color
        case "minimumTrackTintColor":         slider.minimumTrackTintColor = color
        case "maximumTrackTintColor":         slider.maximumTrackTintColor = color
        default:
            return
        }
    }
    
    private func configurePageControl(color: UIColor?, for property: String) {
        guard let pageControl = self.previewObject as? UIPageControl else { return }
        
        switch property {
        case "pageIndicatorTintColor":
            pageControl.pageIndicatorTintColor = color
        case "currentPageIndicatorTintColor":
            pageControl.currentPageIndicatorTintColor = color
        default:
            return
        }
    }
    
    private func configureView(color: UIColor?, for property: String) {
        switch property {
        case "backgroundColor":     self.previewObject.backgroundColor = color
        case "tintColor":           self.previewObject.tintColor = color
        case "borderColor":         self.previewObject.layer.borderColor = color?.cgColor
        default:
            return
        }
    }
    
    private func configureSwitch(color: UIColor?, for property: String) {
        guard let `switch` = self.previewObject as? UISwitch else { return }
        
        switch property {
        case "onTintColor":       `switch`.onTintColor = color
        case "thumbTintColor":    `switch`.thumbTintColor = color
        default:
            return
        }
    }
    
    private func configureButton(color: UIColor?, for property: String) {
        guard let button = self.previewObject as? UIButton else { return }
        
        switch property {
        case "setTitleColor":     button.setTitleColor(color, for: .normal)
        default:
            return
        }
    }
    
    private func configureLabel(color: UIColor?, for property: String) {
        guard let label = self.previewObject as? UILabel else { return }
        
        switch property {
        case "textColor":     label.textColor = color
        default:
            return
        }
    }
    
    private func configureTextField(color: UIColor?, for property: String) {
        guard let textField = self.previewObject as? UITextField else { return }
        
        switch property {
        case "textColor":     textField.textColor = color
        default:
            return
        }
    }
    
    private func configureTableView(color: UIColor?, for property: String) {
        guard let tableView = self.previewObject as? UITableView else { return }
        
        switch property {
        case "separatorColor":      tableView.separatorColor = color
        default:
            return
        }
    }
}

// MARK:- Toggle Interfaces

extension DisplayView {
    
    func configure(isOn: Bool, for property: String, of object: UIKitObject) {
        let property = property.components(separatedBy: ".").last!
        
        switch object {
        case .view:           self.configureView(isOn: isOn, of: property)
        case .button:         self.configureButton(isOn: isOn, of: property)
        case .label:          self.configureLabel(isOn: isOn, of: property)
        case .textField:      self.configureTextField(isOn: isOn, of: property)
        case .stepper:        self.configureStepper(isOn: isOn, of: property)
        case .slider:         self.configureSlider(isOn: isOn, of: property)
        case .switch:         self.configureSwitch(isOn: isOn, of: property)
        case .pageControl:    self.configurePageControl(isOn: isOn, of: property)
        case .tableView:      self.configureTableView(isOn: isOn, of: property)
        case .collectionView: self.configureCollectionView(isOn: isOn, of: property)
        case .activityIndicatorView:
            self.configureActivityIndicator(isOn: isOn, of: property)
        default:
            return
        }
    }
    
    private func configureActivityIndicator(isOn: Bool, of property: String) {
        guard let activityIndicator = self.previewObject as? UIActivityIndicatorView else { return }
        
        switch property {
        case "hidesWhenStopped":
            activityIndicator.hidesWhenStopped = isOn
        default:
            return
        }
    }
    
    private func configureSlider(isOn: Bool, of property: String) {
        guard let slider = self.previewObject as? UISlider else { return }
        
        switch property {
        case "minimumValueImage":
            slider.minimumValueImage = isOn ? ImageReference.minus : nil
        case "maximumValueImage":
            slider.maximumValueImage = isOn ? ImageReference.plus : nil
        default:
            return
        }
    }
    
    private func configureCollectionView(isOn: Bool, of property: String) {
        guard let collectionView = self.previewObject as? UICollectionView,
              let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        switch property {
        case "sectionHeadersPinToVisibleBounds":      layout.sectionHeadersPinToVisibleBounds = isOn
        case "sectionFootersPinToVisibleBounds":      layout.sectionFootersPinToVisibleBounds = isOn
        default:
            return
        }
    }
    
    private func configureTableView(isOn: Bool, of property: String) {
        guard let tableView = self.previewObject as? UITableView else { return }
        
        switch property {
        case "setEditing":
            tableView.setEditing(isOn, animated: true)
        case "isEditing":
            tableView.isEditing = isOn
        default:
            return
        }
    }
    
    private func configurePageControl(isOn: Bool, of property: String) {
        guard let pageControl = self.previewObject as? UIPageControl else { return }
        
        switch property {
        case "hidesForSinglePage":
            pageControl.hidesForSinglePage = isOn
        default:
            return
        }
    }
    
    private func configureLabel(isOn: Bool, of property: String) {
        guard let label = self.previewObject as? UILabel else { return }
        
        switch property {
        case "adjustsFontSizeToFitWidth":
            label.adjustsFontSizeToFitWidth = isOn
        case "allowsDefaultTighteningForTruncation":
            label.allowsDefaultTighteningForTruncation = isOn
        default:
            return
        }
    }
    
    private func configureView(isOn: Bool, of property: String) {
        switch property {
        case "isHidden":        self.previewObject.isHidden = isOn
        case "clipsToBounds":   self.previewObject.clipsToBounds = isOn
        default:
            return
        }
    }
    
    private func configureTextField(isOn: Bool, of property: String) {
        guard let textField = self.previewObject as? UITextField else { return }
        
        switch property {
        case "adjustsFontSizeToFitWidth":
            textField.adjustsFontSizeToFitWidth = isOn
        case "clearsOnBeginEditing":
            textField.clearsOnBeginEditing = isOn
        default:
            return
        }
    }
    
    private func configureButton(isOn: Bool, of property: String) {
        guard let button = self.previewObject as? UIButton else { return }
        let image: UIImage? = isOn ? ImageReference.dummy : nil
        
        switch property {
        case "setImage":              button.setImage(image, for: .normal)
        case "setBackgroundImage":    button.setBackgroundImage(image, for: .normal)
        default:
            return
        }
    }
    
    private func configureStepper(isOn: Bool, of property: String) {
        guard let stepper = self.previewObject as? UIStepper else { return }
        let image: UIImage? = isOn ? ImageReference.dummy : nil
        
        switch property {
        case "wraps":                 stepper.wraps = isOn
        case "setBackgroundImage":    stepper.setBackgroundImage(image, for: .normal)
        case "setIncrementImage":     stepper.setIncrementImage(image, for: .normal)
        case "setDecrementImage":     stepper.setDecrementImage(image, for: .normal)
        case "setDividerImage":       stepper.setDividerImage(image, forLeftSegmentState: .normal, rightSegmentState: .normal)
        default:
            return
        }
    }
    
    private func configureSwitch(isOn: Bool, of property: String) {
        guard let `switch` = self.previewObject as? UISwitch else { return }
        
        switch property {
        case "isOn":    `switch`.isOn = isOn
        case "setOn":   `switch`.setOn(isOn , animated: true)
        default:
            return
        }
    }
}

// MARK:- Slider Interfaces

extension DisplayView {
    
    func configure(value: Float, for property: String, of object: UIKitObject) {
        let property = property.components(separatedBy: ".").last!
        let value = CGFloat(value)
        
        switch object {
        case .view:             self.configureView(value: value, for: property)
        case .label:            self.configureLabel(value: value, for: property)
        case .collectionView:   self.configureCollectionView(value: value, for: property)
        case .textField:        self.configureTextField(value: value, for: property)
        default:
            return
        }
    }
    
    private func configureTextField(value: CGFloat, for property: String) {
        guard let textField = self.previewObject as? UITextField else { return }
        
        switch property {
        case "minimumFontSize":
            if textField.adjustsFontSizeToFitWidth {
                textField.minimumFontSize = value
                func adjustFontSizeDynamically() {
                    textField.adjustsFontSizeToFitWidth = false
                    textField.adjustsFontSizeToFitWidth = true
                }
                adjustFontSizeDynamically()
            }
        default:
            return
        }
    }
    
    private func configureLabel(value: CGFloat, for property: String) {
        guard let label = self.previewObject as? UILabel else { return }
        
        switch property {
        case "minimumScaleFactor":
            if label.adjustsFontSizeToFitWidth {
                label.minimumScaleFactor = value
                func adjustScaleFactorDynamically() {
                    label.adjustsFontSizeToFitWidth = false
                    label.adjustsFontSizeToFitWidth = true
                }
                adjustScaleFactorDynamically()
            }
        default:
            return
        }
    }
    
    private func configureView(value: CGFloat, for property: String) {
        switch property {
        case "alpha":           self.previewObject.alpha = value
        case "borderWidth":     self.previewObject.layer.borderWidth = value
        case "cornerRadius":    self.previewObject.layer.cornerRadius = value
        default:
            return
        }
    }
    
    private func configureCollectionView(value: CGFloat, for property: String) {
        guard let collectionView = self.previewObject as? UICollectionView,
              let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        else { return }
        
        switch property {
        case "itemSize":                    layout.itemSize = CGSize(width: value, height: value)
        case "minimumInteritemSpacing":     layout.minimumInteritemSpacing = value
        case "minimumLineSpacing":          layout.minimumLineSpacing = value
        case "sectionInset":                layout.sectionInset = .init(top: value, left: value, bottom: value, right: value)
        case "headerReferenceSize":         layout.headerReferenceSize = CGSize(width: value, height: value)
        case "footerReferenceSize":         layout.footerReferenceSize = CGSize(width: value, height: value)
        default:
            return
        }
    }
}

// MARK:- Select Interfaces

extension DisplayView {
    
    func configure(rawValue: Int, for property: String, of object: UIKitObject) {
        let property = property.components(separatedBy: ".").last!
        
        switch object {
        case .view:           self.configureView(rawValue: rawValue, for: property)
        case .tableView:      self.configureTableView(rawValue: rawValue, for: property)
        case .textField:      self.configureTextField(rawValue: rawValue, for: property)
        case .button:         self.configureButton(rawValue: rawValue, for: property)
        case .label:          self.configureLabel(rawValue: rawValue, for: property)
        case .collectionView: self.configureCollectionView(rawValue: rawValue, for: property)
        case .activityIndicatorView:
            self.configureActivityIndicator(rawValue: rawValue, for: property)
        case .datePicker:
            self.configureDatePicker(rawValue: rawValue, for: property)
        default:
            return
        }
    }
    
    private func configureDatePicker(rawValue: Int, for property: String) {
        guard let datePicker = self.previewObject as? UIDatePicker else { return }
        
        switch property {
        case "datePickerMode":
            let mode = UIDatePicker.Mode(rawValue: rawValue) ?? .dateAndTime
            datePicker.datePickerMode = mode
        case "preferredDatePickerStyle":
            if #available(iOS 13.4, *) {
                let style = UIDatePickerStyle(rawValue: rawValue) ?? .automatic
                datePicker.preferredDatePickerStyle = style
            }
        default:
            return
        }
    }
    
    private func configureActivityIndicator(rawValue: Int, for property: String) {
        guard let activityIndicator = self.previewObject as? UIActivityIndicatorView else { return }
        
        switch property {
        case "style":
            let style = UIActivityIndicatorView.Style(rawValue: rawValue + 100) ?? .medium
            activityIndicator.style = style
        default:
            return
        }
    }
    
    private func configureCollectionView(rawValue: Int, for property: String) {
        guard let collectionView = self.previewObject as? UICollectionView,
              let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        switch property {
        case "scrollDirection":
            let direction = UICollectionView.ScrollDirection(rawValue: rawValue) ?? .vertical
            flowLayout.scrollDirection = direction
        default:
            return
        }
    }
    
    private func configureLabel(rawValue: Int, for property: String) {
        guard let label = self.previewObject as? UILabel else { return }
        
        switch property {
        case "lineBreakMode":
            let mode = NSLineBreakMode(rawValue: rawValue) ?? .byTruncatingTail
            label.lineBreakMode = mode
        case "textAlignment":
            let alignment = NSTextAlignment(rawValue: rawValue) ?? .left
            label.textAlignment = alignment
        default:
            return
        }
    }
    
    private func configureView(rawValue: Int, for property: String) {
        switch property {
        case "contentMode":
            self.previewObject.contentMode = UIView.ContentMode(rawValue: rawValue) ?? .scaleToFill
        default:
            return
        }
    }
    
    private func configureTableView(rawValue: Int, for property: String) {
        guard let tableView = self.previewObject as? UITableView else { return }
        switch property {
        case "style":
            let style = UITableView.Style(rawValue: rawValue) ?? .plain
            self.replaceTableViewStyle(to: style)
        case "separatorStyle":
            let style = UITableViewCell.SeparatorStyle(rawValue: rawValue) ?? .singleLine
            tableView.separatorStyle = style
        default:
            return
        }
    }
    
    private func replaceTableViewStyle(to style: UITableView.Style) {
        self.previewObject.removeConstraints(self.previewObject.constraints)
        self.previewObject.removeFromSuperview()
        
        let tableView = UITableView(frame: .zero, style: style).then {
            $0.dataSource = self
            $0.delegate = self
        }
        self.previewObject = tableView
        
        self.addSubview(self.previewObject)
        self.previewObject.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalToSuperview().multipliedBy(0.9)
        }
    }
    
    private func configureTextField(rawValue: Int, for property: String) {
        guard let textField = self.previewObject as? UITextField else { return }
        
        let lrView = UIView().then {
            $0.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            $0.backgroundColor = .gray
        }
        textField.leftView = lrView
        textField.rightView = lrView
        
        switch property {
        case "borderStyle":
            textField.borderStyle = UITextField.BorderStyle(rawValue: rawValue) ?? .none
        case "clearButtonMode":
            textField.clearButtonMode = UITextField.ViewMode(rawValue: rawValue) ?? .never
        case "leftViewMode":
            let mode = UITextField.ViewMode(rawValue: rawValue) ?? .never
            textField.leftView = mode == .never ? nil : lrView
            textField.leftViewMode = mode
        case "rightViewMode":
            let mode = UITextField.ViewMode(rawValue: rawValue) ?? .never
            textField.rightView = mode == .never ? nil : lrView
            textField.rightViewMode = mode
        case "textAlignment":
            textField.textAlignment = NSTextAlignment(rawValue: rawValue) ?? .left
        default:
            return
        }
    }
    
    private func configureButton(rawValue: Int, for property: String) {
        switch property {
        case "buttonType":
            let type = UIButton.ButtonType(rawValue: rawValue) ?? .system
            self.replaceButtonType(to: type)
        default:
            return
        }
    }
    
    private func replaceButtonType(to type: UIButton.ButtonType) {
        guard let currentButton = self.previewObject as? UIButton,
              let currentTitle = currentButton.currentTitle else { return }
        self.previewObject.removeConstraints(self.previewObject.constraints)
        self.previewObject.removeFromSuperview()
        
        let newButton = UIButton(type: type)
        newButton.setTitle(currentTitle, for: .normal)
        self.previewObject = newButton
        
        self.addSubview(self.previewObject)
        self.previewObject.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

// MARK:- Stepper Interfaces

extension DisplayView {
    func configure(value: Double, for property: String, of object: UIKitObject) {
        let property = property.components(separatedBy: ".").last!
        
        switch object {
        case .pageControl:    self.configurePageControl(value: Int(value), for: property)
        case .label:          self.configureLabel(value: Int(value), for: property)
        case .stepper:        self.configureStepper(value: value, of: property)
        case .slider:         self.configureSlider(value: Float(value), of: property)
        default:
            return
        }
    }
    
    private func configureSlider(value: Float, of property: String) {
        guard let slider = self.previewObject as? UISlider else { return }
        
        switch property {
        case "minimumValue":    slider.minimumValue = value
        case "maximumValue":    slider.maximumValue = value
        default:
            return
        }
        
        self.valueDisplay.text = String(format: "%.1f", slider.value)
    }
    
    private func configureStepper(value: Double, of property: String) {
        guard let stepper = self.previewObject as? UIStepper else { return }
        
        switch property {
        case "minimumValue":    stepper.minimumValue = value
        case "maximumValue":    stepper.maximumValue = value
        case "stepValue":       stepper.stepValue = value
        default:
            return
        }
        
        self.valueDisplay.text = stepper.value.description
    }
    
    private func configurePageControl(value: Int, for property: String) {
        guard let pageControl = self.previewObject as? UIPageControl else { return }
        
        switch property {
        case "currentPage":     pageControl.currentPage = value
        case "numberOfPages":   pageControl.numberOfPages = value
        default:
            return
        }
    }
    
    private func configureLabel(value: Int, for property: String) {
        guard let label = self.previewObject as? UILabel else { return }
        
        switch property {
        case "numberOfLines":
            label.numberOfLines = value
        default:
            return
        }
    }
}

// MARK:- Method Call Interface

extension DisplayView {
    func callMethod(method: String, of object: UIKitObject) {
        switch object {
        case .activityIndicatorView:
            self.callFromActivitiIndicator(method: method)
        default:
            return
        }
    }
    
    private func callFromActivitiIndicator(method: String) {
        guard let activityIndicator = self.previewObject as? UIActivityIndicatorView else { return }
        
        switch method {
        case "startAnimating":
            activityIndicator.startAnimating()
        case "stopAnimating":
            activityIndicator.stopAnimating()
        default:
            return
        }
    }
}

// MARK:- UITableViewDataSource

extension DisplayView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell()
        cell.textLabel?.text = "Row \(indexPath.row)"
        //    cell.textLabel?.font = .systemFont(ofSize: 12)
        return cell
    }
    
}

// MARK:- UITableViewDelegate

extension DisplayView: UITableViewDelegate {
    
}

// MARK:- UICollectionViewDataSource

extension DisplayView: UICollectionViewDataSource {
    
    private var colors: [UIColor] { return [#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), #colorLiteral(red: 0.7185149789, green: 0.8868054748, blue: 0.8961318135, alpha: 1), #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)] }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(PreviewCollectionViewCell.self, indexPath: indexPath)
        cell.setText("Item \(indexPath.item)")
        cell.backgroundColor = self.colors[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView: UICollectionReusableView
        if kind.contains("Header") {
            let header = collectionView.dequeueReusableView(PreviewCollectionHeaderView.self, kind: kind, indexPath: indexPath)
            header.setText("Header \(indexPath.section)")
            reusableView = header
        } else {
            let footer = collectionView.dequeueReusableView(PreviewCollectionFooterView.self, kind: kind, indexPath: indexPath)
            footer.setText("Footer \(indexPath.section)")
            reusableView = footer
        }
        reusableView.backgroundColor = self.colors[indexPath.section]
        return reusableView
    }
}

// MARK:- UICollectionViewDelegateFlowLayout

extension DisplayView: UICollectionViewDelegateFlowLayout {
    
}

// MARK:- UITextFieldDelegate

extension DisplayView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
