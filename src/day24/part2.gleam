import day24/common
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile

pub type Swaps =
  Dict(common.Wire, common.Wire)

pub fn main(_: String, use_sample: Bool) -> Nil {
  let assert Ok(input) = case use_sample {
    True -> simplifile.read("src/day24/sample-2.txt")
    False -> simplifile.read("src/day24/input.txt")
  }

  let _swaps = case use_sample {
    True -> 2
    False -> 4
  }

  let #(wire_values, gates) = common.parse(input)

  let assert Ok(max_bit_index) =
    wire_values
    |> dict.keys
    |> list.filter(fn(k) { k |> string.starts_with("x") })
    |> list.map(fn(k) {
      k |> string.slice(1, 2) |> int.parse |> result.unwrap(0)
    })
    |> list.sort(int.compare)
    |> list.last

  let swapped_wires = generate_swaps(gates, dict.new(), max_bit_index)

  let result =
    swapped_wires |> dict.keys |> list.sort(string.compare) |> string.join(",")

  common.expect_str(use_sample, result, "z00,z01,z02,z05")
}

fn generate_swaps(
  gates: common.Gates,
  swaps: Swaps,
  max_bit_index: Int,
) -> Swaps {
  let current_output =
    get_swapped_output(gates, swaps, "x00", "y00", common.And)

  generate_swaps_inner(gates, swaps, max_bit_index, 1, current_output)
}

fn generate_swaps_inner(
  gates: common.Gates,
  swaps: Swaps,
  max_bit_index: Int,
  index: Int,
  current_output: Option(common.Wire),
) -> Swaps {
  case index > max_bit_index {
    True -> swaps
    False -> {
      let current_wire_value =
        index |> int.to_string |> string.pad_start(2, "0")

      let x_wire = "x" <> current_wire_value
      let y_wire = "y" <> current_wire_value
      let z_wire = "z" <> current_wire_value

      let assert Some(xor_output) =
        get_swapped_output(gates, swaps, x_wire, y_wire, common.Xor)
      let assert Some(and_output) =
        get_swapped_output(gates, swaps, x_wire, y_wire, common.And)

      let current_xor_output = case current_output {
        Some(current_output) ->
          get_swapped_output(
            gates,
            swaps,
            current_output,
            xor_output,
            common.Xor,
          )
        _ -> None
      }
      let current_and_output = case current_output {
        Some(current_output) ->
          get_swapped_output(
            gates,
            swaps,
            current_output,
            xor_output,
            common.And,
          )
        _ -> None
      }

      case current_xor_output, current_and_output {
        None, None -> {
          let swaps =
            swaps
            |> dict.insert(xor_output, and_output)
            |> dict.insert(and_output, xor_output)
          generate_swaps_inner(
            gates,
            swaps,
            max_bit_index,
            index,
            current_output,
          )
        }
        Some(current_xor_output), _ if current_xor_output != z_wire -> {
          let swaps =
            swaps
            |> dict.insert(current_xor_output, z_wire)
            |> dict.insert(z_wire, current_xor_output)
          generate_swaps_inner(
            gates,
            swaps,
            max_bit_index,
            index,
            current_output,
          )
        }
        _, _ -> {
          let assert Some(current_and_output) = current_and_output
          let current_output =
            get_swapped_output(
              gates,
              swaps,
              and_output,
              current_and_output,
              common.Or,
            )

          generate_swaps_inner(
            gates,
            swaps,
            max_bit_index,
            index + 1,
            current_output,
          )
        }
      }
    }
  }
}

fn get_swapped_output(
  gates: common.Gates,
  swaps: Swaps,
  wire_1: common.Wire,
  wire_2: common.Wire,
  operator: common.GateOperator,
) -> Option(common.Wire) {
  let possible_output = get_output(gates, wire_1, wire_2, operator)

  case possible_output {
    Some(output) -> {
      case swaps |> dict.get(output) {
        Ok(swapped_output) -> Some(swapped_output)
        _ -> possible_output
      }
    }
    None -> possible_output
  }
}

fn get_output(
  gates: common.Gates,
  wire_1: common.Wire,
  wire_2: common.Wire,
  operator: common.GateOperator,
) -> Option(common.Wire) {
  gates
  |> list.filter(fn(gate) {
    gate.operator == operator
    && {
      { gate.operand1 == wire_1 && gate.operand2 == wire_2 }
      || { gate.operand1 == wire_2 && gate.operand2 == wire_1 }
    }
  })
  |> list.map(fn(gate) { gate.result })
  |> list.first
  |> option.from_result
}
