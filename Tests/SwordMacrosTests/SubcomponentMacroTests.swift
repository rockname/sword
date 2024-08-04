import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import SwordMacros

final class SubcomponentMacroTests: XCTestCase {
  let testMacros: [String: Macro.Type] = [
    "Subcomponent": SubcomponentMacro.self
  ]

  func test() {
    assertMacroExpansion(
      """
      @Subcomponent(of: AppComponent.self, arguments: User.self, Account.self)
      final class UserComponent {
      }
      """,
      expandedSource:
        """
        final class UserComponent {

            let user: User

            let account: Account

            private let parent: AppComponent

            init(
                parent: AppComponent,
                user: User,
                account: Account
            ) {
                self.parent = parent
                self.user = user
                self.account = account
            }

            func withSingle<T: AnyObject>(
                _ function: String = #function,
                _ factory: () -> T
            ) -> T {
                _instanceStore.withSingle(function, factory)
            }

            func withWeakReference<T: AnyObject>(
                _ function: String = #function,
                _ factory: () -> T
            ) -> T {
                _instanceStore.withWeakReference(function, factory)
            }

            private let _instanceStore = InstanceStore()
        }

        extension UserComponent: Sword.Subcomponent {
         subscript <T>(dynamicMember keyPath: KeyPath<AppComponent, T>) -> T {
             parent[keyPath: keyPath]
         }
        }
        """,
      macros: testMacros
    )
  }

  func test_publicModifier() {
    assertMacroExpansion(
      """
      @Subcomponent(of: AppComponent.self, arguments: User.self, Account.self)
      public final class UserComponent {
      }
      """,
      expandedSource:
        """
        public final class UserComponent {

            public let user: User

            public let account: Account

            private let parent: AppComponent

            public init(
                parent: AppComponent,
                user: User,
                account: Account
            ) {
                self.parent = parent
                self.user = user
                self.account = account
            }

            public func withSingle<T: AnyObject>(
                _ function: String = #function,
                _ factory: () -> T
            ) -> T {
                _instanceStore.withSingle(function, factory)
            }

            public func withWeakReference<T: AnyObject>(
                _ function: String = #function,
                _ factory: () -> T
            ) -> T {
                _instanceStore.withWeakReference(function, factory)
            }

            private let _instanceStore = InstanceStore()
        }

        extension UserComponent: Sword.Subcomponent {
            public subscript <T>(dynamicMember keyPath: KeyPath<AppComponent, T>) -> T {
                parent[keyPath: keyPath]
            }
        }
        """,
      macros: testMacros
    )
  }
}
