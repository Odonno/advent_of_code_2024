import day08/common
import gleam/dict
import gleam/int
import gleam/iterator
import gleam/list
import gleam/option.{None, Some}
import gleam/set

pub fn main(input: String, use_sample: Bool) -> Nil {
  let map = common.parse(input)
  let frequency_names = common.frequency_names(map)

  let antinodes =
    frequency_names
    |> set.fold(common.create_antinode_map(map), fn(acc, frequency) {
      let antennas_positions =
        map
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

        let left_diff = #(
          case left_antenna.0 < right_antenna.0 {
            True -> -x_distance
            False -> x_distance
          },
          case left_antenna.1 < right_antenna.1 {
            True -> -y_distance
            False -> y_distance
          },
        )

        let right_diff = #(
          case left_antenna.0 < right_antenna.0 {
            True -> x_distance
            False -> -x_distance
          },
          case left_antenna.1 < right_antenna.1 {
            True -> y_distance
            False -> -y_distance
          },
        )

        let left_antinodes =
          iterator.iterate(left_antenna, fn(position) {
            #(position.0 + left_diff.0, position.1 + left_diff.1)
          })
          |> iterator.take_while(fn(position) {
            acc |> dict.get(position) != Error(Nil)
          })

        let right_antinodes =
          iterator.iterate(right_antenna, fn(position) {
            #(position.0 + right_diff.0, position.1 + right_diff.1)
          })
          |> iterator.take_while(fn(position) {
            acc |> dict.get(position) != Error(Nil)
          })

        let antinodes =
          left_antinodes
          |> iterator.append(right_antinodes)

        antinodes
        |> iterator.fold(acc, fn(acc, position) {
          acc |> dict.insert(position, True)
        })
      })
    })

  case use_sample {
    True -> common.print_sample_map(antinodes)
    False -> Nil
  }

  let result =
    antinodes
    |> dict.filter(fn(_, value) { value == True })
    |> dict.size

  common.expect(use_sample, result, 34)
}
