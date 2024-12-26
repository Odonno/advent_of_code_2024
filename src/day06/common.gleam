import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub type Position =
  #(Int, Int)

pub type Direction {
  North
  East
  South
  West
}

pub type MapCellType {
  Empty
  Obstruction
}

pub type GuardMap =
  Dict(Position, MapCellType)

pub type VisitedGuardPositionMap =
  Dict(Position, Bool)

pub type Guard =
  #(Position, Direction)

pub type VisitedGuardMap =
  Dict(Guard, Bool)

pub fn parse(input: String) -> #(GuardMap, Guard) {
  let map =
    input
    |> string.split("\n")
    |> list.index_fold([], fn(acc, line, y) {
      line
      |> string.trim
      |> string.split("")
      |> list.index_fold(acc, fn(acc2, char, x) {
        let cell_type = case char {
          "#" -> Obstruction
          _ -> Empty
        }

        let item = #(#(x, y), cell_type)
        [item, ..acc2]
      })
    })
    |> dict.from_list

  let position =
    input
    |> string.split("\n")
    |> list.index_fold(#(0, 0), fn(acc, line, y) {
      line
      |> string.trim
      |> string.split("")
      |> list.index_fold(acc, fn(acc2, char, x) {
        case char {
          "^" -> #(x, y)
          _ -> acc2
        }
      })
    })
  let direction = North

  #(map, #(position, direction))
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
