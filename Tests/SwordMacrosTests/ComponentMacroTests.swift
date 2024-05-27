import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import SwordMacros

final class ComponentMacroTests: XCTestCase {
  let testMacros: [String: Macro.Type] = [
    "Component": ComponentMacro.self
  ]

  func test() {
    assertMacroExpansion(
      """
      @Component(arguments: .init(EnvVars.self))
      final class AppComponent {
      }
      """,
      expandedSource:
        """
        final class AppComponent {

            let envVars: EnvVars

            init(
                envVars: EnvVars
            ) {
                self.envVars = envVars
            }

            func withSingle<T: AnyObject>(
                _ function: String = #function,
                _ factory: () -> T
            ) -> T {
                _instanceStore.withSingle(function, factory)
            }

            private let _instanceStore = InstanceStore()
        }

        extension AppComponent: Sword.Component {
        }
        """,
      macros: testMacros
    )
  }

  func test_publicModifier() {
    assertMacroExpansion(
      """
      @Component(arguments: .init(EnvVars.self))
      public final class AppComponent {
      }
      """,
      expandedSource:
        """
        public final class AppComponent {

            public let envVars: EnvVars

            public init(
                envVars: EnvVars
            ) {
                self.envVars = envVars
            }

            public func withSingle<T: AnyObject>(
                _ function: String = #function,
                _ factory: () -> T
            ) -> T {
                _instanceStore.withSingle(function, factory)
            }

            private let _instanceStore = InstanceStore()
        }

        extension AppComponent: Sword.Component {
        }
        """,
      macros: testMacros
    )
  }
}
