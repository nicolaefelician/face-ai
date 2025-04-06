import Foundation
import PhotosUI
import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var selectedItem: PhotosPickerItem?
    
    @ObservedObject private var globalState = GlobalState.shared
    @ObservedObject private var photoLibraryService = PhotoLibraryService.shared
    
    func requestForAuthorizationIfNecessary() {
        guard photoLibraryService.authorizationStatus != .authorized ||
                photoLibraryService.authorizationStatus != .limited
        else { return }
        
        photoLibraryService.requestAuthorization { error in
            guard error != nil else { return }
            self.globalState.alertTitle = "Error"
            self.globalState.alertMessage = "Failed to authorize access to Photos."
            self.globalState.showAlert = true
        }
    }
}
