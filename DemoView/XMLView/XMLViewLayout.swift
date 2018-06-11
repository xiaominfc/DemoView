//
//  XMLViewLayout.swift
//  DemoView
//
//  Created by xiaominfc on 2018/6/6.
//  Copyright © 2018 xiaominfc. All rights reserved.
//

import UIKit
import libxml2

class BaseViewAttri {
    
    init() {
        ViewFatoryHelper.sharedInstance.registerView(name: self.tagName(),attri:self)
    }
    
    func bindAttriToView(node:XMLNode, view:UIView){
        let defaultValue:Float = 0.0
        let frame_x = CGFloat(attriForNode(node: node, name: "frame_x", defaultValue: defaultValue));
        let frame_y = CGFloat(attriForNode(node: node, name: "frame_y", defaultValue: defaultValue));
        let frame_w = CGFloat(attriForNode(node: node, name: "width", defaultValue: defaultValue));
        let frame_h = CGFloat(attriForNode(node: node, name: "height", defaultValue: defaultValue));
        
        if (frame_h > 0 && frame_w > 0) {
                view.frame = CGRect(x: frame_x , y: frame_y, width: frame_w, height: frame_h)
        }
        
        if let colorStr = node.attri("background_color") {
            view.backgroundColor = UIColor(hex: colorStr)
        }
        
        if let colorStr = node.attri("border_color") {
            view.layer.masksToBounds = true;
            view.layer.borderColor = UIColor(hex: colorStr).cgColor
        }
        
        let border = CGFloat(attriForNode(node: node, name: "border", defaultValue: defaultValue));
        if border > 0 {
            view.layer.masksToBounds = true;
            view.layer.borderWidth = border
        }
        
        let cornerRadius = CGFloat(attriForNode(node: node, name: "corner", defaultValue: defaultValue));
        if cornerRadius > 0 {
            view.layer.masksToBounds = true;
            view.layer.cornerRadius = cornerRadius
        }
        
        if let idStr = node.attri("id")  {
            view.idStr = idStr
        }
    }
    
    func instanceView() -> UIView {
        return UIView()
    }
    
    func tagName() -> String {
        return String(describing: UIView.self)
    }
    
    func instanceLayoutParams(_ node:XMLNode) -> LayoutParams {
        return  LayoutParams(node)
    }
    
    
    func layoutByRules(_ rootView:UIView){
        
    }
}


class RelativeLayoutAttri: BaseViewAttri {
    
    override func tagName() -> String {
        return String(describing: RelativeLayout.self)
    }
    
    override func instanceView() -> UIView {
        return RelativeLayout()
    }
    
    
    override func instanceLayoutParams(_ node:XMLNode) -> LayoutParams {
        return  RelativeLayoutParams(node)
    }
    
    
    override func layoutByRules(_ rootView:UIView){
            for  child in rootView.subviews {
                child.translatesAutoresizingMaskIntoConstraints = false;
                if let mLayoutParams = child.layoutParams as? RelativeLayoutParams {
                    _ = layoutChildV(child,rootView, mLayoutParams)
                    _ = layoutChildH(child,rootView, mLayoutParams)
                }
            }
    
    }
    
    
    func layoutChildV(_ child:UIView,_ rootView:UIView,_ mLayoutParams:RelativeLayoutParams) -> Int{
        var result:Int = 0;
        if mLayoutParams.center_v_parent != nil {
            rootView.childCenterX(child, rootView, offset: mLayoutParams.offset_v)
            return RelativeLayoutSide.Left.rawValue + RelativeLayoutSide.Right.rawValue
        }
        
        if mLayoutParams.center_v_of != nil {
            if let relayoutView = rootView.findViewById(mLayoutParams.center_v_of!) {
                rootView.childCenterX(child, relayoutView, offset: mLayoutParams.offset_v)
                return RelativeLayoutSide.Left.rawValue + RelativeLayoutSide.Right.rawValue
            }
        }
        if mLayoutParams.rightOf != nil{
            if let relayoutView = rootView.findViewById(mLayoutParams.rightOf!) {
                let con =  NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: relayoutView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: mLayoutParams.marginLeft)
                rootView.addConstraint(con)
                result = RelativeLayoutSide.Left.rawValue
            }
            if mLayoutParams.right_of_align != nil {
                if let relayoutView = rootView.findViewById(mLayoutParams.right_of_align!) {
                    rootView.layoutViewToSide(child, targetView: relayoutView, margin: mLayoutParams.marginRight, attribute: NSLayoutAttribute.trailing)
                    result = result + RelativeLayoutSide.Right.rawValue
                }
            }
        }
        
        if result&RelativeLayoutSide.Right.rawValue != RelativeLayoutSide.Right.rawValue {
            if mLayoutParams.leftOf != nil{
                if let relayoutView = rootView.findViewById(mLayoutParams.leftOf!) {
                    let con =  NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: relayoutView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: mLayoutParams.marginRight)
                    rootView.addConstraint(con)
                    result = result + RelativeLayoutSide.Right.rawValue
                }
            }else if mLayoutParams.right_of_align != nil {
                if let relayoutView = rootView.findViewById(mLayoutParams.right_of_align!) {
                    rootView.layoutViewToSide(child, targetView: relayoutView, margin: mLayoutParams.marginRight, attribute: NSLayoutAttribute.trailing)
                    result = result + RelativeLayoutSide.Right.rawValue
                }
            }
        }
        
        
        var targetView:UIView? = nil
        if let relayoutView = rootView.findViewById(mLayoutParams.left_of_align) {
            targetView = relayoutView
        }else if result == 0 {
            targetView = rootView
        }
        
        if targetView != nil {
            rootView.layoutViewToSide(child, targetView: targetView!, margin: mLayoutParams.marginLeft, attribute: NSLayoutAttribute.leading)
            result = result + RelativeLayoutSide.Left.rawValue
        }
        return result;
    }
    
    
    func layoutChildH(_ child:UIView,_ rootView:UIView,_ mLayoutParams:RelativeLayoutParams) -> Int{
        var result:Int = 0;
        if mLayoutParams.center_h_parent != nil {
            rootView.childCenterY(child, rootView, offset: mLayoutParams.offset_h)
            return RelativeLayoutSide.Top.rawValue + RelativeLayoutSide.Bottom.rawValue
        }
        
        if mLayoutParams.center_h_of != nil {
            if let relayoutView = rootView.findViewById(mLayoutParams.center_h_of!) {
                rootView.childCenterY(child, relayoutView, offset: mLayoutParams.offset_h)
                return RelativeLayoutSide.Top.rawValue + RelativeLayoutSide.Bottom.rawValue
            }
        }
        if mLayoutParams.bottomOf != nil{
            if let relayoutView = rootView.findViewById(mLayoutParams.bottomOf!) {
                let con =  NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: relayoutView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: mLayoutParams.marginTop)
                rootView.addConstraint(con)
                result = RelativeLayoutSide.Top.rawValue
            }
            if mLayoutParams.bottom_of_align != nil {
                if let relayoutView = rootView.findViewById(mLayoutParams.bottom_of_align!) {
                    rootView.layoutViewToSide(child, targetView: relayoutView, margin: mLayoutParams.marginBottom, attribute: NSLayoutAttribute.bottom)
                    result = result + RelativeLayoutSide.Bottom.rawValue
                }
            }
        }
        
        if result&RelativeLayoutSide.Bottom.rawValue != RelativeLayoutSide.Bottom.rawValue {
            if mLayoutParams.topOf != nil{
                if let relayoutView = rootView.findViewById(mLayoutParams.topOf) {
                    let con =  NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: relayoutView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: mLayoutParams.marginBottom)
                    rootView.addConstraint(con)
                    result = result + RelativeLayoutSide.Bottom.rawValue
                }
            } else if mLayoutParams.bottom_of_align != nil {
                
                if let relayoutView = rootView.findViewById(mLayoutParams.bottom_of_align) {
                    rootView.layoutViewToSide(child, targetView: relayoutView, margin: mLayoutParams.marginBottom, attribute: NSLayoutAttribute.bottom)
                    result = result + RelativeLayoutSide.Bottom.rawValue
                }
            }
        }
        
        
        var targetView:UIView? = nil
        if let relayoutView = rootView.findViewById(mLayoutParams.top_of_align) {
            targetView = relayoutView
        }else if result == 0 {
            targetView = rootView
        }
        
        if targetView != nil {
            rootView.layoutViewToSide(child, targetView: targetView!, margin: mLayoutParams.marginTop, attribute: NSLayoutAttribute.top)
            result = result + RelativeLayoutSide.Top.rawValue
        }
        
        
        
        return result;
    }
}

class UILabelAttri:BaseViewAttri {
    override func bindAttriToView(node: XMLNode, view: UIView) {
        super.bindAttriToView(node: node, view: view)
        if let label = view as? UILabel {
            if let text = node.attri("text") {
                label.text = text
            }
            
            if let colorStr = node.attri("text_color") {
                label.textColor = UIColor(hex: colorStr)
            }
            
            let defaultFontSize = Float(label.font.pointSize);
            let newSize = CGFloat(attriForNode(node: node, name: "font", defaultValue: defaultFontSize));
            label.font = UIFont(name: label.font.fontName, size: newSize);
            label.sizeToFit()
        }
    }
    
    override func tagName() -> String {
        return String(describing: UILabel.self)
    }
    
    
    override func instanceView() -> UIView {
        return UILabel()
    }
}


class UIImageViewAttri:BaseViewAttri {
    override func bindAttriToView(node: XMLNode, view: UIView) {
        super.bindAttriToView(node: node, view: view)
        if let imageView = view as? UIImageView {
            if let src = node.attri("src") {
                imageView.image = UIImage(named: src)?.resized(newSize: imageView.frame.size)
            }
        }
    }
    
    override func tagName() -> String {
        return String(describing: UIImageView.self)
    }
    
    override func instanceView() -> UIView {
        return UIImageView()
    }
}



class UIButtonAttri:BaseViewAttri {
    override func bindAttriToView(node: XMLNode, view: UIView) {
        super.bindAttriToView(node: node, view: view)
        if let button = view as? UIButton {
            if let title = node.attri("title") {
                button.setTitle(title, for: UIControlState.normal)
            }
            
            if let colorStr = node.attri("title_color") {
                button.setTitleColor(UIColor(hex: colorStr), for: UIControlState.normal)
            }
        }
    }
    
    override func tagName() -> String {
        return String(describing: UIButton.self)
    }
    
    override func instanceView() -> UIView {
        return UIButton()
    }
}

class UITableViewAttri: BaseViewAttri {
    
    override func bindAttriToView(node: XMLNode, view: UIView) {
        super.bindAttriToView(node: node, view: view)
        if let tableView = view as? UITableView {
            tableView.separatorInset = UIEdgeInsets.zero
            tableView.separatorColor = UIColor.clear
        }
    }
    
    override func tagName() -> String {
        return String(describing: UITableView.self)
    }
    
    override func instanceView() -> UIView {
        return UITableView()
    }
}


class UITableViewCellAttri: BaseViewAttri {
    override func bindAttriToView(node: XMLNode, view: UIView) {
        super.bindAttriToView(node: node, view: view)
        if let cell = view as? UITableViewCell {
            cell.separatorInset = UIEdgeInsets.zero
        }
    }
    
    override func tagName() -> String {
        return String(describing: UITableViewCell.self)
    }
    
    override func instanceView() -> UIView {
        return UITableViewCell()
    }
}

class UINavigationBarAttri: BaseViewAttri {
    override func bindAttriToView(node: XMLNode, view: UIView) {
        super.bindAttriToView(node: node, view: view)
        if let nav = view as? UINavigationBar {
            if let title = node.attri("title") {
                nav.topItem?.title = title
                let navItem = UINavigationItem(title: title)
                nav.setItems([navItem], animated: false)
            }
        }
    }

    override func tagName() -> String {
        return String(describing: UINavigationBar.self)
    }
    
    override func instanceView() -> UIView {
        return UINavigationBar()
    }
}


class UITextFieldAttri:BaseViewAttri {
    
    override func bindAttriToView(node: XMLNode, view: UIView) {
        super.bindAttriToView(node: node, view: view)
        if let field = view as? UITextField {
            if let placeholder = node.attri("placeholder") {
                field.placeholder = placeholder
            }
            if let contentType = node.attri("content_type") {
                field.textContentType = UITextContentType.init(rawValue: contentType)
                if contentType == UITextContentType.password.rawValue {
                    field.isSecureTextEntry = true
                }
            }
        
        }
    }
    
    override func tagName() -> String {
        return String(describing: UITextField.self)
    }
    
    override func instanceView() -> UIView {
        return UITextField()
    }
}

class ViewFatoryHelper {
    var viewMap:Dictionary<String,BaseViewAttri>
    static let sharedInstance = ViewFatoryHelper()
    private init() {
        viewMap = [String: BaseViewAttri]()
    }
    
    func registerBaseView() {
        _ = BaseViewAttri()
        _ = UILabelAttri()
        _ = UIImageViewAttri()
        _ = UIButtonAttri()
        _ = RelativeLayoutAttri()
        _ = UITableViewAttri()
        _ = UITableViewCellAttri()
        _ = UINavigationBarAttri()
        _ = UITextFieldAttri()
    }
    
    func registerView(name:String, attri:BaseViewAttri!) {
        self.viewMap[name] = attri
    }
    
    func buildView(node:XMLNode) -> UIView? {
        if let tag = node.tagName {
            if let attri = self.viewMap[tag] {
                let view =  attri.instanceView()
                view.xmlTag = tag
                view.layoutAndInit(node: node, attri: attri)
                return view
            }
        }
        return nil
    }
    
    static func layout_path(name:String) -> String? {
        return Bundle.main.resourcePath?.appending("/layout.bundle/xml/").appending(name).appending(".xml")
    }
}




func addViewsForNode(node:XMLNode, view:UIView) {
    var rootAttri = ViewFatoryHelper.sharedInstance.viewMap[node.tagName!]
    if rootAttri == nil {
        rootAttri = BaseViewAttri()
    }
    
    for item in node.children! {
        if let subView = ViewFatoryHelper.sharedInstance.buildView(node: item) {
            if let layoutParam = rootAttri?.instanceLayoutParams(item) {
                subView.layoutParams = layoutParam
                view.addSubview(subView)
                layoutParam.layoutSelf(subView,view)
            }
        }
    }
    rootAttri?.layoutByRules(view)
}


func inflaterLayoutParams(node:XMLNode, root:UIView?) ->LayoutParams{
    if root is RelativeLayout {
        return RelativeLayoutParams(node)
    }
    return LayoutParams(node)
}


func inflaterLayoutParams(node:XMLNode, rootTag:String?) ->LayoutParams{
    if let attri = ViewFatoryHelper.sharedInstance.viewMap[rootTag!] {
        return attri.instanceLayoutParams(node)
    }
    return LayoutParams(node)
}



class LayoutParams {
    var marginLeft: CGFloat
    var marginRight: CGFloat
    var marginTop: CGFloat
    var marginBottom: CGFloat
    var width:String?
    var height:String?
    init(_ node:XMLNode) {
        let defaultValue:Float = 0.0
        self.marginLeft = CGFloat(attriForNode(node: node, name: "margin_left", defaultValue: defaultValue));
        self.marginTop = CGFloat(attriForNode(node: node, name: "margin_top", defaultValue: defaultValue));
        self.marginRight = -CGFloat(attriForNode(node: node, name: "margin_right", defaultValue: defaultValue));
        self.marginBottom = -CGFloat(attriForNode(node: node, name: "margin_bottom", defaultValue: defaultValue));
        self.width = node.attri("width")
        self.height = node.attri("height")
    }
    
    func layoutSelf(_ child:UIView, _ rootView:UIView?) {
        
        if rootView != nil {
            let targetView = rootView!
            if self.width != nil {
                child.translatesAutoresizingMaskIntoConstraints = false;
                var multiplier:CGFloat = 0.0
                var constant:CGFloat = 0.0
                if let value = Float(self.width!) {
                    constant = CGFloat(value)
                    child.frame.size.width = constant
                }else {
                    multiplier = 1
                    targetView.childCenterX(child, targetView, offset: 0);
                }
                let con =  NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: targetView , attribute: NSLayoutAttribute.width, multiplier: multiplier, constant: constant)
                targetView.addConstraint(con)
            }
            
            if self.height != nil {
                child.translatesAutoresizingMaskIntoConstraints = false;
                var multiplier:CGFloat = 0.0
                var constant:CGFloat = 0.0
                if let value = Float(self.height!) {
                    constant = CGFloat(value)
                    child.frame.size.height = constant
                }else {
                    multiplier = 1
                    targetView.childCenterY(child, targetView, offset: 0)
                }
                let con =  NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: targetView , attribute: NSLayoutAttribute.height, multiplier: multiplier, constant:constant)
                targetView.addConstraint(con)
            }
        }else {
//            child.contentMode = UIViewContentMode.scaleToFill
//            child.frame = UIScreen.main.bounds
//            child.autoresizesSubviews=true
            
            //child.contentScaleFactor=1.0
        }
    }
}


class RelativeLayoutParams: LayoutParams {
    var bottomOf: String?
    var topOf: String?
    var rightOf: String?
    var leftOf: String?
    var center_v_of: String?
    var center_h_of: String?
    var center_v_parent: String?
    var center_h_parent: String?
    
    var top_of_align: String?
    var bottom_of_align: String?
    var left_of_align: String?
    var right_of_align: String?
    
    var offset_v:CGFloat = 0.0
    var offset_h:CGFloat = 0.0
    
    override init(_ node: XMLNode) {
        super.init(node)
        self.bottomOf = node.attri("bottom_of")
        self.topOf = node.attri("top_of")
        self.rightOf = node.attri("right_of")
        self.leftOf = node.attri("left_of")
        self.center_v_parent = node.attri("center_v_parent")
        self.center_h_parent = node.attri("center_h_parent")
        self.center_v_of = node.attri("center_v_of")
        self.center_h_of = node.attri("center_h_of")
        self.top_of_align = node.attri("top_of_align")
        self.bottom_of_align = node.attri("bottom_of_align")
        self.left_of_align = node.attri("left_of_align")
        self.right_of_align = node.attri("right_of_align")
        let defaultValue:Float = 0.0
        self.offset_v = CGFloat(attriForNode(node: node, name: "offset_v", defaultValue: defaultValue));
        self.offset_h = CGFloat(attriForNode(node: node, name: "offset_h", defaultValue: defaultValue));
    }
}



private struct ViewAttriExtenSion {
    static var kIdStr = "IdStr"
    static var kLayoutParamStr = "LayoutParamStr"
    static var kXmlTag = "XmlTag"
}

extension UIView {
    convenience init(node:XMLNode) {
        self.init()
        layoutAndInit(node: node)
    }
    
    func layoutSelfByXml(xmlPath:String){
        let doc = XMLDoc.parseFile(file: xmlPath)
        self.layoutAndInit(node: doc.rootNode!)
    }
    
    
    func layoutAndInit(node:XMLNode) {
        if let tag = node.tagName , let attri:BaseViewAttri = ViewFatoryHelper.sharedInstance.viewMap[tag] {
            //layoutParam.layoutSelf(subView,view)
//            let layoutParam = inflaterLayoutParams(node: node  , root: nil)
//            self.layoutParams = layoutParam
//            self.layoutParams?.layoutSelf(self, nil)
            layoutAndInit(node: node, attri:attri)
        }else {
            layoutAndInit(node: node, attri:BaseViewAttri())
        }
    }
    
    
    func layoutAndInit(node:XMLNode, attri:BaseViewAttri!) {
        self.xmlTag = node.tagName
        attri.bindAttriToView(node: node, view: self)
        addViewsForNode(node: node, view: self)
    }
    
    var layoutParams: LayoutParams? {
        get {
            return objc_getAssociatedObject(self, &ViewAttriExtenSion.kLayoutParamStr) as? LayoutParams
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &ViewAttriExtenSion.kLayoutParamStr, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var idStr :String? {
        get {
            return objc_getAssociatedObject(self, &ViewAttriExtenSion.kIdStr) as? String
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &ViewAttriExtenSion.kIdStr, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    
    var xmlTag :String? {
        get {
            return objc_getAssociatedObject(self, &ViewAttriExtenSion.kXmlTag) as? String
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &ViewAttriExtenSion.kXmlTag, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    
    func findViewById(_ idStr:String?, _ recursive: Bool = false) ->UIView?{
        if idStr == nil {
            return nil
        }
        
        if idStr == "parent" {
            return self
        }
        var view:UIView?
        for child in self.subviews {
            if let view_id = child.idStr{
                if idStr == view_id{
                    view = child
                    break
                }
            }
            if recursive {
                if let tmpView = child.findViewById(idStr,recursive) {
                    view = tmpView;
                    break
                }
            }
        }
        return view
    }
    
    func childCenterY(_ child:UIView,_ targetView:UIView, offset:CGFloat) {
        let con =  NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: targetView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: offset)
        self.addConstraint(con)
    }
    
    func childCenterX(_ child:UIView,_ targetView:UIView, offset:CGFloat) {
        let con =  NSLayoutConstraint(item: child, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: targetView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: offset)
        self.addConstraint(con)
    }
    
    func childParentSide(_ child:UIView,margin:CGFloat, attribute: NSLayoutAttribute) {
        let con =  NSLayoutConstraint(item: child, attribute: attribute, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: attribute, multiplier: 1, constant: margin)
        self.addConstraint(con)
    }
    
    func layoutViewToSide(_ child:UIView, targetView:UIView, margin:CGFloat, attribute: NSLayoutAttribute) {
        let con =  NSLayoutConstraint(item: child, attribute: attribute, relatedBy: NSLayoutRelation.equal, toItem: targetView, attribute: attribute, multiplier: 1, constant: margin)
        self.addConstraint(con)
    }
}


public enum RelativeLayoutSide : Int {
    case Left = 1,Top = 2,Right = 4,Bottom = 8
}


class RelativeLayout : UIView {

}






