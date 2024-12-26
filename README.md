# Advent of Code 2024

This repository contains the solution for the [Advent of Code of 2024](https://adventofcode.com/2024) using the Gleam language exclusively.

Because this challenge is part of a learning process of the Gleam language, the solution may certainly not be the perfect solution and you can still find room for improvement on most of them.

## Get started

### Run solution code

The gleam CLI is what you'll need to run the code. But only one puzzle at a time, and only one part of a single day. Example: you can run the part 1 of the day 7. You can run the code using the input file or even the sample file provided by the Advent of Code.

For that, you need to set the Env Variables that live in the `.env` file:

```toml
[env]
DAY = "7"
PART = "1"
USE_SAMPLE = "false"
```

`DAY` and `PART` are the day/part you want to run and `USE_SAMPLE` detect whether to run the `input.txt` or the `sample.txt` file inside the `src/day7` folder.

When done, you can run the CLI using the following command:

```bash
gleam run
```

## Language

Gleam 1.5.1

## Dependencies

| Name | Usage |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| dot_env | Load environment variables from `.env` file |
| simplifile | File operations in Gleam to read puzzle inputs |
| gtempo | A datetime/duration library to compute the execution time of a solution |
