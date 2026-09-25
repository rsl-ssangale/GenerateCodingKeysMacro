import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(GenerateCodingKeysMacroMacros)
import GenerateCodingKeysMacroMacros

let testMacros: [String: Macro.Type] = [
    "GenerateCodingKeys": GenerateCodingKeysMacro.self
]
#endif

final class GenerateCodingKeysMacroTests: XCTestCase {

    func testArticleCodingKeys() throws {
        #if canImport(GenerateCodingKeysMacroMacros)

        assertMacroExpansion(
            """
            @GenerateCodingKeys
            struct Article: Codable {
                let articleId: Int
                let articleTitle: String
                let authorName: String
                let publishedDate: String
            }
            """,
            expandedSource: """
            struct Article: Codable {
                let articleId: Int
                let articleTitle: String
                let authorName: String
                let publishedDate: String

                enum CodingKeys: String, CodingKey {
                    case articleId = "article_id"
                    case articleTitle = "article_title"
                    case authorName = "author_name"
                    case publishedDate = "published_date"
                }
            }
            """,
            macros: testMacros
        )

        #else

        throw XCTSkip(
            "macros are only supported when running tests for the host platform"
        )

        #endif
    }

    func testCommentCodingKeys() throws {
        #if canImport(GenerateCodingKeysMacroMacros)

        assertMacroExpansion(
            """
            @GenerateCodingKeys
            struct Comment: Codable {
                let commentId: Int
                let articleId: Int
                let commenterName: String
                let createdAt: String
            }
            """,
            expandedSource: """
            struct Comment: Codable {
                let commentId: Int
                let articleId: Int
                let commenterName: String
                let createdAt: String

                enum CodingKeys: String, CodingKey {
                    case commentId = "comment_id"
                    case articleId = "article_id"
                    case commenterName = "commenter_name"
                    case createdAt = "created_at"
                }
            }
            """,
            macros: testMacros
        )

        #else

        throw XCTSkip(
            "macros are only supported when running tests for the host platform"
        )

        #endif
    }

    func testMacroOnlySupportsStructs() throws {
        #if canImport(GenerateCodingKeysMacroMacros)

        assertMacroExpansion(
            """
            @GenerateCodingKeys
            enum Article {
                case active
            }
            """,
            expandedSource: """
            enum Article {
                case active
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@GenerateCodingKeys can only be applied to a struct.",
                    line: 1,
                    column: 1
                )
            ],
            macros: testMacros
        )

        #else

        throw XCTSkip(
            "macros are only supported when running tests for the host platform"
        )

        #endif
    }
}
