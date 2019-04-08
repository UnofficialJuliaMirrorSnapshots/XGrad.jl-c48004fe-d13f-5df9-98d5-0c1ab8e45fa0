
using XGrad
using ReverseDiff: GradientTape, GradientConfig, gradient, gradient!, compile
using AutoGrad
using BenchmarkTools

include("functions.jl")


# NOTE: benchmarks for different tools seem to affect each other when run
# one after another, so for clear picture it's best to test them
# one by one, each in a frech Julia session
function perf_test(f; ctx=Dict(), compile_tape=true, inputs...)
    vals = ([val for (name, val) in inputs]...)

    println("Compiling derivatives using XGrad")
    @time df = xdiff(f; ctx=ctx, inputs...)
    mem = Dict()
    println("Testing XGrad...")
    r1 = @benchmark $df($vals...; mem=$mem)
    show(STDOUT, MIME{Symbol("text/plain")}(), r1)
    println("\n")

    println("Compiling derivatives using ReverseDiff")
    f_tape = GradientTape(f, vals)
    if compile_tape
        @time compiled_f_tape = compile(f_tape)
    end
    cfg = GradientConfig(vals)
    results = map(similar, vals)
    println("Testing ReverseDiff...")
    if compile_tape
        r2 = @benchmark gradient!($results, $compiled_f_tape, $vals)
    else
        r2 = @benchmark gradient!($results, $f_tape, $vals)
    end
    show(STDOUT, MIME{Symbol("text/plain")}(), r2)
    println("\n")

    println("Compiling derivatives using AutoGrad")
    auto_g = grad(vals -> f(vals...))
    r3 = @benchmark $auto_g($vals)
    show(STDOUT, MIME{Symbol("text/plain")}(), r3)
    println("\n")
    
    println("\n----------------------------------------\n")
    # return r1, r2, r3
end



function benchmark_autoencoder()
    f = autoencoder_cost
    println("\n## On larger data\n")
    We1 = rand(2000, 10_000); b1 = rand(2000); We2 = rand(1000, 2000); b2 = rand(1000);
    Wd = rand(10_000, 1000); x = rand(10_000, 100);
    inputs = [:We1 => We1, :We2 => We2, :Wd => Wd, :b1 => b1, :b2 => b2, :x => x];
    perf_test(f; inputs...)

    println("\n## On smaller data\n")
    We1 = rand(200, 1000); b1 = rand(200); We2 = rand(100, 200); b2 = rand(100);
    Wd = rand(1000, 100); x = rand(1000, 100);
    inputs = [:We1 => We1, :We2 => We2, :Wd => Wd, :b1 => b1, :b2 => b2, :x => x];
    perf_test(f; compile_tape=false, inputs...)
end


function benchmark_mlp1()
    f = mlp1
    println("\n## On larger data\n")
    w1=rand(2000, 10000); w2=rand(1000, 2000); w3=rand(1000, 1000); x1=rand(10000, 500);
    inputs = [:w1=>w1, :w2=>w2, :w3=>w3, :x1=>x1];
    perf_test(f; inputs...)

    println("\n## On smaller data\n")
    w1=rand(200, 1000); w2=rand(100, 200); w3=rand(100, 100); x1=rand(1000, 10);
    inputs = [:w1=>w1, :w2=>w2, :w3=>w3, :x1=>x1];
    perf_test(f; inputs...)
end


function benchmark_mlp2()
    f = mlp2
    println("\n## On larger data\n")
    w1 = randn(2000, 10000); w2 = randn(1000, 2000); w3 = randn(1000, 1000); x1 = randn(10000, 500);
    b1 =  randn(2000); b2 = randn(1000); b3 = randn(1000)
    inputs = [:w1=>w1, :w2=>w2, :w3=>w3, :b1 => b1, :b2 => b2, :b3 => b3, :x1=>x1];
    perf_test(f; inputs...)

    println("\n## On smaller data\n")
    w1=rand(200, 1000); w2=rand(100, 200); w3=rand(100, 100); x1=rand(1000, 10);
    b1 =  rand(200); b2 = rand(100); b3 = rand(100)
    inputs = [:w1=>w1, :w2=>w2, :w3=>w3, :b1 => b1, :b2 => b2, :b3 => b3, :x1=>x1];
    perf_test(f; inputs...)
end


# # TODO: ReverseDiff doesn't support tuples, maybe try another package
# function benchmark_rnn()
#     f = rnn
#     println("\n## On larger data\n")
#     Wxh = randn(4096, 4096); Whh = randn(4096, 4096); Why = randn(128, 4096);
#     hprev = randn(4096); x = randn(4096); y = randn(128);    
#     inputs = [:Wxh=>Wxh, :Whh=>Whh, :Why=>Why, :hprev => hprev, :x => x, :y=>y];
#     perf_test(f; ctx=Dict(:cost => :cost), inputs...)

#     println("\n## On smaller data\n")
#     # w1=rand(200, 1000); w2=rand(100, 200); w3=rand(100, 100); x1=rand(1000, 10);
#     # b1 =  rand(200); b2 = rand(100); b3 = rand(100)
#     # inputs = [:w1=>w1, :w2=>w2, :w3=>w3, :b1 => b1, :b2 => b2, :b3 => b3, :x1=>x1];
#     perf_test(f; ctx=Dict(:cost => :cost), inputs...)
# end
