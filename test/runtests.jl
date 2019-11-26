using UniversalLogger
using Test
using Logging

@testset "UniversalLogger.jl" begin

    let logger = ULogger()
        with_logger(logger) do
            @info "a" x = zeros(5, 5) y = "a1"
            @info :b x = ones(5, 5) y = "b1"

            @info "a" x = zeros(10, 10) y = "a2"
            @info :b x = ones(10, 10) y = "b2"

        end

        lg = logger.log

        @test lg["a"][:x] == [zeros(5, 5), zeros(10, 10)]
        @test lg["a"][:y] == ["a1", "a2"]
        @test lg[:b][:x] == [ones(5, 5), ones(10, 10)]
        @test lg[:b][:y] == ["b1", "b2"]
    end

    let logger = ULogger()
        with_logger(logger) do
            for i = 1:10
                @info "foo" i val1 = i * 2
                if mod(i, 2) == 0
                    @info :bar val2 = i * 3
                end
            end
        end

        log = get(logger)
        @test log["foo"][:val1] == (1:10) .* 2
        @test log[:bar][:val2] == [6, 12, 18, 24, 30]
    end


    let logger = ULogger()
        with_logger(logger) do
          for i=1:10
            @info "foo" i fooval=i*2
            if mod(i, 2) == 0
              @info :bar barval=i*3
            end
          end
        end

        push!(logger, "baz", :baz1=>1)
        push!(logger, "baz", "baz2"=>10)
        push!(logger, "baz", Dict(:baz1=>2, "baz2"=>20))

        @test logger["foo"][:i] == 1:10
        @test logger["foo"][:fooval] == [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]

        @test logger[:bar][:barval] == [6, 12, 18, 24, 30]

        @test logger["baz", :baz1] == [1, 2]
        @test logger["baz", "baz2"] == [10, 20]
    end

end