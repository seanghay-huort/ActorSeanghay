//
//  TaskStore.swift
//  ActorSeanghay
//
//  Created by Seanghay HUORT (IT) on 9/25/26.
//

import Foundation

/// Actor that owns and protects all task state.
///
/// Because this is an `actor` (not a `class`), Swift enforces that only
/// one task at a time can execute code inside it. Any call from outside
/// must be `await`-ed, and the compiler guarantees `tasks` can never be
/// mutated by two callers concurrently. This replaces manual locks /
/// `DispatchQueue` synchronization with a compiler-checked guarantee.
actor TaskStore {
    private var tasks: [TaskModel] = []

    // MARK: - Reads

    func fetchAllTasks() -> [TaskModel] {
        tasks
    }

    func task(withID id: UUID) -> TaskModel? {
        tasks.first { $0.id == id }
    }

    // MARK: - Writes

    @discardableResult
    func addTask(title: String) -> TaskModel {
        let newTask = TaskModel(title: title)
        tasks.append(newTask)
        return newTask
    }

    func removeTask(id: UUID) {
        tasks.removeAll { $0.id == id }
    }

    func toggleCompletion(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isCompleted.toggle()
    }

    func replaceAll(with newTasks: [TaskModel]) {
        tasks = newTasks
    }
}
