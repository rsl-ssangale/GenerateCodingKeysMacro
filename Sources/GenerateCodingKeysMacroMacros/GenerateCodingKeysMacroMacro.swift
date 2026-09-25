import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum GenerateCodingKeysError: Error, CustomStringConvertible {
    case onlyStructSupported

    var description: String {
        switch self {
        case .onlyStructSupported:
            return "@GenerateCodingKeys can only be applied to a struct."
        }
    }
}

public struct GenerateCodingKeysMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        guard let structDeclaration =
            declaration.as(StructDeclSyntax.self)
        else {
            throw GenerateCodingKeysError.onlyStructSupported
        }

        let properties = structDeclaration.memberBlock.members.compactMap {
            member -> String? in

            guard let variable =
                member.decl.as(VariableDeclSyntax.self)
            else {
                return nil
            }

            guard variable.bindings.count == 1,
                  let binding = variable.bindings.first,
                  binding.accessorBlock == nil,
                  let identifier =
                    binding.pattern.as(IdentifierPatternSyntax.self)
            else {
                return nil
            }

            return identifier.identifier.text
        }

        let codingKeyCases = properties.map { propertyName in
            let codingKeyName = snakeCase(propertyName)

            return "case \(propertyName) = \"\(codingKeyName)\""
        }
        .joined(separator: "\n")

        let codingKeys: DeclSyntax = """
        enum CodingKeys: String, CodingKey {
            \(raw: codingKeyCases)
        }
        """

        return [codingKeys]
    }

    private static func snakeCase(_ name: String) -> String {
        var result = ""

        for character in name {
            if character.isUppercase {
                if !result.isEmpty {
                    result.append("_")
                }

                result.append(contentsOf: character.lowercased())
            } else {
                result.append(character)
            }
        }

        return result
    }
}

@main
struct GenerateCodingKeysMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GenerateCodingKeysMacro.self,
    ]
}
