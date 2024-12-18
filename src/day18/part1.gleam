import gleam/dict
import gleam/list
import gleam/option.{Some}
import day18/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let positions = common.parse(input)

    let bytes_to_take = case use_sample {
        True -> 12
        False -> 1024
    }

    let max_x = case use_sample {
        True -> 6
        False -> 70
    }
    let max_y = case use_sample {
        True -> 6
        False -> 70
    }

    let map = common.create_memory_space(positions |> list.take(bytes_to_take), max_x, max_y)

    let initial_position = #(0, 0)
    let target = #(max_x, max_y)

    let assert Some(shortest_path) = common.find_shortest_path(
        map,
        target,
        dict.new() |> dict.insert(initial_position, 0),
        dict.new() |> dict.insert(initial_position, common.calculate_distance(initial_position, target)),
        dict.new(),
        [initial_position]
    )

    let result = { shortest_path |> list.length } - 1

    common.expect(use_sample, result, 22)
}
