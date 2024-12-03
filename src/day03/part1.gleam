import simplifile
import gleam/list
import day03/common

pub fn main(_: String, use_sample: Bool) -> Nil {
    let assert Ok(input) = simplifile.read("src/day03/sample-1.txt")
    let instructions = common.parse(input, True)
    
    let result = instructions |> list.fold(0, fn(acc, i) { 
        let x = case i {
            common.Mul(#(x, y)) -> x * y
        }

        acc + x
    })

    common.expect(use_sample, result, 161)
}