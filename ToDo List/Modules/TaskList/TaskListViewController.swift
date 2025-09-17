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
}

final class TaskListViewController: UIViewController {
    
    var presenter: TaskListPresenterProtocol
    
    private var tasks: [Task] = [] {
        didSet {
            tableView.reloadData()
            updateBottomBarCount()
        }
    }
    
    private var filteredTasks: [Task] = []
    private var isFiltering: Bool {
        searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(named: "Black")
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
    
    private func setupNavigationBar() {
        navigationItem.title = "Задачи"
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .black
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = UIColor(named: "Black")
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "Black")
        
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
                .foregroundColor: UIColor(named: "White")?.withAlphaComponent(0.5) ?? .gray,
                .font: UIFont.systemFont(ofSize: 17, weight: .regular)
            ]
        )
        if let glassIconView = searchController.searchBar.searchTextField.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = UIColor(named: "White")?.withAlphaComponent(0.5)
        }
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor(named: "White")?.withAlphaComponent(0.5)
        searchController.searchBar.searchTextField.backgroundColor = UIColor(named: "Gray")
        searchController.searchBar.searchTextField.tintColor = UIColor(named: "White")?.withAlphaComponent(0.5)
        navigationItem.searchController = searchController
        searchController.searchBar.searchTextField.textColor = UIColor(named: "White")?.withAlphaComponent(0.5)
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func updateBottomBarCount() {
        if tasks.count % 10 == 1 && tasks.count % 100 != 11 {
            bottomBarView.countLabel.text = "\(tasks.count) Задача"
        } else if [1, 2, 3, 4].contains(tasks.count % 10) && ![11, 12, 13, 14].contains(tasks.count % 100) {
            bottomBarView.countLabel.text = "\(tasks.count) Задачи"
        } else {
            bottomBarView.countLabel.text = "\(tasks.count) Задач"
        }
    }
    
    @objc func didTapCreate() {
        //TODO: router to newTask
    }
}

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFiltering ? filteredTasks.count : tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskListCell.identifier, for: indexPath) as? TaskListCell else {
            fatalError("Cannot dequeue TaskListCell")
        }

        let currentTasks = isFiltering ? filteredTasks : tasks
        let task = currentTasks[indexPath.row]
        cell.configure(with: task)
        cell.checkBoxTapped = { [weak self] tapped in
            guard let self else { return }
            
            if let id = self.tasks.firstIndex(where: { $0.id == task.id }) {
                self.tasks[id].completed = tapped
            }
            self.updateSearchResults(for: self.searchController)
        }
        
        return cell
    }
}

extension TaskListViewController: TaskListViewProtocol {
    func show(_ tasks: [Task]) {
        self.tasks = tasks
    }
    
    func showLoadError(_ error: String) {
        let alert = UIAlertController(title: "Ошибка при загрузке данных", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}

extension TaskListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if text.isEmpty {
            filteredTasks = []
        } else {
            filteredTasks = tasks.filter { task in
                let title = task.title?.lowercased() ?? ""
                let description = task.description?.lowercased() ?? ""
                return title.contains(text) || description.contains(text)
            }
        }
        tableView.reloadData()
    }
}
