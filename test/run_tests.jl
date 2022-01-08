using AlphaVantage, Test

@testset "http" begin
    @testset "client instantiation" begin
        c = AlphaVantageClient()
        @test c.key == "demo"

        c = AlphaVantageClient(;key="123")
        @test c.key == "123"
    end
end

@testset "handlers" begin
    
end