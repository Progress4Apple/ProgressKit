//
//  PKMessageStore.swift
//  ProgressKit
//
//  Copyright © 2018 ProgressKit authors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

public class PKMessageStore {
    public static let standard = PKMessageStore(Bundle(for: PKMessageStore.self), pathForResource: "PKMessages", ofType: "plist")
    
    public enum Key: String {
        case title = "title"
        case body = "body"
    }
    
    
    let messages: [String: [String: [String]]]
    
    public init(_ bundle: Bundle, pathForResource path: String, ofType type: String){
        guard let path = bundle.path(forResource: path, ofType: type),
            let messages = NSDictionary(contentsOfFile: path) as? [String: [String: [String]]]  else {
                self.messages = [:]
                return
        }
        self.messages = messages
    }
    
    func random(for type: PKUserNotificationType, key: Key) -> String? {
        guard let messages = messages[type.rawValue]?[key.rawValue], !messages.isEmpty else {
            return nil
        }
        return messages[Int.random(in: 0..<messages.count)]
    }
    
    
    func random(for type: PKUserNotificationType, key: Key, _ args: CVarArg...) -> String {
        guard let message = random(for: type, key: key) else {
            return ""
        }
        return String(format: message, locale: .current, arguments: args)

    }
}
