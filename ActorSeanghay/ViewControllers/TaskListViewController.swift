//
//  TaskListViewController.swift
//  ActorSeanghay
//
//  Created by Seanghay HUORT (IT) on 9/25/26.
//


import UIKit

/// `@MainActor` pins this whole type to the main actor — the same
/// isolation domain UIKit's main thread runs on. That means every
/// property and method here is implicitly safe to touch from UI code,
/// and the compiler will flag any accidental off-main-thread UI update
/// at compile time instead of letting it crash at runtime.
@MainActor
final class TaskListViewController: UITableViewController {

    // The view controller *depends on* the actors but does not own
    // their internal state — it only ever talks to them through
    // `await`-ed async calls.
    private let taskStore = TaskStore()
    private let networkService = NetworkService()

    private var tasks: [TaskModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Actor Architecture Demo"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addTaskTapped))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")

        loadInitialData()
    }

    // MARK: - Actions

    private func loadInitialData() {
        // `Task { }` bridges from synchronous UIKit callback code into
        // async/await. Because the surrounding type is @MainActor, this
        // Task inherits main-actor context, and hops off it only for
        // the `await` calls into the other actors.
        Task {
            do {
                let fetched = try await networkService.fetchInitialTasks()
                await taskStore.replaceAll(with: fetched)
                await refreshFromStore()
            } catch {
                showError(error)
            }
        }
    }

    @objc private func addTaskTapped() {
        let alert = UIAlertController(title: "New Task", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Task title" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self, let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            Task {
                await self.taskStore.addTask(title: title)
                await self.refreshFromStore()
            }
        })
        present(alert, animated: true)
    }

    private func refreshFromStore() async {
        tasks = await taskStore.fetchAllTasks()
        tableView.reloadData()
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = tasks[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = task.title
        config.secondaryText = task.isCompleted ? "Done" : "Pending"
        cell.contentConfiguration = config
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]
        Task {
            await taskStore.toggleCompletion(id: task.id)
            await refreshFromStore()
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let task = tasks[indexPath.row]
        Task {
            await taskStore.removeTask(id: task.id)
            await refreshFromStore()
        }
    }
}
