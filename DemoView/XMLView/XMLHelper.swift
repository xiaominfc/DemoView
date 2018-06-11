//
//  XMLHelper.swift
//  DemoView
//
//  Created by xiaominfc on 2018/6/6.
//  Copyright © 2018 xiaominfc. All rights reserved.
//

import UIKit
import libxml2



func stringFrom(xmlchar: UnsafePointer<xmlChar>) -> String {
    let string = xmlchar.withMemoryRebound(to: CChar.self, capacity: 1) {
        return String(validatingUTF8: $0)
    }
    return string ?? ""
}

func attriForNode<T>(node:XMLNode,name:String,defaultValue: T) ->T{
    let result = defaultValue
    if let value = node.attri(name){
        if defaultValue is String {
            return value as! T
        }
        
        if defaultValue is Int {
            if let outValue = Int(value) {
                return outValue as! T
            }
        }
        
        if defaultValue is Float {
            if let outValue = Float(value) {
                return outValue as! T
            }
        }
    }
    return result
}

protocol ParserInterface {
    func parse()
}

protocol ParseAttriInterface {
    func parseAttris()
}

class XMLNode :ParserInterface, ParseAttriInterface{
    var node:xmlNodePtr;
    var children: [XMLNode]?
    var attributes: [String: String]
    
    var tagName:String?
    
    init(node: xmlNodePtr) {
        self.node = node
        self.attributes = [String:String]()
    }
    
    func attri(_ name:String) -> String? {
        return self.attributes[name]
    }

    
    func parse() {
        self.tagName = stringFrom(xmlchar: self.node.pointee.name)
        self.parseAttris()
        if(children == nil) {
            children = Array<XMLNode>()
        }
        var item = self.node.pointee.children
        while item != nil {
            let mXmlNode = item?.pointee;
            if mXmlNode?.type == XML_ELEMENT_NODE {
                let child = XMLNode(node:item!)
                child.parse()
                children?.append(child)
            }
            item = mXmlNode?.next
        }
    }
    
    func parseAttris() {
        var attri = self.node.pointee.properties
        while attri != nil {
            let name = attri?.pointee.name
            let result = xmlGetProp(self.node,name)
            let value = stringFrom(xmlchar: result!)
            let key = stringFrom(xmlchar: name!)
            self.attributes[key] = value
            attri = attri?.pointee.next
        }
    }
}


class XMLRoot: XMLNode{
    
}

class XMLDoc: ParserInterface{
    var docPtr: xmlDocPtr
    var rootNode: XMLRoot?
    init(file: String){
        docPtr = xmlParseFile(file)
    }
    
    func parse() {
        if let root = xmlDocGetRootElement(self.docPtr) {
            self.rootNode = XMLRoot(node:root)
            rootNode!.parse()
        }
    }
    
    static func parseFile(file:String) -> XMLDoc{
        let doc = XMLDoc(file: file);
        doc.parse()
        return doc
    }
}


