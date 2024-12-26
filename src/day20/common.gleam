import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string

pub type Position =
  #(Int, Int)

pub type MapCell {
  Track
  Wall
}

pub type Map =
  Dict(Position, MapCell)

pub type Path =
  List(Position)

pub type ParentMap =
  Dict(Position, Position)

pub type ScoreMap =
  Dict(Position, Int)

pub fn parse(input: String) -> #(Map, Position, Position) {
  input
  |> string.split("\r\n")
  |> list.index_fold(#(dict.new(), #(0, 0), #(0, 0)), fn(acc, line, y) {
    line
    |> string.split("")
    |> list.index_fold(acc, fn(acc, char, x) {
      let #(map, start_position, end_position) = acc

      let p = #(x, y)

      let start_position = case char == "S" {
        True -> p
        False -> start_position
      }
      let end_position = case char == "E" {
        True -> p
        False -> end_position
      }

      let map_item = case char == "#" {
        True -> Wall
        False -> Track
      }

      let map = map |> dict.insert(p, map_item)

      #(map, start_position, end_position)
    })
  })
}

pub fn calculate_distance(origin: Position, target: Position) -> Int {
  let #(x1, y1) = origin
  let #(x2, y2) = target

  let x_distance = int.absolute_value(x1 - x2)
  let y_distance = int.absolute_value(y1 - y2)

  x_distance + y_distance
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
