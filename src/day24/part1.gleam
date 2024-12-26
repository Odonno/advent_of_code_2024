import day24/common
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn main(input: String, use_sample: Bool) -> Nil {
  let #(wire_values, gates) = common.parse(input)
  let gates = regorder_gates(gates)

  let wire_values = apply_gates(wire_values, gates)

  let result = get_value(wire_values, "z")

  common.expect(use_sample, result, 2024)
}

fn regorder_gates(gates: common.Gates) -> common.Gates {
  let #(new_gates, has_changed) =
    gates
    |> list.fold(#([], False), fn(acc, gate) {
      let #(new_gates, has_changed) = acc

      let first_use =
        new_gates
        |> list.index_fold(-1, fn(acc, item: common.Gate, index) {
          case acc == -1 {
            False -> acc
            True -> {
              case
                item.operand1 == gate.result || item.operand2 == gate.result
              {
                True -> index
                False -> acc
              }
            }
          }
        })

      let new_gates = case first_use {
        -1 -> new_gates |> list.append([gate])
        _ -> {
          let #(left, right) = new_gates |> list.split(first_use)
          left |> list.append([gate]) |> list.append(right)
        }
      }

      let has_changed = has_changed || first_use != -1

      #(new_gates, has_changed)
    })

  case has_changed {
    True -> regorder_gates(new_gates)
    False -> new_gates
  }
}

fn apply_gates(
  wire_values: common.WireValues,
  gates: common.Gates,
) -> common.WireValues {
  gates
  |> list.fold(wire_values, fn(acc, gate) {
    let left = acc |> dict.get(gate.operand1) |> result.unwrap(False)
    let right = acc |> dict.get(gate.operand2) |> result.unwrap(False)

    let result = case gate.operator {
      common.And -> left == True && right == True
      common.Or -> left == True || right == True
      common.Xor -> left != right
    }

    acc |> dict.insert(gate.result, result)
  })
}

fn get_value(wire_values: common.WireValues, dimension: String) -> Int {
  let base2_value =
    wire_values
    |> dict.filter(fn(key, _) { key |> string.starts_with(dimension) })
    |> dict.to_list
    |> list.sort(fn(a, b) { string.compare(a.0, b.0) })
    |> list.reverse
    |> list.map(fn(x) {
      case x.1 {
        True -> "1"
        False -> "0"
      }
    })
    |> string.join("")

  let assert Ok(result) = int.base_parse(base2_value, 2)

  result
}
