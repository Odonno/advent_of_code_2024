import gleam/int
import gleam/string
import gleam/list
import day17/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let #(registers, program) = common.parse(input)

    let out = common.execute(program, registers)

    let result = 
        out 
        |> list.map(fn(x) { x |> int.to_string })
        |> string.join(",")

    common.expect_str(use_sample, result, "4,6,3,5,6,3,5,2,1,0")
}
