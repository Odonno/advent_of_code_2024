import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/string

pub type Position =
  #(Int, Int)

pub type Frequency =
  String

pub type AntennaMap =
  Dict(Position, Option(Frequency))

pub type AntinodeMap =
  Dict(Position, Bool)

pub fn parse(input: String) -> AntennaMap {
  input
  |> string.split("\n")
  |> list.index_fold([], fn(acc, line, y) {
    line
    |> string.trim
    |> string.split("")
    |> list.index_fold(acc, fn(acc2, char, x) {
      let frequency = case char {
        "." -> None
        _ -> Some(char)
      }

      let item = #(#(x, y), frequency)
      [item, ..acc2]
    })
  })
  |> dict.from_list
}

pub fn frequency_names(map: AntennaMap) -> Set(Frequency) {
  map
  |> dict.values
  |> list.filter_map(fn(x) {
    case x {
      None -> Error(Nil)
      Some(frequency) -> Ok(frequency)
    }
  })
  |> set.from_list
}

pub fn create_antinode_map(map: AntennaMap) -> AntinodeMap {
  map
  |> dict.fold(dict.new(), fn(acc, position, _) {
    acc |> dict.insert(position, False)
  })
}

pub fn print_sample_map(antinodes: AntinodeMap) -> Nil {
  iterator.range(0, 12)
  |> iterator.each(fn(y) {
    iterator.range(0, 12)
    |> iterator.each(fn(x) {
      let str = case antinodes |> dict.get(#(x, y)) {
        Ok(True) -> "#"
        _ -> "."
      }
      io.print(str)
    })

    io.println("")
  })
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
