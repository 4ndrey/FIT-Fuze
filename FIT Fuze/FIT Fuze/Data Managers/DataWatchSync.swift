//
//  DataWatchSync.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 07.10.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import Communicator

protocol DataWatchSyncDelegate: class {
    func stateDidChanged(state: Codable)
    func stateSyncError(_ error: Error)
}

struct State<T: Codable> {
    let data: T
    let timestamp: TimeInterval

    init(data: T, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.data = data
        self.timestamp = timestamp
    }
}

class DataWatchSync<T: Codable> {

    var state: State<T>? {
        didSet {
            guard let state = state, previousTimestamp <= state.timestamp else { return }

            do {
                try enqueueSync(state: state)
            } catch (let error) {
                debugPrint("SYNC ERROR: \(error)")
                delegate?.stateSyncError(error)
            }
        }
    }
    private var previousTimestamp: TimeInterval = 0

    weak var delegate: DataWatchSyncDelegate?

    init() {
        #if os(iOS)
        debugPrint(Communicator.shared.currentWatchState)
        #endif

        Communicator.shared.activationStateChangedObservers.add { debugPrint($0) }

        Communicator.shared.contextUpdatedObservers.add { [weak self] context in
            if let data = context.content["state"] as? Data,
               let timestamp = context.content["timestamp"] as? TimeInterval {
                if timestamp > (self?.state?.timestamp ?? 0) {
                    do {
                        let data = try JSONDecoder().decode(T.self, from: data)
                        self?.state = State(data: data, timestamp: timestamp)
                        self?.delegate?.stateDidChanged(state: data)
                    } catch (let error) {
                        self?.delegate?.stateSyncError(error)
                    }
                }
            }
        }
    }

    /// Sync abstract data with Watch App
    private func enqueueSync(state: State<T>) throws {
        let data = try JSONEncoder().encode(state.data)
        let json: JSONDictionary = ["state": data, "timestamp": state.timestamp]
        let context = Context(content: json)
        try Communicator.shared.sync(context: context)
    }

}
