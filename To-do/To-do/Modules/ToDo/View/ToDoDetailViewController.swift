//
//  ToDoDetailViewController.swift
//  To-do
//
//  Created by Александра Тимонова on 08.07.2026.
//

import UIKit

protocol ToDoDetailViewControllerDelegate: AnyObject {
    func didUpdate(todo: ToDoEntity)
}

final class ToDoDetailViewController: UIViewController {
    weak var delegate: ToDoDetailViewControllerDelegate?
    private var todo: ToDoEntity

    // MARK: - UI
    private lazy var titleTextField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = .mainScreenTitle
        textfield.text = todo.todo
        textfield.clearButtonMode = .whileEditing
        textfield.returnKeyType = .done
        textfield.delegate = self
        return textfield
    }()

    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .label
        textView.backgroundColor = .systemBackground
        textView.text = todo.description
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.isScrollEnabled = false
        return textView
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = todo.date.toString()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleTextField, dateLabel, descriptionTextView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    // MARK: - Init

    init(todo: ToDoEntity) {
        self.todo = todo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupKeyboardDismissGesture()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateToDo()
    }
    
    // MARK: - UI

    private func setUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),

            scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
    }

    private func setupKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func endEditing() {
        view.endEditing(true)
    }
    
    private func updateToDo() {
        var newTitle = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        var newDescription = descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    
        if todo.todo == newTitle { newTitle = ""}
        
        if todo.description == newDescription { newDescription = ""}
        
        let newToDo = ToDoEntity(
            id: todo.id,
            todo: newTitle.isEmpty ? todo.todo : newTitle,
            description: newDescription.isEmpty ? todo.description : newDescription,
            completed: todo.completed
        )
        
        if todo.todo.isEmpty && newToDo.todo.isEmpty { return }
        
        delegate?.didUpdate(todo: newToDo)
    }
}

extension ToDoDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === titleTextField {
            descriptionTextView.becomeFirstResponder()
        }
        return true
    }
}
