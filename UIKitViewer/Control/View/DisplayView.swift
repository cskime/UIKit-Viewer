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
  private var previewType: UIKitObject = .UIView
  
  // MARK: Initialize
  
  init(objectType: UIKitObject) {
    super.init(frame: .zero)
    self.previewType = objectType
    self.setupUI()
  }
  
  private func setupUI() {
    self.setupAttributes()
    self.setupObject()
    self.setupConstraint()
  }
  
  private func setupAttributes() {
    self.layer.cornerRadius = 8
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.lightGray.cgColor
    self.backgroundColor = .white
    self.clipsToBounds = true
  }
  
  private func setupObject() {
    self.previewObject = self.previewType.makeInstance() ?? UIView()
    
    switch self.previewType {
    case .UITextField:
      guard let textField = self.previewObject as? UITextField else { return }
      textField.delegate = self
    case .UITableView:
      guard let tableView = self.previewObject as? UITableView else { return }
      tableView.dataSource = self
      tableView.delegate = self
    case .UICollectionView:
      guard let collectionView = self.previewObject as? UICollectionView else { return }
      collectionView.dataSource = self
      collectionView.delegate = self
    default:
      return
    }
  }
  
  private func setupConstraint() {
    self.addSubview(self.previewObject)
    self.previewObject.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    
    self.previewObject.snp.makeConstraints { [weak self] in
      guard let self = self else { return }
      
      switch self.previewType {
      case .UILabel, .UIButton:
        $0.width.lessThanOrEqualToSuperview().dividedBy(2)
      case .UITextField:
        $0.width.equalToSuperview().dividedBy(2)
      case .UIImageView, .UIView, .UITableView, .UICollectionView:
        $0.size.equalToSuperview().multipliedBy(0.9)
      default:
        return
      }
    }
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
    case .UIButton:       self.configureButton(title: text, for: property)
    case .UILabel:        self.configureLabel(text: text, for: property)
    case .UITextField:    self.configureTextField(text: text, for: property)
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
    case .UIView:             self.configureView(color: color, for: property)
    case .UIButton:           self.configureButton(color: color, for: property)
    case .UILabel:            self.configureLabel(color: color, for: property)
    case .UISwitch:           self.configureSwitch(color: color, for: property)
    case .UITextField:        self.configureTextField(color: color, for: property)
    case .UITableView:        self.configureTableView(color: color, for: property)
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
    case .UIView:           self.configureView(isOn: isOn, of: property)
    case .UIButton:         self.configureButton(isOn: isOn, of: property)
    case .UITextField:      self.configureTextField(isOn: isOn, of: property)
    case .UIStepper:        self.configureStepper(isOn: isOn, of: property)
    case .UISwitch:         self.configureSwitch(isOn: isOn, of: property)
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
    case "placeholder":
      textField.placeholder = isOn ? "placeholder" : ""
    default:
      return
    }
  }
  
  private func configureButton(isOn: Bool, of property: String) {
    guard let button = self.previewObject as? UIButton else { return }
    let image: UIImage? = isOn ? UIImage(named: "UIImageView") : nil
    
    switch property {
    case "setImage":              button.setImage(image, for: .normal)
    case "setBackgroundImage":    button.setBackgroundImage(image, for: .normal)
    default:
      return
    }
  }
  
  private func configureStepper(isOn: Bool, of property: String) {
    guard let stepper = self.previewObject as? UIStepper else { return }
    let image: UIImage? = isOn ? UIImage(named: "UIImageView") : nil
    
    switch property {
    case "setIncrementImage":     stepper.setIncrementImage(image, for: .normal)
    case "setDecrementImage":     stepper.setDecrementImage(image, for: .normal)
    case "setDividerImage":       stepper.setDividerImage(image, forLeftSegmentState: .normal, rightSegmentState: .normal)
    case "setBackgroundImage":    stepper.setBackgroundImage(image, for: .normal)
    default:
      return
    }
  }
  
  private func configureSwitch(isOn: Bool, of property: String) {
    guard let `switch` = self.previewObject as? UISwitch else { return }
    
    switch property {
    case "isOn":
      `switch`.isOn = isOn
    case "setOn":
      `switch`.setOn(isOn , animated: true)
    default:
      return
    }
  }
}

// MARK:- Slider Interfaces

extension DisplayView {
  
  func configure(value: Float, for property: String, of object: UIKitObject) {
    let property = property.components(separatedBy: ".").last!
    
    switch object {
    case .UIView:                 self.configureView(value: CGFloat(value), for: property)
    case .UICollectionView:       self.configureCollectionView(value: CGFloat(value), for: property)
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
    case .UIView:           self.configureView(rawValue: rawValue, for: property)
    case .UITableView:      self.configureTableView(rawValue: rawValue, for: property)
    case .UITextField:      self.configureTextField(rawValue: rawValue, for: property)
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
    switch property {
    case "style":
      let style = UITableView.Style(rawValue: rawValue) ?? .plain
      self.replaceTableViewStyle(to: style)
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
    
    switch property {
    case "borderStyle":
      textField.borderStyle = UITextField.BorderStyle(rawValue: rawValue) ?? .none
    case "clearButtonMode":
      textField.clearButtonMode = UITextField.ViewMode(rawValue: rawValue) ?? .never
    default:
      return
    }
  }
}

// MARK:- Stepper Interfaces

extension DisplayView {
  func configure(value: Int, for property: String, of object: UIKitObject) {
    let property = property.components(separatedBy: ".").last!
    
    switch object {
    case .UIPageControl:    self.configurePageControl(value: value, for: property)
    case .UILabel:          self.configureLabel(value: value, for: property)
    default:
      return
    }
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

// MARK:- UITableViewDataSource

extension DisplayView: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Section \(section)"
  }
  
  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return nil
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell()
    cell.textLabel?.text = "Section : \(indexPath.section), Row: \(indexPath.row)"
    //    cell.textLabel?.font = .systemFont(ofSize: 12)
    return cell
  }
  
}

// MARK:- UITableViewDelegate

extension DisplayView: UITableViewDelegate {
  
}

// MARK:- UICollectionViewDataSource

extension DisplayView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 20
  }
  
  var colorsForItem: UIColor? {
    get {
      let colors = [#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
      return colors.randomElement()
    }
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    cell.backgroundColor = self.colorsForItem
    return cell
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
