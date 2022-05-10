//
//  UsersListViewController.swift
//  GitHub-Users-List-App
//
//  Created by 邹奂霖 on 2022/5/5.
//


import UIKit
import SnapKit
class UsersListViewController: UIViewController {
    var viewModel: UsersListViewModelType!
    private var searchController: UISearchController = UISearchController(searchResultsController: nil)
    lazy var searchBar: SearchBar = {
        let searchBar = SearchBar(frame: .zero)
        return searchBar
    }()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.estimatedRowHeight = UsersListCell.height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UsersListCell.self, forCellReuseIdentifier: UsersListCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    // MARK: - Life Cycle
    static func create(with viewModel: UsersListViewModelType) -> UsersListViewController {
        let view = UsersListViewController()
        view.viewModel = viewModel
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        hideKeyboardWhenTappedAround()
        setupStyle()
        bindSearchBar()
        bindViewModel()
        viewModel.inputs.loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(searchBar)
        view.addSubview(tableView)
        hideKeyboardWhenTappedAround()
    }

    private func setupStyle() {
        searchBar.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(topBarHeight)
        }
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(topBarHeight)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.snp.bottomMargin)
        }
    }

    func bindViewModel() {
        viewModel.outputs.usersList.observe(on: self) { [weak self] users in
            self?.updateItems()
        }
    }
    func bindSearchBar() {
        searchBar.searchText.observe(on: self) { text in
            print("received : \(text)")
        }
    }
    func updateItems() {
        reload()
    }
    func reload() {
        tableView.reloadData()
    }

}

// MARK: - UITableView DataSource
extension UsersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UsersListCell.reuseIdentifier, for: indexPath) as? UsersListCell else {
            assertionFailure("Cannot dequeue reusable cell \(UsersListCell.self) with reuseIdentifier: \(UsersListCell.reuseIdentifier)")
            return UITableViewCell()
        }
        cell.bindViewModel(viewModel.outputs.usersList.value[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outputs.usersList.value.count
    }
}
// MARK: - UITableView Delegate
extension UsersListViewController: UITableViewDelegate {

}

extension UIViewController {

    /**
     *  Height of status bar + navigation bar (if navigation bar exist)
     */

    var topBarHeight: CGFloat {
        var top = self.navigationController?.navigationBar.frame.height ?? 0.0
        if #available(iOS 13.0, *) {
            top += UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            top += UIApplication.shared.statusBarFrame.height
        }
        return top
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
