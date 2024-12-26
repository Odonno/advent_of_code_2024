import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub type Position =
  #(Int, Int)

pub type XmasMap =
  Dict(Position, String)

pub fn parse(input: String) -> XmasMap {
  input
  |> string.split("\n")
  |> list.index_fold([], fn(acc, line, y) {
    line
    |> string.trim
    |> string.split("")
    |> list.index_fold(acc, fn(acc2, char, x) {
      let item = #(#(x, y), char)
      [item, ..acc2]
    })
  })
  |> dict.from_list
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
