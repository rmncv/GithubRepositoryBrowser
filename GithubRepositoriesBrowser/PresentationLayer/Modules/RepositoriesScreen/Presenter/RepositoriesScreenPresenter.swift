//
//  RepositoriesScreenRepositoriesScreenPresenter.swift
//  GithubRepositoriesBrowser
//
//  Created by Denis Rumiantsev on 20/12/2017.
//  Copyright © 2017 Denys Rumiantsev. All rights reserved.
//

class RepositoriesScreenPresenter: RepositoriesScreenModuleInput, RepositoriesScreenViewOutput, RepositoriesScreenInteractorOutput {

    weak var view: RepositoriesScreenViewInput!
    var interactor: RepositoriesScreenInteractorInput!
    var router: RepositoriesScreenRouterInput!
    private var state: RepositoriesScreenConfigurator.State!
    private var searchInput: String?

    func viewIsReady() {
        view.itemsPerPage = 30
        view.currentPage = 0
        view.setupInitialState(forState: state!)
        view.makeActivityIndicator(hidden: false)
        
        switch state! {
            
        case .search(let q):
            searchInput = q
            requestNextPage(q: q)
        case .recent:
            view.makeCancelSearchButton(enabled: false)
            interactor.obtainAllPreviouslyStoredRepositories()
        }
    }
    
    func didRequestNextRepositoriesPage() {
        guard let searchInput = searchInput else {
            return
        }
        requestNextPage(q: searchInput)
    }
    
    func didPressedCancelSearch() {
        interactor.cancelSearch()
        view.makeCancelSearchButton(enabled: false)
    }
    
    func setup(_ state: RepositoriesScreenConfigurator.State) {
        self.state = state
    }
    
    func didObtain(_ repositories: [GithubRepositoryPlain]) {
        view.currentPage = view.currentPage + 1
        view.add(repositories)
        view.makeCancelSearchButton(enabled: false)
        view.makeActivityIndicator(hidden: true)
        view.reloadData()
    }
    
    func didSelected(_ repository: GithubRepositoryPlain) {
        router.showDetailsScreenFor(repository)
        guard !repository.isViewed else {
            return
        }
        // updating models
        var copy = repository
        copy.markAsViewed()
        interactor.markAsViewed(repository)
        view.replace(repository, with: copy)
    }
    
    // MARK: - Tech
    private func requestNextPage(q: String) {
        view.makeCancelSearchButton(enabled: true)
        interactor.obtainRepositoriesWithName(startedWith: q, onPage: view.currentPage, itemsPerPage: view.itemsPerPage)
    }
}
