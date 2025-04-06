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
}
