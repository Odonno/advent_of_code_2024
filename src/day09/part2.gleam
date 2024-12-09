import gleam/string
import gleam/int
import gleam/iterator
import gleam/list
import day09/common

pub type FileBlock {
    FileBlock(id: Int, length: Int)
    EmptyFileBlock(length: Int)
}

pub type FileBlocks = List(FileBlock)

fn parse_blocks(input: String) -> FileBlocks {
    input
        |> string.split("")
        |> list.map(fn(x) {
            let assert Ok(x) = x |> int.parse
            x
        })
        |> list.index_map(fn(item, index) {
            case index % 2 == 0 {
                True -> FileBlock(index / 2, item)
                False -> EmptyFileBlock(item)
            }
        })
}

pub fn main(input: String, use_sample: Bool) -> Nil {
    let blocks = parse_blocks(input)
    let reversed_file_block_ids =
        blocks
        |> list.filter_map(fn(b) { 
            case b {
                FileBlock(id, _) -> Ok(id)
                _ -> Error(Nil)
            }
        })
        |> list.reverse

    let blocks = 
        reversed_file_block_ids
        |> list.fold(blocks, fn(acc, b_id) {
            let assert Ok(#(current_disk, current_disk_index)) = 
                acc 
                |> iterator.from_list
                |> iterator.index
                |> iterator.find(fn(x) { 
                    let #(x, _) = x
                    case x {
                        FileBlock(id, _) -> id == b_id
                        EmptyFileBlock(_) -> False
                    }
                })

            let assert FileBlock(_, disk_length) = current_disk

            let free_disk_file = 
                acc 
                |> iterator.from_list
                |> iterator.index
                |> iterator.filter(fn(x) { x.1 < current_disk_index })
                |> iterator.find(fn(x) { 
                    let #(x, _) = x
                    case x {
                        EmptyFileBlock(free_space) -> free_space >= disk_length
                        _ -> False
                    }
                })

            case free_disk_file {
                Ok(#(free_disk, free_index)) -> {
                    let assert EmptyFileBlock(previous_free_space) = free_disk

                    // replace free disk & move file block
                    let new_free_space = previous_free_space - disk_length
                    let new_free_block = EmptyFileBlock(new_free_space)

                    let remaining_free_space = disk_length

                    let #(left, right) = acc |> list.split(free_index)

                    left
                    |> list.append([current_disk, new_free_block])
                    |> list.append(
                        right 
                        |> list.drop(1) 
                        |> list.map(fn(x) { 
                            case x == current_disk {
                                True -> EmptyFileBlock(remaining_free_space)
                                False -> x
                            }
                        })
                    )
                }
                _ -> acc
            }
        })

    let result = 
        blocks
        |> iterator.from_list
        |> iterator.flat_map(fn(b) {
            case b {
                FileBlock(id, length) -> iterator.repeat(id) |> iterator.take(length)
                EmptyFileBlock(length) -> iterator.repeat(0) |> iterator.take(length)
            }
        })
        |> iterator.index
        |> iterator.map(fn(x) { x.0 * x.1 })
        |> iterator.fold(0, fn(acc, v) { acc + v })

    common.expect(use_sample, result, 2858)
}