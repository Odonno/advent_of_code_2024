import day25/common
import gleam/list

pub fn main(input: String, use_sample: Bool) -> Nil {
  let schematics = common.parse(input)

  let limit = 5

  let keys = schematics |> list.filter(fn(s) { s.t == common.Key })
  let locks = schematics |> list.filter(fn(s) { s.t == common.Lock })

  let result =
    keys
    |> list.flat_map(fn(k) {
      locks
      |> list.filter(fn(l) {
        k.heights
        |> list.zip(l.heights)
        |> list.map(fn(h) { h.0 + h.1 })
        |> list.all(fn(d) { d <= limit })
      })
    })
    |> list.length

  common.expect(use_sample, result, 3)
}
