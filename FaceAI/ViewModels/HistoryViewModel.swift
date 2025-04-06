import Foundation
import SwiftUI
import Combine

final class HistoryViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var filteredPresets: [ImageJob] = []
    @Published var filteredEnhanceJobs: [EnhanceJob] = []
    @Published var selectedItemIndex = 0
    
    @ObservedObject private var globalState = GlobalState.shared
    
    private var cancelables: Set<AnyCancellable> = []
    
    init() {
        updateFilteredLists()
        
        $inputText
            .sink { _ in
                self.updateFilteredLists()
            }
            .store(in: &cancelables)
        
        globalState.$historyJobs
            .sink { _ in
                self.updateFilteredLists()
            }
            .store(in: &cancelables)
        
        globalState.$enhanceJobs
            .sink { _ in
                self.updateFilteredLists()
            }
            .store(in: &cancelables)
    }
    
    private func updateFilteredLists() {
        let value = inputText.lowercased()
        
        if value.isEmpty {
            filteredPresets = globalState.historyJobs
            filteredEnhanceJobs = globalState.enhanceJobs
        } else {
            filteredPresets = globalState.historyJobs.filter {
                $0.presetCategory.rawValue.lowercased().contains(value) ||
                $0.systemPrompt.lowercased().contains(value) ||
                $0.creationDate.description.contains(value)
            }
            
            filteredEnhanceJobs = globalState.enhanceJobs.filter {
                $0.status.text.lowercased().contains(value) ||
                $0.createdAt.description.contains(value)
            }
        }
    }
}
