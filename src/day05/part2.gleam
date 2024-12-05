import gleam/order
import gleam/result
import gleam/dict
import day05/common
import gleam/list

pub fn main(input: String, use_sample: Bool) -> Nil {
    let #(rules, updates) = common.parse(input)
    
    let incorrect_updates = 
        updates
        |> list.filter(fn(u) {
            let is_valid = common.is_valid_update(rules, u)
            !is_valid
        })

    let updated_updates = incorrect_updates
        |> list.map(fn(u) {
            u 
            |> list.sort(fn(a, b) {
                let rule_a = rules |> dict.get(a) |> result.unwrap([])

                case rule_a |> list.contains(b) {
                    True -> order.Gt
                    False -> order.Lt
                }
            })
        })

    let result = common.get_result(updated_updates)

    common.expect(use_sample, result, 123)
}