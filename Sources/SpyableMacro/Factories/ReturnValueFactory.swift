import SwiftSyntax
import SwiftSyntaxBuilder

/// The `ReturnValueFactory` is designed to generate a representation of a Swift
/// variable declaration to store the return value of a certain function.
///
/// The generated variable type is implicitly unwrapped optional if the function has a non-optional
/// return type, otherwise, the type is the same as the function's return type. The name of the variable
/// is constructed by appending the word "ReturnValue" to the `variablePrefix` parameter.
///
/// The factory also generates a return statement that uses the stored value as the return value of the function.
///
/// The following code:
/// ```swift
/// var fooReturnValue: Int!
///
/// return fooReturnValue
/// ```
/// would be generated for a function like this:
/// ```swift
/// func foo() -> Int
/// ```
/// and an argument `variablePrefix` equal to `foo`.
///
/// If the return type of the function is optional, the generated variable type is the same as the return type:
/// ```swift
/// var barReturnValue: String?
///
/// return barReturnValue
/// ```
/// for a function like this:
/// ```swift
/// func bar() -> String?
/// ```
/// and an argument `variablePrefix` equal to `bar`.
///
/// - Note: The `ReturnValueFactory` allows you to specify the return value for a function in
///         your tests. You can use it to simulate different scenarios and verify that your code reacts
///         correctly to different returned values.
struct ReturnValueFactory {
    func variableDeclaration(variablePrefix: String, functionReturnType: TypeSyntax) -> VariableDeclSyntax {
        VariableDeclSyntax(
            bindingKeyword: .keyword(.var),
            bindingsBuilder: {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(
                        identifier: variableIdentifier(variablePrefix: variablePrefix)
                    ),
                    typeAnnotation: {
                        if functionReturnType.is(OptionalTypeSyntax.self) {
                            TypeAnnotationSyntax(type: functionReturnType)
                        } else {
                            TypeAnnotationSyntax(
                                type: ImplicitlyUnwrappedOptionalTypeSyntax(wrappedType: functionReturnType)
                            )
                        }
                    }()
                )
            }
        )
    }

    func returnStatement(variablePrefix: String) -> ReturnStmtSyntax {
        ReturnStmtSyntax(
            returnKeyword: .keyword(.return),
            expression: IdentifierExprSyntax(identifier: variableIdentifier(variablePrefix: variablePrefix))
        )
    }

    private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
        TokenSyntax.identifier(variablePrefix + "ReturnValue")
    }
}