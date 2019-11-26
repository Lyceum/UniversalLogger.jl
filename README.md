# UniversalLogger

*A tool for logging aribitrary data.*

![](https://github.com/Lyceum/UniversalLogger.jl/workflows/Run%20tests/badge.svg)

## Example

```julia
using UniversalLogger

logger = ULogger()
with_logger(logger) do
  for i=1:10
    @info "foo" i fooval=i*2
    if mod(i, 2) == 0
      @info :bar barval=i*3
    end
  end
end

push!(logger, "baz", baz1=1)
push!(logger, "baz", "baz2"=>10)
push!(logger, "baz", Dict(:baz1=>2, "baz2"=>20))

@assert logger["foo"][:i] == 1:10
@assert logger["foo"][:fooval] == [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

@assert logger[:bar][:barval] == [6, 12, 18, 24, 30]

@assert logger["baz", :baz1] == [1, 2]
@assert logger["baz", "baz2"] == [10, 20]
```

