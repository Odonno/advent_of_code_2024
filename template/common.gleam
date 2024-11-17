import gleam/string

pub fn parse(input: String) -> List(String) {
    input |> string.split("\n")
}