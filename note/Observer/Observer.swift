//
//  Observer.swift
//  note
//
//  Created by MacBook Pro on 11/05/2024.
//

import Foundation

class Observer<T> {
    private var listener: ((T) -> Void)?
    
    var value: T {
        didSet {listener?(value)}
    }
    
    init(value: T) {
        self.value = value
    }
    
    func bind(_ closure: @escaping (T) -> Void) {
        self.listener = closure
        listener?(value)
    }
}
