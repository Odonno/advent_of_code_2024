import day11/common
import gleam/iterator
import gleam/list

pub fn main(input: String, use_sample: Bool) -> Nil {
  let stones = common.parse(input)

  let stones =
    iterator.range(0, 24)
    |> iterator.fold(stones, fn(acc, _) {
      acc
      |> list.flat_map(common.blink_stone)
    })

  let result = stones |> list.length

  common.expect(use_sample, result, 55_312)
}
