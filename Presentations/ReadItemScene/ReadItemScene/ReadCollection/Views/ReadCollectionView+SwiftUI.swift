//
//  ReadCollectionView.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/09/22.
//

import Foundation
//import SwiftUI

import RxSwift
import RxCocoa

import Domain


//// MARK: - ReadCollectionViewPreseningData
//
//public final class ReadCollectionViewData: ObservableObject {
//
//    @Published var currentSortOrder: ReadCollectionItemSortOrder?
//    @Published var cellViewModels: [ReadItemCellViewModel] = []
//
//    private let disposeBag = DisposeBag()
//
//    func bind(viewModel: ReadCollectionViewModel) {
//
//        viewModel.currentSortOrder
//            .asDriver(onErrorDriveWith: .never())
//            .drive(onNext: { [weak self] order in
//                self?.currentSortOrder = order
//            })
//            .disposed(by: self.disposeBag)
//
////        viewModel.cellViewModels
////            .asDriver(onErrorDriveWith: .never())
////            .drive(onNext: { [weak self] cellViewModels in
////                self?.cellViewModels = cellViewModels
////            })
////            .disposed(by: self.disposeBag)
//    }
//}
//
//
//// MARK: - ReadCollectionView
//
//public struct ReadCollectionView: View {
//
//    @StateObject var data: ReadCollectionViewData
//
//    public var body: some View {
//
//        NavigationView {
//            ScrollView {
//                // collection attribute header position
//                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 400))], spacing: 20) {
//                    ForEach(data.cellViewModels, id: \.presetingID) {
//                        self.readItemView($0)
//                            .aspectRatio(contentMode: .fill)
//                            .padding(10)
//                    }
//                }
//            }
//            .navigationTitle("123")
//        }
//    }
//
//
//    private func readItemView(_ cellViewModel: ReadItemCellViewModel) -> some View {
//        switch cellViewModel {
//        case let collection as ReadCollectionCellViewModel:
//            return self.readCollectionView(collection)
//                .background(Color.secondary)
//                .asAnyView()
//
//        case let link as ReadLinkCellViewModel:
//            return self.readLinkView(link)
//                .clipShape(RoundedRectangle(cornerRadius: 2.0))
//                .shadow(radius: 1)
//                .asAnyView()
//
//        default: return Rectangle().asAnyView()
//        }
//    }
//
//    private func readCollectionView(_ cellViewModel: ReadCollectionCellViewModel) -> some View {
//        Text("collection: \(cellViewModel.name)")
//    }
//
//    private func readLinkView(_ cellViewModel: ReadLinkCellViewModel) -> some View {
//        ZStack {
//            self.linkThumbnailImageView(cellViewModel)
//            self.linkMetaDataView(cellViewModel)
//            if let priority = cellViewModel.priority {
//                self.priorityView(for: priority)
//            }
//        }
//    }
//
//    private func linkThumbnailImageView(_ cellViewModel: ReadLinkCellViewModel) -> some View {
//        VStack {
//            Image(systemName: "square.and.arrow.up.fill")
//                .aspectRatio(0.75, contentMode: .fill)
//            Spacer()
//        }
//    }
//
//    private func linkMetaDataView(_ cellViewModel: ReadLinkCellViewModel) -> some View {
//        VStack {
//            Spacer()
//            VStack(alignment: .leading) {
//                Label("Title", systemImage: "link").font(.callout)
//                HStack {
//
//                    Spacer()
//                }
//            }
//            .padding(6)
//            .background(Color.gray)
//
//        }
//    }
//
//    private func priorityView(for prioriry: ReadPriority) -> some View {
//        VStack {
//            HStack(alignment: .top) {
//                Spacer()
//                Text(prioriry.description).font(.caption)
//                    .padding(EdgeInsets.init(top: 5, leading: 8, bottom: 5, trailing: 8))
//                    .background(Color.blue)
//                    .clipShape(RoundedRectangle(cornerRadius: 5))
//            }
//            Spacer()
//        }
//    }
//}
//
//private extension ReadPriority {
//
//    var description: String {
//        switch self {
//        case .beforeDying: return "read before you die".localized
//        case .someDay: return "read before you die".localized
//        case .thisWeek: return "read this week".localized
//        case .today: return "You should read it today!".localized
//        case .beforeGoToBed: return "read before bed".localized
//        case .onTheWaytoWork: return "on the way to work".localized
//        case .afterAWhile: return "later".localized
//        }
//    }
//}
//
//
//// MARK: - preview
//
//struct ReadCollectionViewPreview: PreviewProvider {
//
//    static var previews: some View {
//
//        let dummies: [ReadItemCellViewModel] = (0..<100).map {
//            let url = "https://gearmamn06.medium.com/writing-high-performance-swift-code-7a3eff0643d0"
//            var model = ReadLinkCellViewModel(uid: "some:\($0)", linkUrl: url)
//            model.priority = .afterAWhile
//            return model
//        }
//        let data = ReadCollectionViewData()
//        data.cellViewModels = dummies
//        return Group {
//            ReadCollectionView(data: data)
//                .previewDevice("iPad Pro (12.9-inch) (5th generation)")
//            ReadCollectionView(data: data)
//                .preferredColorScheme(.light)
//        }
//    }
//}
