//
//  TaskListViewController.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 16/9/25.
//

import UIKit

protocol TaskListViewProtocol: AnyObject {
    var presenter: TaskListPresenterProtocol { get set }
    
    func show(_ tasks: [Task])
    func showLoadError(_ error: String)
    func applyTableChanges(model: UpdateTableModel)
}

final class TaskListViewController: UIViewController {
    
    var presenter: TaskListPresenterProtocol
    
    private var tasks: [Task] = []
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(named: "BlackTodo")
        tableView.separatorColor = .stroke
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        tableView.tableHeaderView = UIView()
        tableView.allowsSelection = false
        tableView.register(TaskListCell.self, forCellReuseIdentifier: TaskListCell.identifier)
        return tableView
    }()
    
    private let bottomBarView = TaskListBottomBarView()
    
    init(presenter: TaskListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupSearch()
        
        presenter.loadTasks()
        updateBottomBarCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Задачи"
        navigationItem.backButtonTitle = "Назад"
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "WhiteTodo") ?? .white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "WhiteTodo") ?? .white]
        appearance.backgroundColor = UIColor(named: "BlackTodo")
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = UIColor(named: "BlackTodo")
        navigationController?.navigationBar.tintColor = UIColor(named: "YellowTodo")
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "BlackTodo")
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        view.addSubview(bottomBarView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: 93)
        ])
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [
                .foregroundColor: UIColor(named: "WhiteTodo")?.withAlphaComponent(0.5) ?? .gray,
                .font: UIFont.systemFont(ofSize: 17, weight: .regular)
            ]
        )
        if let searchIcon = searchController.searchBar.searchTextField.leftView as? UIImageView {
            searchIcon.image = searchIcon.image?.withRenderingMode(.alwaysTemplate)
            searchIcon.tintColor = UIColor(named: "WhiteTodo")?.withAlphaComponent(0.5)
        }
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor(named: "WhiteTodo")?.withAlphaComponent(0.5)
        searchController.searchBar.searchTextField.backgroundColor = UIColor(named: "GrayTodo")
        searchController.searchBar.searchTextField.tintColor = UIColor(named: "WhiteTodo")?.withAlphaComponent(0.5)
        navigationItem.searchController = searchController
        searchController.searchBar.searchTextField.textColor = UIColor(named: "WhiteTodo")?.withAlphaComponent(0.5)
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func updateBottomBarCount() {
        if tasks.count % 10 == 1 && tasks.count % 100 != 11 {
            bottomBarView.countLabel.text = "\(tasks.count) Задача"
        } else if [1, 2, 3, 4].contains(tasks.count % 10) && ![11, 12, 13, 14].contains(tasks.count % 100) {
            bottomBarView.countLabel.text = "\(tasks.count) Задачи"
        } else {
            bottomBarView.countLabel.text = "\(tasks.count) Задач"
        }
    }
    
    @objc func didTapCreate() {
        presenter.didSelectCreate(from: self)
    }
}

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskListCell.identifier, for: indexPath) as? TaskListCell else {
            fatalError("Cannot dequeue TaskListCell")
        }

        let task = tasks[indexPath.row]
        cell.configure(with: task)
        cell.checkBoxTapped = { [weak self] completed in
            guard let self else { return }
            presenter.updateTaskState(task: task, done: completed)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let configuration = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
            guard let self, indexPath.row < self.tasks.count else { return UIMenu(children: []) }
            let task = self.tasks[indexPath.row]
            
            let edit = UIAction(title: "Редактировать", image: UIImage(named: "EditIcon")) { [weak self] _ in
                guard let self else { return }
                presenter.didSelectEdit(from: self, task: self.tasks[indexPath.row])
            }
            
            let share = UIAction(title: "Поделиться", image: UIImage(named: "ExportIcon")) { [weak self] _ in
                guard let self else { return }
                presenter.didSelectShare(vc: self, task)
            }
            
            let delete = UIAction(title: "Удалить", image: UIImage(named: "TrashIcon"), attributes: .destructive) { [weak self] _ in
                guard let self else { return }
                presenter.didSelectDelete(task)
                presenter.searchTextDidChange(searchController.searchBar.text)
            }
            
            return UIMenu(children: [edit, share, delete])
        }
        return configuration
    }
    
    func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: (any UIContextMenuInteractionAnimating)?) {
        guard let indexPath = configuration.identifier as? NSIndexPath else { return }
        
        if let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as? TaskListCell {
            animator?.addAnimations({
                cell.selectedTask(true)
            })
        }
    }

    func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        guard let indexPath = configuration.identifier as? NSIndexPath else { return }
        
        if let cell = tableView.cellForRow(at: IndexPath(row: indexPath.row, section: indexPath.section)) as? TaskListCell {
            animator?.addAnimations({
                cell.selectedTask(false)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row < tasks.count else { return nil }
        let task = tasks[indexPath.row]
        
        let doneAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard let self else { return }
            presenter.updateTaskState(task: task, done: !task.completed)
            completion(true)
        }
        doneAction.backgroundColor = UIColor(named: "YellowTodo")
        doneAction.image = UIImage(systemName: task.completed ? "arrow.uturn.backward" : "checkmark")
        
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row < tasks.count else { return nil }
        let task = tasks[indexPath.row]
        
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completion in
            guard let self else { return }
            presenter.didSelectEdit(from: self, task: task)
            completion(true)
        }
        editAction.backgroundColor = UIColor(named: "GrayTodo")
        editAction.image = UIImage(named: "EditIcon")
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self else { return }
            presenter.didSelectDelete(task)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(named: "TrashIcon")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

extension TaskListViewController: TaskListViewProtocol {
    func show(_ tasks: [Task]) {
        self.tasks = tasks
        applyTableChanges(model: .reload)
    }
    
    func showLoadError(_ error: String) {
        let alert = UIAlertController(title: "Ошибка при загрузке данных", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
    
    func applyTableChanges(model: UpdateTableModel) {
        switch model {
        case .delete(let indexPath, let tasks):
            self.tasks = tasks
            tableView.performBatchUpdates({
                self.tableView.deleteRows(at: [indexPath], with: .fade)
             }, completion: { _ in
                 self.updateBottomBarCount()
             })
        case .reload:
            tableView.reloadData()
            updateBottomBarCount()
        }
    }
}

extension TaskListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter.searchTextDidChange(searchController.searchBar.text)
    }
}
