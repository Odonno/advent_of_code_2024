import day09/common
import gleam/iterator
import gleam/list

pub fn main(input: String, use_sample: Bool) -> Nil {
    let disk_files = common.parse(input)
    let reversed_disk_files = disk_files |> list.reverse

    let fragmented_disk_files = 
        reversed_disk_files
        |> list.fold(disk_files, fn(acc, d) {
            let assert Ok(#(current_disk, current_disk_index)) = 
                acc 
                |> iterator.from_list
                |> iterator.index
                |> iterator.find(fn(x) { x.0.id == d.id })

            let free_disk_file = 
                acc 
                |> iterator.from_list
                |> iterator.index
                |> iterator.filter(fn(x) { x.1 < current_disk_index })
                |> iterator.find(fn(x) { x.0.free_space >= current_disk.length })

            case free_disk_file {
                Ok(#(free_disk, free_index)) -> {
                    let assert Ok(#(previous_disk, _)) = 
                        acc 
                        |> iterator.from_list
                        |> iterator.index
                        |> iterator.find(fn(x) { x.1 == current_disk_index - 1 })

                    let acc = 
                        acc 
                        |> list.filter(fn(x) { x.id != current_disk.id })
                        |> list.map(fn(x) {
                            case x.id == free_disk.id {
                                True -> common.DiskFile(..x, free_space: 0)
                                False -> x
                            }
                        })
                        |> list.map(fn(x) {
                            case x.id == previous_disk.id {
                                True -> common.DiskFile(..x, free_space: x.free_space + current_disk.length + current_disk.free_space)
                                False -> x
                            }
                        })

                    let new_free_space = free_disk.free_space - current_disk.length
                    let current_disk = common.DiskFile(..current_disk, free_space: new_free_space)

                    let #(left, right) = acc |> list.split(free_index + 1)

                    left |> list.append([current_disk]) |> list.append(right)
                }
                _ -> acc
            }
        })

    let result = 
        fragmented_disk_files
        |> iterator.from_list
        |> iterator.flat_map(fn(d) {
            let length_iterator = iterator.repeat(d.id) |> iterator.take(d.length)
            let free_space_iterator = iterator.repeat(0) |> iterator.take(d.free_space)

            length_iterator |> iterator.append(free_space_iterator)
        })
        |> iterator.index
        |> iterator.map(fn(x) { x.0 * x.1 })
        |> iterator.fold(0, fn(acc, v) { acc + v })

    common.expect(use_sample, result, 2858)
}

// fn print_files(files: common.DiskFiles) -> Nil {
//     io.println("")

//     files
//         |> iterator.from_list
//         |> iterator.flat_map(fn(d) {
//             let length_iterator = iterator.repeat(d.id) |> iterator.take(d.length)
//             let free_space_iterator = iterator.repeat(-1) |> iterator.take(d.free_space)

//             length_iterator |> iterator.append(free_space_iterator)
//         })
//         |> iterator.each(fn(x) {
//             case x == -1 {
//                 True -> io.print(".")
//                 False -> io.print(x |> int.to_string)
//             }
//         })
// }