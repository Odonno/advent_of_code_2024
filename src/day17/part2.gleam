import day17/common
import gleam/dict
import gleam/float
import gleam/int
import gleam/iterator
import gleam/list
import gleam/result
import simplifile

pub fn main(_: String, use_sample: Bool) -> Nil {
  let assert Ok(input) = case use_sample {
    True -> simplifile.read("src/day17/sample-2.txt")
    False -> simplifile.read("src/day17/input.txt")
  }

  let #(_, program) = common.parse(input)

  let length = program |> list.length

  let #(a_value, _) =
    iterator.single(0)
    |> iterator.cycle
    |> iterator.fold_until(#(0, length - 1), fn(acc, _) {
      let #(a_value, index) = acc
      let registers =
        dict.new()
        |> dict.insert("A", a_value)
        |> dict.insert("B", 0)
        |> dict.insert("C", 0)
      let output = common.execute(program, registers)

      let to_compare = length - index

      let is_correct =
        program |> list.reverse |> list.take(to_compare)
        == output |> list.reverse |> list.take(to_compare)
      case is_correct {
        True -> {
          case index == 0 {
            True -> list.Stop(#(a_value, index))
            False -> list.Continue(#(a_value, index - 1))
          }
        }
        False -> {
          let adder =
            int.power(8, index |> int.to_float)
            |> result.unwrap(0.0)
            |> float.truncate
          list.Continue(#(a_value + adder, index))
        }
      }
    })

  let result = a_value

  common.expect(use_sample, result, 117_440)
}
