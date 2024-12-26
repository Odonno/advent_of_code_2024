import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub type Position =
  #(Int, Int)

pub type Plant =
  String

pub type GardenMap =
  Dict(Position, Plant)

pub type Region {
  Region(area: Int, perimeter: Int)
}

pub fn parse(input: String) -> GardenMap {
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

pub fn extract_region_positions(
  current_area: Set(Position),
  plant: Plant,
  map: GardenMap,
) -> Set(Position) {
  let next_area =
    current_area
    |> set.to_list
    |> list.flat_map(fn(position) {
      [
        #(position.0 - 1, position.1),
        #(position.0 + 1, position.1),
        #(position.0, position.1 - 1),
        #(position.0, position.1 + 1),
      ]
    })
    |> set.from_list
    |> set.filter(fn(position) { map |> dict.get(position) == Ok(plant) })

  let next_area = next_area |> set.union(current_area)

  let current_area_size = current_area |> set.size
  let next_area_size = next_area |> set.size

  case current_area_size == next_area_size {
    True -> current_area
    False -> extract_region_positions(next_area, plant, map)
  }
}

pub fn calculate_result(regions: List(Region)) -> Int {
  regions
  |> list.fold(0, fn(acc, region) { acc + { region.area * region.perimeter } })
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
