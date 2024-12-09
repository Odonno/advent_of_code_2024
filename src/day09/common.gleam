import gleam/list
import gleam/io
import gleam/string
import gleam/int

pub type DiskFile {
    DiskFile(id: Int, length: Int, free_space: Int)
}

pub type DiskFiles = List(DiskFile)

pub fn parse(input: String) -> DiskFiles {
    input
        |> string.split("")
        |> list.sized_chunk(2)
        |> list.index_map(fn(x, index) {
            let #(length, free_space) = case x {
                [length] -> #(length, "0")
                [length, free_space] -> #(length, free_space)
                _ -> panic as "Failed to parse"
            }

            let assert Ok(length) = length |> int.parse
            let assert Ok(free_space) = free_space |> int.parse

            DiskFile(index, length, free_space)
        })
}

pub fn expect(use_sample: Bool, result: Int, sample_expected: Int) -> Nil {
    case use_sample {
        True -> {
            case result == sample_expected {
                True -> {
                    io.debug("Sample OK")
                    Nil
                }
                False -> 
                    panic as { "Expected: " <> sample_expected |> int.to_string <> ", got " <> result |> int.to_string }
            }
        }
        False -> {
            io.debug("Result: " <> result |> int.to_string)
            Nil
        }
    }
}