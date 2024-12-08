import gleam/int
import gleam/list
import gleam/dict
import gleam/set
import gleam/option.{None, Some}
import day08/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let map = common.parse(input)
    let frequency_names = common.frequency_names(map)

    let antinodes = frequency_names
        |> set.fold(common.create_antinode_map(map), fn(acc, frequency) {
            let antennas_positions = map
                |> dict.filter(fn(_, value) {
                    case value {
                        None -> False
                        Some(f) -> f == frequency
                    }
                })
                |> dict.keys
                |> set.from_list

            antennas_positions
                |> set.to_list
                |> list.combination_pairs
                |> list.fold(acc, fn(acc, pair) {
                    let #(left_antenna, right_antenna) = pair

                    let x_distance = int.absolute_value(left_antenna.0 - right_antenna.0)
                    let y_distance = int.absolute_value(left_antenna.1 - right_antenna.1)

                    let left_antinode_position = #(
                        case left_antenna.0 < right_antenna.0 {
                            True -> left_antenna.0 - x_distance
                            False -> left_antenna.0 + x_distance
                        },
                        case left_antenna.1 < right_antenna.1 {
                            True -> left_antenna.1 - y_distance
                            False -> left_antenna.1 + y_distance
                        }
                    )

                    let right_antinode_position = #(
                        case left_antenna.0 < right_antenna.0 {
                            True -> right_antenna.0 + x_distance
                            False -> right_antenna.0 - x_distance
                        },
                        case left_antenna.1 < right_antenna.1 {
                            True -> right_antenna.1 + y_distance
                            False -> right_antenna.1 - y_distance
                        }
                    )

                    let acc = case acc |> dict.get(left_antinode_position) {
                        Ok(_) -> {
                            acc |> dict.insert(left_antinode_position, True)
                        }
                        _ -> acc
                    }

                    let acc = case acc |> dict.get(right_antinode_position) {
                        Ok(_) -> {
                            acc |> dict.insert(right_antinode_position, True)
                        }
                        _ -> acc
                    }

                    acc
                })
        })

    case use_sample {
        True -> common.print_sample_map(antinodes)
        False -> Nil
    }

    let result = 
        antinodes
        |> dict.filter(fn(_, value) {
            value == True
        })
        |> dict.size

    common.expect(use_sample, result, 14)
}