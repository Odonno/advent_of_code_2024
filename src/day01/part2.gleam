import gleam/list
import gleam/int
import day01/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let locations = common.parse(input)

    let second_list = locations
        |> list.map(fn(x) { x.1 })
        |> list.sort(int.compare)

    let result = locations
        |> list.map(fn(x) { x.0 })
        |> list.map(fn(x) {
            let count = second_list |> list.filter(fn(y) { y == x }) |> list.length
            x * count
        })
        |> list.fold(0, fn(x, acc) { x + acc })

    common.expect(use_sample, result, 31)
}