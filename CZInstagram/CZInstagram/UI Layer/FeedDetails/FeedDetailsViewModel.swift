//
//  FeedDetailsViewModel.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/4/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit

class FeedDetailsViewModel: NSObject, NSCopying {
    private(set) var feed: Feed
    private(set) var feeds: [Comment] = []
    private(set) var page: Int = 0
    private(set) var isLoadingFeeds: Bool = false
    private(set) var lastMinFeedId: String = "-1"
    var store: Store<FeedDetailsState>?

    init(feed: Feed) {
        self.feed = feed
        super.init()
    }

    lazy var sectionModelsTransformer: CZFeedListFacadeView.SectionModelsTransformer = { (feeds: [Any]) -> [CZSectionModel] in
        guard let feeds = feeds as? [Comment] else { fatalError() }
        // Header Section
        let headCellViewModel = FeedCellViewModel(self.feed)
        headCellViewModel.isInFeedDetails = true
        let headerFeedModel = CZFeedModel(viewClass: FeedCellView.self,
                                          viewModel: headCellViewModel)
        let headerSectionModel = CZSectionModel(feedModels: [headerFeedModel])

        // Feeds Section
        let feedModels = feeds.compactMap { CZFeedModel(viewClass: FeedDetailsCellView.self,
                                                     viewModel: FeedDetailsCellViewModel($0)) }
        let feedsSectionModel = CZSectionModel(feedModels: feedModels)
        return [headerSectionModel, feedsSectionModel]
    }

    func fetchFeeds(type fetchType: FetchingFeedsType = .fresh) {
        guard !isLoadingFeeds else {
            CZUtils.dbgPrint("Still in loading feeds process.")
            return
        }
        isLoadingFeeds = true
        var isLoadMore = false
        switch fetchType {
        case .fresh:
            page = 0
            lastMinFeedId = "-1"
        case .loadMore:
            isLoadMore = true
        default:
            break
        }

        store?.dispatch(action: FeedDetailsAction.fetchingFeeds(fetchType))

        var params: [AnyHashable: Any] = ["count": "\(Instagram.FeedDetails.countPerPage)"]
        if isLoadMore {
            params["max_id"] = lastMinFeedId
        }
        Services.shared.fetchComments(
            feedId: feed.feedId,
            params: params,
            success: {[weak self] feeds in
                guard let `self` = self else {
                    return
                }
                self.isLoadingFeeds = false
                self.lastMinFeedId = feeds.last?.commentId ?? self.lastMinFeedId
                
                if fetchType == FetchingFeedsType.loadMore {
                    self.feeds.append(contentsOf: feeds)
                } else {
                    self.feeds = feeds
                }
                // Fire action after fetch feeds, notify subscribers to update UI
                self.store?.dispatch(action: FeedDetailsAction.fetchedFeeds)
            }, failure: { error in
                self.isLoadingFeeds = false
        })
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

extension FeedDetailsViewModel: State {
    func reduce(action: Action) {
        feeds.forEach {$0.reduce(action: action)}

        switch action {
        case let CZFeedListViewAction.selectedCell(feedModel):
            CZUtils.dbgPrint(feedModel)
            if let viewModel = feedModel.viewModel as? FeedCellViewModel {
                let success = { (data: Any?) in
                    self.fetchFeeds()
                }
                let failure = { (error: Error) in }
                if viewModel.feed.userHasLiked {
                    // Services.shared.unlikeFeed(feedId: viewModel.feed.feedId, success: success, failure: failure)
                } else {
                    // Services.shared.likeFeed(feedId: viewModel.feed.feedId, success: success, failure: failure)
                }
            }
        default:
            break
        }
    }
}
