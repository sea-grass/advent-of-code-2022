# advent-of-code-zig

Solving Advent of Code 2022 problems in the Zig programming language.

Each day, two new coding problems will be released as part of Advent of Code. Each problem comes with the problem statement, an example input and output pair (inline the form of many lines of text), and the problem input you need to generate output for. This means that all solutions will involve, at the bare minimum, reading text input and writing text output.

Since all problem input is known ahead of time, we can make use of Zig's comptime feature to process data at compile-time. Simple problems will likely result in programs where all the processing happened ahead of time and the only runtime function is to print the output.

The [ziglings](https://github.com/ratfactor/ziglings) repository defines a build target for each exercise and could be used as a reference.

## Code Problems

### Day 1: Calorie Counting

Problem description: [https://adventofcode.com/2022/day/1](https://adventofcode.com/2022/day/1)

Source: [01_calorie_counting.zig](./src/01_calorie_counting.zig)

Solve:

```sh
zig build 1
zig build 1 -- part2
```

### Day 2: Rock Paper Scissors

Problem description: [https://adventofcode.com/2022/day/1](https://adventofcode.com/2022/day/2)

Source: [02_rock_paper_scissors.zig](./src/02_rock_paper_scissors.zig)

Solve:

```sh
zig build 2
zig build 2 -- part2
```

### Day 3: Rucksack Reorganization

Problem description: [https://adventofcode.com/2022/day/3](https://adventofcode.com/2022/day/3)

Source: [03_rucksack_reorganization.zig](./src/03_rucksack_reorganization.zig)

Solve:

```sh
zig build 3
zig build 3 -- part2
```

### Day 4: Camp Cleanup

Problem description: [https://adventofcode.com/2022/day/4](https://adventofcode.com/2022/day/4)

Source: [04_rucksack_reorganization.zig](./src/04_camp_cleanup.zig)

Solve:

```sh
zig build 4
zig build 4 -- part2
```
