import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string

pub type ComputerName =
  String

pub type NetworkNode =
  #(ComputerName, ComputerName)

pub type NetworkNodes =
  List(NetworkNode)

pub type NetworkLinks =
  Dict(ComputerName, Set(ComputerName))

pub fn parse(input: String) -> NetworkNodes {
  input
  |> string.split("\r\n")
  |> list.map(parse_line)
}

pub fn parse_line(line: String) -> NetworkNode {
  let assert [a, b] = line |> string.split("-")
  #(a, b)
}

pub fn get_network_links(nodes: NetworkNodes) -> NetworkLinks {
  nodes
  |> list.fold(dict.new(), fn(acc, node) {
    let #(a, b) = node

    acc
    |> dict.upsert(a, fn(x) {
      case x {
        Some(s) -> s |> set.insert(b)
        None -> set.from_list([b])
      }
    })
    |> dict.upsert(b, fn(x) {
      case x {
        Some(s) -> s |> set.insert(a)
        None -> set.from_list([a])
      }
    })
  })
}

pub fn expect(use_sample: Bool, result: Int, sample_expected: Int) -> Nil {
  expect_str(
    use_sample,
    result |> int.to_string,
    sample_expected |> int.to_string,
  )
}

pub fn expect_str(
  use_sample: Bool,
  result: String,
  sample_expected: String,
) -> Nil {
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
