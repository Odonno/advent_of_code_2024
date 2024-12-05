import gleam/list
import day05/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let #(rules, updates) = common.parse(input)

    let valid_updates = 
        updates
        |> list.filter(fn(u) {
            common.is_valid_update(rules, u)
        })
    
    let result = common.get_result(valid_updates)

    common.expect(use_sample, result, 143)
}