import day18/common
import gleam/dict
import gleam/int
import gleam/iterator
import gleam/list
import gleam/option.{None}

pub fn main(input: String, use_sample: Bool) -> Nil {
  let positions = common.parse(input)

  let max_x = case use_sample {
    True -> 6
    False -> 70
  }
  let max_y = case use_sample {
    True -> 6
    False -> 70
  }

  let assert Ok(taken_bytes) =
    iterator.range(0, positions |> list.length)
    |> iterator.find(fn(bytes_to_take) {
      let map =
        common.create_memory_space(
          positions |> list.take(bytes_to_take),
          max_x,
          max_y,
        )

      let initial_position = #(0, 0)
      let target = #(max_x, max_y)

      let path =
        common.find_shortest_path(
          map,
          target,
          dict.new() |> dict.insert(initial_position, 0),
          dict.new()
            |> dict.insert(
              initial_position,
              common.calculate_distance(initial_position, target),
            ),
          dict.new(),
          [initial_position],
        )

      path == None
    })

  let assert Ok(result) = positions |> list.drop(taken_bytes - 1) |> list.first

  let result = result.0 |> int.to_string <> "," <> result.1 |> int.to_string

  common.expect_str(use_sample, result, "6,1")
}
