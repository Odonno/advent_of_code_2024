import day04/common
import gleam/dict
import gleam/int
import gleam/iterator
import gleam/list

pub fn main(input: String, use_sample: Bool) -> Nil {
  let map = common.parse(input)

  let result = search_xmas(map)

  common.expect(use_sample, result, 9)
}

fn search_xmas(map: common.XmasMap) -> Int {
  let assert Ok(max_x) =
    map
    |> dict.keys
    |> list.map(fn(p) { p.0 })
    |> list.sort(int.compare)
    |> list.last
  let assert Ok(max_y) =
    map
    |> dict.keys
    |> list.map(fn(p) { p.1 })
    |> list.sort(int.compare)
    |> list.last

  iterator.range(0, max_x)
  |> iterator.fold(0, fn(acc, x) {
    iterator.range(0, max_y)
    |> iterator.fold(acc, fn(acc2, y) {
      let has_center_a = dict.get(map, #(x, y)) == Ok("A")

      let is_search_ok =
        has_center_a
        && {
          {
            dict.get(map, #(x - 1, y - 1)) == Ok("M")
            && dict.get(map, #(x + 1, y + 1)) == Ok("S")
          }
          || {
            dict.get(map, #(x - 1, y - 1)) == Ok("S")
            && dict.get(map, #(x + 1, y + 1)) == Ok("M")
          }
        }
        && {
          {
            dict.get(map, #(x + 1, y - 1)) == Ok("M")
            && dict.get(map, #(x - 1, y + 1)) == Ok("S")
          }
          || {
            dict.get(map, #(x + 1, y - 1)) == Ok("S")
            && dict.get(map, #(x - 1, y + 1)) == Ok("M")
          }
        }

      case is_search_ok {
        True -> acc2 + 1
        _ -> acc2
      }
    })
  })
}
