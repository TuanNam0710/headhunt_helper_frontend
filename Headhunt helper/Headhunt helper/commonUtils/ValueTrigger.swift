//
//  ValueTrigger.swift
//  Headhunt helper
//
//  Created by Phạm Lê Tuấn Nam on 08/07/2022.
//

import Foundation

final class ValueTrigger<ValueType> {

    private struct TriggerAgent {
        let action: (ValueType) -> Void
        weak var lane: AnyObject?
    }

    var value: ValueType {
        get {
            return _value
        }
        set {
            setValue(val: newValue, shouldNotify: true)
        }
    }

    private var _value: ValueType
    private var observers = [String: TriggerAgent]()

    init(_ initValue: ValueType) {
        _value = initValue
    }

    func addObserver(name: String = "", onTrigger: @escaping (ValueType) -> Void) {
        let agent = TriggerAgent(action: onTrigger)
        observers[name] = agent
    }

    func addObserver(name: String = "", dispatch: DispatchQueue, onTrigger: @escaping (ValueType) -> Void) {
        var agent = TriggerAgent(action: onTrigger)
        agent.lane = dispatch
        observers[name] = agent
    }

    func addObserver(name: String = "", queue: OperationQueue, onTrigger: @escaping (ValueType) -> Void) {
        var agent = TriggerAgent(action: onTrigger)
        agent.lane = queue
        observers[name] = agent
    }

    func removeObserver(name: String) {
        observers.removeValue(forKey: name)
    }

    func setValue(val: ValueType, shouldNotify: Bool = false) {
        _value = val
        if shouldNotify {
            notify()
        }
    }

    private func notify() {
        let val = _value
        for agent in observers.values {
            if let queue = agent.lane as? OperationQueue {
                queue.addOperation {
                    agent.action(val)
                }
            } else if let dispatch = agent.lane as? DispatchQueue {
                dispatch.async {
                    agent.action(val)
                }
            } else {
                agent.action(val)
            }
        }
    }

}
