import day22/common
import gleam/iterator
import gleam/list

pub fn main(input: String, use_sample: Bool) -> Nil {
  let values = common.parse(input)

  let iterations = 2000

  let result =
    values
    |> list.map(fn(value) {
      iterator.range(1, iterations)
      |> iterator.fold(value, fn(acc, _) { common.iterate(acc) })
    })
    |> list.fold(0, fn(acc, v) { acc + v })

  common.expect(use_sample, result, 37_327_623)
}
