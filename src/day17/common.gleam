import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{None, Some}
import gleam/regex
import gleam/result
import gleam/string

pub type Registers =
  Dict(String, Int)

pub type Program =
  List(Int)

pub fn parse(input: String) -> #(Registers, Program) {
  let assert [registers_str, program_str] = input |> string.split("\r\n\r\n")

  #(parse_registers(registers_str), parse_program(program_str))
}

fn parse_registers(str: String) -> Registers {
  let lines = str |> string.split("\r\n")
  let assert Ok(re) = regex.from_string("Register ([A-Z]): (\\d+)")

  lines
  |> list.fold(dict.new(), fn(acc, line) {
    let assert [match] = re |> regex.scan(line)

    let assert [name, value] = match.submatches

    let assert Some(name) = name
    let assert Some(value) = value
    let value = value |> int.parse |> result.unwrap(0)

    acc |> dict.insert(name, value)
  })
}

fn parse_program(str: String) -> Program {
  let assert Ok(re) = regex.from_string("(\\d)")
  let matches = re |> regex.scan(str)

  matches
  |> list.map(fn(match) { match.content |> int.parse |> result.unwrap(0) })
}

pub fn execute(program: Program, registers: Registers) -> Program {
  let #(_, _, out) =
    iterator.single(0)
    |> iterator.cycle
    |> iterator.fold_until(#(0, registers, []), fn(acc, _) {
      let #(instruction, registers, out) = acc

      let opcode =
        program |> list.drop(instruction) |> list.first |> result.unwrap(0)
      let operand =
        program |> list.drop(instruction + 1) |> list.first |> result.unwrap(0)

      let #(instruction_opt, registers, out) = case opcode {
        0 | 6 | 7 -> {
          let register_target = case opcode {
            0 -> "A"
            6 -> "B"
            7 -> "C"
            _ -> panic as "Unexpected opcode"
          }

          let combo_operand = get_combo_operand(operand, registers)

          let numerator = registers |> dict.get("A") |> result.unwrap(0)
          let assert Ok(denominator) =
            int.power(2, combo_operand |> int.to_float)
          let denominator = denominator |> float.truncate

          let value = numerator / denominator
          let registers = registers |> dict.insert(register_target, value)

          #(None, registers, out)
        }
        1 -> {
          let b_value = registers |> dict.get("B") |> result.unwrap(0)

          let value = int.bitwise_exclusive_or(b_value, operand)

          let registers = registers |> dict.insert("B", value)

          #(None, registers, out)
        }
        2 -> {
          let combo_operand = get_combo_operand(operand, registers)
          let value = combo_operand % 8

          let registers = registers |> dict.insert("B", value)

          #(None, registers, out)
        }
        3 -> {
          let a_value = registers |> dict.get("A") |> result.unwrap(0)

          case a_value == 0 {
            True -> #(None, registers, out)
            False -> {
              let instruction = operand
              #(Some(instruction), registers, out)
            }
          }
        }
        4 -> {
          let b_value = registers |> dict.get("B") |> result.unwrap(0)
          let c_value = registers |> dict.get("C") |> result.unwrap(0)

          let value = int.bitwise_exclusive_or(b_value, c_value)

          let registers = registers |> dict.insert("B", value)

          #(None, registers, out)
        }
        5 -> {
          let combo_operand = get_combo_operand(operand, registers)
          let value = combo_operand % 8
          let out = [value, ..out]

          #(None, registers, out)
        }
        _ -> panic as "Unexpected opcode"
      }

      let instruction = case instruction_opt {
        Some(i) -> i
        None -> instruction + 2
      }

      let acc = #(instruction, registers, out)

      case instruction >= program |> list.length {
        True -> list.Stop(acc)
        _ -> list.Continue(acc)
      }
    })

  out |> list.reverse
}

fn get_combo_operand(operand: Int, registers: Registers) -> Int {
  case operand {
    4 -> registers |> dict.get("A") |> result.unwrap(0)
    5 -> registers |> dict.get("B") |> result.unwrap(0)
    6 -> registers |> dict.get("C") |> result.unwrap(0)
    7 -> panic as "Unexpected operand 7"
    _ -> operand
  }
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
