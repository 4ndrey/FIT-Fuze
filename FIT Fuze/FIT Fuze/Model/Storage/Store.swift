//
//  Store.swift
//  FIT Fuze
//
//  Created by Andrei Toropchin on 08.06.18.
//  Copyright © 2018 FIT. All rights reserved.
//

import Foundation

protocol Store {
    associatedtype T: Codable
    
    func get(_ id: String) -> T?
    func save(_ object: T, id: String)
    func remove(_ id: String)
    func findAll(where: (T) -> Bool) -> [T]
}

extension Store {
    func get(_ id: String) -> T? {
        if let url = url(with: id) {
            if let data = FileManager.default.contents(atPath: url.path) {
                do {
                    let model = try JSONDecoder().decode(T.self, from: data)
                    return model
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print("No data at \(url.path)")
            }
        }
        return nil
    }

    func save(_ object: T, id: String) {
        if let url = url(with: id) {
            do {
                let data = try JSONEncoder().encode(object)
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
                FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func remove(_ id: String) {
        if let url = url(with: id) {
            do {
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func findAll(where: (T) -> Bool) -> [T] {
        // 1. Iterate through all items
        // 2. Check `where` closure for result
        // 3. If `true` => add to resulting array, if `false` - skip it
        // 4. Return resulting array
        return []
    }

    func url(with id: String) -> URL? {
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            try? FileManager.default.createDirectory(at: url.appendingPathComponent("\(type(of: self))"), withIntermediateDirectories: true, attributes: nil)
            return url.appendingPathComponent("\(type(of: self))/\(id).json")
        } else {
            return nil
        }
    }
}
