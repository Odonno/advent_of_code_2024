import gleam/option.{Some, None}
import gleam/iterator
import gleam/float
import gleam/int
import gleam/string
import gleam/result
import gleam/list
import gleam/dict
import day17/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let #(registers, program) = common.parse(input)

    let #(_, _, out) = 
        iterator.single(0)
        |> iterator.cycle
        |> iterator.fold_until(#(0, registers, []), fn(acc, _) {
            let #(instruction, registers, out) = acc

            let opcode = program |> list.drop(instruction) |> list.first |> result.unwrap(0)
            let operand = program |> list.drop(instruction + 1) |> list.first |> result.unwrap(0)

            let #(instruction_opt, registers, out) = case opcode {
                0 | 6 | 7 -> {
                    let register_target = case opcode {
                        0 -> "A"
                        6 -> "B"
                        7 -> "C"
                        _ -> panic as "Unexpected opcode"
                    }

                    let combo_operand = get_combo_operand(operand, registers)

                    let numerator = registers |> dict.get("A") |> result.unwrap(0)
                    let assert Ok(denominator) = int.power(2, combo_operand |> int.to_float)
                    let denominator = denominator |> float.truncate

                    let value = numerator / denominator 

                    let registers = registers |> dict.insert(register_target, value)

                    #(None, registers, out)
                }
                1 -> {
                    let b_value = registers |> dict.get("B") |> result.unwrap(0)

                    let value = int.bitwise_exclusive_or(b_value, operand)

                    let registers = registers |> dict.insert("B", value)

                    #(None, registers, out)
                }
                2 -> {
                    let combo_operand = get_combo_operand(operand, registers)
                    let value = combo_operand % 8

                    let registers = registers |> dict.insert("B", value)

                    #(None, registers, out)
                }
                3 -> {
                    let a_value = registers |> dict.get("A") |> result.unwrap(0)

                    case a_value == 0 {
                        True -> #(None, registers, out)
                        False -> {
                            let instruction = operand
                            #(Some(instruction), registers, out)
                        } 
                    }
                }
                4 -> {
                    let b_value = registers |> dict.get("B") |> result.unwrap(0)
                    let c_value = registers |> dict.get("C") |> result.unwrap(0)

                    let value = int.bitwise_exclusive_or(b_value, c_value)

                    let registers = registers |> dict.insert("B", value)

                    #(None, registers, out)
                }
                5 -> {
                    let combo_operand = get_combo_operand(operand, registers)
                    let value = combo_operand % 8
                    let out = [value, ..out]

                    #(None, registers, out)
                }
                _ -> panic as "Unexpected opcode"
            }

            let instruction = case instruction_opt {
                Some(i) -> i
                None -> instruction + 2
            }

            let acc = #(instruction, registers, out)

            case instruction >= program |> list.length {
                True -> list.Stop(acc)
                _ -> list.Continue(acc)
            }
        })

    let out = out |> list.reverse

    let result = 
        out 
        |> list.map(fn(x) { x |> int.to_string })
        |> string.join(",")

    common.expect(use_sample, result, "4,6,3,5,6,3,5,2,1,0")
}

fn get_combo_operand(operand: Int, registers: common.Registers) -> Int {
    case operand {
        4 -> registers |> dict.get("A") |> result.unwrap(0)
        5 -> registers |> dict.get("B") |> result.unwrap(0)
        6 -> registers |> dict.get("C") |> result.unwrap(0)
        7 -> panic as "Unexpected operand 7"
        _ -> operand
    }
}