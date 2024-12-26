import day10/common
import gleam/dict
import gleam/list

pub fn main(input: String, use_sample: Bool) -> Nil {
  let map = common.parse(input)

  let zero_positions =
    map
    |> dict.filter(fn(_, value) { value == 0 })
    |> dict.keys()

  let result =
    zero_positions
    |> list.map(fn(p) { common.get_trailheads(map, [p], 0, False) })
    |> list.fold(0, fn(acc, v) { acc + v })

  common.expect(use_sample, result, 81)
}
