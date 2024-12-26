import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regex
import gleam/string

pub type Wire =
  String

pub type WireValues =
  Dict(Wire, Bool)

pub type GateOperator {
  And
  Or
  Xor
}

pub type Gate {
  Gate(operand1: Wire, operator: GateOperator, operand2: Wire, result: Wire)
}

pub type Gates =
  List(Gate)

pub fn parse(input: String) -> #(WireValues, Gates) {
  let assert [wires_str, gates_str] = input |> string.split("\r\n\r\n")

  let wire_values =
    wires_str
    |> string.split("\r\n")
    |> list.map(parse_wire_value)
    |> dict.from_list

  let gates =
    gates_str
    |> string.split("\r\n")
    |> list.map(parse_gate)

  #(wire_values, gates)
}

fn parse_wire_value(line: String) -> #(Wire, Bool) {
  let assert [name, value] = line |> string.split(":")
  let value = value |> string.trim == "1"

  #(name, value)
}

fn parse_gate(line: String) -> Gate {
  let assert Ok(re) = regex.from_string("(\\w+) (AND|XOR|OR) (\\w+) -> (\\w+)")
  let assert [match] = re |> regex.scan(line)

  let assert [operand1, operator, operand2, result] = match.submatches

  let assert Some(operand1) = operand1
  let assert Some(operand2) = operand2
  let assert Some(result) = result

  let operator = case operator {
    Some("AND") -> And
    Some("OR") -> Or
    Some("XOR") -> Xor
    _ -> panic as "An operator is required"
  }

  Gate(operand1, operator, operand2, result)
}

pub fn expect(use_sample: Bool, result: Int, sample_expected: Int) -> Nil {
  expect_str(
    use_sample,
    result |> int.to_string,
    sample_expected |> int.to_string,
  )
}

pub fn expect_str(
  use_sample: Bool,
  result: String,
  sample_expected: String,
) -> Nil {
  case use_sample {
    True -> {
      case result == sample_expected {
        True -> {
          io.debug("Sample OK")
          Nil
        }
        False ->
          panic as { "Expected: " <> sample_expected <> ", got " <> result }
      }
    }
    False -> {
      io.debug("Result: " <> result)
      Nil
    }
  }
}
