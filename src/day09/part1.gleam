import gleam/iterator
import gleam/list
import day09/common

type FromIteratorType {
    FromFirst
    FromLast
}

pub fn main(input: String, use_sample: Bool) -> Nil {
    let disk_files = common.parse(input)
    let reversed_disk_files = disk_files |> list.reverse

    let total_iterations = 
        disk_files
        |> list.fold(0, fn(acc, d) { acc + d.length })
    
    let iterations = disk_files
        |> iterator.from_list
        |> iterator.fold(iterator.empty(), fn(acc, d) {
            let from_first_iterator = iterator.repeat(FromFirst) |> iterator.take(d.length)
            let from_last_iterator = iterator.repeat(FromLast) |> iterator.take(d.free_space)

            acc |> iterator.append(from_first_iterator) |> iterator.append(from_last_iterator)
        })
        |> iterator.take(total_iterations)

    let from_first_iterator = 
        disk_files 
        |> iterator.from_list 
        |> iterator.flat_map(fn(d) {
            iterator.repeat(d.id) |> iterator.take(d.length)
        })

    let from_last_iterator = 
        reversed_disk_files 
        |> iterator.from_list 
        |> iterator.flat_map(fn(d) {
            iterator.repeat(d.id) |> iterator.take(d.length)
        })

    let result_from_first = 
        iterations 
        |> iterator.index
        |> iterator.filter(fn(x) { x.0 == FromFirst })
        |> iterator.zip(from_first_iterator)
        |> iterator.map(fn(x) { x.0.1 * x.1 })
        |> iterator.fold(0, fn(acc, v) { acc + v })

    let result_from_last = 
        iterations 
        |> iterator.index
        |> iterator.filter(fn(x) { x.0 == FromLast })
        |> iterator.zip(from_last_iterator)
        |> iterator.map(fn(x) { x.0.1 * x.1 })
        |> iterator.fold(0, fn(acc, v) { acc + v })

    let result = result_from_first + result_from_last

    common.expect(use_sample, result, 1928)
}