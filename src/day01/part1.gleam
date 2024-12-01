import gleam/list
import gleam/int
import day01/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let locations = common.parse(input)

    let first_list = locations
        |> list.map(fn(x) { x.0 })
        |> list.sort(int.compare)

    let second_list = locations
        |> list.map(fn(x) { x.1 })
        |> list.sort(int.compare)
    
    let result = list.zip(first_list, second_list)
        |> list.map(fn(x) { int.absolute_value(x.0 - x.1) })
        |> list.fold(0, fn(x, acc) { x + acc })

    common.expect(use_sample, result, 11)
}