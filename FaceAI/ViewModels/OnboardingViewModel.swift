import SwiftUI
import PhotosUI

final class OnboardingViewModel: ObservableObject {
    @Published var currentPageIndex = 0
    
    @Published var showGenderPicker = false
    @Published var showPrivacyPolicy = true
    
    @Published var selectedGender = ""
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var selectedImages: [UIImage] = []
    
    @Published var showGenerationView: Bool = false
    @Published var currentUploadedPhotoIndex: Int = 0
    
    @Published var isLoading: Bool = false
    @Published var showFaceProcessing: Bool = false
    
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
