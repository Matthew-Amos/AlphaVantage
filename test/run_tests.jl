using AlphaVantage, Test

@testset "http" begin
    @testset "client instantiation" begin
        c = AlphaVantageClient()
        @test c.key == "demo"

        c = AlphaVantageClient(;key="123")
        @test c.key == "123"
    end
    
    @testset "direct get" begin
        c = AlphaVantageClient()
        p = Dict(
            "function" => "TIME_SERIES_MONTHLY_ADJUSTED",
            "symbol" => "IBM",
            "apikey" => "demo"
        )
        resp = get(c, p)
        @test typeof(resp) == Vector{UInt8}
        @test length(resp) > 0
    end
end

@testset "handlers" begin
    
end