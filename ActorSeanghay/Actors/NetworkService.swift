//
//  NetworkService.swift
//  ActorSeanghay
//
//  Created by Seanghay HUORT (IT) on 9/25/26.
//


import Foundation

/// Simulates a network layer as its own actor, isolated from `TaskStore`.
///
/// This is the core idea of an "actor-per-responsibility" architecture:
/// each actor owns exactly one piece of mutable state or one external
/// resource (a cache, a socket, a database handle, etc.), and actors
/// only ever communicate with each other through async function calls
/// — never by reaching into each other's stored properties.
actor NetworkService {
    enum NetworkError: Error {
        case simulatedFailure
    }

    func fetchInitialTasks() async throws -> [TaskModel] {
        // Simulate network latency without blocking any thread.
        try await Task.sleep(nanoseconds: 800_000_000)

        return [
            TaskModel(title: "Learn Swift Actors"),
            TaskModel(title: "Build a UIKit demo app"),
            TaskModel(title: "Write unit tests")
        ]
    }
}
