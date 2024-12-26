import day12/common
import gleam/dict
import gleam/int
import gleam/iterator
import gleam/list
import gleam/set.{type Set}

pub fn main(input: String, use_sample: Bool) -> Nil {
  let map = common.parse(input)

  let regions = extract_regions(map)
  let result = common.calculate_result(regions)

  common.expect(use_sample, result, 1206)
}

fn extract_regions(map: common.GardenMap) -> List(common.Region) {
  let remaining_positions = map |> dict.keys |> set.from_list
  extract_regions_inner(map, remaining_positions)
}

fn extract_regions_inner(
  map: common.GardenMap,
  remaining_positions: Set(common.Position),
) -> List(common.Region) {
  let assert Ok(random_position) =
    remaining_positions |> set.to_list |> list.first

  let assert Ok(plant) = map |> dict.get(random_position)
  let region_positions =
    common.extract_region_positions(
      [random_position] |> set.from_list,
      plant,
      map,
    )

  let perimeter = calculate_perimeter(plant, region_positions, map)

  let region =
    common.Region(area: region_positions |> set.size, perimeter: perimeter)

  let remaining_positions =
    remaining_positions
    |> set.difference(region_positions)

  case remaining_positions |> set.size {
    0 -> [region]
    _ -> [region, ..extract_regions_inner(map, remaining_positions)]
  }
}

fn calculate_perimeter(
  plant: common.Plant,
  region_positions: Set(common.Position),
  map: common.GardenMap,
) -> Int {
  let min_x = 0
  let assert Ok(max_x) =
    region_positions
    |> set.map(fn(position) { position.0 })
    |> set.to_list
    |> list.sort(int.compare)
    |> list.last

  let min_y = 0
  let assert Ok(max_y) =
    region_positions
    |> set.map(fn(position) { position.1 })
    |> set.to_list
    |> list.sort(int.compare)
    |> list.last

  let lines_0 =
    iterator.range(min_y, max_y)
    |> iterator.fold(#(0, [] |> set.from_list), fn(acc, y) {
      let #(total, previous_row) = acc

      let current_row =
        iterator.range(min_x, max_x)
        |> iterator.filter(fn(x) { region_positions |> set.contains(#(x, y)) })
        |> iterator.filter(fn(x) {
          let previous_plant = map |> dict.get(#(x - 1, y))
          previous_plant != Ok(plant)
        })
        |> iterator.to_list
        |> set.from_list

      let new_lines = current_row |> set.difference(previous_row)

      let total = total + { new_lines |> set.size }

      #(total, current_row)
    })
  let lines_0 = lines_0.0

  let lines_1 =
    iterator.range(min_y, max_y)
    |> iterator.fold(#(0, [] |> set.from_list), fn(acc, y) {
      let #(total, previous_row) = acc

      let current_row =
        iterator.range(min_x, max_x)
        |> iterator.filter(fn(x) { region_positions |> set.contains(#(x, y)) })
        |> iterator.filter(fn(x) {
          let next_plant = map |> dict.get(#(x + 1, y))
          next_plant != Ok(plant)
        })
        |> iterator.to_list
        |> set.from_list

      let new_lines = current_row |> set.difference(previous_row)

      let total = total + { new_lines |> set.size }

      #(total, current_row)
    })
  let lines_1 = lines_1.0

  let lines_2 =
    iterator.range(min_x, max_x)
    |> iterator.fold(#(0, [] |> set.from_list), fn(acc, x) {
      let #(total, previous_row) = acc

      let current_row =
        iterator.range(min_y, max_y)
        |> iterator.filter(fn(y) { region_positions |> set.contains(#(x, y)) })
        |> iterator.filter(fn(y) {
          let previous_plant = map |> dict.get(#(x, y - 1))
          previous_plant != Ok(plant)
        })
        |> iterator.to_list
        |> set.from_list

      let new_lines = current_row |> set.difference(previous_row)

      let total = total + { new_lines |> set.size }

      #(total, current_row)
    })
  let lines_2 = lines_2.0

  let lines_3 =
    iterator.range(min_x, max_x)
    |> iterator.fold(#(0, [] |> set.from_list), fn(acc, x) {
      let #(total, previous_row) = acc

      let current_row =
        iterator.range(min_y, max_y)
        |> iterator.filter(fn(y) { region_positions |> set.contains(#(x, y)) })
        |> iterator.filter(fn(y) {
          let next_plant = map |> dict.get(#(x, y + 1))
          next_plant != Ok(plant)
        })
        |> iterator.to_list
        |> set.from_list

      let new_lines = current_row |> set.difference(previous_row)

      let total = total + { new_lines |> set.size }

      #(total, current_row)
    })
  let lines_3 = lines_3.0

  lines_0 + lines_1 + lines_2 + lines_3
}
