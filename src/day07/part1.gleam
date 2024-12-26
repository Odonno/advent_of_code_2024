import day07/common
import gleam/list

pub fn main(input: String, use_sample: Bool) -> Nil {
  let equations = common.parse(input)

  let result =
    equations
    |> list.filter(is_valid)
    |> list.map(fn(e) { e.0 })
    |> list.fold(0, fn(acc, x) { acc + x })

  common.expect(use_sample, result, 3749)
}

fn is_valid(equation: common.Equation) -> Bool {
  let assert [first, ..rest] = equation.1

  is_valid_inner(equation.0, first, rest)
}

fn is_valid_inner(expected: Int, value: Int, remaining: List(Int)) -> Bool {
  case remaining {
    [] -> value == expected
    [first, ..rest] -> {
      let addition_total = value + first
      let multiplication_total = value * first

      is_valid_inner(expected, addition_total, rest)
      || is_valid_inner(expected, multiplication_total, rest)
    }
  }
}
