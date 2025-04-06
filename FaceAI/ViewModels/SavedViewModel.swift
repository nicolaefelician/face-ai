import Foundation
import SwiftUI
import Combine

final class SavedViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var filteredList: [SavedImage] = []
    
    @ObservedObject private var globalState = GlobalState.shared
    
    private func updateFilteredList() {
        let value = inputText.lowercased()
        
        if value.isEmpty {
            self.filteredList = globalState.savedImages
        } else {
            self.filteredList = globalState.savedImages.filter {
                $0.presetCategory.rawValue.lowercased().contains(value) ||
                $0.creationDate.description.lowercased().contains(value)
            }
        }
    }
    
    private var cancelables: Set<AnyCancellable> = []
    
    init() {
        self.filteredList = self.globalState.savedImages
        
        $inputText
            .sink { newValue in
                self.updateFilteredList()
            }
            .store(in: &cancelables)
        
        globalState.$savedImages
            .sink { _ in
                self.updateFilteredList()
            }
            .store(in: &cancelables)
    }
}
