import SwiftSyntax
import SwiftSyntaxBuilder

package struct SwordRenderer {
  package init() {}
  func render(
    bindingGraph: BindingGraph,
    imports: [Import]
  ) -> String {
    let output = SourceFileSyntax {
      for `import` in imports {
        ImportDeclSyntax(
          importKindSpecifier: `import`.kind.map { .identifier($0) },
          path: ImportPathComponentListSyntax {
            ImportPathComponentSyntax(name: .identifier(`import`.path))
          }
        )
      }
      render(bindingGraph, for: bindingGraph.rootComponent)
    }
    var formatted = ""
    output.formatted().write(to: &formatted)
    return formatted
  }

  private func render(_ bindingGraph: BindingGraph, for component: Component) -> CodeBlockItemListSyntax {
    CodeBlockItemListSyntax {
      ExtensionDeclSyntax(
        leadingTrivia: .newlines(2),
        extendedType: IdentifierTypeSyntax(
          name: .identifier(component.name.value)
        )
      ) {
        for binding in bindingGraph.bindings(for: component) {
          if case .registration(
            let parameters,
            let calledExpression,
            let hasMainActor,
            let scope
          ) = binding.kind {
            VariableDeclSyntax(
              attributes: hasMainActor
                ? [
                  .attribute(
                    .init(
                      atSign: .atSignToken(),
                      attributeName: IdentifierTypeSyntax(name: .identifier("MainActor")),
                      trailingTrivia: .newline
                    )
                  )
                ] : [],
              bindingSpecifier: .keyword(.var)
            ) {
              let registrationBody = FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(
                  baseName: "\(raw: calledExpression)"
                ),
                leftParen: .leftParenToken(),
                rightParen: .rightParenToken()
              ) {
                for (index, parameter) in parameters.enumerated() {
                  LabeledExprSyntax(
                    label: .identifier(parameter.name),
                    colon: .colonToken(),
                    expression: DeclReferenceExprSyntax(
                      baseName: parameter.isAssisted
                        ? "\(raw: parameter.name)" : "self.\(raw: parameter.key.value)"
                    ),
                    trailingComma: index < (parameters.count - 1) ? .commaToken() : nil
                  )
                }
              }
              let assistedParameters = parameters.filter(\.isAssisted)
              let isAssistedInjection = !assistedParameters.isEmpty
              let registrationType = IdentifierTypeSyntax(name: .identifier(binding.type.value))
              let returnType: any TypeSyntaxProtocol =
                if isAssistedInjection {
                  FunctionTypeSyntax(
                    parameters: TupleTypeElementListSyntax {
                      for assistedParameter in assistedParameters {
                        TupleTypeElementSyntax(
                          firstName: .wildcardToken(),
                          secondName: .identifier(assistedParameter.name),
                          colon: .colonToken(),
                          type: IdentifierTypeSyntax(name: .identifier(assistedParameter.type.value))
                        )
                      }
                    },
                    returnClause: ReturnClauseSyntax(type: registrationType)
                  )
                } else {
                  registrationType
                }
              PatternBindingSyntax(
                pattern: IdentifierPatternSyntax(identifier: .identifier(binding.key.value)),
                typeAnnotation: TypeAnnotationSyntax(type: returnType),
                accessorBlock: AccessorBlockSyntax(
                  accessors: .getter(
                    CodeBlockItemListSyntax {
                      if let scope {
                        FunctionCallExprSyntax(
                          calledExpression: DeclReferenceExprSyntax(
                            baseName: .identifier(scope.methodName)
                          ),
                          arguments: [],
                          trailingClosure: ClosureExprSyntax(
                            leftBrace: .leftBraceToken(),
                            rightBrace: .rightBraceToken()
                          ) {
                            registrationBody
                          }
                        )
                      } else if isAssistedInjection {
                        ClosureExprSyntax(
                          signature: ClosureSignatureSyntax(
                            parameterClause: .simpleInput(
                              ClosureShorthandParameterListSyntax {
                                for (index, assistedParameter) in assistedParameters.enumerated() {
                                  ClosureShorthandParameterSyntax(
                                    name: .identifier(assistedParameter.name),
                                    trailingComma: index < (assistedParameters.count - 1)
                                      ? .commaToken() : nil
                                  )
                                }
                              }
                            )
                          )
                        ) {
                          registrationBody
                        }
                      } else {
                        registrationBody
                      }
                    }
                  )
                )
              )
            }
          }
        }

        for (index, subcomponent) in bindingGraph.subcomponents(for: component).enumerated() {
          FunctionDeclSyntax(
            leadingTrivia: index == 0
              ? [
                .newlines(2),
                .lineComment("// MARK: Subcomponent Factories"),
                .newlines(2),
              ] : [],
            name: "make\(raw: subcomponent.name.value)",
            signature: FunctionSignatureSyntax(
              parameterClause: FunctionParameterClauseSyntax(
                parameters: FunctionParameterListSyntax(
                  subcomponent.arguments.enumerated().map { index, argument in
                    FunctionParameterSyntax(
                      firstName: .identifier(argument.key.value),
                      type: IdentifierTypeSyntax(name: .identifier(argument.type.value)),
                      trailingComma: index < (subcomponent.arguments.count - 1)
                        ? .commaToken() : nil
                    )
                  }
                )
              ),
              returnClause: ReturnClauseSyntax(
                type: IdentifierTypeSyntax(
                  name: .identifier(subcomponent.name.value)
                )
              )
            )
          ) {
            FunctionCallExprSyntax(
              calledExpression: DeclReferenceExprSyntax(
                baseName: .identifier(subcomponent.name.value)
              ),
              leftParen: .leftParenToken(),
              rightParen: .rightParenToken()
            ) {
              LabeledExprSyntax(
                label: "parent",
                colon: .colonToken(),
                expression: DeclReferenceExprSyntax(baseName: "self"),
                trailingComma: subcomponent.arguments.isEmpty
                  ? nil : .commaToken()
              )
              for (index, argument) in subcomponent.arguments.enumerated() {
                LabeledExprSyntax(
                  label: .identifier(argument.key.value),
                  colon: .colonToken(),
                  expression: DeclReferenceExprSyntax(baseName: .identifier(argument.key.value)),
                  trailingComma: index < (subcomponent.arguments.count - 1)
                    ? .commaToken() : nil
                )
              }
            }
          }
        }
      }
      for subcomponent in bindingGraph.subcomponents(for: component) {
        render(bindingGraph, for: subcomponent)
      }
    }
  }
}
