//
//  Extensions.swift
//  QuirkyByte
//
//  Created by iMAC on 23/03/18.
//  Copyright © 2018 BackBenchers. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

extension UIView {
    
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        let layer = self.layer
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.cornerRadius = 6
        
        let backgroundCGColor = self.backgroundColor?.cgColor
        self.backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    func addDashedBorder() {
        let color = UIColor.lightGray.cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [6,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
}

extension UIColor {
    static var appColor: UIColor {
        return UIColor(red: 255/255, green: 112/255, blue: 42/255, alpha: 1)
    }
    
    
}

extension UIButton {
    func toggleCheckbox (){
        isSelected = !isSelected
        setImage(UIImage(named:"checkBoxOn"), for: .selected)
        setImage(UIImage(named:"checkBoxOff"), for: .normal)
    }
    
    func blink(enabled: Bool = true, duration: CFTimeInterval = 0.5, stopAfter: CFTimeInterval = 0.0 ) {
        enabled ? (UIView.animate(withDuration: duration, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) },
            completion: { [weak self] _ in self?.transform = .identity })) : self.layer.removeAllAnimations()
        if !stopAfter.isEqual(to: 0.0) && enabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + stopAfter) { [weak self] in
                self?.layer.removeAllAnimations()
            }
        }
    }
    
    func animate(x: CGFloat = 0.975, y: CGFloat = 0.96, duration: Double = 0.2) {
//        UIButton.animate(withDuration: duration, animations: {
//            self.transform = CGAffineTransform(scaleX: x, y: y)}, completion: { finish in
//                UIButton.animate(withDuration: 0.2, animations: {
//                    self.transform = CGAffineTransform.identity })
//        })
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: x, y: y)
        }, completion: { finish in
            UIButton.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform.identity })
        })
    }
    
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 0.98
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        layer.add(pulse, forKey: nil)
    }
    
    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.3
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 2
        layer.add(flash, forKey: nil)
    }
    
    
}

final class CheckBoxButton: UIButton {
    static  let checkbox = CheckBoxButton()
    
    override func awakeFromNib() {
        self.setImage(UIImage(named:"checkBoxOn"), for: .selected)
        self.setImage(UIImage(named:"checkBoxOff"), for: .normal)
        self.addTarget(self, action: #selector(CheckBoxButton.buttonClicked(_:)), for: .touchUpInside)
    }
    
    
    
    @objc func buttonClicked(_ sender: UIButton) {
        //print("checkBox buttonClicked")
        //print(self)
        //print(sender)
        sender.isSelected = !sender.isSelected
        sender.setImage(UIImage(named:"checkBoxOn"), for: .selected)
        sender.setImage(UIImage(named:"checkBoxOff"), for: .normal)
    }
    
}


final class BackButton: UIButton {
    static  let checkbox = BackButton()
    typealias isPressed = (BackButton) -> ()
    var pressed :isPressed? {
        didSet {
            if pressed != nil {
                print("backButton Is Pressed  NOT Nil")
                addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            } else {
                print("backButton Is Pressed Nil")
                removeTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(BackButton.buttonClicked(_:)), for: .touchUpInside)
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        
        if let handler = pressed {
            print("class back button")
            sender.animate()
            handler(self)
        } else {
            print("pressed is Nil")
        }
//        let navigationController = window?.rootViewController as? UINavigationController
//        let viewControllers = navigationController?.viewControllers as? [UIViewController]
//        navigationController?.popToViewController(viewControllers![(viewControllers?.count)! - 2], animated: true)
    }
    
}

extension UINavigationController {
    
//    public func presentTransparentNavigationBar() {
//        navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
//        navigationBar.isTranslucent = true
//        navigationBar.shadowImage = UIImage()
//        setNavigationBarHidden(false, animated: true)
//    }
//    
//    public func hideTransparentNavigationBar() {
//        setNavigationBarHidden(true, animated:false)
//        navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: UIBarMetrics.default), for:UIBarMetrics.default)
//        navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
//        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
//        //navigationBar.barTintColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
//    }
}

extension Double {
    var stringWithTwoDigitsAfterDecimalPoint: String {
        return String(format: "%.2f", self)
    }
}

extension Int {
    var stringValue: String {
        return String(self)
    }
}


extension String {
    public func getMobileNumber() -> String {
        let firstTry = self.replacingOccurrences(of: " ", with: "")
        let secondTry = firstTry.replacingOccurrences(of: "-", with: "")
        let thirdTry = secondTry.replacingOccurrences(of: "(", with: "")
        let fourthTry = thirdTry.replacingOccurrences(of: ")", with: "")
        return fourthTry
    }
    
    public func createStringFromPhone() -> String {
        let str = self
        var newStr = ""
        for (index, i) in str.enumerated() {
            if index == 0 {
                newStr += "(\(i)"
            } else if index > 0 && index < 3 {
                newStr += "\(i)"
            } else if index == 3 {
                newStr += ") \(i)"
            } else if index > 3 && index < 6 {
                newStr += "\(i)"
            } else if index == 6 {
                newStr += "-\(i)"
            } else if index > 6 && index < 10 {
                newStr += "\(i)"
            }
        }
        return newStr
    }
}


public enum ImageFormat {
    case png
    case jpeg(CGFloat)
}

//extension UIImage {
//    
//    public func base64(format: ImageFormat) -> String? {
//        var imageData: Data?
//        switch format {
//        case .png: imageData = self.pngData()
//        case .jpeg(let compression): imageData = UIImageJPEGRepresentation(self, compression)
//        }
//        return imageData?.base64EncodedString()
//    }
//    
//    func isEqual(to image: UIImage) -> Bool {
//        guard let data1: Data = UIImagePNGRepresentation(self),
//            let data2: Data = UIImagePNGRepresentation(image) else {
//                return false
//        }
//        return data1.elementsEqual(data2)
//    }
//}

extension UIButton {
    func selectedButton(title:String, iconName: String, widthConstraints: NSLayoutConstraint){
        self.backgroundColor = UIColor(red: 0, green: 118/255, blue: 254/255, alpha: 1)
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .highlighted)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.white, for: .highlighted)
        self.setImage(UIImage(named: iconName), for: .normal)
        self.setImage(UIImage(named: iconName), for: .highlighted)
        let imageWidth = self.imageView!.frame.width
        let textWidth = (title as NSString).size(withAttributes:[NSAttributedString.Key.font:self.titleLabel!.font!]).width
        let width = textWidth + imageWidth + 24
        //24 - the sum of your insets from left and right
        widthConstraints.constant = width
        self.layoutIfNeeded()
    }
}

extension UIFont {
    func bold() -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits.traitBold)
        return UIFont(descriptor: descriptor!, size: 12)
    }
    
    func font(size: CGFloat) -> UIFont? {
        return UIFont.init(name: "ITC Serif Gothic Std", size: size)
    }
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
}

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}

extension CAGradientLayer {
    
    convenience init(frame: CGRect, colors: [UIColor]) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 0, y: 1)
    }
    
    func createGradientImage() -> UIImage? {
        
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
    
}


extension UINavigationBar {
    
    func setGradientBackground(colors: [UIColor]) {
        
        var updatedFrame = bounds
        updatedFrame.size.height += self.frame.origin.y
        
        let gradientLayer = CAGradientLayer(frame: updatedFrame, colors: colors)
        
        self.setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}


extension UICollectionViewCell {
    // The @objc is added to silence the complier errors
    @objc class var identifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell {
    // The @objc is added to silence the complier errors
    @objc class var identifier: String {
        return String(describing: self)
    }
}

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}


extension UIView
{
    // Create View Extensions to provide gradient effect to view.....
    func applyGradient(colours: [UIColor], cornerRadius : CGFloat? = 9) -> Void {
        self.applyGradient(colours: colours, locations: nil, cornerRadius : cornerRadius! )
    }
    func applyGradient(colours: [UIColor], locations: [NSNumber]?, cornerRadius : CGFloat) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = colours.map { $0.cgColor }
//        gradient.startPoint = CGPoint(x: 0, y: 0)
//        gradient.endPoint = CGPoint(x: 1, y: 0)
        //Horizontal
        gradient.endPoint = CGPoint(x: 0.9, y: 0.5)
        gradient.startPoint = CGPoint(x: 0, y: 0.8)
        gradient.frame = self.bounds
        gradient.cornerRadius = cornerRadius
        self.layer.insertSublayer(gradient, at: 0)
    }
    
}



extension UIView
{
    // Create View Extensions to provide gradient effect to view.....
    func applyTopToBottomGradient(colours: [UIColor], cornerRadius : CGFloat? = 9) -> Void {
        self.applyTopToBottomGradientWith(colours: colours, locations: nil, cornerRadius : cornerRadius!)
    }
    func applyTopToBottomGradientWith(colours: [UIColor], locations: [NSNumber]?, cornerRadius : CGFloat) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = colours.map { $0.cgColor }
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.frame = self.bounds
        gradient.cornerRadius = cornerRadius
        self.layer.insertSublayer(gradient, at: 0)
    }
}


final class CustomButton: UIButton {
    static  let checkbox = CustomButton()
    typealias isPressed = (CustomButton) -> ()
    var pressed :isPressed? {
        didSet {
            if pressed != nil {
                print("backButton Is Pressed  NOT Nil")
                addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            } else {
                print("backButton Is Pressed Nil")
                removeTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(CustomButton.buttonClicked(_:)), for: .touchUpInside)
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        
        if let handler = pressed {
            print("class back button")
            handler(self)
        } else {
            print("pressed is Nil")
        }
        //        let navigationController = window?.rootViewController as? UINavigationController
        //        let viewControllers = navigationController?.viewControllers as? [UIViewController]
        //        navigationController?.popToViewController(viewControllers![(viewControllers?.count)! - 2], animated: true)
    }
    
}

extension UIButton {
    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
}

extension String {
    var integerValue: Int {
        var _val = 0
        if let val = Int(self) {
            _val = val
        } else {
            _val = 0
        }
        return _val
    }
    
    var doubleValue: Double {
        var _val: Double = 0
        if let val = Double(self) {
            _val = val
        } else {
            _val = 0
        }
        return _val
    }
}

extension Double {
    var stringValue: String {
        return String(self)
    }
}

extension String {
    var stringValue: String {
        return String(self)
    }
}


extension Collection where Indices.Iterator.Element == Index {
    subscript (exist index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


extension UIViewController{
    /*func showHUD() {
        SVProgressHUD.setContainerView(self.view)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setBackgroundColor(UIColor.myGray)
        SVProgressHUD.show()
        
    }
    
    func hideHUD() {
        SVProgressHUD.dismiss()
    }
    
    func ShowHUDProgress(Progress:Float,Status:String){
        SVProgressHUD.setContainerView(self.view)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setBackgroundColor(UIColor.myGray)
        SVProgressHUD.showProgress(Progress, status: Status)
    }
    
    func SetHUDStatus(Status:String){
        SVProgressHUD.setStatus(Status)
    }
    func showHUDStatus(Status:String){
        SVProgressHUD.setContainerView(self.view)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setBackgroundColor(UIColor.myGray)
        SVProgressHUD.show(withStatus: Status)
    }*/
    
    func showMessage(Title:String,subTitle:String,theme:Theme) {
//        self.hideHUD()
        let success = MessageView.viewFromNib(layout: .cardView)
        success.configureTheme(theme)
        success.configureDropShadow()
        success.configureContent(title: Title, body: subTitle)
        success.button?.isHidden = true
        var successConfig = SwiftMessages.defaultConfig
        successConfig.presentationStyle = .top
        successConfig.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        SwiftMessages.show(config: successConfig, view: success)
    }
    
    func showMessageWithOption(Title:String,subTitle:String,btnTitle:String,handler:((UIButton) -> Void)?) {
        let success = MessageView.viewFromNib(layout: .cardView)
        success.configureDropShadow()
        //        success.titleLabel?.font = UIFont.init(name: "Avenir", size: 15)
        //        success.bodyLabel?.font = UIFont.init(name: "Avenir", size: 10)
        
        success.configureContent(title: Title, body: subTitle, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: btnTitle, buttonTapHandler: handler)
        var successConfig = SwiftMessages.defaultConfig
        successConfig.presentationStyle = .center
        successConfig.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        SwiftMessages.show(config: successConfig, view: success)
    }
    
    func showMessageCenterd(Title:String,subTitle:String) {
        let success = MessageView.viewFromNib(layout: .cardView)
        success.configureTheme(backgroundColor: #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1), foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        success.configureDropShadow()
        success.titleLabel?.font = UIFont.init(name: "Avenir", size: 15)
        success.bodyLabel?.font = UIFont.init(name: "Avenir", size: 10)
        //        success.button?.setTitle("Hide", for: .normal)
        success.configureContent(title: Title, body: subTitle, iconImage: nil, iconText: "", buttonImage: nil, buttonTitle: "Done") { _ in
            SwiftMessages.hide()
        }
        //        success.configureContent(title: Title, body: subTitle)
        var successConfig = SwiftMessages.defaultConfig
        successConfig.duration = .forever
        successConfig.presentationStyle = .center
        successConfig.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        SwiftMessages.show(config: successConfig, view: success)
    }
}


extension AppDelegate {
    static var _shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
//    var rootViewController: IntroVC {
//        return window!.rootViewController?.children.first as! IntroVC
//    }
}




private func _swizzling(forClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    if let originalMethod = class_getInstanceMethod(forClass, originalSelector),
       let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector) {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIViewController {

    static let preventPageSheetPresentation: Void = {
        if #available(iOS 13, *) {
            _swizzling(forClass: UIViewController.self,
                       originalSelector: #selector(present(_: animated: completion:)),
                       swizzledSelector: #selector(_swizzledPresent(_: animated: completion:)))
        }
    }()

    @available(iOS 13.0, *)
    @objc private func _swizzledPresent(_ viewControllerToPresent: UIViewController,
                                        animated flag: Bool,
                                        completion: (() -> Void)? = nil) {
        if viewControllerToPresent.modalPresentationStyle == .pageSheet
                   || viewControllerToPresent.modalPresentationStyle == .automatic {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        }
        _swizzledPresent(viewControllerToPresent, animated: flag, completion: completion)
    }
}


@IBDesignable class PaddingLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 0.0
    @IBInspectable var bottomInset: CGFloat = 0.0
    @IBInspectable var leftInset: CGFloat = 0.0
    @IBInspectable var rightInset: CGFloat = 0.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}


extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}


extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}


extension UIImage {
    
    public func base64(format: ImageFormat) -> String? {
        var imageData: Data?
        switch format {
        case .png: imageData = self.pngData()
        case .jpeg(let compression): imageData = self.jpegData(compressionQuality: compression)//UIImageJPEGRepresentation(self, compression)
        }
        return imageData?.base64EncodedString()
    }

}


