import gleam/result
import gleam/list
import gleam/io
import gleam/string
import gleam/int
import gleam/dict.{type Dict}
import gleam/option.{None, Some}

pub type PageRule = #(Int, Int)
pub type PageRules = Dict(Int, List(Int))

pub type PageUpdate = List(Int)
pub type PageUpdates = List(PageUpdate)

pub fn parse(input: String) -> #(PageRules, PageUpdates) {
    input 
        |> string.split("\n")
        |> list.fold(#(dict.new(), []), fn(acc, line) {
            let line = line |> string.trim

            let is_page_rule = line |> string.contains("|")
            let is_page_update = line |> string.contains(",")

            case is_page_rule, is_page_update {
                True, True -> panic as "Cannot parse line"
                True, _ -> {
                    let #(one, two) = parse_rule(line)
                    let new_rules = acc.0 
                        |> dict.upsert(one, fn(x) {
                            case x {
                                Some(l) -> [two, ..l]
                                None -> [two]
                            }
                        })

                    #(new_rules, acc.1)
                }
                _, True -> {
                    #(acc.0, [parse_update(line), ..acc.1])
                }
                _, _ -> acc
            }
        })
}

fn parse_rule(line: String) -> PageRule {
    let assert [one, two] = 
        line 
            |> string.split("|")
            |> list.map(fn(x) {
                let assert Ok(n) = int.parse(x)
                n
            })
                    
    #(one, two)
}

fn parse_update(line: String) -> PageUpdate {
    line 
        |> string.split(",")
        |> list.map(fn(x) {
            let assert Ok(n) = int.parse(x)
            n
        })
}

pub fn is_valid_update(rules: PageRules, update: PageUpdate) -> Bool {
    update 
    |> list.index_fold(True, fn(acc, item, index) {
        let rule = 
            rules 
            |> dict.get(item) 
            |> result.unwrap([])

        case acc {
            False -> acc
            True -> {
                let #(_, updates_after) = update |> list.split(index + 1)

                updates_after
                    |> list.all(fn(a) {
                        rule |> list.contains(a)
                    })
            }
        }
    })
}

pub fn get_result(updates: PageUpdates) -> Int {
    updates
        |> list.map(fn(l) {
            let len = l |> list.length
            let middle_index = len / 2

            l 
                |> list.index_map(fn (x, index) {
                    case index == middle_index {
                        True -> x
                        _ -> 0
                    }
                })
                |> list.fold(0, fn(acc, v) { acc + v })
        })
        |> list.fold(0, fn(acc, v) { acc + v })
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