//
//  TaskDetailViewController.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 17/9/25.
//

import UIKit

protocol TaskDetailViewProtocol: UIViewController {
    var presenter: TaskDetailPresenterProtocol { get set }
    
    func fill(with task: Task)
}

final class TaskDetailViewController: UIViewController {
    var presenter: TaskDetailPresenterProtocol
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var maxTitleHeight: CGFloat { (titleTextView.font?.lineHeight ?? 34) * 3 }
    
    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor(named: "WhiteTodo")
        textView.backgroundColor = UIColor(named: "BlackTodo")
        textView.font = .systemFont(ofSize: 34, weight: .bold)
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    private let titlePlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Заголовок"
        label.textColor = UIColor(named: "WhiteTodo")?.withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private var titleHeightConstraint: NSLayoutConstraint?
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "WhiteTodo")?.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = UIColor(named: "WhiteTodo")
        textView.backgroundColor = UIColor(named: "BlackTodo")
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textContainerInset = .zero
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    private let descriptionPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Описание"
        label.textColor = UIColor(named: "WhiteTodo")?.withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.isUserInteractionEnabled = false
        return label
    }()
    
    init(presenter: TaskDetailPresenterProtocol) {
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
        setupKeyboardObservers()
        
        titleTextView.delegate = self
        descriptionTextView.delegate = self
        
        presenter.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.didTapSave(title: titleTextView.text, description: descriptionTextView.text, date: dateLabel.text?.toDate())
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "BlackTodo")
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        contentView.addSubview(titleTextView)
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titlePlaceholder)
        titlePlaceholder.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titlePlaceholder.topAnchor.constraint(equalTo: titleTextView.topAnchor),
            titlePlaceholder.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),
            titlePlaceholder.trailingAnchor.constraint(equalTo: titleTextView.trailingAnchor)
        ])
        
        titleHeightConstraint = titleTextView.heightAnchor.constraint(equalToConstant: titleTextView.font?.lineHeight ?? 34)
        titleHeightConstraint?.isActive = true
        
        contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        contentView.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(descriptionPlaceholder)
        descriptionPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 240),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            descriptionPlaceholder.topAnchor.constraint(equalTo: descriptionTextView.topAnchor),
            descriptionPlaceholder.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            descriptionPlaceholder.trailingAnchor.constraint(equalTo: descriptionTextView.trailingAnchor, constant: -5)
        ])
        
        dateLabel.text = Date().toString()

        adjustTitleHeight()
        updatePlaceholders()
    }
    
    private func adjustTitleHeight() {
        let size = CGSize(width: titleTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let capped = min(maxTitleHeight, titleTextView.sizeThatFits(size).height)
        titleHeightConstraint?.constant = max(titleTextView.font?.lineHeight ?? 34, capped)
        view.layoutIfNeeded()
    }
    
    private func updatePlaceholders() {
        titlePlaceholder.isHidden = !(titleTextView.text?.isEmpty ?? true)
        descriptionPlaceholder.isHidden = !(descriptionTextView.text?.isEmpty ?? true)
    }
    
    @objc private func didTapSave() {
        presenter.didTapSave(title: titleTextView.text, description: descriptionTextView.text, date: Date())
    }
}

extension TaskDetailViewController: TaskDetailViewProtocol {
    func fill(with task: Task) {
        titleTextView.text = task.title
        descriptionTextView.text = task.description
        dateLabel.text = task.date?.toString()
        
        adjustTitleHeight()
        updatePlaceholders()
    }
}

extension TaskDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard textView === titleTextView else {
            updatePlaceholders()
            return
        }
        
        let size = CGSize(width: titleTextView.bounds.width, height: .greatestFiniteMagnitude)
        let fitting = titleTextView.sizeThatFits(size)
        
        guard fitting.height > maxTitleHeight, let range = titleTextView.selectedTextRange else {
            adjustTitleHeight()
            updatePlaceholders()
            return
        }
            
        let start = titleTextView.offset(from: titleTextView.beginningOfDocument, to: range.start)
        if start > 0 {
            let string = NSMutableString(string: titleTextView.text ?? "")
            string.deleteCharacters(in: NSRange(location: start - 1, length: 1))
            titleTextView.text = String(string)
            let end = titleTextView.endOfDocument
            titleTextView.selectedTextRange = titleTextView.textRange(from: end, to: end)
        }
        adjustTitleHeight()
        updatePlaceholders()
    }
}

extension TaskDetailViewController {
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        scrollView.contentInset.bottom = keyboardHeight - view.safeAreaInsets.bottom
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
    }
}
