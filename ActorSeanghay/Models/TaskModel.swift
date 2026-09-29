//
//  TaskModel.swift
//  ActorSeanghay
//
//  Created by Seanghay HUORT (IT) on 9/25/26.
//


import Foundation

/// `nonisolated` opts this type out of the project's default MainActor
/// isolation (Xcode 26+), so any actor can create and use it.
/// `Sendable` lets it safely cross actor boundaries.
nonisolated struct TaskModel: Identifiable, Equatable, Sendable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
