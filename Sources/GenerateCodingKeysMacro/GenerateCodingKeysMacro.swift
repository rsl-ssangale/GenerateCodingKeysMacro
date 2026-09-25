




@attached(member, names: named(CodingKeys))
public macro GenerateCodingKeys() = #externalMacro(
    module: "GenerateCodingKeysMacroMacros",
    type: "GenerateCodingKeysMacro")
