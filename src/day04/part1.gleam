import day04/common
import gleam/iterator
import gleam/list
import gleam/int
import gleam/dict

pub fn main(input: String, use_sample: Bool) -> Nil {
    let map = common.parse(input)
    
    let result = search_vertical(map) + search_horizontal(map) + search_diagonal(map)

    common.expect(use_sample, result, 18)
}

fn search_vertical(map: common.XmasMap) -> Int {
    let assert Ok(max_x) = map |> dict.keys |> list.map(fn(p) { p.0 }) |> list.sort(int.compare) |> list.last
    let assert Ok(max_y) = map |> dict.keys |> list.map(fn(p) { p.1 }) |> list.sort(int.compare) |> list.last

    iterator.range(0, max_x)
        |> iterator.fold(0, fn(acc, x) {
                iterator.range(0, max_y)
                    |> iterator.fold(acc, fn(acc2, y) {
                        let is_search_ok = 
                            dict.get(map, #(x, y)) == Ok("X") && 
                            dict.get(map, #(x, y + 1)) == Ok("M") && 
                            dict.get(map, #(x, y + 2)) == Ok("A") && 
                            dict.get(map, #(x, y + 3)) == Ok("S")
                        
                        let is_backward_search_ok = 
                            dict.get(map, #(x, y)) == Ok("S") && 
                            dict.get(map, #(x, y + 1)) == Ok("A") && 
                            dict.get(map, #(x, y + 2)) == Ok("M") && 
                            dict.get(map, #(x, y + 3)) == Ok("X")

                        case is_search_ok, is_backward_search_ok {
                            True, True -> acc2 + 2
                            True, _ -> acc2 + 1
                            _, True -> acc2 + 1
                            _, _ -> acc2
                        }
                    })
            })
}

fn search_horizontal(map: common.XmasMap) -> Int {
    let assert Ok(max_x) = map |> dict.keys |> list.map(fn(p) { p.0 }) |> list.sort(int.compare) |> list.last
    let assert Ok(max_y) = map |> dict.keys |> list.map(fn(p) { p.1 }) |> list.sort(int.compare) |> list.last

    iterator.range(0, max_x)
        |> iterator.fold(0, fn(acc, x) {
                iterator.range(0, max_y)
                    |> iterator.fold(acc, fn(acc2, y) {
                        let is_search_ok = 
                            dict.get(map, #(x, y)) == Ok("X") && 
                            dict.get(map, #(x + 1, y)) == Ok("M") && 
                            dict.get(map, #(x + 2, y)) == Ok("A") && 
                            dict.get(map, #(x + 3, y)) == Ok("S")
                        
                        let is_backward_search_ok = 
                            dict.get(map, #(x, y)) == Ok("S") && 
                            dict.get(map, #(x + 1, y)) == Ok("A") && 
                            dict.get(map, #(x + 2, y)) == Ok("M") && 
                            dict.get(map, #(x + 3, y)) == Ok("X")

                        case is_search_ok, is_backward_search_ok {
                            True, True -> acc2 + 2
                            True, _ -> acc2 + 1
                            _, True -> acc2 + 1
                            _, _ -> acc2
                        }
                    })
            })
}

fn search_diagonal(map: common.XmasMap) -> Int {
    search_diagonal_left(map) + search_diagonal_right(map)
}

fn search_diagonal_left(map: common.XmasMap) -> Int {
    let assert Ok(max_x) = map |> dict.keys |> list.map(fn(p) { p.0 }) |> list.sort(int.compare) |> list.last
    let assert Ok(max_y) = map |> dict.keys |> list.map(fn(p) { p.1 }) |> list.sort(int.compare) |> list.last

    iterator.range(0, max_x)
        |> iterator.fold(0, fn(acc, x) {
                iterator.range(0, max_y)
                    |> iterator.fold(acc, fn(acc2, y) {
                        let is_search_ok = 
                            dict.get(map, #(x, y)) == Ok("X") && 
                            dict.get(map, #(x + 1, y + 1)) == Ok("M") && 
                            dict.get(map, #(x + 2, y + 2)) == Ok("A") && 
                            dict.get(map, #(x + 3, y + 3)) == Ok("S")
                        
                        let is_backward_search_ok = 
                            dict.get(map, #(x, y)) == Ok("S") && 
                            dict.get(map, #(x + 1, y + 1)) == Ok("A") && 
                            dict.get(map, #(x + 2, y + 2)) == Ok("M") && 
                            dict.get(map, #(x + 3, y + 3)) == Ok("X")

                        case is_search_ok, is_backward_search_ok {
                            True, True -> acc2 + 2
                            True, _ -> acc2 + 1
                            _, True -> acc2 + 1
                            _, _ -> acc2
                        }
                    })
            })
}

fn search_diagonal_right(map: common.XmasMap) -> Int {
    let assert Ok(max_x) = map |> dict.keys |> list.map(fn(p) { p.0 }) |> list.sort(int.compare) |> list.last
    let assert Ok(max_y) = map |> dict.keys |> list.map(fn(p) { p.1 }) |> list.sort(int.compare) |> list.last

    iterator.range(0, max_x)
        |> iterator.fold(0, fn(acc, x) {
                iterator.range(0, max_y)
                    |> iterator.fold(acc, fn(acc2, y) {
                        let is_search_ok = 
                            dict.get(map, #(x, y)) == Ok("X") && 
                            dict.get(map, #(x + 1, y - 1)) == Ok("M") && 
                            dict.get(map, #(x + 2, y - 2)) == Ok("A") && 
                            dict.get(map, #(x + 3, y - 3)) == Ok("S")
                        
                        let is_backward_search_ok = 
                            dict.get(map, #(x, y)) == Ok("S") && 
                            dict.get(map, #(x + 1, y - 1)) == Ok("A") && 
                            dict.get(map, #(x + 2, y - 2)) == Ok("M") && 
                            dict.get(map, #(x + 3, y - 3)) == Ok("X")

                        case is_search_ok, is_backward_search_ok {
                            True, True -> acc2 + 2
                            True, _ -> acc2 + 1
                            _, True -> acc2 + 1
                            _, _ -> acc2
                        }
                    })
            })
}