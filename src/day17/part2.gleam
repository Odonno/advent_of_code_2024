import gleam/int
import day17/common
import simplifile

pub fn main(_: String, use_sample: Bool) -> Nil {
    let assert Ok(input) = case use_sample {
        True -> simplifile.read("src/day17/sample-2.txt")
        False -> simplifile.read("src/day17/input.txt")
    }

    let #(_registers, _program) = common.parse(input)

    let result = 0

    common.expect(use_sample, result |> int.to_string, "117440")
}