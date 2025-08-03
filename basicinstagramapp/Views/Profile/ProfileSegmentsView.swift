

import SwiftUI

struct ProfileSegmentsView: View {
    @Binding internal var selectedTab: ProfileTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                VStack(spacing: 8) {
         
                    Image(systemName: iconName(for: tab))
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(selectedTab == tab ? .primary : .gray)
                    
       
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(selectedTab == tab ? .primary : .clear)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    func iconName(for tab: ProfileTab) -> String {
        switch tab {
        case .uploads: 
            return "square.grid.3x3"
        case .saved: 
            return "bookmark"
        case .liked: 
            return "heart"
        }
    }
}


