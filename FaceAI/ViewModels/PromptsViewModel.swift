import Combine
import Foundation
import SwiftUI

final class PromptsViewModel: ObservableObject {
    @Published var selectedCategory: PresetCategory?
    @Published var inputText: String = ""
    @Published var isAllSelected: Bool = true
    
    @Published var filteredCategories: [PresetCategory] = Array(PresetCategory.allCases)
    @Published var filteredPresets: [ImagePreset] = []
    
    @ObservedObject private var globalState = GlobalState.shared
    
    private var cancellables: Set<AnyCancellable> = []
    
    func filterPresets() {
        self.filteredPresets = imagePresets.filter({ $0.category == self.selectedCategory })
    }
    
    init() {
        $inputText.sink { newValue in
            let allCases = Array(PresetCategory.allCases)
            if newValue.isEmpty && self.isAllSelected {
                self.filteredCategories = allCases
                return
            } else if newValue.isEmpty && !self.isAllSelected {
                self.filterPresets()
                return
            }
            
            let lowerCased = newValue.lowercased()
            if self.isAllSelected {
                self.filteredCategories = allCases.filter {
                    $0.rawValue.lowercased().contains(lowerCased)
                }
            } else {
                self.filterPresets()
                self.filteredPresets = self.filteredPresets.filter({ $0.category.rawValue.lowercased().contains(lowerCased) || $0.systemPrompt.lowercased().contains(lowerCased) })
            }
        }
        .store(in: &cancellables)
    }
}
