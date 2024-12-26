import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub type Location =
  #(Int, Int)

pub type Locations =
  List(Location)

pub fn parse(input: String) -> Locations {
  input
  |> string.split("\n")
  |> list.map(parse_line)
}

fn parse_line(line: String) -> Location {
  let int_array =
    line
    |> string.trim
    |> string.split(" ")
    |> list.filter(fn(x) { x != "" })
    |> list.map(int.parse)

  let assert [Ok(x), Ok(y)] = int_array

  #(x, y)
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
