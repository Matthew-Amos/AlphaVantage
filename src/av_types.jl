"""
Full type hierarchy intended to be mostly a 1:1 relationship with the functions listed in
the AlphaVantage documentation: https://www.alphavantage.co/documentation/.

Forex and Crypto have been grouped together under AVCurrency since they are very similar.
"""

# Abstracts
abstract type AVFunction end
abstract type AVTimeSeries <: AVFunction end
abstract type AVFundamental <: AVFunction end
abstract type AVCurrency <: AVFunction end
abstract type AVEconomicIndicator <: AVFunction end
abstract type AVTechnicalIndicator <: AVFunction end

# Time series
struct TIME_SERIES_INTRADAY <: AVTimeSeries end
struct TIME_SERIES_INTRADAY_EXTENDED <: AVTimeSeries end
struct TIME_SERIES_DAILY <: AVTimeSeries end
struct TIME_SERIES_DAILY_ADJUSTED <: AVTimeSeries end
struct TIME_SERIES_WEEKLY <: AVTimeSeries end
struct TIME_SERIES_WEEKLY_ADJUSTED <: AVTimeSeries end
struct TIME_SERIES_MONTHLY <: AVTimeSeries end
struct TIME_SERIES_MONTHLY_ADJUSTED <: AVTimeSeries end
struct GLOBAL_QUOTE <: AVTimeSeries end
struct SYMBOL_SEARCH <: AVTimeSeries end

# Fundamentals
struct INCOME_STATEMENT <: AVFundamental end
struct BALANCE_SHEET <: AVFundamental end
struct CASH_FLOW <: AVFundamental end
struct EARNINGS <: AVFundamental end
struct OVERVIEW <: AVFundamental end
struct LISTING_STATUS <: AVFundamental end
struct EARNINGS_CALENDAR <: AVFundamental end
struct IPO_CALENDAR <: AVFundamental end

# Forex / Crypto
struct CURRENCY_EXCHANGE_RATE <: AVCurrency end
struct FX_INTRADAY <: AVCurrency end
struct FX_DAILY <: AVCurrency end
struct FX_WEEKLY <: AVCurrency end
struct FX_MONTHLY <: AVCurrency end
struct AVC_PRICE <: AVCurrency end
struct CRYPTO_INTRADAY <: AVCurrency end
struct DIGITAL_CURRENCY_DAILY <: AVCurrency end
struct DIGITAL_CURRENCY_WEEKLY <: AVCurrency end
struct DIGITAL_CURRENCY_MONTHLY <: AVCurrency end

# Economic Indicators
struct REAL_GDP <: AVEconomicIndicator end
struct REAL_GDP_PER_CAPITA <: AVEconomicIndicator end
struct TREASURY_YIELD <: AVEconomicIndicator end
struct FEDERAL_FUNDS_RATE <: AVEconomicIndicator end
struct INFLATION <: AVEconomicIndicator end
struct INFLATION_EXPECTATION <: AVEconomicIndicator end
struct CONSUMER_SENTIMENT <: AVEconomicIndicator end
struct RETAIL_SALES <: AVEconomicIndicator end
struct DURABLES <: AVEconomicIndicator end
struct UNEMPLOYMENT <: AVEconomicIndicator end
struct NONFARM_PAYROLL <: AVEconomicIndicator end

# Technical Indicators
struct SMA <: AVTechnicalIndicator end
struct EMA <: AVTechnicalIndicator end
struct WMA <: AVTechnicalIndicator end
struct DEMA <: AVTechnicalIndicator end
struct TEMA <: AVTechnicalIndicator end
struct TRIMA <: AVTechnicalIndicator end
struct KAMA <: AVTechnicalIndicator end
struct MAMA <: AVTechnicalIndicator end
struct VWAP <: AVTechnicalIndicator end
struct T3 <: AVTechnicalIndicator end
struct MACD <: AVTechnicalIndicator end
struct MACDEXT <: AVTechnicalIndicator end
struct STOCH <: AVTechnicalIndicator end
struct STOCHF <: AVTechnicalIndicator end
struct RSI <: AVTechnicalIndicator end
struct STOCHRSI <: AVTechnicalIndicator end
struct WILLR <: AVTechnicalIndicator end
struct ADX <: AVTechnicalIndicator end
struct ADXR <: AVTechnicalIndicator end
struct APO <: AVTechnicalIndicator end
struct PPO <: AVTechnicalIndicator end
struct MOM <: AVTechnicalIndicator end
struct BOP <: AVTechnicalIndicator end
struct CCI <: AVTechnicalIndicator end
struct CMO <: AVTechnicalIndicator end
struct ROC <: AVTechnicalIndicator end
struct ROCR <: AVTechnicalIndicator end
struct AROON <: AVTechnicalIndicator end
struct AROONOSC <: AVTechnicalIndicator end
struct MFI <: AVTechnicalIndicator end
struct TRIX <: AVTechnicalIndicator end
struct ULTOSC <: AVTechnicalIndicator end
struct DX <: AVTechnicalIndicator end
struct MINUS_DI <: AVTechnicalIndicator end
struct PLUS_DI <: AVTechnicalIndicator end
struct MINUS_DM <: AVTechnicalIndicator end
struct PLUS_DM <: AVTechnicalIndicator end
struct BBANDS <: AVTechnicalIndicator end
struct MIDPOINT <: AVTechnicalIndicator end
struct MIDPRICE <: AVTechnicalIndicator end
struct SAR <: AVTechnicalIndicator end
struct TRANGE <: AVTechnicalIndicator end
struct ATR <: AVTechnicalIndicator end
struct NATR <: AVTechnicalIndicator end
struct AD <: AVTechnicalIndicator end
struct ADOSC <: AVTechnicalIndicator end
struct OBV <: AVTechnicalIndicator end
struct HT_TRENDLINE <: AVTechnicalIndicator end
struct HT_SINE <: AVTechnicalIndicator end
struct HT_TRENDMODE <: AVTechnicalIndicator end
struct HT_DCPERIOD <: AVTechnicalIndicator end
struct HT_DCPHASE <: AVTechnicalIndicator end
struct HT_PHASOR <: AVTechnicalIndicator end

Base.string(x::A where A <: AVFunction) = string(typeof(x))
