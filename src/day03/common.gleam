import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regex
import gleam/string

pub type Instruction {
  Mul(#(Int, Int))
}

pub fn parse(input: String, always_enabled: Bool) -> List(Instruction) {
  input
  |> string.split("\n")
  |> list.fold([], fn(acc: List(#(Instruction, Bool)), line) {
    let enabled = case acc {
      [] -> True
      [first, ..] -> first.1
    }
    parse_line(line, enabled)
    |> list.append(acc)
  })
  |> list.filter(fn(x) { always_enabled || x.1 == True })
  |> list.map(fn(x) { x.0 })
}

fn parse_line(line: String, initial_enabled: Bool) -> List(#(Instruction, Bool)) {
  let assert Ok(re) =
    regex.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)|do\\(\\)|don't\\(\\)")
  let matches = re |> regex.scan(line)

  let results =
    matches
    |> list.fold(#([], initial_enabled), fn(acc, m) {
      case m.content {
        "do()" -> #(acc.0, True)
        "don't()" -> #(acc.0, False)
        _ -> {
          let assert [x, y] = m.submatches

          let assert Ok(x) = int.parse(x |> option.unwrap("0"))
          let assert Ok(y) = int.parse(y |> option.unwrap("0"))

          let instruction = Mul(#(x, y))
          let instructions = [#(instruction, acc.1), ..acc.0]

          #(instructions, acc.1)
        }
      }
    })

  results.0
}

pub fn expect(use_sample: Bool, result: Int, sample_expected: Int) -> Nil {
  case use_sample {
    True -> {
      case result == sample_expected {
        True -> {
          io.debug("Sample OK")
          Nil
        }
        False ->
          panic as {
            "Expected: "
            <> sample_expected |> int.to_string
            <> ", got "
            <> result |> int.to_string
          }
      }
    }
    False -> {
      io.debug("Result: " <> result |> int.to_string)
      Nil
    }
  }
}
