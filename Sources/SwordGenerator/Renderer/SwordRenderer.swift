import SwiftSyntax
import SwiftSyntaxBuilder

public struct SwordRenderer {
  public init() {}
  func render(
    componentTree: ComponentTree,
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
      render(componentTree)
    }
    var formatted = ""
    output.formatted().write(to: &formatted)
    return formatted
  }

  private func render(_ componentTree: ComponentTree) -> CodeBlockItemListSyntax {
    CodeBlockItemListSyntax {
      ExtensionDeclSyntax(
        leadingTrivia: .newlines(2),
        extendedType: IdentifierTypeSyntax(
          name: .identifier(componentTree.componentNode.name.value)
        )
      ) {
        for (index, registration) in componentTree.registrations.enumerated() {
          VariableDeclSyntax(
            leadingTrivia: index == 0
              ? [
                .newlines(2),
                .lineComment("// MARK: Registrations"),
                .newlines(2),
              ] : [],
            bindingSpecifier: .keyword(.var)
          ) {
            let registrationBody = FunctionCallExprSyntax(
              calledExpression: DeclReferenceExprSyntax(
                baseName: "\(raw: registration.calledExpressionName)"
              ),
              leftParen: .leftParenToken(),
              rightParen: .rightParenToken()
            ) {
              for (index, parameter) in registration.parameters.enumerated() {
                LabeledExprSyntax(
                  label: .identifier(parameter.name),
                  colon: .colonToken(),
                  expression: DeclReferenceExprSyntax(
                    baseName: parameter.isAssisted
                      ? "\(raw: parameter.name)" : "self.\(raw: parameter.key.value)"
                  ),
                  trailingComma: index < (registration.parameters.count - 1) ? .commaToken() : nil
                )
              }
            }
            let assistedParameters = registration.parameters.filter(\.isAssisted)
            let isAssistedInjection = !assistedParameters.isEmpty
            let registrationType = IdentifierTypeSyntax(name: .identifier(registration.type.value))
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
              pattern: IdentifierPatternSyntax(identifier: .identifier(registration.key.value)),
              typeAnnotation: TypeAnnotationSyntax(type: returnType),
              accessorBlock: AccessorBlockSyntax(
                accessors: .getter(
                  CodeBlockItemListSyntax {
                    if let scope = registration.scope {
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

        for (index, subcomponentTree) in componentTree.subcomponentTrees.enumerated() {
          FunctionDeclSyntax(
            leadingTrivia: index == 0
              ? [
                .newlines(2),
                .lineComment("// MARK: Subcomponent Factories"),
                .newlines(2),
              ] : [],
            name: "make\(raw: subcomponentTree.componentNode.name.value)",
            signature: FunctionSignatureSyntax(
              parameterClause: FunctionParameterClauseSyntax(
                parameters: FunctionParameterListSyntax(
                  subcomponentTree.componentNode.arguments.enumerated().map { index, argument in
                    FunctionParameterSyntax(
                      firstName: .identifier(argument.key.value),
                      type: IdentifierTypeSyntax(name: .identifier(argument.type.value)),
                      trailingComma: index < (subcomponentTree.componentNode.arguments.count - 1)
                        ? .commaToken() : nil
                    )
                  }
                )
              ),
              returnClause: ReturnClauseSyntax(
                type: IdentifierTypeSyntax(
                  name: .identifier(subcomponentTree.componentNode.name.value)
                )
              )
            )
          ) {
            FunctionCallExprSyntax(
              calledExpression: DeclReferenceExprSyntax(
                baseName: .identifier(subcomponentTree.componentNode.name.value)
              ),
              leftParen: .leftParenToken(),
              rightParen: .rightParenToken()
            ) {
              LabeledExprSyntax(
                label: "parent",
                colon: .colonToken(),
                expression: DeclReferenceExprSyntax(baseName: "self"),
                trailingComma: subcomponentTree.componentNode.arguments.isEmpty
                  ? nil : .commaToken()
              )
              for (index, argument) in subcomponentTree.componentNode.arguments.enumerated() {
                LabeledExprSyntax(
                  label: .identifier(argument.key.value),
                  colon: .colonToken(),
                  expression: DeclReferenceExprSyntax(baseName: .identifier(argument.key.value)),
                  trailingComma: index < (subcomponentTree.componentNode.arguments.count - 1)
                    ? .commaToken() : nil
                )
              }
            }
          }
        }
      }
      for subcomponentTree in componentTree.subcomponentTrees {
        render(subcomponentTree)
      }
    }
  }
}
