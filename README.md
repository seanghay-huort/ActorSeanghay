# Actor Architecture Demo (UIKit)

A minimal UIKit app that shows how to structure an app around Swift's
`actor` type instead of `class` + `DispatchQueue`/locks.

## What "Actor Architecture" means here

Rather than one shared mutable model touched from many threads, the app
is split into isolation domains:

- **`TaskStore`** (`actor`) — owns the in-memory list of tasks. Every
  method is implicitly synchronized; the compiler refuses to compile
  any code that would touch `tasks` without going through the actor.
- **`NetworkService`** (`actor`) — owns the simulated network call.
  Kept as a *separate* actor from `TaskStore` because it's a separate
  resource/responsibility — this is the "actor per responsibility"
  pattern.
- **`TaskListViewController`** (`@MainActor` class) — UIKit requires UI
  work on the main thread, so the view controller is pinned to the
  main actor. It never stores or mutates task data itself; it always
  asks `TaskStore` for a fresh snapshot and re-renders.

Every cross-actor call is `await`-ed (`await taskStore.addTask(...)`),
which is Swift's way of making "this hops to another isolation domain"
visible right in the call site, instead of hiding it in a
`DispatchQueue.async` block.

## Why this beats the classic `class` + `DispatchQueue` approach

- No `DispatchQueue.sync`/`async` boilerplate, no `NSLock`.
- Data races are caught by the **compiler**, not by luck at runtime
  under thread-sanitizer.
- The dependency direction is explicit: the view controller depends on
  the actors, not the other way around, which keeps them independently
  testable (you can unit-test `TaskStore` with no UIKit involved).

## Project layout

```
ActorArchitectureDemo/
├── AppDelegate.swift
├── SceneDelegate.swift
├── Models/
│   └── TaskModel.swift
├── Actors/
│   ├── TaskStore.swift
│   └── NetworkService.swift
└── ViewControllers/
    └── TaskListViewController.swift
```

## Running it

1. Create a new **UIKit App** project in Xcode (iOS 15+ recommended,
   since it targets Swift Concurrency; iOS 13+ works if you lower the
   availability and adjust `async`/`await` usage).
2. Delete the template's `ViewController.swift` / storyboard, or make
   sure "Use Storyboard" is unchecked when creating the project (this
   sample builds its UI entirely in code via `SceneDelegate`).
3. Drag these files into the project, preserving the folder structure.
4. Build and run. You'll see a list load after ~0.8s (simulated
   network), with the ability to add, complete, and delete tasks —
   all of it going through the two actors.

## Extending this pattern

- Add a `UserSessionActor` for auth state, a `CacheActor` for disk
  persistence, etc. — one actor per resource.
- Use `nonisolated` for pure/stateless helper functions on an actor
  that don't need synchronization.
- For state that many view controllers observe, consider pairing an
  actor with `AsyncStream` to push updates instead of manual
  `refreshFromStore()` polling.
