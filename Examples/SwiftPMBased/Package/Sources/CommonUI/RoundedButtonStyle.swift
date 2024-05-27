import SwiftUI

public struct RoundedButtonStyle: ButtonStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.headline)
      .fontWeight(.semibold)
      .padding()
      .background(Color.accentColor)
      .foregroundStyle(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}

extension ButtonStyle where Self == RoundedButtonStyle {
  public static var rounded: Self {
    .init()
  }
}
