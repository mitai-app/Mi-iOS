//
//  ObservedObjectCollection.swift
//  Mi
//
//  Created by Vonley on 10/7/22.
//

import Foundation
import Combine
import SwiftUI

private class ObservedObjectCollectionBox<Element>: ObservableObject where Element: ObservableObject {
    private var subscription: AnyCancellable?
    
    init(_ wrappedValue: AnyCollection<Element>) {
        self.reset(wrappedValue)
    }
    
    func reset(_ newValue: AnyCollection<Element>) {
        self.subscription = Publishers.MergeMany(newValue.map{ $0.objectWillChange })
            .eraseToAnyPublisher()
            .sink { _ in
                self.objectWillChange.send()
            }
    }
}

@propertyWrapper
public struct ObservedObjectCollection<Element>: DynamicProperty where Element: ObservableObject {
    public var wrappedValue: AnyCollection<Element> {
        didSet {
            if isKnownUniquelyReferenced(&observed) {
                self.observed.reset(wrappedValue)
            } else {
                self.observed = ObservedObjectCollectionBox(wrappedValue)
            }
        }
    }
    
    @ObservedObject private var observed: ObservedObjectCollectionBox<Element>

    public init(wrappedValue: AnyCollection<Element>) {
        self.wrappedValue = wrappedValue
        self.observed = ObservedObjectCollectionBox(wrappedValue)
    }
    
    public init(wrappedValue: AnyCollection<Element>?) {
        self.init(wrappedValue: wrappedValue ?? AnyCollection([]))
    }
    
    public init<C: Collection>(wrappedValue: C) where C.Element == Element {
        self.init(wrappedValue: AnyCollection(wrappedValue))
    }
    
    public init<C: Collection>(wrappedValue: C?) where C.Element == Element {
        if let wrappedValue = wrappedValue {
            self.init(wrappedValue: wrappedValue)
        } else {
            self.init(wrappedValue: AnyCollection([]))
        }
    }
}
