//
//  LogoView.swift
//  GTStudyBuddy
//
//  Created by Jai Chawla on 4/16/22.
//

import SwiftUI

struct LogoView: View {
  @EnvironmentObject var session: SessionStore
  @Binding var hasLoaded: Bool
    var body: some View {
      VStack(spacing: 15) {
        Spacer()

        Text("Study")
          .font(.title)
        Text("Together")
          .font(.title)
          .italic()
        Text("🤝 📚")
          .font(.title)
        
        Spacer()
        
        Text("Made for Georgia Tech students by Georgia Students")
          .font(.caption)
          .multilineTextAlignment(.center)

      }
      .onAppear {
#if DEBUG
        LaunchBehaviour.when(.ensureSignIn, session.signOut)
#endif
        session.listen() {
          self.hasLoaded = true
        }
      }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
      LogoView(hasLoaded: .constant(false))
        .environmentObject(SessionStore())
    }
}
