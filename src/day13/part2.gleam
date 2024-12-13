import gleam/list
import day13/common

pub fn main(input: String, use_sample: Bool) -> Nil {
    let machines = common.parse(input)

    let machines = 
        machines
        |> list.map(fn(m) {
            let prize = m.prize
            let prize = common.MachineConfiguration(x: prize.x + 10000000000000, y: prize.y + 10000000000000)

            common.Machine(..m, prize: prize)
        })
    
    let result = machines
        |> list.map(common.calculate_button_press)
        |> list.map(common.calculate_total_tokens)
        |> list.fold(0, fn(acc, v) { acc + v })

    common.expect(use_sample, result, 0)
}
