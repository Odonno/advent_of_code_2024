import day17/common
import gleam/int
import gleam/list
import gleam/string

pub fn main(input: String, use_sample: Bool) -> Nil {
  let #(registers, program) = common.parse(input)

  let out = common.execute(program, registers)

  let result =
    out
    |> list.map(fn(x) { x |> int.to_string })
    |> string.join(",")

  common.expect_str(use_sample, result, "4,6,3,5,6,3,5,2,1,0")
}
