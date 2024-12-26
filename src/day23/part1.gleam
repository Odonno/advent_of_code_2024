import day23/common
import gleam/dict
import gleam/list
import gleam/set
import gleam/string

pub fn main(input: String, use_sample: Bool) -> Nil {
  let network_nodes = common.parse(input)
  let links = common.get_network_links(network_nodes)

  let computers_with_three_connections =
    network_nodes
    |> list.flat_map(fn(n) {
      let #(a, b) = n

      let assert Ok(left_links) = links |> dict.get(a)
      let assert Ok(right_links) = links |> dict.get(b)

      let third_computers = left_links |> set.intersection(right_links)

      third_computers
      |> set.to_list
      |> list.map(fn(c) { [a, b, c] |> list.sort(string.compare) })
    })
    |> set.from_list

  let result =
    computers_with_three_connections
    |> set.filter(fn(c) {
      c |> list.any(fn(c) { c |> string.starts_with("t") })
    })
    |> set.size

  common.expect(use_sample, result, 7)
}
