import gleam/result
import gleam/list
import gleam/regex
import gleam/io
import gleam/string
import gleam/int
import gleam/dict.{type Dict}
import gleam/option.{Some}

pub type Registers = Dict(String, Int)

pub type Program = List(Int)

pub fn parse(input: String) -> #(Registers, Program) {
    let assert [registers_str, program_str] = input |> string.split("\r\n\r\n")

    #(parse_registers(registers_str), parse_program(program_str))
}

fn parse_registers(str: String) -> Registers {
    let lines = str |> string.split("\r\n")
    let assert Ok(re) = regex.from_string("Register ([A-Z]): (\\d+)")

    lines
    |> list.fold(dict.new(), fn(acc, line) {
        let assert [match] = re |> regex.scan(line)

        let assert [name, value] = match.submatches

        let assert Some(name) = name
        let assert Some(value) = value 

        let value = value |> int.parse |> result.unwrap(0)

        acc |> dict.insert(name, value)
    })
}

fn parse_program(str: String) -> Program {
    let assert Ok(re) = regex.from_string("(\\d)")
    let matches = re |> regex.scan(str)

    matches
        |> list.map(fn(match) {
            match.content |> int.parse |> result.unwrap(0)
        })
}

pub fn expect(use_sample: Bool, result: String, sample_expected: String) -> Nil {
    case use_sample {
        True -> {
            case result == sample_expected {
                True -> {
                    io.debug("Sample OK")
                    Nil
                }
                False -> 
                    panic as { "Expected: " <> sample_expected <> ", got " <> result }
            }
        }
        False -> {
            io.debug("Result: " <> result)
            Nil
        }
    }
}