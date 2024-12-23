import gleam/result
import gleam/string
import gleam/list
import gleam/dict
import gleam/set.{type Set}
import simplifile
import day23/common

pub type Connection = List(common.ComputerName)
pub type Connections = List(Connection)

pub fn main(_: String, use_sample: Bool) -> Nil {
    let assert Ok(input) = case use_sample {
        True -> simplifile.read("src/day23/sample-2.txt")
        False -> simplifile.read("src/day23/input.txt")
    }

    let network_nodes = common.parse(input)
    let links = common.get_network_links(network_nodes)

    let current_two_connections = 
        network_nodes
        |> list.map(fn(x) { [x.0, x.1] })

    let larger_link = 
        get_unique_connection(current_two_connections, links)

    let result = 
        larger_link 
        |> list.sort(string.compare) 
        |> string.join(",")

    common.expect_str(use_sample, result, "co,de,ka,ta")
}

fn get_unique_connection(current_connections: Connections, links: common.NetworkLinks) -> Connection {
    case get_computers_with_n_connections(current_connections, links) {
        [] -> panic as "Unexpected"
        [first] -> first
        r -> get_unique_connection(r, links)
    }
}

fn get_computers_with_n_connections(current_connections: Connections, links: common.NetworkLinks) -> Connections {
    current_connections
        |> list.flat_map(fn(n) {
            let all_links = n |> list.map(fn(l) { links |> dict.get(l) |> result.unwrap(set.new()) })

            let related_computers = get_related_computers(all_links)

            related_computers
            |> set.difference(n |> set.from_list)
            |> set.to_list
            |> list.map(fn(c) {
                [c, ..n] |> list.sort(string.compare)
            })
        })
        |> set.from_list
        |> set.to_list
}

fn get_related_computers(
    all_links: List(Set(common.ComputerName))
) -> Set(common.ComputerName) {
    case all_links {
        [first] -> first
        [first, ..rest] -> {
            first |> set.intersection(get_related_computers(rest))
        }
        _ -> panic as "Unexpected"
    }
}
