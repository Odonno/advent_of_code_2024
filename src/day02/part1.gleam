import gleam/list
import day02/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let reports = common.parse(input)

    let result = reports |> list.filter(common.is_safe_report) |> list.length

    common.expect(use_sample, result, 2)
}