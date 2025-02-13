import Core

/// Creates a record of the specified type, consuming `operands` to initialize its members.
public struct RecordInstruction: Instruction {

  /// The type of the created record.
  public let objectType: LoweredType

  /// The operands consumed to initialize the record members.
  public private(set) var operands: [Operand]

  /// The site of the code corresponding to that instruction.
  public let site: SourceRange

  /// Creates an instance with the given properties.
  fileprivate init(objectType: LoweredType, operands: [Operand], site: SourceRange) {
    self.objectType = objectType
    self.operands = operands
    self.site = site
  }

  public var types: [LoweredType] { [objectType] }

  public mutating func replaceOperand(at i: Int, with new: Operand) {
    operands[i] = new
  }

}

extension RecordInstruction: CustomStringConvertible {

  public var description: String {
    "record \(objectType) \(list: operands)"
  }

}

extension Module {

  /// Creates a `record` anchored at `site` that creates a record of type `recordType` by
  /// aggregating its `parts`.
  ///
  /// - Parameters:
  ///   - type: The type of the produced record. Must have a record layout.
  ///   - parts: A collection of parts. Must have object types.
  func makeRecord<T: TypeProtocol>(
    _ recordType: T,
    aggregating parts: [Operand],
    at site: SourceRange
  ) -> RecordInstruction {
    let t = AbstractTypeLayout(of: recordType, definedIn: program)

    precondition(t.properties.count == parts.count)
    for (p, q) in zip(t.properties, parts) {
      let u = type(of: q)
      precondition(u.isObject && program.relations.areEquivalent(p.type, type(of: q).ast))
    }

    return .init(objectType: .object(recordType), operands: parts, site: site)
  }

}
