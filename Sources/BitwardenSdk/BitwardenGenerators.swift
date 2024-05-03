// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!

// swiftlint:disable all
import Foundation

// Depending on the consumer's build setup, the low-level FFI code
// might be in a separate module, or it might be compiled inline into
// this module. This is a bit of light hackery to work with both.
#if canImport(BitwardenGeneratorsFFI)
import BitwardenGeneratorsFFI
#endif

fileprivate extension RustBuffer {
    // Allocate a new buffer, copying the contents of a `UInt8` array.
    init(bytes: [UInt8]) {
        let rbuf = bytes.withUnsafeBufferPointer { ptr in
            RustBuffer.from(ptr)
        }
        self.init(capacity: rbuf.capacity, len: rbuf.len, data: rbuf.data)
    }

    static func empty() -> RustBuffer {
        RustBuffer(capacity: 0, len:0, data: nil)
    }

    static func from(_ ptr: UnsafeBufferPointer<UInt8>) -> RustBuffer {
        try! rustCall { ffi_bitwarden_generators_rustbuffer_from_bytes(ForeignBytes(bufferPointer: ptr), $0) }
    }

    // Frees the buffer in place.
    // The buffer must not be used after this is called.
    func deallocate() {
        try! rustCall { ffi_bitwarden_generators_rustbuffer_free(self, $0) }
    }
}

fileprivate extension ForeignBytes {
    init(bufferPointer: UnsafeBufferPointer<UInt8>) {
        self.init(len: Int32(bufferPointer.count), data: bufferPointer.baseAddress)
    }
}

// For every type used in the interface, we provide helper methods for conveniently
// lifting and lowering that type from C-compatible data, and for reading and writing
// values of that type in a buffer.

// Helper classes/extensions that don't change.
// Someday, this will be in a library of its own.

fileprivate extension Data {
    init(rustBuffer: RustBuffer) {
        // TODO: This copies the buffer. Can we read directly from a
        // Rust buffer?
        self.init(bytes: rustBuffer.data!, count: Int(rustBuffer.len))
    }
}

// Define reader functionality.  Normally this would be defined in a class or
// struct, but we use standalone functions instead in order to make external
// types work.
//
// With external types, one swift source file needs to be able to call the read
// method on another source file's FfiConverter, but then what visibility
// should Reader have?
// - If Reader is fileprivate, then this means the read() must also
//   be fileprivate, which doesn't work with external types.
// - If Reader is internal/public, we'll get compile errors since both source
//   files will try define the same type.
//
// Instead, the read() method and these helper functions input a tuple of data

fileprivate func createReader(data: Data) -> (data: Data, offset: Data.Index) {
    (data: data, offset: 0)
}

// Reads an integer at the current offset, in big-endian order, and advances
// the offset on success. Throws if reading the integer would move the
// offset past the end of the buffer.
fileprivate func readInt<T: FixedWidthInteger>(_ reader: inout (data: Data, offset: Data.Index)) throws -> T {
    let range = reader.offset..<reader.offset + MemoryLayout<T>.size
    guard reader.data.count >= range.upperBound else {
        throw UniffiInternalError.bufferOverflow
    }
    if T.self == UInt8.self {
        let value = reader.data[reader.offset]
        reader.offset += 1
        return value as! T
    }
    var value: T = 0
    let _ = withUnsafeMutableBytes(of: &value, { reader.data.copyBytes(to: $0, from: range)})
    reader.offset = range.upperBound
    return value.bigEndian
}

// Reads an arbitrary number of bytes, to be used to read
// raw bytes, this is useful when lifting strings
fileprivate func readBytes(_ reader: inout (data: Data, offset: Data.Index), count: Int) throws -> Array<UInt8> {
    let range = reader.offset..<(reader.offset+count)
    guard reader.data.count >= range.upperBound else {
        throw UniffiInternalError.bufferOverflow
    }
    var value = [UInt8](repeating: 0, count: count)
    value.withUnsafeMutableBufferPointer({ buffer in
        reader.data.copyBytes(to: buffer, from: range)
    })
    reader.offset = range.upperBound
    return value
}

// Reads a float at the current offset.
fileprivate func readFloat(_ reader: inout (data: Data, offset: Data.Index)) throws -> Float {
    return Float(bitPattern: try readInt(&reader))
}

// Reads a float at the current offset.
fileprivate func readDouble(_ reader: inout (data: Data, offset: Data.Index)) throws -> Double {
    return Double(bitPattern: try readInt(&reader))
}

// Indicates if the offset has reached the end of the buffer.
fileprivate func hasRemaining(_ reader: (data: Data, offset: Data.Index)) -> Bool {
    return reader.offset < reader.data.count
}

// Define writer functionality.  Normally this would be defined in a class or
// struct, but we use standalone functions instead in order to make external
// types work.  See the above discussion on Readers for details.

fileprivate func createWriter() -> [UInt8] {
    return []
}

fileprivate func writeBytes<S>(_ writer: inout [UInt8], _ byteArr: S) where S: Sequence, S.Element == UInt8 {
    writer.append(contentsOf: byteArr)
}

// Writes an integer in big-endian order.
//
// Warning: make sure what you are trying to write
// is in the correct type!
fileprivate func writeInt<T: FixedWidthInteger>(_ writer: inout [UInt8], _ value: T) {
    var value = value.bigEndian
    withUnsafeBytes(of: &value) { writer.append(contentsOf: $0) }
}

fileprivate func writeFloat(_ writer: inout [UInt8], _ value: Float) {
    writeInt(&writer, value.bitPattern)
}

fileprivate func writeDouble(_ writer: inout [UInt8], _ value: Double) {
    writeInt(&writer, value.bitPattern)
}

// Protocol for types that transfer other types across the FFI. This is
// analogous go the Rust trait of the same name.
fileprivate protocol FfiConverter {
    associatedtype FfiType
    associatedtype SwiftType

    static func lift(_ value: FfiType) throws -> SwiftType
    static func lower(_ value: SwiftType) -> FfiType
    static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> SwiftType
    static func write(_ value: SwiftType, into buf: inout [UInt8])
}

// Types conforming to `Primitive` pass themselves directly over the FFI.
fileprivate protocol FfiConverterPrimitive: FfiConverter where FfiType == SwiftType { }

extension FfiConverterPrimitive {
    public static func lift(_ value: FfiType) throws -> SwiftType {
        return value
    }

    public static func lower(_ value: SwiftType) -> FfiType {
        return value
    }
}

// Types conforming to `FfiConverterRustBuffer` lift and lower into a `RustBuffer`.
// Used for complex types where it's hard to write a custom lift/lower.
fileprivate protocol FfiConverterRustBuffer: FfiConverter where FfiType == RustBuffer {}

extension FfiConverterRustBuffer {
    public static func lift(_ buf: RustBuffer) throws -> SwiftType {
        var reader = createReader(data: Data(rustBuffer: buf))
        let value = try read(from: &reader)
        if hasRemaining(reader) {
            throw UniffiInternalError.incompleteData
        }
        buf.deallocate()
        return value
    }

    public static func lower(_ value: SwiftType) -> RustBuffer {
          var writer = createWriter()
          write(value, into: &writer)
          return RustBuffer(bytes: writer)
    }
}
// An error type for FFI errors. These errors occur at the UniFFI level, not
// the library level.
fileprivate enum UniffiInternalError: LocalizedError {
    case bufferOverflow
    case incompleteData
    case unexpectedOptionalTag
    case unexpectedEnumCase
    case unexpectedNullPointer
    case unexpectedRustCallStatusCode
    case unexpectedRustCallError
    case unexpectedStaleHandle
    case rustPanic(_ message: String)

    public var errorDescription: String? {
        switch self {
        case .bufferOverflow: return "Reading the requested value would read past the end of the buffer"
        case .incompleteData: return "The buffer still has data after lifting its containing value"
        case .unexpectedOptionalTag: return "Unexpected optional tag; should be 0 or 1"
        case .unexpectedEnumCase: return "Raw enum value doesn't match any cases"
        case .unexpectedNullPointer: return "Raw pointer value was null"
        case .unexpectedRustCallStatusCode: return "Unexpected RustCallStatus code"
        case .unexpectedRustCallError: return "CALL_ERROR but no errorClass specified"
        case .unexpectedStaleHandle: return "The object in the handle map has been dropped already"
        case let .rustPanic(message): return message
        }
    }
}

fileprivate extension NSLock {
    func withLock<T>(f: () throws -> T) rethrows -> T {
        self.lock()
        defer { self.unlock() }
        return try f()
    }
}

fileprivate let CALL_SUCCESS: Int8 = 0
fileprivate let CALL_ERROR: Int8 = 1
fileprivate let CALL_UNEXPECTED_ERROR: Int8 = 2
fileprivate let CALL_CANCELLED: Int8 = 3

fileprivate extension RustCallStatus {
    init() {
        self.init(
            code: CALL_SUCCESS,
            errorBuf: RustBuffer.init(
                capacity: 0,
                len: 0,
                data: nil
            )
        )
    }
}

private func rustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    try makeRustCall(callback, errorHandler: nil)
}

private func rustCallWithError<T>(
    _ errorHandler: @escaping (RustBuffer) throws -> Error,
    _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    try makeRustCall(callback, errorHandler: errorHandler)
}

private func makeRustCall<T>(
    _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T,
    errorHandler: ((RustBuffer) throws -> Error)?
) throws -> T {
    uniffiEnsureInitialized()
    var callStatus = RustCallStatus.init()
    let returnedVal = callback(&callStatus)
    try uniffiCheckCallStatus(callStatus: callStatus, errorHandler: errorHandler)
    return returnedVal
}

private func uniffiCheckCallStatus(
    callStatus: RustCallStatus,
    errorHandler: ((RustBuffer) throws -> Error)?
) throws {
    switch callStatus.code {
        case CALL_SUCCESS:
            return

        case CALL_ERROR:
            if let errorHandler = errorHandler {
                throw try errorHandler(callStatus.errorBuf)
            } else {
                callStatus.errorBuf.deallocate()
                throw UniffiInternalError.unexpectedRustCallError
            }

        case CALL_UNEXPECTED_ERROR:
            // When the rust code sees a panic, it tries to construct a RustBuffer
            // with the message.  But if that code panics, then it just sends back
            // an empty buffer.
            if callStatus.errorBuf.len > 0 {
                throw UniffiInternalError.rustPanic(try FfiConverterString.lift(callStatus.errorBuf))
            } else {
                callStatus.errorBuf.deallocate()
                throw UniffiInternalError.rustPanic("Rust panic")
            }

        case CALL_CANCELLED:
            fatalError("Cancellation not supported yet")

        default:
            throw UniffiInternalError.unexpectedRustCallStatusCode
    }
}

private func uniffiTraitInterfaceCall<T>(
    callStatus: UnsafeMutablePointer<RustCallStatus>,
    makeCall: () throws -> T,
    writeReturn: (T) -> ()
) {
    do {
        try writeReturn(makeCall())
    } catch let error {
        callStatus.pointee.code = CALL_UNEXPECTED_ERROR
        callStatus.pointee.errorBuf = FfiConverterString.lower(String(describing: error))
    }
}

private func uniffiTraitInterfaceCallWithError<T, E>(
    callStatus: UnsafeMutablePointer<RustCallStatus>,
    makeCall: () throws -> T,
    writeReturn: (T) -> (),
    lowerError: (E) -> RustBuffer
) {
    do {
        try writeReturn(makeCall())
    } catch let error as E {
        callStatus.pointee.code = CALL_ERROR
        callStatus.pointee.errorBuf = lowerError(error)
    } catch {
        callStatus.pointee.code = CALL_UNEXPECTED_ERROR
        callStatus.pointee.errorBuf = FfiConverterString.lower(String(describing: error))
    }
}
fileprivate class UniffiHandleMap<T> {
    private var map: [UInt64: T] = [:]
    private let lock = NSLock()
    private var currentHandle: UInt64 = 1

    func insert(obj: T) -> UInt64 {
        lock.withLock {
            let handle = currentHandle
            currentHandle += 1
            map[handle] = obj
            return handle
        }
    }

     func get(handle: UInt64) throws -> T {
        try lock.withLock {
            guard let obj = map[handle] else {
                throw UniffiInternalError.unexpectedStaleHandle
            }
            return obj
        }
    }

    @discardableResult
    func remove(handle: UInt64) throws -> T {
        try lock.withLock {
            guard let obj = map.removeValue(forKey: handle) else {
                throw UniffiInternalError.unexpectedStaleHandle
            }
            return obj
        }
    }

    var count: Int {
        get {
            map.count
        }
    }
}


// Public interface members begin here.


fileprivate struct FfiConverterUInt8: FfiConverterPrimitive {
    typealias FfiType = UInt8
    typealias SwiftType = UInt8

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> UInt8 {
        return try lift(readInt(&buf))
    }

    public static func write(_ value: UInt8, into buf: inout [UInt8]) {
        writeInt(&buf, lower(value))
    }
}

fileprivate struct FfiConverterBool : FfiConverter {
    typealias FfiType = Int8
    typealias SwiftType = Bool

    public static func lift(_ value: Int8) throws -> Bool {
        return value != 0
    }

    public static func lower(_ value: Bool) -> Int8 {
        return value ? 1 : 0
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> Bool {
        return try lift(readInt(&buf))
    }

    public static func write(_ value: Bool, into buf: inout [UInt8]) {
        writeInt(&buf, lower(value))
    }
}

fileprivate struct FfiConverterString: FfiConverter {
    typealias SwiftType = String
    typealias FfiType = RustBuffer

    public static func lift(_ value: RustBuffer) throws -> String {
        defer {
            value.deallocate()
        }
        if value.data == nil {
            return String()
        }
        let bytes = UnsafeBufferPointer<UInt8>(start: value.data!, count: Int(value.len))
        return String(bytes: bytes, encoding: String.Encoding.utf8)!
    }

    public static func lower(_ value: String) -> RustBuffer {
        return value.utf8CString.withUnsafeBufferPointer { ptr in
            // The swift string gives us int8_t, we want uint8_t.
            ptr.withMemoryRebound(to: UInt8.self) { ptr in
                // The swift string gives us a trailing null byte, we don't want it.
                let buf = UnsafeBufferPointer(rebasing: ptr.prefix(upTo: ptr.count - 1))
                return RustBuffer.from(buf)
            }
        }
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> String {
        let len: Int32 = try readInt(&buf)
        return String(bytes: try readBytes(&buf, count: Int(len)), encoding: String.Encoding.utf8)!
    }

    public static func write(_ value: String, into buf: inout [UInt8]) {
        let len = Int32(value.utf8.count)
        writeInt(&buf, len)
        writeBytes(&buf, value.utf8)
    }
}


/**
 * Passphrase generator request options.
 */
public struct PassphraseGeneratorRequest {
    /**
     * Number of words in the generated passphrase.
     * This value must be between 3 and 20.
     */
    public let numWords: UInt8
    /**
     * Character separator between words in the generated passphrase. The value cannot be empty.
     */
    public let wordSeparator: String
    /**
     * When set to true, capitalize the first letter of each word in the generated passphrase.
     */
    public let capitalize: Bool
    /**
     * When set to true, include a number at the end of one of the words in the generated
     * passphrase.
     */
    public let includeNumber: Bool

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(
        /**
         * Number of words in the generated passphrase.
         * This value must be between 3 and 20.
         */numWords: UInt8, 
        /**
         * Character separator between words in the generated passphrase. The value cannot be empty.
         */wordSeparator: String, 
        /**
         * When set to true, capitalize the first letter of each word in the generated passphrase.
         */capitalize: Bool, 
        /**
         * When set to true, include a number at the end of one of the words in the generated
         * passphrase.
         */includeNumber: Bool) {
        self.numWords = numWords
        self.wordSeparator = wordSeparator
        self.capitalize = capitalize
        self.includeNumber = includeNumber
    }
}



extension PassphraseGeneratorRequest: Equatable, Hashable {
    public static func ==(lhs: PassphraseGeneratorRequest, rhs: PassphraseGeneratorRequest) -> Bool {
        if lhs.numWords != rhs.numWords {
            return false
        }
        if lhs.wordSeparator != rhs.wordSeparator {
            return false
        }
        if lhs.capitalize != rhs.capitalize {
            return false
        }
        if lhs.includeNumber != rhs.includeNumber {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(numWords)
        hasher.combine(wordSeparator)
        hasher.combine(capitalize)
        hasher.combine(includeNumber)
    }
}


public struct FfiConverterTypePassphraseGeneratorRequest: FfiConverterRustBuffer {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> PassphraseGeneratorRequest {
        return
            try PassphraseGeneratorRequest(
                numWords: FfiConverterUInt8.read(from: &buf), 
                wordSeparator: FfiConverterString.read(from: &buf), 
                capitalize: FfiConverterBool.read(from: &buf), 
                includeNumber: FfiConverterBool.read(from: &buf)
        )
    }

    public static func write(_ value: PassphraseGeneratorRequest, into buf: inout [UInt8]) {
        FfiConverterUInt8.write(value.numWords, into: &buf)
        FfiConverterString.write(value.wordSeparator, into: &buf)
        FfiConverterBool.write(value.capitalize, into: &buf)
        FfiConverterBool.write(value.includeNumber, into: &buf)
    }
}


public func FfiConverterTypePassphraseGeneratorRequest_lift(_ buf: RustBuffer) throws -> PassphraseGeneratorRequest {
    return try FfiConverterTypePassphraseGeneratorRequest.lift(buf)
}

public func FfiConverterTypePassphraseGeneratorRequest_lower(_ value: PassphraseGeneratorRequest) -> RustBuffer {
    return FfiConverterTypePassphraseGeneratorRequest.lower(value)
}


/**
 * Password generator request options.
 */
public struct PasswordGeneratorRequest {
    /**
     * Include lowercase characters (a-z).
     */
    public let lowercase: Bool
    /**
     * Include uppercase characters (A-Z).
     */
    public let uppercase: Bool
    /**
     * Include numbers (0-9).
     */
    public let numbers: Bool
    /**
     * Include special characters: ! @ # $ % ^ & *
     */
    public let special: Bool
    /**
     * The length of the generated password.
     * Note that the password length must be greater than the sum of all the minimums.
     */
    public let length: UInt8
    /**
     * When set to true, the generated password will not contain ambiguous characters.
     * The ambiguous characters are: I, O, l, 0, 1
     */
    public let avoidAmbiguous: Bool
    /**
     * The minimum number of lowercase characters in the generated password.
     * When set, the value must be between 1 and 9. This value is ignored is lowercase is false
     */
    public let minLowercase: UInt8?
    /**
     * The minimum number of uppercase characters in the generated password.
     * When set, the value must be between 1 and 9. This value is ignored is uppercase is false
     */
    public let minUppercase: UInt8?
    /**
     * The minimum number of numbers in the generated password.
     * When set, the value must be between 1 and 9. This value is ignored is numbers is false
     */
    public let minNumber: UInt8?
    /**
     * The minimum number of special characters in the generated password.
     * When set, the value must be between 1 and 9. This value is ignored is special is false
     */
    public let minSpecial: UInt8?

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(
        /**
         * Include lowercase characters (a-z).
         */lowercase: Bool, 
        /**
         * Include uppercase characters (A-Z).
         */uppercase: Bool, 
        /**
         * Include numbers (0-9).
         */numbers: Bool, 
        /**
         * Include special characters: ! @ # $ % ^ & *
         */special: Bool, 
        /**
         * The length of the generated password.
         * Note that the password length must be greater than the sum of all the minimums.
         */length: UInt8, 
        /**
         * When set to true, the generated password will not contain ambiguous characters.
         * The ambiguous characters are: I, O, l, 0, 1
         */avoidAmbiguous: Bool, 
        /**
         * The minimum number of lowercase characters in the generated password.
         * When set, the value must be between 1 and 9. This value is ignored is lowercase is false
         */minLowercase: UInt8?, 
        /**
         * The minimum number of uppercase characters in the generated password.
         * When set, the value must be between 1 and 9. This value is ignored is uppercase is false
         */minUppercase: UInt8?, 
        /**
         * The minimum number of numbers in the generated password.
         * When set, the value must be between 1 and 9. This value is ignored is numbers is false
         */minNumber: UInt8?, 
        /**
         * The minimum number of special characters in the generated password.
         * When set, the value must be between 1 and 9. This value is ignored is special is false
         */minSpecial: UInt8?) {
        self.lowercase = lowercase
        self.uppercase = uppercase
        self.numbers = numbers
        self.special = special
        self.length = length
        self.avoidAmbiguous = avoidAmbiguous
        self.minLowercase = minLowercase
        self.minUppercase = minUppercase
        self.minNumber = minNumber
        self.minSpecial = minSpecial
    }
}



extension PasswordGeneratorRequest: Equatable, Hashable {
    public static func ==(lhs: PasswordGeneratorRequest, rhs: PasswordGeneratorRequest) -> Bool {
        if lhs.lowercase != rhs.lowercase {
            return false
        }
        if lhs.uppercase != rhs.uppercase {
            return false
        }
        if lhs.numbers != rhs.numbers {
            return false
        }
        if lhs.special != rhs.special {
            return false
        }
        if lhs.length != rhs.length {
            return false
        }
        if lhs.avoidAmbiguous != rhs.avoidAmbiguous {
            return false
        }
        if lhs.minLowercase != rhs.minLowercase {
            return false
        }
        if lhs.minUppercase != rhs.minUppercase {
            return false
        }
        if lhs.minNumber != rhs.minNumber {
            return false
        }
        if lhs.minSpecial != rhs.minSpecial {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(lowercase)
        hasher.combine(uppercase)
        hasher.combine(numbers)
        hasher.combine(special)
        hasher.combine(length)
        hasher.combine(avoidAmbiguous)
        hasher.combine(minLowercase)
        hasher.combine(minUppercase)
        hasher.combine(minNumber)
        hasher.combine(minSpecial)
    }
}


public struct FfiConverterTypePasswordGeneratorRequest: FfiConverterRustBuffer {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> PasswordGeneratorRequest {
        return
            try PasswordGeneratorRequest(
                lowercase: FfiConverterBool.read(from: &buf), 
                uppercase: FfiConverterBool.read(from: &buf), 
                numbers: FfiConverterBool.read(from: &buf), 
                special: FfiConverterBool.read(from: &buf), 
                length: FfiConverterUInt8.read(from: &buf), 
                avoidAmbiguous: FfiConverterBool.read(from: &buf), 
                minLowercase: FfiConverterOptionUInt8.read(from: &buf), 
                minUppercase: FfiConverterOptionUInt8.read(from: &buf), 
                minNumber: FfiConverterOptionUInt8.read(from: &buf), 
                minSpecial: FfiConverterOptionUInt8.read(from: &buf)
        )
    }

    public static func write(_ value: PasswordGeneratorRequest, into buf: inout [UInt8]) {
        FfiConverterBool.write(value.lowercase, into: &buf)
        FfiConverterBool.write(value.uppercase, into: &buf)
        FfiConverterBool.write(value.numbers, into: &buf)
        FfiConverterBool.write(value.special, into: &buf)
        FfiConverterUInt8.write(value.length, into: &buf)
        FfiConverterBool.write(value.avoidAmbiguous, into: &buf)
        FfiConverterOptionUInt8.write(value.minLowercase, into: &buf)
        FfiConverterOptionUInt8.write(value.minUppercase, into: &buf)
        FfiConverterOptionUInt8.write(value.minNumber, into: &buf)
        FfiConverterOptionUInt8.write(value.minSpecial, into: &buf)
    }
}


public func FfiConverterTypePasswordGeneratorRequest_lift(_ buf: RustBuffer) throws -> PasswordGeneratorRequest {
    return try FfiConverterTypePasswordGeneratorRequest.lift(buf)
}

public func FfiConverterTypePasswordGeneratorRequest_lower(_ value: PasswordGeneratorRequest) -> RustBuffer {
    return FfiConverterTypePasswordGeneratorRequest.lower(value)
}

// Note that we don't yet support `indirect` for enums.
// See https://github.com/mozilla/uniffi-rs/issues/396 for further discussion.

public enum AppendType {
    
    /**
     * Generates a random string of 8 lowercase characters as part of your username
     */
    case random
    /**
     * Uses the websitename as part of your username
     */
    case websiteName(website: String
    )
}


public struct FfiConverterTypeAppendType: FfiConverterRustBuffer {
    typealias SwiftType = AppendType

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> AppendType {
        let variant: Int32 = try readInt(&buf)
        switch variant {
        
        case 1: return .random
        
        case 2: return .websiteName(website: try FfiConverterString.read(from: &buf)
        )
        
        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    public static func write(_ value: AppendType, into buf: inout [UInt8]) {
        switch value {
        
        
        case .random:
            writeInt(&buf, Int32(1))
        
        
        case let .websiteName(website):
            writeInt(&buf, Int32(2))
            FfiConverterString.write(website, into: &buf)
            
        }
    }
}


public func FfiConverterTypeAppendType_lift(_ buf: RustBuffer) throws -> AppendType {
    return try FfiConverterTypeAppendType.lift(buf)
}

public func FfiConverterTypeAppendType_lower(_ value: AppendType) -> RustBuffer {
    return FfiConverterTypeAppendType.lower(value)
}



extension AppendType: Equatable, Hashable {}



// Note that we don't yet support `indirect` for enums.
// See https://github.com/mozilla/uniffi-rs/issues/396 for further discussion.
/**
 * Configures the email forwarding service to use.
 * For instructions on how to configure each service, see the documentation:
 * <https://bitwarden.com/help/generator/#username-types>
 */

public enum ForwarderServiceType {
    
    /**
     * Previously known as "AnonAddy"
     */
    case addyIo(apiToken: String, domain: String, baseUrl: String
    )
    case duckDuckGo(token: String
    )
    case firefox(apiToken: String
    )
    case fastmail(apiToken: String
    )
    case forwardEmail(apiToken: String, domain: String
    )
    case simpleLogin(apiKey: String
    )
}


public struct FfiConverterTypeForwarderServiceType: FfiConverterRustBuffer {
    typealias SwiftType = ForwarderServiceType

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> ForwarderServiceType {
        let variant: Int32 = try readInt(&buf)
        switch variant {
        
        case 1: return .addyIo(apiToken: try FfiConverterString.read(from: &buf), domain: try FfiConverterString.read(from: &buf), baseUrl: try FfiConverterString.read(from: &buf)
        )
        
        case 2: return .duckDuckGo(token: try FfiConverterString.read(from: &buf)
        )
        
        case 3: return .firefox(apiToken: try FfiConverterString.read(from: &buf)
        )
        
        case 4: return .fastmail(apiToken: try FfiConverterString.read(from: &buf)
        )
        
        case 5: return .forwardEmail(apiToken: try FfiConverterString.read(from: &buf), domain: try FfiConverterString.read(from: &buf)
        )
        
        case 6: return .simpleLogin(apiKey: try FfiConverterString.read(from: &buf)
        )
        
        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    public static func write(_ value: ForwarderServiceType, into buf: inout [UInt8]) {
        switch value {
        
        
        case let .addyIo(apiToken,domain,baseUrl):
            writeInt(&buf, Int32(1))
            FfiConverterString.write(apiToken, into: &buf)
            FfiConverterString.write(domain, into: &buf)
            FfiConverterString.write(baseUrl, into: &buf)
            
        
        case let .duckDuckGo(token):
            writeInt(&buf, Int32(2))
            FfiConverterString.write(token, into: &buf)
            
        
        case let .firefox(apiToken):
            writeInt(&buf, Int32(3))
            FfiConverterString.write(apiToken, into: &buf)
            
        
        case let .fastmail(apiToken):
            writeInt(&buf, Int32(4))
            FfiConverterString.write(apiToken, into: &buf)
            
        
        case let .forwardEmail(apiToken,domain):
            writeInt(&buf, Int32(5))
            FfiConverterString.write(apiToken, into: &buf)
            FfiConverterString.write(domain, into: &buf)
            
        
        case let .simpleLogin(apiKey):
            writeInt(&buf, Int32(6))
            FfiConverterString.write(apiKey, into: &buf)
            
        }
    }
}


public func FfiConverterTypeForwarderServiceType_lift(_ buf: RustBuffer) throws -> ForwarderServiceType {
    return try FfiConverterTypeForwarderServiceType.lift(buf)
}

public func FfiConverterTypeForwarderServiceType_lower(_ value: ForwarderServiceType) -> RustBuffer {
    return FfiConverterTypeForwarderServiceType.lower(value)
}



extension ForwarderServiceType: Equatable, Hashable {}



// Note that we don't yet support `indirect` for enums.
// See https://github.com/mozilla/uniffi-rs/issues/396 for further discussion.

public enum UsernameGeneratorRequest {
    
    /**
     * Generates a single word username
     */
    case word(
        /**
         * Capitalize the first letter of the word
         */capitalize: Bool, 
        /**
         * Include a 4 digit number at the end of the word
         */includeNumber: Bool
    )
    /**
     * Generates an email using your provider's subaddressing capabilities.
     * Note that not all providers support this functionality.
     * This will generate an address of the format `youremail+generated@domain.tld`
     */
    case subaddress(
        /**
         * The type of subaddress to add to the base email
         */type: AppendType, 
        /**
         * The full email address to use as the base for the subaddress
         */email: String
    )
    case catchall(
        /**
         * The type of username to use with the catchall email domain
         */type: AppendType, 
        /**
         * The domain to use for the catchall email address
         */domain: String
    )
    case forwarded(
        /**
         * The email forwarding service to use, see [ForwarderServiceType]
         * for instructions on how to configure each
         */service: ForwarderServiceType, 
        /**
         * The website for which the email address is being generated
         * This is not used in all services, and is only used for display purposes
         */website: String?
    )
}


public struct FfiConverterTypeUsernameGeneratorRequest: FfiConverterRustBuffer {
    typealias SwiftType = UsernameGeneratorRequest

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> UsernameGeneratorRequest {
        let variant: Int32 = try readInt(&buf)
        switch variant {
        
        case 1: return .word(capitalize: try FfiConverterBool.read(from: &buf), includeNumber: try FfiConverterBool.read(from: &buf)
        )
        
        case 2: return .subaddress(type: try FfiConverterTypeAppendType.read(from: &buf), email: try FfiConverterString.read(from: &buf)
        )
        
        case 3: return .catchall(type: try FfiConverterTypeAppendType.read(from: &buf), domain: try FfiConverterString.read(from: &buf)
        )
        
        case 4: return .forwarded(service: try FfiConverterTypeForwarderServiceType.read(from: &buf), website: try FfiConverterOptionString.read(from: &buf)
        )
        
        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    public static func write(_ value: UsernameGeneratorRequest, into buf: inout [UInt8]) {
        switch value {
        
        
        case let .word(capitalize,includeNumber):
            writeInt(&buf, Int32(1))
            FfiConverterBool.write(capitalize, into: &buf)
            FfiConverterBool.write(includeNumber, into: &buf)
            
        
        case let .subaddress(type,email):
            writeInt(&buf, Int32(2))
            FfiConverterTypeAppendType.write(type, into: &buf)
            FfiConverterString.write(email, into: &buf)
            
        
        case let .catchall(type,domain):
            writeInt(&buf, Int32(3))
            FfiConverterTypeAppendType.write(type, into: &buf)
            FfiConverterString.write(domain, into: &buf)
            
        
        case let .forwarded(service,website):
            writeInt(&buf, Int32(4))
            FfiConverterTypeForwarderServiceType.write(service, into: &buf)
            FfiConverterOptionString.write(website, into: &buf)
            
        }
    }
}


public func FfiConverterTypeUsernameGeneratorRequest_lift(_ buf: RustBuffer) throws -> UsernameGeneratorRequest {
    return try FfiConverterTypeUsernameGeneratorRequest.lift(buf)
}

public func FfiConverterTypeUsernameGeneratorRequest_lower(_ value: UsernameGeneratorRequest) -> RustBuffer {
    return FfiConverterTypeUsernameGeneratorRequest.lower(value)
}



extension UsernameGeneratorRequest: Equatable, Hashable {}



fileprivate struct FfiConverterOptionUInt8: FfiConverterRustBuffer {
    typealias SwiftType = UInt8?

    public static func write(_ value: SwiftType, into buf: inout [UInt8]) {
        guard let value = value else {
            writeInt(&buf, Int8(0))
            return
        }
        writeInt(&buf, Int8(1))
        FfiConverterUInt8.write(value, into: &buf)
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> SwiftType {
        switch try readInt(&buf) as Int8 {
        case 0: return nil
        case 1: return try FfiConverterUInt8.read(from: &buf)
        default: throw UniffiInternalError.unexpectedOptionalTag
        }
    }
}

fileprivate struct FfiConverterOptionString: FfiConverterRustBuffer {
    typealias SwiftType = String?

    public static func write(_ value: SwiftType, into buf: inout [UInt8]) {
        guard let value = value else {
            writeInt(&buf, Int8(0))
            return
        }
        writeInt(&buf, Int8(1))
        FfiConverterString.write(value, into: &buf)
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> SwiftType {
        switch try readInt(&buf) as Int8 {
        case 0: return nil
        case 1: return try FfiConverterString.read(from: &buf)
        default: throw UniffiInternalError.unexpectedOptionalTag
        }
    }
}

private enum InitializationResult {
    case ok
    case contractVersionMismatch
    case apiChecksumMismatch
}
// Use a global variables to perform the versioning checks. Swift ensures that
// the code inside is only computed once.
private var initializationResult: InitializationResult {
    // Get the bindings contract version from our ComponentInterface
    let bindings_contract_version = 26
    // Get the scaffolding contract version by calling the into the dylib
    let scaffolding_contract_version = ffi_bitwarden_generators_uniffi_contract_version()
    if bindings_contract_version != scaffolding_contract_version {
        return InitializationResult.contractVersionMismatch
    }

    return InitializationResult.ok
}

private func uniffiEnsureInitialized() {
    switch initializationResult {
    case .ok:
        break
    case .contractVersionMismatch:
        fatalError("UniFFI contract version mismatch: try cleaning and rebuilding your project")
    case .apiChecksumMismatch:
        fatalError("UniFFI API checksum mismatch: try cleaning and rebuilding your project")
    }
}

// swiftlint:enable all