//
//  ToDoViewController.swift
//  To-do
//
//  Created by Кирилл Зезюков on 28.08.2024.
//

import UIKit

import UIKit

final class ToDoViewController: UIViewController, ToDoViewControllerProtocol {
    var presenter: ToDoPresenterProtocol!
    var todos: [ToDoEntity] = []
    private var isAddedState: Bool = false
    private var isSearching: Bool = false {
        didSet {
            micButton.isHidden = isSearching
        }
    }
    private var filteredTodos: [ToDoEntity] = []
    private var currentTodos: [ToDoEntity] {
        isSearching ? filteredTodos : todos
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = .mainScreenTitle
        label.font = .systemFont(ofSize: Constants.fontSize34, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private lazy var footerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
       
        return view
    }()
    
    private lazy var micButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        button.tintColor = .systemGray

        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.placeholder = .search
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        searchBar.barStyle = .black

        if let textField = searchBar.searchTextField as UITextField? {
            textField.backgroundColor = .secondarySystemBackground
            textField.textColor = .white
            textField.tintColor = .white
            textField.layer.cornerRadius = 10
            textField.clipsToBounds = true

            if let glassIconView = textField.leftView as? UIImageView {
                glassIconView.tintColor = .systemGray
            }

            let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 24))
            textField.rightView = spacer
            textField.rightViewMode = .always
        }

        return searchBar
    }()
    
    private lazy var footerViewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.fontSize11, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private lazy var footerViewButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.newTodo, for: .normal)
        button.tintColor = .systemYellow
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(ToDoTableViewCell.self, forCellReuseIdentifier: ToDoTableViewCell.identifier)
        tv.contentInset = .zero
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        let backButton = UIBarButtonItem(
            title: .backButtonTitle,
            style: .plain,
            target: nil,
            action: nil
        )
        
        backButton.tintColor = .yellow
        
        navigationItem.backBarButtonItem = backButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    private func setUpUI() {
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(micButton)
        view.addSubview(tableView)
        
        footerView.addSubview(footerViewLabel)
        footerView.addSubview(footerViewButton)
        view.addSubview(footerView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.mainTitleTopPadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.mainTitleHorizontalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.mainTitleHorizontalPadding),

            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            micButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            micButton.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -16),
            micButton.widthAnchor.constraint(equalToConstant: 17),
            micButton.heightAnchor.constraint(equalToConstant: 22),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Constants.tableViewTopPadding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            footerView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / Constants.footerHeightMultiplier),
            
            footerViewLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            footerViewLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            
            footerViewButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            footerViewButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor)
        ])
    }
    
    @objc private func addButtonTapped() {
        isAddedState = true
        let newTodo = ToDoEntity.default
        let vc = ToDoDetailViewController(todo: newTodo)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    func displayTodos(_ todos: [ToDoEntity]) {
        self.todos = todos
        footerViewLabel.text = "\(todos.filter { $0.completed == false }.count) \(String.numberOfTasks)"
        applyFilter()
    }

    private func applyFilter() {
        let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        isSearching = !query.isEmpty
      
        if isSearching {
            filteredTodos = todos.filter {
                $0.todo.localizedCaseInsensitiveContains(query) ||
                $0.description.localizedCaseInsensitiveContains(query)
            }
            footerViewLabel.text = "\(filteredTodos.filter { $0.completed == false }.count) \(String.numberOfTasks)"
        }
        tableView.reloadData()
    }

    private func calculateCellHeight(for message: String) -> CGFloat {
        let ptrWidth = view.frame.width - 48 - 60

        let font = UIFont.systemFont(ofSize: Constants.fontSize14)
        let messageLabel = UITextView(frame: CGRect(x: 0, y: 0, width: ptrWidth, height: .greatestFiniteMagnitude))
        messageLabel.text = message
        messageLabel.font = font
        messageLabel.sizeToFit()
        let messageHeight = messageLabel.frame.height
        let minHeight: CGFloat = 106
        let padding: CGFloat = 20

        return max(messageHeight + padding * 2, minHeight)
    }
}

extension ToDoViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTodos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoTableViewCell.identifier, for: indexPath) as? ToDoTableViewCell else {
            return UITableViewCell()
        }

        let todo = currentTodos[indexPath.row]
        cell.configure(with: todo)
        cell.delegate = self

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isAddedState = false
        let vc = ToDoDetailViewController(todo: currentTodos[indexPath.row])
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let todo = currentTodos[indexPath.row]
        return calculateCellHeight(for: todo.todo)
    }
}

extension ToDoViewController: ToDoTableCellDelegate {
    func didSelect(todo: ToDoEntity) {
        let todo = ToDoEntity(id: todo.id, todo: todo.todo, description: todo.description, completed: !todo.completed)
        presenter.updateToDo(todo: todo)
    }
    
    func update(todo: ToDoEntity) {
        isAddedState = false
        let vc = ToDoDetailViewController(todo: todo)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func delete(todo: ToDoEntity) {
        presenter.deleteToDo(todo: todo)
    }
    
    func share(todo: ToDoEntity) {
        var parts: [String] = []
        if !todo.todo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append("\(String.numberOfTasks)\(todo.todo)")
        }
        if !todo.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parts.append("\(String.sharedDescription): \(todo.description)")
        }
        parts.append("\(String.sharedDate): \(todo.date.toString())")
        parts.append("\(String.sharedStatus): " + (todo.completed ? .complete : .notComplete))
        
        let textToShare = parts.joined(separator: "\n\n")
        
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityVC, animated: true)
    }
}

extension ToDoViewController: ToDoDetailViewControllerDelegate {
    func didUpdate(todo: ToDoEntity) {
        if isAddedState || !todos.contains(where: { $0.id == todo.id }) {
            presenter.addToDo(todo: todo)
        } else {
            presenter.updateToDo(todo: todo)
        }
        isAddedState = false
    }
}

extension ToDoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        applyFilter()
    }
}
