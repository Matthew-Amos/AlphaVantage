using AlphaVantage, Test

@testset "http" begin
  @testset "client instantiation" begin
      c = AlphaVantageClient()
      @test c.key == "demo"

      c = AlphaVantageClient(;key="123")
      @test c.key == "123"

      c = AlphaVantageClient("xyz")
      @test c.key == "xyz"
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
  c = AlphaVantageClient()

  @testset "time series" begin
    ts = get(c, TIME_SERIES_MONTHLY(), Dict("symbol" => "AAPL"))
    @test typeof(ts) == DataFrame
    @test nrow(ts) > 0
  end

  @testset "fundamentals" begin

  end

  @testset "currency" begin

  end

  @testset "economic" begin

  end

  @testset "technical" begin

  end
end
