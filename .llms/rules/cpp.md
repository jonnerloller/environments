# C++ Rules

## Avoid side effects inside constructor or function-call argument lists

In C++, the evaluation order of constructor arguments and function-call operands is not something to rely on for sequencing side effects. If an expression reads from shared mutable state, advances a stream, mutates an iterator, or otherwise depends on order, do that work in separate statements first.

Prefer this pattern:

1. Read or compute each value in its own statement.
2. Store intermediate results in local variables with meaningful names.
3. Pass the already-materialized values into the constructor or function call.

This is especially important for:

- `std::istream` / binary parsing
- iterators that advance
- global or shared mutable state
- locks, counters, or stateful callbacks
- parsing code where correctness depends on read order

### Bad

```cpp
[[nodiscard]] std::array<float, 4> read_vec4(std::istream& in) {
    return std::array<float, 4>{
        read_f32(in),
        read_f32(in),
        read_f32(in),
        read_f32(in),
    };
}
```

This is fragile because the reads are embedded directly in the aggregate construction expression. The code assumes sequencing that should be made explicit.

### Good

```cpp
[[nodiscard]] std::array<float, 4> read_vec4(std::istream& in) {
    const float x = read_f32(in);
    const float y = read_f32(in);
    const float z = read_f32(in);
    const float w = read_f32(in);
    return std::array<float, 4>{x, y, z, w};
}
```

### Another good example with a constructor

```cpp
Vertex read_vertex(std::istream& in) {
    const float px = read_f32(in);
    const float py = read_f32(in);
    const float pz = read_f32(in);
    const float nx = read_f32(in);
    const float ny = read_f32(in);
    const float nz = read_f32(in);
    return Vertex(px, py, pz, nx, ny, nz);
}
```

### Rule of thumb

If the arguments do I/O, mutate state, or must happen in a specific order, split them into named locals first. Favor explicit sequencing over compact one-liners.
