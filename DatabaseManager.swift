import Foundation
import SQLite3

final class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: OpaquePointer?
    private let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    private init() {
        openDatabase()
        createTable()
    }

    private func openDatabase() {
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("FoundIt.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("FoundIt: Could not open database: \(errorMessage)")
        } else {
            print("FoundIt: Database opened at \(fileURL.path)")
        }
    }

    private var errorMessage: String {
        guard let db, let message = sqlite3_errmsg(db) else {
            return "Unknown SQLite error"
        }
        return String(cString: message)
    }

    private func createTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            itemDescription TEXT NOT NULL,
            location TEXT NOT NULL,
            type TEXT NOT NULL,
            status TEXT NOT NULL,
            date TEXT NOT NULL
        );
        """

        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK {
            print("FoundIt: Could not create table: \(errorMessage)")
        }
    }

    private func bind(_ value: String, to index: Int32, in statement: OpaquePointer?) {
        sqlite3_bind_text(statement, index, (value as NSString).utf8String, -1, transient)
    }

    private func columnText(_ statement: OpaquePointer?, _ index: Int32) -> String {
        guard let pointer = sqlite3_column_text(statement, index) else { return "" }
        return String(cString: pointer)
    }

    // CREATE
    @discardableResult
    func insert(_ item: LostFoundItem) -> Bool {
        let sql = """
        INSERT INTO items (name, itemDescription, location, type, status, date)
        VALUES (?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("FoundIt: Insert prepare failed: \(errorMessage)")
            return false
        }
        defer { sqlite3_finalize(statement) }

        bind(item.name, to: 1, in: statement)
        bind(item.itemDescription, to: 2, in: statement)
        bind(item.location, to: 3, in: statement)
        bind(item.type, to: 4, in: statement)
        bind(item.status, to: 5, in: statement)
        bind(item.date, to: 6, in: statement)

        let result = sqlite3_step(statement) == SQLITE_DONE
        if !result { print("FoundIt: Insert failed: \(errorMessage)") }
        return result
    }

    // READ
    func fetchAll() -> [LostFoundItem] {
        let sql = """
        SELECT id, name, itemDescription, location, type, status, date
        FROM items ORDER BY id DESC;
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("FoundIt: Select prepare failed: \(errorMessage)")
            return []
        }
        defer { sqlite3_finalize(statement) }

        var items: [LostFoundItem] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            items.append(
                LostFoundItem(
                    id: Int(sqlite3_column_int(statement, 0)),
                    name: columnText(statement, 1),
                    itemDescription: columnText(statement, 2),
                    location: columnText(statement, 3),
                    type: columnText(statement, 4),
                    status: columnText(statement, 5),
                    date: columnText(statement, 6)
                )
            )
        }
        return items
    }

    // UPDATE
    @discardableResult
    func update(_ item: LostFoundItem) -> Bool {
        let sql = """
        UPDATE items
        SET name = ?, itemDescription = ?, location = ?, type = ?, status = ?, date = ?
        WHERE id = ?;
        """
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("FoundIt: Update prepare failed: \(errorMessage)")
            return false
        }
        defer { sqlite3_finalize(statement) }

        bind(item.name, to: 1, in: statement)
        bind(item.itemDescription, to: 2, in: statement)
        bind(item.location, to: 3, in: statement)
        bind(item.type, to: 4, in: statement)
        bind(item.status, to: 5, in: statement)
        bind(item.date, to: 6, in: statement)
        sqlite3_bind_int(statement, 7, Int32(item.id))

        let result = sqlite3_step(statement) == SQLITE_DONE
        if !result { print("FoundIt: Update failed: \(errorMessage)") }
        return result
    }

    // DELETE
    @discardableResult
    func delete(id: Int) -> Bool {
        let sql = "DELETE FROM items WHERE id = ?;"
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("FoundIt: Delete prepare failed: \(errorMessage)")
            return false
        }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_int(statement, 1, Int32(id))
        let result = sqlite3_step(statement) == SQLITE_DONE
        if !result { print("FoundIt: Delete failed: \(errorMessage)") }
        return result
    }

    deinit {
        sqlite3_close(db)
    }
}
